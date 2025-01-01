Core = exports.vorp_core:GetCore()
MenuData = exports.vorp_menu:GetMenuData()
Doors = {}
DoorEnities = {}
ClosestDoor = nil

-- Setup the UI Prompts for the door system
local LockGroup = U.Prompts:SetupPromptGroup()
local UnlockGroup = U.Prompts:SetupPromptGroup()
local DoorlockPrompt = UnlockGroup:RegisterPrompt(_('lock'), Config.Keys.lock, true, true, false, 'click', {})
local DoorUnlockPrompt = LockGroup:RegisterPrompt(_('unlock'), Config.Keys.lock, true, true, false, 'click', {})
local LockpickPrompt = LockGroup:RegisterPrompt(_('lockpick'), Config.Keys.lockpick, false, true, false, 'click', {})

---Event triggered when player selects their character
---@param doors table
RegisterNetEvent('gs-doorlocks:client:LoadData', function(doors)
    DevPrint('Loading doors', json.encode(doors))

    for doorid, door in next, doors do
        Doors[doorid] = door
        SetupDoor(door)
    end
end)

---Event triggered when a new door is added
---@param data table
RegisterNetEvent('gs-doorlocks:client:AddedDoor', function(data)
    DevPrint('Added door', json.encode(data))

    if not LocalPlayer.state.IsInSession then return end
    Doors[data.doorid] = data
    SetupDoor(data)
end)

---Event triggered when a door is updated (single param)
---@param doorid number
---@param param string
---@param value any
RegisterNetEvent('gs-doorlocks:client:UpdateDoor', function(doorid, param, value)
    DevPrint('Updated door', doorid, param, value)

    if not LocalPlayer.state.IsInSession then return end
    if not Doors[doorid] then return end
    
    Doors[doorid][param] = value

    if param == 'locked' then
        UpdateDoorState(doorid)
    end
end)

---Event triggered when a door is updated (full table)
---@param data table
RegisterNetEvent('gs-doorlocks:client:UpdatedDoor', function(data)
    DevPrint('Updated door', json.encode(data))
    if not LocalPlayer.state.IsInSession then return end

    Doors[data.doorid] = data
end)

---Event triggered when a door is removed
---@param doorid number
RegisterNetEvent('gs-doorlocks:client:DeletedDoor', function(doorid)
    DevPrint('Removed door', doorid)
    if not LocalPlayer.state.IsInSession then return end
    RemoveDoor(doorid)
    Doors[doorid] = nil
end)

-- Event triggered when the create door command is executed
RegisterNetEvent('gs-doorlocks:client:CreateDoor', function()
    OpenLockMenu(true)
end)

-- Event triggered when the edit door command is executed
RegisterNetEvent('gs-doorlocks:client:EditDoor', function()
    if not ClosestDoor then
        Core.NotifyAvanced(_('no_door_nearby'), 'BLIPS', 'blip_proc_home_locked', 'COLOR_RED', 1500)
        return
    end

    -- Format the door data for the menu
    local data <const> = Doors[ClosestDoor.doorid]

    local edit = {
        doorid = data.doorid,
        name = data.name,
        jobAccess = data.jobAccess,
        charAccess = data.charAccess,
        lockedOnStart = data.lockedOnStart,
        canLockpick = data.canLockpick,
        showPrompt = data.showPrompt
    }

    OpenLockMenu(edit)
end)

---Event triggered when the open all doors command is executed
---@param doorid number
---@param itemId number | nil
RegisterNetEvent('gs-doorlocks:client:LockpickDoor', function(doorid, itemId)
    if not LocalPlayer.state.IsInSession then return end
    if not Doors[doorid] then return end
    local data = Doors[doorid]

    if data.locked then
        LockpickAnimation(data.coords)

        if Config.Lockpick.minigame then
            LockpickGame(function(success)
                if success then
                    TriggerServerEvent('gs-doorlocks:server:ToggleDoorStatus', data.doorid, false, itemId)
                else
                    if Config.Lockpick.removeOnFail then
                        TriggerServerEvent('gs-inventory:server:RemoveItem', itemId)
                    end
                    Core.NotifyAvanced(_('lockpick_fail'), 'BLIPS', 'blip_proc_home_locked', 'COLOR_RED', 1500)
                end

                ClearPedTasks(U.Cache.Ped)
            end)
        else
            Wait(2500)
            ClearPedTasks(U.Cache.Ped)
            TriggerServerEvent('gs-doorlocks:server:ToggleDoorStatus', data.doorid, false, itemId)
        end
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        for doorid, door in next, Doors do
            RemoveDoor(doorid)
        end
    end
end)

CreateThread(function()
    if LocalPlayer.state.IsInSession then
        Wait(2500)
        TriggerServerEvent('gs-doorlocks:server:LoadData')
    end

    while true do
        Wait(1000)

        local Closest = nil
        local ClosestDist = nil
        
        if not LocalPlayer.state.IsInSession then
            goto continue
        end

        table.wipe(DoorEnities) -- Clear the door entities, memory performance?

        for doorid, data in next, Doors do
            -- Ignore anything > 50 meters. No need to check everything in existance... performance?
            local dist = #(U.Cache.Coords - data.coords)
            if dist < 50 then

                if data.doors then
                    for i = 1, 2 do
                        local entity = GetEntityByDoorhash(data.doors[i].hash, 0)

                        if entity ~= 0 then
                            DoorEnities[entity] = doorid
                        end
                    end

                    -- Find the objects center point to place the sprite (if enabled) (Calculated server-side)
                    data.center = vec3(data.coords.x, data.coords.y, data.coords.z + 1.0)
                else
                    local entity = GetEntityByDoorhash(data.door.hash, 0)

                    if entity ~= 0 then
                        DoorEnities[entity] = doorid

                        -- Find the objects center point to place the sprite (if enabled)
                        local calc = CalculateModelCenterPoint(entity, data.door.model)
                        data.center = vec3(calc.x, calc.y, data.coords.z + 1.0)
                    end
                end

                -- Find the closest door to the player... I'm sure theres a million ways to do this

                if not ClosestDist or dist < ClosestDist then
                    ClosestDist = dist
                    Closest = {doorid = doorid, distance = dist}
                end
            end
        end

        ClosestDoor = Closest

        ::continue::
    end
end)

-- DoorlockPrompt, DoorUnlockPrompt, LockpickPrompt

CreateThread(function()
    -- Setup the UI Prompts for the door system
    while true do
        local sleep = 1000
        if ClosestDoor and ClosestDoor.distance <= Config.DoorDistance then
            local data = Doors[ClosestDoor.doorid]

            if data and data.showPrompt and not IsPedDeadOrDying(U.Cache.Ped, false) and not SelectionActive then
                sleep = 5
                local enableLockpick = data.canLockpick and not data.locked
                local enableLock = not data.locked
                local enableUnlock = data.locked

                local isJob = (#data.jobAccess == 0 and true or U.table.contains(data.jobAccess, LocalPlayer.state.Character.Job))
                local isChar = (#data.charAccess == 0 and true or U.table.contains(data.charAccess, LocalPlayer.state.Character.CharId))
                
                if Config.EnableDrawSprite then
                    DrawLock(data.center, data.locked)
                end

                if data.locked then
                    if isJob and isChar then
                        enableLock = true
                    end

                    if data.canLockpick then
                        enableLockpick = true
                    end
                    
                    -- Do not show prompts if UseIsControlJustReleased is enabled
                    if not Config.UseIsControlJustReleased then

                        LockGroup:ShowGroup(_('locked_doorlock'))
                        DoorlockPrompt:EnabledPrompt(enableLock)
                        LockpickPrompt:EnabledPrompt(enableLockpick)

                        DoorUnlockPrompt:EnabledPrompt(enableUnlock)

                        if enableUnlock and DoorUnlockPrompt:HasCompleted() then
                            DevPrint('Unlocking door', data.doorid)
                            LockAnimation(data.coords)
                            TriggerServerEvent('gs-doorlocks:server:ToggleDoorStatus', data.doorid, false)
                        end
                        
                        if enableLockpick and LockpickPrompt:HasCompleted() then
                            DevPrint('Lockpicking door', data.doorid)
                            TriggerServerEvent('gs-doorlocks:server:LockpickDoor', data.doorid)
                        end

                    else
                        if enableUnlock and IsControlJustReleased(0, Config.Keys.lock) then
                            DevPrint('Unlocking door', data.doorid)
                            LockAnimation(data.coords)
                            TriggerServerEvent('gs-doorlocks:server:ToggleDoorStatus', data.doorid, false)
                        end

                        if enableLockpick and IsControlJustReleased(0, Config.Keys.lockpick) then
                            DevPrint('Lockpicking door', data.doorid)
                            TriggerServerEvent('gs-doorlocks:server:LockpickDoor', data.doorid)
                        end
                    end

                else
                    if isJob and isChar then
                        enableUnlock = true
                    end

                    -- Do not show prompts if UseIsControlJustReleased is enabled
                    if not Config.UseIsControlJustReleased then
                        UnlockGroup:ShowGroup(_('unlocked_doorlock'))

                        if enableLock and DoorlockPrompt:HasCompleted() then
                            DevPrint('Locking door', data.doorid)
                            LockAnimation(data.coords)
                            TriggerServerEvent('gs-doorlocks:server:ToggleDoorStatus', data.doorid, true)
                        end
                    else
                        if enableLock and IsControlJustReleased(0, Config.Keys.lock) then
                            DevPrint('Locking door', data.doorid)
                            LockAnimation(data.coords)
                            TriggerServerEvent('gs-doorlocks:server:ToggleDoorStatus', data.doorid, true)
                        end
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

RegisterCommand(Config.UnlockCommand, function()
    if not ClosestDoor then
        Core.NotifyAvanced(_('no_door_nearby'), 'BLIPS', 'blip_proc_home_locked', 'COLOR_RED', 1500)
        return
    end

    local data = Doors[ClosestDoor.doorid]

    local isJob = (#data.jobAccess == 0 and true or U.table.contains(data.jobAccess, LocalPlayer.state.Character.Job))
    local isChar = (#data.charAccess == 0 and true or U.table.contains(data.charAccess, LocalPlayer.state.Character.CharId))

    if isJob and isChar then
        LockAnimation(data.coords)
        TriggerServerEvent('gs-doorlocks:server:ToggleDoorStatus', data.doorid, not data.locked)
    else
        Core.NotifyAvanced(_('no_perms'), 'BLIPS', 'blip_proc_home_locked', 'COLOR_RED', 1500)
    end
end)