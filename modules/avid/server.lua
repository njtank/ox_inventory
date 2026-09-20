local Spatial = require 'modules.avid.spatial'
local TriggerEventHooks = require 'modules.hooks.server'
local Items = require 'modules.items.server'

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
                    compatibleEquipment = Spatial.GetCompatibleEquipment(item.name),
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
                    compatibleEquipment = Spatial.GetCompatibleEquipment(item.name),
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

    local function externalInventory(player)
        local openId = player and player.open
        if not openId then return end

        local inv = Inventory(openId)
        if not inv or inv == player or not Spatial.IsExternalStorage(inv) then return end

        return inv
    end

    local function resolveInventory(player, name)
        if name == 'pockets' then return player end
        if name == 'backpack' then return equippedBackpack(player) end
        if name == 'external' then return externalInventory(player) end
    end

    local function validateContainerTransfer(player, fromInv, toInv, item)
        if not item then return false, 'item_missing' end

        if item.metadata and item.metadata.container and toInv.type == 'container' then
            return false, 'nested_containers_disabled'
        end

        if toInv.type == 'container' and player.containerSlot then
            local containerItem = player.items[player.containerSlot]
            local rules = containerItem and Items.containers[containerItem.name]

            if rules then
                if rules.whitelist and not rules.whitelist[item.name] then
                    return false, 'container_item_restricted'
                end

                if rules.blacklist and rules.blacklist[item.name] then
                    return false, 'container_item_restricted'
                end
            end
        end

        return true
    end

    local function transferHook(source, fromInv, toInv, fromItem, toSlot, count, action)
        local hooks <close> = TriggerEventHooks('swapItems', {
            source = source,
            fromInventory = fromInv.id,
            fromSlot = fromItem,
            fromType = fromInv.type,
            toInventory = toInv.id,
            toSlot = toInv.items[toSlot] or toSlot,
            toType = toInv.type,
            count = count,
            action = action or 'move',
        })

        if not hooks.success then
            return false, 'transfer_rejected'
        end

        return true
    end

    local function groundInventory(player)
        local openId = player and player.open
        if not openId then return end

        local inv = Inventory(openId)
        if inv and inv.type == 'drop' then return inv end
    end

    local function serializeGround(inv)
        if not inv then return end

        local items = {}

        for slot, item in pairs(inv.items or {}) do
            if item and item.name then
                items[#items + 1] = {
                    slot = tonumber(slot),
                    name = item.name,
                    label = item.metadata and item.metadata.label or item.label or item.name,
                    count = item.count or 1,
                    weight = item.weight or 0,
                    metadata = item.metadata or {},
                    avid = { version = 1 },
                    width = 1,
                    height = 1,
                    compatibleEquipment = {},
                }
            end
        end

        table.sort(items, function(a, b) return a.slot < b.slot end)

        return {
            id = inv.id,
            label = inv.label or 'Ground',
            slots = inv.slots or 6,
            weight = inv.weight or 0,
            maxWeight = inv.maxWeight or 0,
            items = items,
        }
    end

    local function state(source)
        local inv = Inventory(source)
        if not inv then return end

        return {
            character = {
                name = inv.label or (inv.player and inv.player.name) or 'Character',
                sex = inv.player and inv.player.sex or nil,
            },
            pockets = serialize(inv),
            equipment = equipped(inv),
            equipmentSlots = Spatial.GetEquipmentConfig(),
            backpack = serialize(equippedBackpack(inv)),
            external = serialize(externalInventory(inv)),
            ground = serializeGround(groundInventory(inv)),
        }
    end

    lib.callback.register('ox_inventory:avid:getState', function(source)
        return state(source)
    end)

    lib.callback.register('ox_inventory:avid:setGrid', function(source, data)
        if type(data) ~= 'table' then return { success = false, error = 'invalid_payload' } end

        local player = Inventory(source)
        if not player then return { success = false, error = 'invalid_inventory' } end

        local inv = resolveInventory(player, data.inventory)

        if not inv then return { success = false, error = 'invalid_inventory' } end

        local ok, err = Spatial.SetGrid(inv, tonumber(data.slot), tonumber(data.x), tonumber(data.y), false)
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

    lib.callback.register('ox_inventory:avid:unequipToGrid', function(source, data)
        if type(data) ~= 'table' then return { success = false, error = 'invalid_payload' } end

        local inv = Inventory(source)
        if not inv then return { success = false, error = 'invalid_inventory' } end

        local slot = tonumber(data.slot)
        local item = inv.items[slot]
        if not item or not (item.avid and item.avid.equipped) then
            return { success = false, error = 'item_not_equipped' }
        end

        local ok, err = Spatial.UnequipToGrid(inv, slot, tonumber(data.x), tonumber(data.y), false)
        if ok then sync(inv, slot) end

        return { success = ok == true, error = err, state = ok and state(source) or nil }
    end)

    lib.callback.register('ox_inventory:avid:groundToGrid', function(source, data)
        if type(data) ~= 'table' then return { success = false, error = 'invalid_payload' } end

        local player = Inventory(source)
        if not player then return { success = false, error = 'invalid_inventory' } end

        local ground = groundInventory(player)
        if not ground then return { success = false, error = 'ground_not_open' } end

        local backpack = equippedBackpack(player)
        local target = data.to == 'pockets' and player or data.to == 'backpack' and backpack
        if not target then return { success = false, error = 'invalid_inventory' } end

        local fromSlot = tonumber(data.slot)
        local item = fromSlot and ground.items[fromSlot]
        if not item then return { success = false, error = 'item_missing' } end

        local x, y = tonumber(data.x), tonumber(data.y)
        local ok, err = Spatial.CanPlace(target, item.name, x, y, data.rotated == true)
        if not ok then return { success = false, error = err } end

        local targetSlot = Inventory.GetEmptySlot(target)
        if not targetSlot then return { success = false, error = 'inventory_full' } end

        local count = math.max(1, math.min(math.floor(tonumber(data.count) or item.count), item.count))
        local metadata = table.clone(item.metadata or {})

        local removed, removeErr = Inventory.RemoveItem(ground, item.name, count, metadata, fromSlot, false, true)
        if not removed then return { success = false, error = removeErr or 'remove_failed' } end

        local added, response = Inventory.AddItem(target, item.name, count, metadata, targetSlot)

        if not added then
            Inventory.AddItem(ground, item.name, count, metadata, fromSlot)
            return { success = false, error = response or 'add_failed' }
        end

        local newSlot = type(response) == 'table' and response.slot or targetSlot
        Spatial.SetGrid(target, newSlot, x, y, data.rotated == true)

        sync(target, newSlot)
        sync(ground, fromSlot)

        if backpack and target == backpack then
            local bag = equipped(player).backpack
            local bagItem = bag and player.items[bag.slot]

            if bagItem then
                Inventory.ContainerWeight(bagItem, backpack.weight, player)
                sync(player, bag.slot)
            end
        end

        return { success = true, state = state(source) }
    end)

    lib.callback.register('ox_inventory:avid:gridToGround', function(source, data)
        if type(data) ~= 'table' then return { success = false, error = 'invalid_payload' } end

        local player = Inventory(source)
        if not player then return { success = false, error = 'invalid_inventory' } end

        local ground = groundInventory(player)
        if not ground then return { success = false, error = 'ground_not_open' } end

        local backpack = equippedBackpack(player)
        local fromInv = data.from == 'pockets' and player or data.from == 'backpack' and backpack
        if not fromInv then return { success = false, error = 'invalid_inventory' } end

        local fromSlot = tonumber(data.slot)
        local item = fromSlot and fromInv.items[fromSlot]
        if not item then return { success = false, error = 'item_missing' } end
        if item.avid and item.avid.equipped then return { success = false, error = 'unequip_first' } end

        local count = math.max(1, math.min(math.floor(tonumber(data.count) or item.count), item.count))
        local metadata = table.clone(item.metadata or {})
        local targetSlot = tonumber(data.toSlot)

        if not targetSlot or targetSlot < 1 or targetSlot > ground.slots then
            targetSlot = Inventory.GetEmptySlot(ground)
        end

        if not targetSlot then return { success = false, error = 'ground_full' } end
        if ground.items[targetSlot] then return { success = false, error = 'occupied' } end

        local removed, removeErr = Inventory.RemoveItem(fromInv, item.name, count, metadata, fromSlot, false, true)
        if not removed then return { success = false, error = removeErr or 'remove_failed' } end

        local added, response = Inventory.AddItem(ground, item.name, count, metadata, targetSlot)

        if not added then
            Inventory.AddItem(fromInv, item.name, count, metadata, fromSlot)
            return { success = false, error = response or 'add_failed' }
        end

        sync(ground, targetSlot)

        if backpack and fromInv == backpack then
            local bag = equipped(player).backpack
            local bagItem = bag and player.items[bag.slot]

            if bagItem then
                Inventory.ContainerWeight(bagItem, backpack.weight, player)
                sync(player, bag.slot)
            end
        end

        return { success = true, state = state(source) }
    end)

    lib.callback.register('ox_inventory:avid:drop', function(source, data)
        if type(data) ~= 'table' then return { success = false, error = 'invalid_payload' } end

        local player = Inventory(source)
        if not player then return { success = false, error = 'invalid_inventory' } end

        local backpack = equippedBackpack(player)
        local inv = data.from == 'pockets' and player or data.from == 'backpack' and backpack

        if not inv then return { success = false, error = 'invalid_inventory' } end

        local slot = tonumber(data.slot)
        local item = slot and inv.items[slot]
        if not item then return { success = false, error = 'item_missing' } end
        if item.avid and item.avid.equipped then return { success = false, error = 'unequip_first' } end

        local coords = data.coords
        if type(coords) ~= 'table' or not coords.x or not coords.y or not coords.z then
            return { success = false, error = 'invalid_drop_position' }
        end

        local count = math.max(1, math.min(math.floor(tonumber(data.count) or item.count), item.count))
        local success, response = Inventory.DropFromInventory(
            source,
            inv,
            slot,
            count,
            vec3(coords.x + 0.0, coords.y + 0.0, coords.z + 0.0),
            Player(source).state.instance
        )

        if not success then
            return { success = false, error = type(response) == 'string' and response or 'drop_failed' }
        end

        if backpack and inv == backpack then
            local bag = equipped(player).backpack
            local bagItem = bag and player.items[bag.slot]

            if bagItem then
                Inventory.ContainerWeight(bagItem, backpack.weight, player)
                sync(player, bag.slot)
            end
        end

        return { success = true, state = state(source) }
    end)

    lib.callback.register('ox_inventory:avid:mergeStack', function(source, data)
        if type(data) ~= 'table' then return { success = false, error = 'invalid_payload' } end

        local player = Inventory(source)
        if not player then return { success = false, error = 'invalid_inventory' } end

        local backpack = equippedBackpack(player)
        local fromInv = resolveInventory(player, data.from)
        local toInv = resolveInventory(player, data.to)

        if not fromInv or not toInv then return { success = false, error = 'invalid_inventory' } end

        local fromSlot = tonumber(data.fromSlot)
        local toSlot = tonumber(data.toSlot)

        if not fromSlot or not toSlot then return { success = false, error = 'invalid_slot' } end
        if fromInv == toInv and fromSlot == toSlot then return { success = false, error = 'same_slot' } end

        local fromItem = fromInv.items[fromSlot]
        local toItem = toInv.items[toSlot]

        if not fromItem or not toItem then return { success = false, error = 'item_missing' } end
        if fromItem.avid and fromItem.avid.equipped then return { success = false, error = 'unequip_first' } end
        if not fromItem.stack or not toItem.stack then return { success = false, error = 'cannot_stack' } end
        if fromItem.name ~= toItem.name then return { success = false, error = 'cannot_stack' } end
        if not table.matches(fromItem.metadata or {}, toItem.metadata or {}) then
            return { success = false, error = 'cannot_stack' }
        end

        if toInv.maxWeight and fromInv ~= toInv and toInv.weight + (fromItem.weight or 0) > toInv.maxWeight then
            return { success = false, error = 'inventory_overweight' }
        end

        local allowed, restriction = validateContainerTransfer(player, fromInv, toInv, fromItem)
        if not allowed then return { success = false, error = restriction } end

        local hooked, hookError = transferHook(source, fromInv, toInv, fromItem, toSlot, fromItem.count, 'stack')
        if not hooked then return { success = false, error = hookError } end

        local count = fromItem.count
        local metadata = table.clone(fromItem.metadata or {})
        local oldGrid = fromItem.avid and fromItem.avid.grid and table.clone(fromItem.avid.grid)

        local removed, removeErr = Inventory.RemoveItem(fromInv, fromItem.name, count, metadata, fromSlot, false, true)
        if not removed then return { success = false, error = removeErr or 'remove_failed' } end

        local added, response = Inventory.AddItem(toInv, fromItem.name, count, metadata, toSlot)

        if not added then
            local restored, restoreResponse = Inventory.AddItem(fromInv, fromItem.name, count, metadata, fromSlot)

            if restored and oldGrid then
                local restoredSlot = type(restoreResponse) == 'table' and restoreResponse.slot or fromSlot
                Spatial.SetGrid(fromInv, restoredSlot, oldGrid.x, oldGrid.y, false)
                sync(fromInv, restoredSlot)
            end

            return { success = false, error = response or 'merge_failed' }
        end

        sync(fromInv, fromSlot)
        sync(toInv, toSlot)

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

    lib.callback.register('ox_inventory:avid:splitStack', function(source, data)
        if type(data) ~= 'table' then return { success = false, error = 'invalid_payload' } end

        local player = Inventory(source)
        if not player then return { success = false, error = 'invalid_inventory' } end

        local backpack = equippedBackpack(player)
        local inv = resolveInventory(player, data.from)

        if not inv then return { success = false, error = 'invalid_inventory' } end

        local slot = tonumber(data.slot)
        local item = slot and inv.items[slot]

        if not item then return { success = false, error = 'item_missing' } end
        if item.avid and item.avid.equipped then return { success = false, error = 'unequip_first' } end
        if (item.count or 1) <= 1 then return { success = false, error = 'stack_too_small' } end

        local splitCount = math.floor(tonumber(data.count) or math.floor(item.count / 2))
        splitCount = math.max(1, math.min(splitCount, item.count - 1))

        local placement = Spatial.FirstFit(inv, item.name)
        if not placement then return { success = false, error = 'no_grid_space' } end

        local targetSlot = Inventory.GetEmptySlot(inv)
        if not targetSlot then return { success = false, error = 'inventory_full' } end

        local metadata = table.clone(item.metadata or {})

        -- Remove first so AddItem sees the correct current inventory weight.
        local removed, removeErr = Inventory.RemoveItem(inv, item.name, splitCount, metadata, slot, false, true)
        if not removed then return { success = false, error = removeErr or 'remove_failed' } end

        local added, response = Inventory.AddItem(inv, item.name, splitCount, metadata, targetSlot)

        if not added then
            Inventory.AddItem(inv, item.name, splitCount, metadata, slot)
            return { success = false, error = response or 'split_failed' }
        end

        local newSlot = type(response) == 'table' and response.slot or targetSlot
        Spatial.SetGrid(inv, newSlot, placement.x, placement.y, false)

        sync(inv, slot)
        sync(inv, newSlot)

        return { success = true, state = state(source) }
    end)

    lib.callback.register('ox_inventory:avid:quickMove', function(source, data)
        if type(data) ~= 'table' then return { success = false, error = 'invalid_payload' } end

        local player = Inventory(source)
        if not player then return { success = false, error = 'invalid_inventory' } end

        local backpack = equippedBackpack(player)
        local external = externalInventory(player)
        local fromName = data.from == 'external' and 'external'
            or data.from == 'backpack' and 'backpack'
            or 'pockets'
        local toName

        if external then
            if fromName == 'external' then
                toName = 'pockets'
            elseif fromName == 'pockets' then
                toName = 'external'
            else
                toName = 'pockets'
            end
        else
            toName = fromName == 'pockets' and 'backpack' or 'pockets'
        end

        local fromInv = resolveInventory(player, fromName)
        local toInv = resolveInventory(player, toName)

        if not fromInv then return { success = false, error = 'invalid_inventory' } end
        if not toInv then
            return {
                success = false,
                error = toName == 'backpack' and 'no_backpack_equipped' or 'invalid_inventory'
            }
        end

        local slot = tonumber(data.slot)
        local item = slot and fromInv.items[slot]

        if not item then return { success = false, error = 'item_missing' } end
        if item.avid and item.avid.equipped then return { success = false, error = 'unequip_first' } end
        if toName == 'backpack' and item.name:find('^backpack_') then
            return { success = false, error = 'nested_backpacks_disabled' }
        end

        local allowed, restriction = validateContainerTransfer(player, fromInv, toInv, item)
        if not allowed then return { success = false, error = restriction } end

        if toInv.maxWeight and toInv.weight + (item.weight or 0) > toInv.maxWeight then
            return { success = false, error = 'inventory_overweight' }
        end

        local placement = Spatial.FirstFit(toInv, item.name)
        if not placement then return { success = false, error = 'no_grid_space' } end

        local targetSlot = Inventory.GetEmptySlot(toInv)
        if not targetSlot then return { success = false, error = 'inventory_full' } end

        local hooked, hookError = transferHook(source, fromInv, toInv, item, targetSlot, item.count, 'move')
        if not hooked then return { success = false, error = hookError } end

        local count = item.count
        local metadata = table.clone(item.metadata or {})
        local oldGrid = item.avid and item.avid.grid and table.clone(item.avid.grid)

        local removed, removeErr = Inventory.RemoveItem(fromInv, item.name, count, metadata, slot, false, true)
        if not removed then return { success = false, error = removeErr or 'remove_failed' } end

        local added, response = Inventory.AddItem(toInv, item.name, count, metadata, targetSlot)

        if not added then
            local restored, restoreResponse = Inventory.AddItem(fromInv, item.name, count, metadata, slot)

            if restored and oldGrid then
                local restoredSlot = type(restoreResponse) == 'table' and restoreResponse.slot or slot
                Spatial.SetGrid(fromInv, restoredSlot, oldGrid.x, oldGrid.y, false)
                sync(fromInv, restoredSlot)
            end

            return { success = false, error = response or 'add_failed' }
        end

        local newSlot = type(response) == 'table' and response.slot or targetSlot
        Spatial.SetGrid(toInv, newSlot, placement.x, placement.y, false)
        sync(fromInv, slot)
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

    lib.callback.register('ox_inventory:avid:move', function(source, data)
        if type(data) ~= 'table' then return { success = false, error = 'invalid_payload' } end

        local player = Inventory(source)
        if not player then return { success = false, error = 'invalid_inventory' } end

        local backpack = equippedBackpack(player)
        local fromInv = resolveInventory(player, data.from)
        local toInv = resolveInventory(player, data.to)

        if not fromInv or not toInv or fromInv == toInv then
            return { success = false, error = 'invalid_inventory' }
        end

        local slot = tonumber(data.slot)
        local item = slot and fromInv.items[slot]

        if not item then return { success = false, error = 'item_missing' } end
        if item.avid and item.avid.equipped then return { success = false, error = 'unequip_first' } end
        if data.to == 'backpack' and item.name:find('^backpack_') then
            return { success = false, error = 'nested_backpacks_disabled' }
        end

        local allowed, restriction = validateContainerTransfer(player, fromInv, toInv, item)
        if not allowed then return { success = false, error = restriction } end

        if toInv.maxWeight and toInv.weight + (item.weight or 0) > toInv.maxWeight then
            return { success = false, error = 'inventory_overweight' }
        end

        local x, y = tonumber(data.x), tonumber(data.y)
        local ok, err = Spatial.CanPlace(toInv, item.name, x, y, false)
        if not ok then return { success = false, error = err } end

        local targetSlot = Inventory.GetEmptySlot(toInv)
        if not targetSlot then return { success = false, error = 'inventory_full' } end

        local count = math.max(1, math.min(math.floor(tonumber(data.count) or item.count), item.count))
        local hooked, hookError = transferHook(source, fromInv, toInv, item, targetSlot, count, 'move')
        if not hooked then return { success = false, error = hookError } end

        local metadata = table.clone(item.metadata or {})
        local oldGrid = item.avid and item.avid.grid and table.clone(item.avid.grid)

        local removed, removeErr = Inventory.RemoveItem(fromInv, item.name, count, metadata, slot, false, true)
        if not removed then return { success = false, error = removeErr or 'remove_failed' } end

        local added, response = Inventory.AddItem(toInv, item.name, count, metadata, targetSlot)

        if not added then
            local restored, restoreResponse = Inventory.AddItem(fromInv, item.name, count, metadata, slot)

            if restored and oldGrid then
                local restoredSlot = type(restoreResponse) == 'table' and restoreResponse.slot or slot
                Spatial.SetGrid(fromInv, restoredSlot, oldGrid.x, oldGrid.y, false)
                sync(fromInv, restoredSlot)
            end

            return { success = false, error = response or 'add_failed' }
        end

        local newSlot = type(response) == 'table' and response.slot or targetSlot
        Spatial.SetGrid(toInv, newSlot, x, y, false)
        sync(fromInv, slot)
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
