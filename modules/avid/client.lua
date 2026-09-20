local function respond(cb, value)
    cb(value or { success = false, error = 'no_response' })
end

RegisterNUICallback('avid:getState', function(_, cb)
    respond(cb, lib.callback.await('ox_inventory:avid:getState', false))
end)

RegisterNUICallback('avid:setGrid', function(data, cb)
    respond(cb, lib.callback.await('ox_inventory:avid:setGrid', false, data))
end)

RegisterNUICallback('avid:equip', function(data, cb)
    respond(cb, lib.callback.await('ox_inventory:avid:equip', false, data))
end)

RegisterNUICallback('avid:unequip', function(data, cb)
    respond(cb, lib.callback.await('ox_inventory:avid:unequip', false, data.equipmentSlot))
end)

RegisterNUICallback('avid:unequipToGrid', function(data, cb)
    respond(cb, lib.callback.await('ox_inventory:avid:unequipToGrid', false, data))
end)

RegisterNUICallback('avid:groundToGrid', function(data, cb)
    respond(cb, lib.callback.await('ox_inventory:avid:groundToGrid', false, data))
end)

RegisterNUICallback('avid:gridToGround', function(data, cb)
    respond(cb, lib.callback.await('ox_inventory:avid:gridToGround', false, data))
end)

RegisterNUICallback('avid:drop', function(data, cb)
    if cache.vehicle or IsPedFalling(cache.ped) then
        return cb({ success = false, error = 'cannot_drop_here' })
    end

    local coords = GetOffsetFromEntityInWorldCoords(cache.ped, 0.0, 0.65, 0.0)

    data.coords = {
        x = coords.x,
        y = coords.y,
        z = coords.z - 0.15,
    }

    respond(cb, lib.callback.await('ox_inventory:avid:drop', false, data))
end)

RegisterNUICallback('avid:mergeStack', function(data, cb)
    respond(cb, lib.callback.await('ox_inventory:avid:mergeStack', false, data))
end)

RegisterNUICallback('avid:splitStack', function(data, cb)
    respond(cb, lib.callback.await('ox_inventory:avid:splitStack', false, data))
end)

RegisterNUICallback('avid:confiscateEquipped', function(data, cb)
    respond(cb, lib.callback.await('ox_inventory:avid:confiscateEquipped', false, data))
end)

RegisterNUICallback('avid:quickMove', function(data, cb)
    respond(cb, lib.callback.await('ox_inventory:avid:quickMove', false, data))
end)

RegisterNUICallback('avid:move', function(data, cb)
    respond(cb, lib.callback.await('ox_inventory:avid:move', false, data))
end)


local institutionalLockers = {
    police = 'policelocker',
    ems = 'emslocker',
    ambulance = 'emslocker',
    lawyer = 'lawyerlocker',
}

local function openInstitutionLocker(locker)
    local stash = institutionalLockers[locker] or locker

    if type(stash) ~= 'string' or stash == '' then
        return false
    end

    return client.openInventory('stash', stash)
end

local function openEvidenceLocker(caseId)
    if caseId == nil or caseId == '' then
        return client.openInventory('policeevidence')
    end

    return client.openInventory('policeevidence', tostring(caseId))
end

local function claimPrisonProperty()
    local success, reason = lib.callback.await('ox_inventory:avid:claimPrisonProperty', false)

    if success then
        lib.notify({
            type = 'success',
            description = reason == 'inventory_empty'
                and 'No stored property was found.'
                or 'Your stored property has been returned.',
        })
    else
        local message = reason == 'no_prison_property'
            and 'You do not have any property waiting for you.'
            or 'Your stored property could not be returned.'

        lib.notify({
            type = 'error',
            description = message,
        })
    end

    return success, reason
end

RegisterNetEvent('ox_inventory:avid:openLocker', function(locker)
    openInstitutionLocker(locker)
end)

RegisterNetEvent('ox_inventory:avid:openEvidence', function(caseId)
    openEvidenceLocker(caseId)
end)

RegisterNetEvent('ox_inventory:avid:claimPrisonProperty', function()
    claimPrisonProperty()
end)

exports('openInstitutionLocker', openInstitutionLocker)
exports('openEvidenceLocker', openEvidenceLocker)
exports('claimPrisonProperty', claimPrisonProperty)
