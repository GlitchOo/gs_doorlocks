local DoorAPI = {}

--- Get class for a door
--- @param doorid number
--- @return table | nil
function DoorAPI:Door(doorid)
    if not Doors[doorid] then return end

    local doorData <const> = Doors[doorid]
    
    -- Door class
    self.fn = {}
    self.Data = {}

    self.Data.doorid = doorid
    self.Data.name = doorData.name
    self.Data.locked = doorData.locked
    self.Data.coords = doorData.coords
    self.Data.charAccess = doorData.charAccess
    self.Data.jobAccess = doorData.jobAccess
    self.Data.lockedOnStart = doorData.lockedOnStart
    self.Data.canLockpick = doorData.canLockpick


    --- Set the door to locked or unlocked
    ---@param bool boolean
    function self.fn.SetLock(bool)
        self.Data.locked = bool
        UpdateDoor(self.Data.doorid, 'locked', self.Data.locked)
    end

    --- Set the name of the door
    --- @param name string
    function self.fn.SetName(name)
        self.Data.name = name
        UpdateDoor(self.Data.doorid, 'name', self.Data.name)
    end

    --- Set the job access for the door
    --- @param jobAccess table
    function self.fn.SetJobAccess(jobAccess)
        self.Data.jobAccess = jobAccess
        UpdateDoor(self.Data.doorid, 'jobAccess', self.Data.jobAccess)
    end

    --- Add a job to the door access
    --- @param name string
    --- @return boolean
    function self.fn.AddJob(name)
        if not U.table.contains(self.Data.jobAccess, name) then

            table.insert(self.Data.jobAccess, name)
            UpdateDoor(self.Data.doorid, 'jobAccess', self.Data.jobAccess)

            return true
        end

        return false
    end

    --- Remove a job from the door access
    --- @param name string
    --- @return boolean
    function self.fn.RemoveJob(name)
        local index = U.table.indexof(self.Data.jobAccess, name)
        if index then

            table.remove(self.Data.jobAccess, index)
            UpdateDoor(self.Data.doorid, 'jobAccess', self.Data.jobAccess)

            return true
        end

        return false
    end

    --- Set the character access for the door
    --- @param charAccess table
    function self.fn.SetCharAccess(charAccess)
        self.Data.charAccess = charAccess
        UpdateDoor(self.Data.doorid, 'charAccess', self.Data.charAccess)
    end

    --- Add a character to the door access
    --- @param charId number
    --- @return boolean
    function self.fn.AddChar(charId)
        if not U.table.contains(self.Data.charAccess, charId) then

            table.insert(self.Data.charAccess, charId)
            UpdateDoor(self.Data.doorid, 'charAccess', self.Data.charAccess)

            return true
        end

        return false
    end

    --- Remove a character from the door access
    --- @param charId number
    --- @return boolean
    function self.fn.RemoveChar(charId) 
        local index = U.table.indexof(self.Data.charAccess, charId)
        if index then

            table.remove(self.Data.charAccess, index)
            UpdateDoor(self.Data.doorid, 'charAccess', self.Data.charAccess)

            return true
        end

        return false
    end

    --- Set the door to be locked on start
    --- @param bool boolean
    function self.fn.SetLockOnStart(bool)
        self.Data.lockedOnStart = bool
        UpdateDoor(self.Data.doorid, 'lockedOnStart', self.Data.lockedOnStart)
    end

    --- Set if the door can be lockpicked
    --- @param bool boolean
    function self.fn.SetCanLockpick(bool)
        self.Data.canLockpick = bool
        UpdateDoor(self.Data.doorid, 'canLockpick', self.Data.canLockpick)
    end

    --- Set if the door should show a prompt
    --- @param bool boolean
    function self.fn.ShowUIPrompt(bool)
        self.Data.showPrompt = bool
        UpdateDoor(self.Data.doorid, 'showPrompt', self.Data.showPrompt)
    end

    --- Update the door data
    --- @param data table
    function self.fn.Update(data)
        self.Data.name = data.name or self.Data.name
        self.Data.locked = (data.locked == nil and self.Data.locked or data.locked)
        self.Data.coords = data.coords or self.Data.coords
        self.Data.charAccess = ((not data.charAccess or type(data.charAccess) ~= 'table') and self.Data.charAccess or data.charAccess)
        self.Data.jobAccess = ((not data.jobAccess or type(data.jobAccess) ~= 'table') and self.Data.jobAccess or data.jobAccess)
        self.Data.lockedOnStart = (data.lockedOnStart == nil and self.Data.lockedOnStart or data.lockedOnStart)
        self.Data.canLockpick = (data.canLockpick == nil and self.Data.canLockpick or data.canLockpick)

        BulkUpdateDoor(self.Data.doorid, self.Data)
    end

    --- Set if the door should show a prompt
    function self.fn.Delete()
        RemoveDoor(self.Data.doorid)
    end

    return self
end

--- Get class for a door by hash
--- @param hash number
--- @return table | nil
function DoorAPI:DoorByHash(hash)
    for doorid, data in next, Doors do
        if data.doors then
            for i = 1, 2 do
                if data.doors[i].hash == hash then
                    return self:Door(doorid)
                end
            end
        else
            if data.door.hash == hash then
                return self:Door(doorid)
            end
        end
    end
end

--- Get class for a door by name
--- @param name string
--- @return table | nil | table[]
function DoorAPI:DoorsByName(name)
    local found = {}
    for doorid, data in next, Doors do
        if data.name == name then
            found[#found+1] = self:Door(doorid)
        end
    end
    return found
end

--- Get all doors as classes
---@return table
function DoorAPI:AllDoors()
    local found = {}

    for doorid, _ in next, Doors do
        found[#found+1] = self:Door(doorid)
    end

    return found
end

--- Add a new door
--- @param door table
--- @return boolean | number
function DoorAPI:AddNewDoor(door) 
    -- Check to see if door exists
    if door.doors then
        if self:DoorByHash(door.doors[1].hash) then
            print('Failed to create new door: Door already exists', door.name)
            return false
        end

        if self:DoorByHash(door.doors[2].hash) then
            print('Failed to create new door: Door already exists', door.name)
            return false
        end
    else
        if self:DoorByHash(door.door.hash) then
            print('Failed to create new door: Door already exists', door.name)
            return false
        end
    end

    local insertId = MySQL.insert.await('INSERT INTO `gs_doorlocks` ( `name` ) VALUES ( ? )', { door.name })
    if insertId then
        local newDoor = InitDoor(insertId, door)
        Doors[insertId] = newDoor

        MySQL.update('UPDATE gs_doorlocks SET data = ? WHERE doorid = ?', {json.encode(newDoor), insertId})

        -- Send to clients
        TriggerClientEvent('gs-doorlocks:client:AddedDoor', -1, newDoor)

        return insertId
    end

    return false
end

--- Get Door API
exports('GetAPI', function()
    return DoorAPI
end)