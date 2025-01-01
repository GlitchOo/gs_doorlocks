---Calculates the center position for double doors and returns the door object  
---@param doorid number
---@param data table
---@return table
function InitDoor(doorid, data)
    local response = {}
    response.doorid = doorid
    response.name = data.name

    if data.isDouble or data.doors then
        local doors = data.door or data.doors

        doors[1].coords = vec3(doors[1].coords.x, doors[1].coords.y, doors[1].coords.z)
        doors[2].coords = vec3(doors[2].coords.x, doors[2].coords.y, doors[2].coords.z)

        response.coords = doors[1].coords - ((doors[1].coords - doors[2].coords) / 2)
        response.doors = doors
    else
        response.coords = vec3(data.door.coords.x, data.door.coords.y, data.door.coords.z)
        response.door = data.door
    end

    response.jobAccess = data.jobAccess
    response.charAccess = data.charAccess
    response.locked = data.lockedOnStart
    response.lockedOnStart = data.lockedOnStart
    response.canLockpick = data.canLockpick
    response.showPrompt = data.showPrompt

    return response
end

---Updates info about the door annd sends updated info to clients
---@param doorid number
---@param param string
---@param value any
function UpdateDoor(doorid, param, value)
    if not Doors[doorid] then return end
    
    if Doors[doorid][param] and Doors[doorid][param] == value then 
        return -- No need to update if the value is the same
    end

    Doors[doorid][param] = value

    MySQL.update('UPDATE `gs_doorlocks` SET `data` = ? WHERE `doorid` = ?', {json.encode(Doors[doorid]), doorid},
    function(records)
        if records > 0 then
            TriggerClientEvent('gs-doorlocks:client:UpdateDoor', -1, doorid, param, value)
        end
    end)

    if param == 'name' then
        MySQL.update('UPDATE `gs_doorlocks` SET `name` = ? WHERE `doorid` = ?', {value, doorid})
    end
end

--- Deletes a door from the database and sends the info to clients
---@param doorid number
function RemoveDoor(doorid)
    if not Doors[doorid] then return end

    MySQL.update('DELETE FROM `gs_doorlocks` WHERE `doorid` = ?', {doorid},
    function(records)
        if records > 0 then
            Doors[doorid] = nil
            TriggerClientEvent('gs-doorlocks:client:DeletedDoor', -1, doorid)
        end
    end)
end

--- Get class for a door by hash
--- @param hash number
--- @return table | nil
function DoorByHash(hash)
    for doorid, data in next, Doors do
        if data.doors then
            for i = 1, 2 do
                if data.doors[i].hash == hash then
                    return DoorAPI:Door(doorid)
                end
            end
        else
            if data.door.hash == hash then
                return DoorAPI:Door(doorid)
            end
        end
    end
end

--- Get class for a door by name
--- @param name string
--- @return table | nil | table[]
function DoorsByName(name)
    local found = {}
    for doorid, data in next, Doors do
        if data.name == name then
            table.insert(found, DoorAPI:Door(doorid))
        end
    end
    return found
end