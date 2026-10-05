local Config = require 'modules.avid.shops.config'

local zones = {}
local clerks = {}
local targetResource

local messages = {
    basket_full = 'Your basket is full.',
    finish_current_basket = 'Finish or clear your current basket first.',
    basket_empty = 'Your basket is empty.',
    inventory_overweight = 'You do not have enough carrying capacity.',
    no_grid_space = 'You do not have enough physical inventory space.',
    not_enough_cash = 'You do not have enough cash.',
    not_enough_bank = 'You do not have enough money in the bank.',
    payment_failed = 'Payment could not be completed.',
    checkout_add_failed = 'The purchase could not be placed into your inventory.',
    too_far_from_shelf = 'Move closer to the shelf.',
    too_far_from_register = 'Move closer to the clerk.',
}

local function notify(message, kind)
    lib.notify({
        title = 'Avid Retail',
        description = message,
        type = kind or 'inform',
    })
end

local function resolveTarget()
    if targetResource and GetResourceState(targetResource) == 'started' then
        return targetResource
    end

    for _, name in ipairs({ Config.targetResource, 'avid_target', 'ox_target', 'osm-target' }) do
        if name and GetResourceState(name) == 'started' then
            targetResource = name
            return name
        end
    end
end

local function targetCall(method, ...)
    local resource = resolveTarget()
    if not resource then return end

    local proxy = exports[resource]
    local fn = proxy[method]
    if not fn then return end

    local ok, result = pcall(fn, proxy, ...)
    if ok then return result end

    print(('[ox_inventory] Avid shop target call failed: %s (%s)'):format(method, tostring(result)))
end

local function playPickup()
    local anim = Config.pickupAnim
    if not anim then return end

    lib.requestAnimDict(anim.dict)
    TaskPlayAnim(cache.ped, anim.dict, anim.clip, 4.0, -4.0, anim.duration or 700, anim.flag or 49, 0.0, false, false, false)
end

local function addToBasket(storeId, shelfId, product)
    local result = lib.callback.await('ox_inventory:avid:shop:add', false, {
        storeId = storeId,
        shelfId = shelfId,
        item = product.name,
    })

    if not result or not result.success then
        return notify(messages[result and result.error] or 'That item could not be added.', 'error')
    end

    playPickup()

    local basket = result.basket
    notify(('%s added to basket · %s item%s · $%s'):format(
        product.label or product.name,
        basket.count,
        basket.count == 1 and '' or 's',
        basket.total
    ), 'success')
end

local function checkout(storeId, payment)
    local result = lib.callback.await('ox_inventory:avid:shop:checkout', false, {
        storeId = storeId,
        payment = payment,
    })

    if not result or not result.success then
        return notify(messages[result and result.error] or 'Checkout failed.', 'error')
    end

    notify(('Purchase complete · $%s paid by %s.'):format(
        result.total,
        result.payment == 'card' and 'card' or 'cash'
    ), 'success')
end

local function openCheckout(storeId)
    local basket = lib.callback.await('ox_inventory:avid:shop:getBasket', false, storeId)

    if not basket then
        return notify('Your basket is empty.', 'inform')
    end

    local options = {}

    for i = 1, #basket.lines do
        local line = basket.lines[i]
        options[#options + 1] = {
            title = ('%sx %s'):format(line.count, line.label),
            description = ('$%s'):format(line.total),
            readOnly = true,
        }
    end

    options[#options + 1] = {
        title = ('Pay Cash · $%s'):format(basket.total),
        icon = 'money-bill',
        onSelect = function()
            checkout(storeId, 'cash')
        end,
    }

    options[#options + 1] = {
        title = ('Pay Card · $%s'):format(basket.total),
        icon = 'credit-card',
        onSelect = function()
            checkout(storeId, 'card')
        end,
    }

    options[#options + 1] = {
        title = 'Clear Basket',
        icon = 'trash',
        onSelect = function()
            lib.callback.await('ox_inventory:avid:shop:clear', false)
            notify('Basket cleared.', 'inform')
        end,
    }

    lib.registerContext({
        id = 'avid_shop_checkout',
        title = basket.storeLabel,
        options = options,
    })

    lib.showContext('avid_shop_checkout')
end

local function createClerk(storeId, store)
    local cfg = store.clerk
    if not cfg or not cfg.model or not cfg.coords then return end

    local model = lib.requestModel(cfg.model)
    if not model then return end

    local ped = CreatePed(4, model, cfg.coords.x, cfg.coords.y, cfg.coords.z, cfg.coords.w or 0.0, false, false)
    if not ped or ped == 0 then return end

    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_STAND_IMPATIENT', 0, true)

    clerks[#clerks + 1] = ped
    SetModelAsNoLongerNeeded(model)
end

local function registerTargets()
    if not resolveTarget() then
        print('[ox_inventory] avid shops could not find avid_target/ox_target compatible resource.')
        return
    end

    for storeId, store in pairs(Config.stores) do
        createClerk(storeId, store)

        for shelfId, shelf in pairs(store.shelves or {}) do
            local options = {}

            for i = 1, #(shelf.items or {}) do
                local product = shelf.items[i]

                options[#options + 1] = {
                    name = ('avid_shop_%s_%s_%s'):format(storeId, shelfId, i),
                    icon = 'basket-shopping',
                    label = ('Take %s · $%s'):format(product.label or product.name, product.price),
                    distance = 1.8,
                    onSelect = function()
                        addToBasket(storeId, shelfId, product)
                    end,
                }
            end

            local zone = targetCall('addBoxZone', {
                name = ('avid_shop_shelf_%s_%s'):format(storeId, shelfId),
                coords = shelf.coords,
                size = shelf.size or vec3(1.0, 0.7, 0.8),
                rotation = shelf.rotation or 0.0,
                drawSprite = false,
                options = options,
            })

            if zone then zones[#zones + 1] = zone end
        end

        local target = store.clerk and store.clerk.target

        if target then
            local zone = targetCall('addBoxZone', {
                name = ('avid_shop_checkout_%s'):format(storeId),
                coords = target.coords,
                size = target.size or vec3(0.9, 0.9, 1.1),
                rotation = target.rotation or 0.0,
                drawSprite = false,
                options = {
                    {
                        name = ('avid_shop_checkout_action_%s'):format(storeId),
                        icon = 'cash-register',
                        label = 'Checkout',
                        distance = 2.0,
                        onSelect = function()
                            openCheckout(storeId)
                        end,
                    },
                },
            })

            if zone then zones[#zones + 1] = zone end
        end
    end

    print(('[ox_inventory] Avid physical shops initialized with %s.'):format(targetResource))
end

CreateThread(function()
    local attempts = 0

    while not resolveTarget() and attempts < 120 do
        attempts += 1
        Wait(500)
    end

    registerTargets()
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= cache.resource then return end

    for i = 1, #zones do
        targetCall('removeZone', zones[i])
    end

    for i = 1, #clerks do
        if DoesEntityExist(clerks[i]) then
            DeleteEntity(clerks[i])
        end
    end
end)
