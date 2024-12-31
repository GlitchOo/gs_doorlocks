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
function DoorAPI:DoorByNames(name)
    local found = {}
    for doorid, data in next, Doors do
        if data.name == name then
            table.insert(found, self:Door(doorid))
        end
    end
    return found
end

exports('GetAPI', function()
    return DoorAPI
end)