local db = require 'modules.mysql.server'
local Items = require 'modules.items.server'
local Spatial = require 'modules.avid.spatial'

local PRISON_STASH = 'avid_prison_property'
local prisonDesks = {}

local function decodeSnapshot(raw)
    if not raw then return end

    if type(raw) == 'string' then
        local ok, decoded = pcall(json.decode, raw)
        if not ok then return end
        raw = decoded
    end

    if type(raw) ~= 'table' then return end

    return raw
end

local function snapshotHasItems(snapshot)
    if type(snapshot) ~= 'table' then return false end

    for _, entry in pairs(snapshot) do
        if type(entry) == 'table' and entry.name and (entry.count or 0) > 0 then
            return true
        end
    end

    return false
end

local function normalizeCoords(coords)
    if type(coords) ~= 'table' and type(coords) ~= 'vector3' then return end

    local x = coords.x or coords[1]
    local y = coords.y or coords[2]
    local z = coords.z or coords[3]

    if not x or not y or not z then return end

    return vec3(x + 0.0, y + 0.0, z + 0.0)
end

return function(Inventory)
    local function clone(value)
        if type(value) ~= 'table' then return value end

        local ok, encoded = pcall(json.encode, value)
        if not ok or not encoded then return {} end

        local decodedOk, decoded = pcall(json.decode, encoded)
        return decodedOk and decoded or {}
    end

    local function targetBackpack(target)
        for _, item in pairs(target.items or {}) do
            if item and item.avid and item.avid.equipped == 'backpack' and item.metadata and item.metadata.container then
                return Inventory(item.metadata.container), item
            end
        end
    end

    local function resolveEvidenceSource(officerId, data)
        data = type(data) == 'table' and data or {}

        local officer = Inventory(officerId)
        local targetId = tonumber(data.target)
        local target = targetId and Inventory(targetId)

        if not officer or not officer.player or not target or not target.player then
            return nil, 'invalid_search_target'
        end

        if not server.hasGroup(officer, shared.police) then
            return nil, 'police_access_required'
        end

        local officerCoords = GetEntityCoords(officer.player.ped)
        local targetCoords = GetEntityCoords(target.player.ped)

        if #(officerCoords - targetCoords) > 4.0 then
            return nil, 'search_target_too_far'
        end

        local kind = tostring(data.sourceKind or '')
        local fromInventory = target

        if kind == 'searchedBackpack' then
            fromInventory = targetBackpack(target)
            if not fromInventory then
                return nil, 'searched_backpack_missing'
            end
        elseif kind ~= 'searched' and kind ~= 'searchedEquipment' then
            return nil, 'invalid_evidence_source'
        end

        local slot = tonumber(data.slot)
        local item = slot and fromInventory.items[slot]

        if not item then
            return nil, 'item_missing'
        end

        if kind == 'searched' and item.avid and item.avid.equipped then
            return nil, 'item_is_equipped'
        end

        if kind == 'searchedEquipment' then
            local expected = tostring(data.equipmentSlot or '')
            local equippedSlot = item.avid and item.avid.equipped

            if not equippedSlot or (expected ~= '' and equippedSlot ~= expected) then
                return nil, 'equipment_changed'
            end
        end

        return {
            officer = officer,
            target = target,
            inventory = fromInventory,
            item = item,
            slot = slot,
            kind = kind,
        }
    end

    local function rebuildInventory(inv, snapshot)
        local inventory, totalWeight = {}, 0
        local ostime = os.time()

        for _, data in pairs(snapshot or {}) do
            if type(data) == 'table' and data.name and data.slot and data.count and data.count > 0 then
                local item = Items(data.name)

                if item then
                    local metadata = Items.CheckMetadata(data.metadata or {}, item, data.name, ostime)
                    local slotData = {
                        name = item.name,
                        label = item.label,
                        weight = 0,
                        slot = tonumber(data.slot),
                        count = math.floor(data.count),
                        description = item.description,
                        metadata = metadata,
                        stack = item.stack,
                        close = item.close,
                        avid = type(data.avid) == 'table' and table.clone(data.avid) or nil,
                    }

                    slotData.weight = Inventory.SlotWeight(item, slotData)
                    totalWeight += slotData.weight
                    inventory[slotData.slot] = slotData
                end
            end
        end

        inv.items = inventory
        inv.weight = totalWeight
        inv.weapon = nil
        inv.changed = true

        Spatial.Normalize(inv)

        return inventory, inv.weight
    end

    local function hasPrisonProperty(playerId)
        local inv = Inventory(playerId)
        if not inv or not inv.player then return false end

        local snapshot = decodeSnapshot(db.loadStash(inv.owner, PRISON_STASH))
        return snapshotHasItems(snapshot)
    end

    local function storePrisonProperty(playerId)
        local inv = Inventory(playerId)
        if not inv or not inv.player then
            return false, 'invalid_inventory'
        end

        local existing = decodeSnapshot(db.loadStash(inv.owner, PRISON_STASH))

        if snapshotHasItems(existing) then
            return false, 'prison_property_already_stored'
        end

        local snapshot = inv:minimal()

        if not snapshotHasItems(snapshot) then
            return true, 'inventory_empty'
        end

        local saved = db.saveStash(inv.owner, PRISON_STASH, json.encode(snapshot))
        if saved == nil then
            return false, 'prison_property_save_failed'
        end

        inv:closeInventory()
        Inventory.Clear(inv)
        Inventory.Save(inv)

        TriggerClientEvent('ox_inventory:inventoryConfiscated', inv.id, true)

        if server.loglevel > 0 then
            lib.logger(inv.owner, 'prisonPropertyStored', ('Stored prison property for "%s" (%s items)'):format(inv.label, #snapshot))
        end

        return true, 'prison_property_stored'
    end

    local function returnPrisonProperty(playerId)
        local inv = Inventory(playerId)
        if not inv or not inv.player then
            return false, 'invalid_inventory'
        end

        local raw = db.loadStash(inv.owner, PRISON_STASH)
        local snapshot = decodeSnapshot(raw)

        if not snapshotHasItems(snapshot) then
            return false, 'no_prison_property'
        end

        -- Anything still carried at release is discarded before the exact pre-sentence
        -- snapshot is restored. This keeps prison-issued/contraband items from corrupting
        -- the player's original spatial layout.
        if next(inv.items) then
            Inventory.Clear(inv)
        end

        local inventory, totalWeight = rebuildInventory(inv, snapshot)
        local saved = Inventory.Save(inv)

        if saved == nil then
            return false, 'prison_property_restore_failed'
        end

        db.deleteStash(inv.owner, PRISON_STASH)

        TriggerClientEvent('ox_inventory:inventoryReturned', inv.id, {
            inventory,
            totalWeight = totalWeight,
        })

        if server.syncInventory then
            server.syncInventory(inv)
        end

        if server.loglevel > 0 then
            lib.logger(inv.owner, 'prisonPropertyReturned', ('Returned prison property to "%s"'):format(inv.label))
        end

        return true, 'prison_property_returned'
    end

    local function nearPrisonDesk(playerId)
        local inv = Inventory(playerId)
        local ped = inv and inv.player and inv.player.ped

        if not ped or ped == 0 then return false end

        local playerCoords = GetEntityCoords(ped)

        for _, desk in pairs(prisonDesks) do
            if #(playerCoords - desk.coords) <= desk.distance then
                return true
            end
        end

        return false
    end

    lib.callback.register('ox_inventory:avid:claimPrisonProperty', function(source)
        if not nearPrisonDesk(source) then
            return false, 'not_at_prison_property_desk'
        end

        return returnPrisonProperty(source)
    end)

    lib.callback.register('ox_inventory:avid:hasPrisonProperty', function(source)
        return hasPrisonProperty(source)
    end)

    exports('InspectEvidenceSource', function(officerId, data)
        local resolved, reason = resolveEvidenceSource(officerId, data)
        if not resolved then return false, reason end

        local item = resolved.item

        return true, {
            name = item.name,
            label = item.label,
            count = item.count,
            weight = item.weight,
            metadata = clone(item.metadata or {}),
            avid = clone(item.avid or {}),
            inventoryId = resolved.inventory.id,
            inventoryType = resolved.inventory.type,
            targetId = resolved.target.id,
        }
    end)

    exports('StoreEvidenceItem', function(officerId, data)
        local resolved, reason = resolveEvidenceSource(officerId, data)
        if not resolved then return false, reason end

        data = type(data) == 'table' and data or {}
        local lockerKey = tostring(data.lockerKey or ''):upper():gsub('[^%w%-%_]', '-'):sub(1, 100)
        if lockerKey == '' then return false, 'invalid_evidence_locker' end

        local item = resolved.item
        local count = math.max(1, math.min(math.floor(tonumber(data.count) or 1), item.count))

        if item.metadata and item.metadata.avidEvidence then
            return false, 'item_already_evidence'
        end

        if data.expectedName and tostring(data.expectedName) ~= item.name then
            return false, 'item_changed'
        end

        local evidenceMetadata = clone(data.metadata or {})
        if type(evidenceMetadata) ~= 'table' or not evidenceMetadata.avidEvidence then
            return false, 'evidence_metadata_required'
        end

        evidenceMetadata.avidEvidence.lockerKey = lockerKey

        local destination = Inventory(('evidence-%s'):format(lockerKey))
        if not destination or destination.type ~= 'policeevidence' then
            return false, 'evidence_locker_unavailable'
        end

        if not Inventory.CanCarryItem(destination, item.name, count, evidenceMetadata) then
            return false, 'evidence_locker_full'
        end

        local originalMetadata = clone(item.metadata or {})
        local originalAvid = clone(item.avid or {})
        local originalCount = item.count
        local wasWeapon = resolved.inventory == resolved.target and resolved.target.weapon == resolved.slot

        local removed, removeReason = Inventory.RemoveItem(
            resolved.inventory,
            item.name,
            count,
            originalMetadata,
            resolved.slot,
            false,
            true
        )

        if not removed then
            return false, removeReason or 'evidence_remove_failed'
        end

        local added, response = Inventory.AddItem(destination, item.name, count, evidenceMetadata)

        if not added then
            local restored, restoreResponse = Inventory.AddItem(
                resolved.inventory,
                item.name,
                count,
                originalMetadata,
                resolved.slot
            )

            if restored and originalCount == count then
                local restoredSlot = type(restoreResponse) == 'table' and restoreResponse.slot or resolved.slot

                if originalAvid.equipped then
                    Spatial.SetEquipped(resolved.inventory, restoredSlot, originalAvid.equipped)
                elseif originalAvid.grid then
                    Spatial.SetGrid(
                        resolved.inventory,
                        restoredSlot,
                        originalAvid.grid.x,
                        originalAvid.grid.y,
                        false
                    )
                end
            end

            return false, response or 'evidence_store_failed'
        end

        if wasWeapon and originalCount == count then
            resolved.target.weapon = nil
            TriggerClientEvent('ox_inventory:disarm', resolved.target.id)
        end

        local destinationSlot = type(response) == 'table' and response.slot or nil

        return true, {
            lockerId = destination.id,
            lockerKey = lockerKey,
            slot = destinationSlot,
            count = count,
        }
    end)

    exports('StorePrisonProperty', storePrisonProperty)
    exports('ReturnPrisonProperty', returnPrisonProperty)
    exports('HasPrisonProperty', hasPrisonProperty)

    exports('RegisterPrisonPropertyDesk', function(name, coords, distance)
        local normalized = normalizeCoords(coords)
        if not normalized then return false end

        prisonDesks[tostring(name or #prisonDesks + 1)] = {
            coords = normalized,
            distance = math.max(0.5, tonumber(distance) or 2.0),
        }

        return true
    end)

    -- Allows job resources to register additional personal lockers without editing
    -- ox_inventory internals. owner=true guarantees one persistent locker per character.
    exports('RegisterInstitutionLocker', function(name, label, slots, maxWeight, groups)
        if type(name) ~= 'string' or name == '' then return false end

        Inventory.RegisterStash(
            name,
            label or 'Personal Locker',
            tonumber(slots) or 56,
            tonumber(maxWeight) or 60000,
            true,
            groups
        )

        return true
    end)
end
