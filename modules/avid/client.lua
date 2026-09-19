local previewPed
local previewActive = false

local function cameraVectors()
    local rot = GetGameplayCamRot(2)
    local rx = math.rad(rot.x)
    local rz = math.rad(rot.z)
    local cosX = math.abs(math.cos(rx))

    local forward = vec3(
        -math.sin(rz) * cosX,
        math.cos(rz) * cosX,
        math.sin(rx)
    )

    local right = vec3(math.cos(rz), math.sin(rz), 0.0)

    return rot, forward, right
end

local function stopPreview()
    previewActive = false

    if previewPed and DoesEntityExist(previewPed) then
        DeleteEntity(previewPed)
    end

    previewPed = nil
end

local function startPreview()
    stopPreview()

    local ped = cache.ped
    if not ped or ped == 0 or not DoesEntityExist(ped) or cache.vehicle then return end

    previewPed = ClonePed(ped, false, false, true)
    if not previewPed or previewPed == 0 then return end

    previewActive = true

    SetEntityInvincible(previewPed, true)
    SetEntityCollision(previewPed, false, false)
    SetBlockingOfNonTemporaryEvents(previewPed, true)
    SetPedCanRagdoll(previewPed, false)
    SetPedCanBeTargetted(previewPed, false)
    RemoveAllPedWeapons(previewPed, true)
    FreezeEntityPosition(previewPed, true)

    CreateThread(function()
        while previewActive and previewPed and DoesEntityExist(previewPed) do
            local camPos = GetGameplayCamCoord()
            local rot, forward, right = cameraVectors()

            -- Keep the exact player appearance framed in the left character pane
            -- while preserving the player's existing world view.
            local distance = 2.75
            local horizontal = -0.78
            local vertical = -1.20

            local pos = vec3(
                camPos.x + forward.x * distance + right.x * horizontal,
                camPos.y + forward.y * distance + right.y * horizontal,
                camPos.z + forward.z * distance + vertical
            )

            SetEntityCoordsNoOffset(previewPed, pos.x, pos.y, pos.z, false, false, false)
            SetEntityHeading(previewPed, rot.z + 180.0)
            SetEntityVisible(previewPed, true, false)
            FreezeEntityPosition(previewPed, true)

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

RegisterNUICallback('avid:move', function(data, cb)
    respond(cb, lib.callback.await('ox_inventory:avid:move', false, data))
end)
