local response = promise.new()

--- Return door id for exports
--- @param doorid number | nil
RegisterNetEvent('gs-doorlocks:client:AddedDoorExport', function(doorid)
    response:resolve(doorid)
end)

--- Start lock creator from external resources
--- @return number
exports('CreateDoor', function()
    response = promise.new()

    OpenLockMenu(true, true)

    return Citizen.Await(response)
end)

exports('GetDoorId', function()
    return SelectDoorIdThread()
end)

--- Gets the door ID of the closest door
--- @param dist number | nil
--- @return number | nil
exports('ClosestDoor', function(dist)
    if not ClosestDoor then return end

    if dist then
        if #(U.Cache.Coords - Doors[ClosestDoor].coords) > dist then
            return
        end
    end

    return ClosestDoor
end)