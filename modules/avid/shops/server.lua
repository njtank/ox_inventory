local Config = require 'modules.avid.shops.config'
local Items = require 'modules.items.server'
local Spatial = require 'modules.avid.spatial'

local baskets = {}

local function getStore(storeId)
    return Config.stores[tostring(storeId or '')]
end

local function getProduct(storeId, shelfId, itemName)
    local store = getStore(storeId)
    local shelf = store and store.shelves and store.shelves[tostring(shelfId or '')]

    if not shelf then return end

    for i = 1, #(shelf.items or {}) do
        local product = shelf.items[i]

        if product.name == itemName then
            return store, shelf, product
        end
    end
end

local function playerNear(source, coords, distance)
    local ped = GetPlayerPed(source)
    if not ped or ped == 0 then return false end

    return #(GetEntityCoords(ped) - coords) <= (distance or 3.0)
end

local function summary(source)
    local basket = baskets[source]
    if not basket then return end

    local store = getStore(basket.storeId)
    if not store then
        baskets[source] = nil
        return
    end

    local lines, count, total = {}, 0, 0

    for name, line in pairs(basket.items) do
        if line.count > 0 then
            local lineTotal = line.count * line.price
            count += line.count
            total += lineTotal

            lines[#lines + 1] = {
                name = name,
                label = line.label,
                count = line.count,
                price = line.price,
                total = lineTotal,
            }
        end
    end

    table.sort(lines, function(a, b) return a.label < b.label end)

    if count == 0 then
        baskets[source] = nil
        return
    end

    return {
        storeId = basket.storeId,
        storeLabel = store.label,
        count = count,
        total = total,
        lines = lines,
    }
end

local function clearBasket(source)
    baskets[source] = nil
    return true
end

return function(Inventory)
    lib.callback.register('ox_inventory:avid:shop:add', function(source, data)
        if type(data) ~= 'table' then return { success = false, error = 'invalid_payload' } end

        local store, shelf, product = getProduct(data.storeId, data.shelfId, data.item)
        if not store or not shelf or not product then
            return { success = false, error = 'shop_item_missing' }
        end

        if not playerNear(source, shelf.coords, 2.5) then
            return { success = false, error = 'too_far_from_shelf' }
        end

        if not Items(product.name) then
            return { success = false, error = 'shop_item_invalid' }
        end

        local basket = baskets[source]

        if basket and basket.storeId ~= data.storeId then
            return { success = false, error = 'finish_current_basket' }
        end

        basket = basket or {
            storeId = data.storeId,
            items = {},
        }

        local current = summary(source)
        local currentCount = current and current.count or 0

        if currentCount >= Config.basketLimit then
            return { success = false, error = 'basket_full' }
        end

        local line = basket.items[product.name] or {
            label = product.label or Items(product.name).label or product.name,
            price = math.max(0, math.floor(tonumber(product.price) or 0)),
            count = 0,
        }

        line.count += 1
        basket.items[product.name] = line
        baskets[source] = basket

        return {
            success = true,
            basket = summary(source),
        }
    end)

    lib.callback.register('ox_inventory:avid:shop:getBasket', function(source, storeId)
        local basket = baskets[source]

        if not basket or (storeId and basket.storeId ~= storeId) then
            return nil
        end

        return summary(source)
    end)

    lib.callback.register('ox_inventory:avid:shop:clear', function(source)
        clearBasket(source)
        return { success = true }
    end)

    lib.callback.register('ox_inventory:avid:shop:checkout', function(source, data)
        if type(data) ~= 'table' then return { success = false, error = 'invalid_payload' } end

        local basket = baskets[source]
        local store = basket and getStore(basket.storeId)

        if not basket or not store or basket.storeId ~= data.storeId then
            return { success = false, error = 'basket_empty' }
        end

        local register = store.clerk and store.clerk.target
        if not register or not playerNear(source, register.coords, Config.checkoutDistance) then
            return { success = false, error = 'too_far_from_register' }
        end

        local inv = Inventory(source)
        if not inv or not inv.player then
            return { success = false, error = 'invalid_inventory' }
        end

        local basketSummary = summary(source)
        if not basketSummary then
            return { success = false, error = 'basket_empty' }
        end

        local totalWeight = 0
        local neededRecords = {}

        for i = 1, #basketSummary.lines do
            local line = basketSummary.lines[i]
            local item = Items(line.name)

            if not item then
                return { success = false, error = 'shop_item_invalid' }
            end

            totalWeight += Inventory.SlotWeight(item, {
                count = line.count,
                metadata = {},
            })

            if item.stack then
                local hasStack = false

                for _, existing in pairs(inv.items) do
                    if existing and existing.name == line.name and (not existing.metadata or not next(existing.metadata)) then
                        hasStack = true
                        break
                    end
                end

                if not hasStack then
                    neededRecords[#neededRecords + 1] = line.name
                end
            else
                for _ = 1, line.count do
                    neededRecords[#neededRecords + 1] = line.name
                end
            end
        end

        if inv.maxWeight and inv.weight + totalWeight > inv.maxWeight then
            return { success = false, error = 'inventory_overweight' }
        end

        if not Spatial.CanFitItems(inv, neededRecords) then
            return { success = false, error = 'no_grid_space' }
        end

        local payment = data.payment == 'card' and 'card' or 'cash'
        local total = basketSummary.total
        local paid = false
        local qbxPlayer

        if payment == 'cash' then
            local cash = Inventory.Search(inv, 'count', 'money') or 0

            if cash < total then
                return { success = false, error = 'not_enough_cash' }
            end

            paid = Inventory.RemoveItem(inv, 'money', total) == true
        else
            if GetResourceState('qbx_core') ~= 'started' then
                return { success = false, error = 'bank_unavailable' }
            end

            qbxPlayer = exports.qbx_core:GetPlayer(source)

            if not qbxPlayer or qbxPlayer.Functions.GetMoney('bank') < total then
                return { success = false, error = 'not_enough_bank' }
            end

            paid = qbxPlayer.Functions.RemoveMoney('bank', total, 'avid-shop-checkout') == true
        end

        if not paid then
            return { success = false, error = 'payment_failed' }
        end

        local added = {}

        for i = 1, #basketSummary.lines do
            local line = basketSummary.lines[i]
            local ok = Inventory.AddItem(inv, line.name, line.count)

            if not ok then
                for j = 1, #added do
                    Inventory.RemoveItem(inv, added[j].name, added[j].count, nil, nil, true, false)
                end

                if payment == 'cash' then
                    Inventory.AddItem(inv, 'money', total)
                elseif qbxPlayer then
                    qbxPlayer.Functions.AddMoney('bank', total, 'avid-shop-refund')
                end

                return { success = false, error = 'checkout_add_failed' }
            end

            added[#added + 1] = {
                name = line.name,
                count = line.count,
            }
        end

        clearBasket(source)

        return {
            success = true,
            total = total,
            payment = payment,
            items = added,
        }
    end)

    AddEventHandler('playerDropped', function()
        baskets[source] = nil
    end)

    exports('ClearAvidShopBasket', function(playerId)
        baskets[tonumber(playerId)] = nil
        return true
    end)
end
