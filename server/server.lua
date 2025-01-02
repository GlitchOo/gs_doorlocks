Core = exports.vorp_core:GetCore()
Doors = {}

while not DatabaseReady do
    Wait(100)
end

---Event triggered when player selects their character
AddEventHandler("vorp:SelectedCharacter",function(source)
    TriggerClientEvent('gs-doorlocks:client:LoadData', source, Doors)
end)

---Event triggered from client when resources is re/started and player is logged in
RegisterNetEvent('gs-doorlocks:server:LoadData', function()
    TriggerClientEvent('gs-doorlocks:client:LoadData', source, Doors)
end)

---Create Door
---@param data table
---@param isExport boolean
RegisterNetEvent('gs-doorlocks:server:CreateDoor', function(data, isExport)
    local _source = source
    local User <const> = Core.getUser(_source)
    if not User then return end
    local Group <const> = User.getGroup

    if not IsPlayerAceAllowed(_source, Config.CreateDoor.Permission) and Group ~= Config.CreateDoor.Group then
        return
    end

    local insertId = MySQL.insert.await('INSERT INTO `gs_doorlocks` ( `name` ) VALUES ( ? )', { data.name })

    if insertId then
        local door = InitDoor(insertId, data)
        
        MySQL.update('UPDATE gs_doorlocks SET data = ? WHERE doorid = ?', {json.encode(door), insertId})

        Doors[insertId] = door

        TriggerClientEvent('gs-doorlocks:client:AddedDoor', -1, door)

        if isExport then
            TriggerClientEvent('gs-doorlocks:client:AddedDoorExport', _source, insertId)
        end

        Core.NotifyAvanced(_source, _('door_created'), 'BLIPS', 'blip_proc_home_locked', 'COLOR_GREEN', 1500)
    else

        if isExport then
            TriggerClientEvent('gs-doorlocks:client:AddedDoorExport', _source)
        end

        Core.NotifyAvanced(_source, _('failed_to_update'), 'BLIPS', 'blip_proc_home_locked', 'COLOR_RED', 1500)
    end
end)

---Delete Door
---@param doorid number
RegisterNetEvent('gs-doorlocks:server:DeleteDoor', function(doorid)
    local _source = source
    local User <const> = Core.getUser(_source)
    if not User then return end
    local Group <const> = User.getGroup

    if not IsPlayerAceAllowed(_source, Config.CreateDoor.Permission) and Group ~= Config.CreateDoor.Group then
        return
    end

    local door = Doors[doorid]

    if not door then
        Core.NotifyAvanced(_source, _('door_not_found'), 'BLIPS', 'blip_proc_home_locked', 'COLOR_RED', 1500)
        return
    end

    MySQL.update('DELETE FROM gs_doorlocks WHERE doorid = ?', {doorid},
    function(records)
        if records > 0 then
            Doors[doorid] = nil
            TriggerClientEvent('gs-doorlocks:client:DeletedDoor', -1, doorid)
            Core.NotifyAvanced(_source, _('door_deleted'), 'BLIPS', 'blip_proc_home_locked', 'COLOR_GREEN', 1500)
        else
            Core.NotifyAvanced(_source, _('failed_to_update'), 'BLIPS', 'blip_proc_home_locked', 'COLOR_RED', 1500)
        end
    end)
    
end)

---Update Door
---@param data table
RegisterNetEvent('gs-doorlocks:server:UpdateDoor', function(data)
    local _source = source
    local User <const> = Core.getUser(_source)
    if not User then return end
    local Group <const> = User.getGroup

    if not IsPlayerAceAllowed(_source, Config.CreateDoor.Permission) and Group ~= Config.CreateDoor.Group then
        return
    end

    local door = Doors[data.doorid]

    if not door then
        Core.NotifyAvanced(_source, _('door_not_found'), 'BLIPS', 'blip_proc_home_locked', 'COLOR_RED', 1500)
        return
    end 

    door.name = data.name
    door.jobAccess = data.jobAccess
    door.charAccess = data.charAccess
    door.lockedOnStart = data.lockedOnStart
    door.canLockpick = data.canLockpick
    door.showPrompt = data.showPrompt

    MySQL.update('UPDATE gs_doorlocks SET data = ? WHERE doorid = ?', {json.encode(door), data.doorid},
    function(records)
        if records > 0 then
            TriggerClientEvent('gs-doorlocks:client:UpdatedDoor', -1, door)
            Core.NotifyAvanced(_source, _('door_updated'), 'BLIPS', 'blip_proc_home_locked', 'COLOR_GREEN', 1500)
        else
            Core.NotifyAvanced(_source, _('failed_to_update'), 'BLIPS', 'blip_proc_home_locked', 'COLOR_RED', 1500)
        end
    end)
end)

RegisterNetEvent('gs-doorlocks:server:ToggleDoorStatus', function(doorid, status, lockpick)
    local _source = source
    local User <const> = Core.getUser(_source)
    if not User then return end

    local Character <const> = User.getUsedCharacter
    if not Character then return end

    local Group <const> = User.getGroup
    local Job <const> = Character.job
    local JobGrade <const> = Character.jobGrade

    local door = Doors[doorid]

    if not door then return end

    local CanAccess = false

    if lockpick and door.canLockpick then
        if Config.Lockpick.remove then
            if exports.vorp_inventory:subItemById(_source, lockpick, nil, true, 1) then
                CanAccess = true
                Core.NotifyAvanced(_source, _('lockpick_removed'), 'itemtype_textures', 'itemtype_all', 'COLOR_RED', 1500)
            end
        else
            CanAccess = exports.vorp_inventory:getItemById(_source, lockpick) or false
        end
    end

    if not CanAccess and door.jobAccess[Job] and door.jobAccess[Job] <= JobGrade then
        CanAccess = true
        DevPrint('Job Access', Job, 'Door', doorid)
    end

    if not CanAccess and #door.charAccess > 0 and U.table.contains(door.charAccess, Character.charIdentifier) then
        CanAccess = true
        DevPrint('Character Access', Character.charIdentifier, 'Door', doorid)
    end

    if not CanAccess and Config.OpenAllDoors.Enabled then
        if IsPlayerAceAllowed(_source, Config.OpenAllDoors.Permission) or Group == Config.OpenAllDoors.Group then
            CanAccess = true
            if Config.OpenAllDoors.ConsoleLog then
                print('Player', _source, 'Opened/Closed Door', doorid, 'With OpenAllDoors')
            end
        end
    end

    if not CanAccess then return end

    UpdateDoor(doorid, 'locked', status)

    if door.locked then
        Core.NotifyAvanced(_source, _('locked'), 'BLIPS', 'blip_proc_home_locked', 'COLOR_RED', 1500)
    else
        Core.NotifyAvanced(_source, _('unlocked'), 'BLIPS', 'blip_proc_home_locked', 'COLOR_GREEN', 1500)  
    end
end)

---Lockpick Door
---@param doorid number
RegisterNetEvent('gs-doorlocks:server:LockpickDoor', function(doorid)
    local _source = source
    local User <const> = Core.getUser(_source)
    if not User then return end

    local Character <const> = User.getUsedCharacter
    if not Character then return end

    local door = Doors[doorid]

    if not door then return end
    if not Config.Lockpick.itemName or Config.Lockpick.itemName == '' then return end
    if not door.canLockpick then return end
    if not door.locked then return end

    local lockpick = exports.vorp_inventory:getItemByName(_source, Config.Lockpick.itemName)

    if lockpick then
        TriggerClientEvent('gs-doorlocks:client:LockpickDoor', _source, doorid, lockpick.id)
    else
        Core.NotifyAvanced(_source, _('no_lockpick'), 'BLIPS', 'blip_proc_home_locked', 'COLOR_RED', 1500)
    end
end)

---Lockpick Failed & Remove Item
---@param itemId number
RegisterNetEvent('gs-doorlocks:server:RemoveItem', function(itemId)
    local _source = source
    if not itemId then return end
    if exports.vorp_inventory:subItemById(_source, itemId, nil, true, 1) then
        Core.NotifyAvanced(_source, _('lockpick_removed'), 'itemtype_textures', 'itemtype_all', 'COLOR_RED', 1500)
    end
end)

if Config.CreateDoor.Enabled then
    RegisterCommand(Config.CreateDoor.Command, function(source, args)
        local hasPermission = false

        local User <const> = Core.getUser(source)
        if not User then return end
        local Group <const> = User.getGroup
        
        if IsPlayerAceAllowed(source, Config.CreateDoor.Permission) then
            hasPermission = true
        end

        if Group == Config.CreateDoor.Group then
            hasPermission = true
        end

        if not hasPermission then
            return
        end

        TriggerClientEvent('gs-doorlocks:client:CreateDoor', source)
    end)
end

if Config.EditDoor.Enabled then
    RegisterCommand(Config.EditDoor.Command, function(source, args)
        local hasPermission = false

        local User <const> = Core.getUser(source)
        if not User then return end
        local Group <const> = User.getGroup
        
        if IsPlayerAceAllowed(source, Config.EditDoor.Permission) then
            hasPermission = true
        end

        if Group == Config.EditDoor.Group then
            hasPermission = true
        end

        if not hasPermission then
            return
        end

        TriggerClientEvent('gs-doorlocks:client:EditDoor', source)
    end)
end