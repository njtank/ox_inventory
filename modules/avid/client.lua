local previewPed
local previewActive = false

local function stopPreview()
    previewActive = false

    if previewPed and DoesEntityExist(previewPed) then
        SetEntityAsMissionEntity(previewPed, true, true)
        DeleteEntity(previewPed)
    end

    previewPed = nil
end

local function startPreview()
    stopPreview()

    local ped = cache.ped
    if not ped or ped == 0 or not DoesEntityExist(ped) or cache.vehicle then return end

    previewPed = ClonePed(ped, GetEntityHeading(ped), false, true)
    if not previewPed or previewPed == 0 or not DoesEntityExist(previewPed) then return end

    previewActive = true

    SetEntityAsMissionEntity(previewPed, true, true)
    SetEntityInvincible(previewPed, true)
    SetEntityCollision(previewPed, false, false)
    SetBlockingOfNonTemporaryEvents(previewPed, true)
    SetPedCanRagdoll(previewPed, false)
    SetPedCanBeTargetted(previewPed, false)
    SetEntityVisible(previewPed, true, false)
    SetEntityAlpha(previewPed, 255, false)
    SetEntityAlwaysPrerender(previewPed, true)
    SetEntityLodDist(previewPed, 0xFFFF)
    RemoveAllPedWeapons(previewPed, true)
    ClearPedTasksImmediately(previewPed)
    FreezeEntityPosition(previewPed, true)

    CreateThread(function()
        while previewActive and previewPed and DoesEntityExist(previewPed) do
            -- Frame the clone inside the dedicated live-character viewport.
            -- Pulling the clone farther from the camera keeps the whole body inside
            -- the panel, while the screen anchor places it clear of the equipment column.
            local nearPoint, normal = GetWorldCoordFromScreenCoord(0.132, 0.735)
            local depth = 3.55
            local pos = nearPoint + normal * depth
            local camRot = GetGameplayCamRot(2)

            SetEntityCoordsNoOffset(previewPed, pos.x, pos.y, pos.z, false, false, false)
            SetEntityHeading(previewPed, camRot.z + 180.0)
            SetEntityVisible(previewPed, true, false)
            SetEntityAlpha(previewPed, 255, false)
            FreezeEntityPosition(previewPed, true)

            -- The normal third-person player model remains in the world behind the UI.
            -- Hide it only for this client's frame so the inventory shows one clean preview.
            SetEntityLocallyInvisible(ped)
            HideHudAndRadarThisFrame()
            Wait(0)
        end
    end)
end

AddEventHandler('ox_inventory:avid:preview', function(enabled)
    if enabled then
        startPreview()
    else
        stopPreview()
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then stopPreview() end
end)

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

RegisterNUICallback('avid:quickMove', function(data, cb)
    respond(cb, lib.callback.await('ox_inventory:avid:quickMove', false, data))
end)

RegisterNUICallback('avid:move', function(data, cb)
    respond(cb, lib.callback.await('ox_inventory:avid:move', false, data))
end)
