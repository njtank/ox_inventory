local Spatial = require 'modules.avid.spatial'

return function(Inventory)
    local function sync(inv, slot)
        local item = inv.items[slot]

        inv:syncSlotsWithClients({
            {
                item = item or { slot = slot },
                inventory = inv.id
            }
        }, true)

        if inv.player and server.syncInventory then
            server.syncInventory(inv)
        end
    end

    local function serialize(inv)
        if not inv then return end

        local normalized = Spatial.Normalize(inv)
        local layout = Spatial.GetLayout(inv)
        if not layout then return end

        local items = {}

        for slot, item in pairs(inv.items or {}) do
            if item and item.name then
                local size = Spatial.GetItemSize(item.name, item.avid and item.avid.grid and item.avid.grid.rotated == true)

                items[#items + 1] = {
                    slot = tonumber(slot),
                    name = item.name,
                    label = item.metadata and item.metadata.label or item.label or item.name,
                    count = item.count or 1,
                    weight = item.weight or 0,
                    metadata = item.metadata or {},
                    avid = item.avid or { version = 1 },
                    width = size.w,
                    height = size.h,
                }
            end
        end

        table.sort(items, function(a, b) return a.slot < b.slot end)

        return {
            id = inv.id,
            type = inv.type,
            label = inv.label,
            cols = layout.cols,
            rows = layout.rows,
            weight = inv.weight or 0,
            maxWeight = inv.maxWeight or 0,
            overflow = normalized.overflow,
            items = items,
        }
    end

    local function equipped(inv)
        local result = {}

        for slot, item in pairs(inv.items or {}) do
            local equipmentSlot = item.avid and item.avid.equipped

            if equipmentSlot then
                result[equipmentSlot] = {
                    slot = tonumber(slot),
                    name = item.name,
                    label = item.metadata and item.metadata.label or item.label or item.name,
                    count = item.count,
                    weight = item.weight,
                    metadata = item.metadata or {},
                    avid = item.avid,
                }
            end
        end

        return result
    end

    local function equippedBackpack(inv)
        local eq = equipped(inv)
        local bag = eq.backpack
        if not bag then return end

        local source = inv.id
        local sourceItem = inv.items[bag.slot]
        local containerId = sourceItem and sourceItem.metadata and sourceItem.metadata.container

        if not containerId then return end

        local container = Inventory(containerId)

        if not container then
            local size = sourceItem.metadata.size
            if not size then return end

            container = Inventory.Create(containerId, sourceItem.label, 'container', size[1], 0, size[2], false)
        end

        return container
    end

    local function state(source)
        local inv = Inventory(source)
        if not inv then return end

        return {
            pockets = serialize(inv),
            equipment = equipped(inv),
            equipmentSlots = Spatial.GetEquipmentConfig(),
            backpack = serialize(equippedBackpack(inv)),
        }
    end

    lib.callback.register('ox_inventory:avid:getState', function(source)
        return state(source)
    end)

    lib.callback.register('ox_inventory:avid:setGrid', function(source, data)
        if type(data) ~= 'table' then return { success = false, error = 'invalid_payload' } end

        local player = Inventory(source)
        if not player then return { success = false, error = 'invalid_inventory' } end

        local inv = player

        if data.inventory == 'backpack' then
            inv = equippedBackpack(player)
        elseif data.inventory ~= 'pockets' then
            return { success = false, error = 'invalid_inventory' }
        end

        if not inv then return { success = false, error = 'invalid_inventory' } end

        local ok, err = Spatial.SetGrid(inv, tonumber(data.slot), tonumber(data.x), tonumber(data.y), data.rotated == true)
        if ok then sync(inv, tonumber(data.slot)) end

        return { success = ok == true, error = err, state = ok and state(source) or nil }
    end)

    lib.callback.register('ox_inventory:avid:equip', function(source, data)
        if type(data) ~= 'table' then return { success = false, error = 'invalid_payload' } end

        local inv = Inventory(source)
        local slot = tonumber(data.slot)
        local equipmentSlot = tostring(data.equipmentSlot or '')
        local item = inv and inv.items[slot]

        if not item then return { success = false, error = 'item_missing' } end
        if not Spatial.ValidEquipment(item.name, equipmentSlot) then
            return { success = false, error = 'wrong_item_type' }
        end

        for _, other in pairs(inv.items) do
            if other.avid and other.avid.equipped == equipmentSlot then
                return { success = false, error = 'equipment_slot_occupied' }
            end
        end

        local ok, err = Spatial.SetEquipped(inv, slot, equipmentSlot)
        if ok then sync(inv, slot) end

        return { success = ok == true, error = err, state = ok and state(source) or nil }
    end)

    lib.callback.register('ox_inventory:avid:unequip', function(source, equipmentSlot)
        local inv = Inventory(source)
        if not inv then return { success = false, error = 'invalid_inventory' } end

        for slot, item in pairs(inv.items) do
            if item.avid and item.avid.equipped == equipmentSlot then
                local ok, err = Spatial.Unequip(inv, tonumber(slot))
                if ok then sync(inv, tonumber(slot)) end

                return { success = ok == true, error = err, state = ok and state(source) or nil }
            end
        end

        return { success = false, error = 'nothing_equipped' }
    end)

    lib.callback.register('ox_inventory:avid:move', function(source, data)
        if type(data) ~= 'table' then return { success = false, error = 'invalid_payload' } end

        local player = Inventory(source)
        if not player then return { success = false, error = 'invalid_inventory' } end

        local backpack = equippedBackpack(player)
        local fromInv = data.from == 'pockets' and player or data.from == 'backpack' and backpack
        local toInv = data.to == 'pockets' and player or data.to == 'backpack' and backpack

        if not fromInv or not toInv or fromInv == toInv then
            return { success = false, error = 'invalid_inventory' }
        end

        local slot = tonumber(data.slot)
        local item = fromInv.items[slot]
        if not item then return { success = false, error = 'item_missing' } end
        if item.avid and item.avid.equipped then return { success = false, error = 'unequip_first' } end
        if data.to == 'backpack' and item.name:find('^backpack_') then
            return { success = false, error = 'nested_backpacks_disabled' }
        end

        local ok, err = Spatial.CanPlace(toInv, item.name, tonumber(data.x), tonumber(data.y), data.rotated == true)
        if not ok then return { success = false, error = err } end

        local targetSlot = Inventory.GetEmptySlot(toInv)
        if not targetSlot then return { success = false, error = 'inventory_full' } end

        local count = math.max(1, math.min(tonumber(data.count) or item.count, item.count))
        local metadata = table.clone(item.metadata or {})

        local removed, removeErr = Inventory.RemoveItem(fromInv, item.name, count, metadata, slot, false, true)
        if not removed then return { success = false, error = removeErr or 'remove_failed' } end

        local added, response = Inventory.AddItem(toInv, item.name, count, metadata, targetSlot)

        if not added then
            Inventory.AddItem(fromInv, item.name, count, metadata, slot)
            return { success = false, error = response or 'add_failed' }
        end

        local newSlot = type(response) == 'table' and response.slot or targetSlot
        Spatial.SetGrid(toInv, newSlot, tonumber(data.x), tonumber(data.y), data.rotated == true)
        sync(toInv, newSlot)

        if backpack and (fromInv == backpack or toInv == backpack) then
            local bag = equipped(player).backpack
            local bagItem = bag and player.items[bag.slot]

            if bagItem then
                Inventory.ContainerWeight(bagItem, backpack.weight, player)
                sync(player, bag.slot)
            end
        end

        return { success = true, state = state(source) }
    end)

    exports('AvidGetState', state)
end
