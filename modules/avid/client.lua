local previewCam
local previewActive = false

local function stopPreview()
    previewActive = false

    if previewCam and DoesCamExist(previewCam) then
        RenderScriptCams(false, true, 220, true, true)
        DestroyCam(previewCam, false)
    end

    previewCam = nil
end

local function startPreview()
    stopPreview()

    local ped = cache.ped
    if not ped or ped == 0 or not DoesEntityExist(ped) or cache.vehicle then return end

    local coords = GetEntityCoords(ped)
    local camPos = GetOffsetFromEntityInWorldCoords(ped, 0.15, 3.15, 0.72)
    local right = GetEntityRightVector(ped)
    local target = vec3(
        coords.x + right.x * 1.22,
        coords.y + right.y * 1.22,
        coords.z + 0.72
    )

    previewCam = CreateCamWithParams(
        'DEFAULT_SCRIPTED_CAMERA',
        camPos.x, camPos.y, camPos.z,
        0.0, 0.0, 0.0,
        33.0,
        true,
        2
    )

    PointCamAtCoord(previewCam, target.x, target.y, target.z)
    SetCamActive(previewCam, true)
    RenderScriptCams(true, true, 260, true, true)
    previewActive = true

    CreateThread(function()
        while previewActive and previewCam and DoesCamExist(previewCam) do
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
