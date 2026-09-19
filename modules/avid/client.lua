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

RegisterNUICallback('avid:move', function(data, cb)
    respond(cb, lib.callback.await('ox_inventory:avid:move', false, data))
end)
