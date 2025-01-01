local Editing = false
local IsExport = false
local Data = {
    name = 'Door',
    charAccess = {},
    jobAccess = {},
    lockedOnStart = true,
    canLockpick = false,
    isDouble = false,
    showPrompt = true,
    door = {},
}

--- Resets the global data table
function ResetData()
    Data = {
        name = 'Door',
        charAccess = {},
        jobAccess = {},
        lockedOnStart = true,
        canLockpick = false,
        isDouble = false,
        showPrompt = true,
        door = {},
    }
end

function MainMenuDescription(label)
    return ([[
        <div style="padding: 2px;">
            <p>%s</p>
        </div>

        <div style="padding: 2px;">
            <table style="width: 100%%; color: white; margin-left: 5%%; margin-right: 10%%">
                <tr>
                    <th style='text-align: left;'>%s</th>
                    <td style='text-align: center;'>%s</td>
                </tr>
                <tr>
                    <th style='text-align: left;'>%s</th>
                    <td style='text-align: center;'>%s</td>
                </tr>
                <tr>
                    <th style='text-align: left;'>%s</th>
                    <td style='text-align: center;'>%s</td>
                </tr>
                <tr>
                    <th style='text-align: left;'>%s</th>
                    <td style='text-align: center;'>%s</td> 
                </tr>
                <tr>
                    <th style='text-align: left;'>%s</th>
                    <td style='text-align: center;'>%s</td>
                </tr>
                <tr>
                    <th style='text-align: left;'>%s</th>
                    <td style='text-align: center;'>%s</td>
                </tr>
                <tr>
                    <th style='text-align: left;'>%s</th>
                    <td style='text-align: center;'>%s</td>
                </tr>
            </table>
        </div>
    ]]):format(
        label, 
        _('doorid'), Data.doorid or _('none'),
        _('door_name'), Data.name, 
        _('locked_on_start'), Data.lockedOnStart and _('yes') or _('no'),
        _('lockpickable'), Data.canLockpick and _('yes') or _('no'),
        _('show_prompt'), Data.showPrompt and _('yes') or _('no'),
        _('lockperms'), #Data.charAccess > 0 and table.concat(Data.charAccess, ', ') or _('none'),
        _('job_lockperms'), #Data.jobAccess > 0 and table.concat(Data.jobAccess, ', ') or _('none')
    )
end

--- Opens the doorlock menu
--- @param fresh table | boolean | nil
--- @param isExport boolean | nil
function OpenLockMenu(fresh, isExport)
    MenuData.CloseAll()

    -- Hide the radar
    DisplayRadar(false)

    if type(fresh) == 'table' then
        Editing = true
        Data = fresh
    elseif fresh == true then
        Editing = false
        IsExport = isExport or false
        ResetData()
    end

    MenuData.CloseAll()

    local CustomLabel = '%s <span style="float: right; position: relative; right: 5vh; top: 3px;"><i class="%s"></i></span>'
    local Check = 'fas fa-square-check'
    local Uncheck = 'fas fa-square'

    MenuElements = {
        {
            labelText = _('door_name'),
            label = _('door_name'),
            value = "name",
            descText = _('door_name_desc'),
            desc = MainMenuDescription(_('door_name_desc')),
            input = {
                type = "enableinput",
                inputType = "input",
                button = _('confirm'),
                style = "block",
                attributes = {
                    type = "text",
                    inputHeader = _('door_name_desc'),
                    value = Data.name,
                    pattern = ".*",
                    style = "border-radius: 10px; background-color: ; border:none;"
                }
            }
        },
        {
            labelText = _('lockperms'),
            label = _('lockperms'),
            value = "charAccess",
            descText = _('permission_desc'),
            menu = "Perms",
            desc = MainMenuDescription(_('permission_desc'))
        },
        {
            labelText = _('job_lockperms'),
            label = _('job_lockperms'),
            value = "jobAccess",
            descText = _('job_permission_desc'),
            menu = "JobPerms",
            desc = MainMenuDescription(_('job_permission_desc'))
        },
        {
            labelText = _('locked_on_start'),
            label = CustomLabel:format(_('locked_on_start'), (Data.lockedOnStart and Check or Uncheck)),
            value = "lockedOnStart",
            descText = _('locked_on_start_desc'),
            toggle = true,
            desc = MainMenuDescription(_('locked_on_start_desc'))
        },
        {
            labelText = _('lockpickable'),
            label = CustomLabel:format(_('lockpickable'), (Data.canLockpick and Check or Uncheck)),
            value = "canLockpick",
            descText = _('lockpickable_desc'),
            toggle = true,
            desc = MainMenuDescription(_('lockpickable_desc'))
        },
        {
            labelText = _('show_prompt'),
            label = CustomLabel:format(_('show_prompt'), (Data.showPrompt and Check or Uncheck)),
            value = "showPrompt",
            toggle = true,
            descText = _('show_prompt_desc'),
            desc = MainMenuDescription(_('show_prompt_desc'))
        }
    }

    if not Editing then
        table.insert(MenuElements, {
            labelText = _('is_double'),
            label = CustomLabel:format(_('is_double'), (Data.isDouble and Check or Uncheck)),
            value = "isDouble",
            descText = _('is_double_desc'),
            toggle = true,
            desc = MainMenuDescription(_('is_double_desc'))
        })

        table.insert(MenuElements, {
            labelText = _('select_door_save'),
            label = _('select_door_save'),
            value = "SetupDoor",
            descText = _('select_door_save_desc'),
            desc = MainMenuDescription(_('select_door_save_desc'))
        })
    else
        table.insert(MenuElements, {
            labelText = _('update_door'),
            label = _('update_door'),
            value = "save",
            descText = _('update_door_desc'),
            desc = MainMenuDescription(_('update_door_desc'))
        })

        table.insert(MenuElements, {
            labelText = _('delete_door'),
            label = _('delete_door'),
            value = "delete",
            descText = _('delete_door_desc'),
            desc = MainMenuDescription(_('delete_door_desc')),
            confirm = {
                type = "enableinput",
                inputType = "input",
                button = _('confirm'),
                style = "block",
                attributes = {
                    type = "text",
                    inputHeader  = _('delete_door_confirm', Config.EditDoor.DeleteConfirm),
                    pattern = ".*",
                    style = "border-radius: 10px; background-color: ; border:none;"
                }
            }
        })
    end

    MenuData.Open("default",GetCurrentResourceName(),"OpenMenu",
        {
            title = _('doorlock'), 
            subtext = _('new_edit'),
            align = "align",
            elements = MenuElements,
            itemHeight = "2vh",
        },

        function(data, menu)
            if (data.current == "backup") then
                return  _G[data.trigger](any,any)
            end
            
            -- Input Values 
            if data.current.input then
                local result = exports.vorp_inputs:advancedInput(data.current.input)
                if result and result ~= '' then

                    Data[data.current.value] = result

                    for k, v in next, data.elements do
                        menu.setElement(k, "desc", MainMenuDescription(v.descText))
                    end

                    menu.refresh()
                end
            end

            -- Toggle Values
            if data.current.toggle then
                Data[data.current.value] = not Data[data.current.value]

                for k, v in next, data.elements do
                    if v.toggle then
                        menu.setElement(k, "label", CustomLabel:format(v.labelText, (Data[v.value] and Check or Uncheck)))
                    end
                    menu.setElement(k, "desc", MainMenuDescription(v.descText))
                end

                menu.refresh()
            end

            if data.current.menu then
                return _G[data.current.menu]()
            end

            if data.current.value == 'SetupDoor' then
                menu.close()

                SelectionActive = true

                Data.door = SelectDoorThread(Data.isDouble) or {}

                if next(Data.door) then
                    DevPrint('Saving Data', json.encode(Data, {indent = true}))
                    TriggerServerEvent('gs-doorlocks:server:CreateDoor', Data, IsExport)
                    ResetData()
                else
                    DevPrint('No Door Selected')
                    OpenLockMenu()
                end
            end

            if data.current.value == 'save' then
                menu.close()
                DevPrint('Updating Data', json.encode(Data, {indent = true}))
                TriggerServerEvent('gs-doorlocks:server:UpdateDoor', Data)
                ResetData()
            end

            if data.current.value == 'delete' then
                -- Confirm Input to prevent any accidental deletions

                local result = exports.vorp_inputs:advancedInput(data.current.confirm)
                if result == Config.EditDoor.DeleteConfirm then
                    menu.close()
                    DevPrint('Deleting Data', json.encode(Data, {indent = true}))
                    TriggerServerEvent('gs-doorlocks:server:DeleteDoor', Data.doorid)
                    ResetData()
                end
            end
            
        end,function(data, menu)
            menu.close()
            -- Show the radar again
            DisplayRadar(true)
        end
    )
end


function Perms()
    MenuData.CloseAll()

    local CustomLabel = '%s <span style="float: right; position: relative; right: 5vh; top: 3px; color: red;"><i class="fas fa-trash"></i></span>'

    local MenuElements = {}

    for k, v in next, Data.charAccess do
        table.insert(MenuElements, {
            label = CustomLabel:format(v),
            value = 'remove',
            index = k,
            desc = ('remove_access'):format(v),
        })
    end

    table.insert(MenuElements, {
        label = _('add'),
        value = 'add',
        desc = _('add_perm'),
        input = {
            type = "enableinput",
            inputType = "input",
            placeholder = "0",
            button = _('confirm'),
            style = "block",
            attributes = {
                type = "number",
                inputHeader = _('permission'),
                pattern = "[0-9]",
                style = "border-radius: 10px; background-color: ; border:none;"
            }
        }
    })

    table.insert(MenuElements, {
        label = _('clear'),
        value = 'clear',
        desc = _('clear_desc'),
    })

    MenuData.Open("default",GetCurrentResourceName(),"OpenPermsMenu",
        {
            title = _('lockperms'),
            subtext = _('add_perm'),
            align = "align",
            elements = MenuElements,
            itemHeight = "2vh",
            lastmenu = "OpenLockMenu",
        },

        function(data, menu)
            if (data.current == "backup") then 
                return _G[data.trigger]()
            end

            if data.current.value == 'clear' then
                Data.charAccess = {}
                Perms()
            end

            if data.current.input then
                local result = exports.vorp_inputs:advancedInput(data.current.input)
                result = tonumber(result)
                if result and result ~= 0 then
                    table.insert(Data.charAccess, result)
                    Perms()
                end
            end

            if data.current.value == 'remove' then
                table.remove(Data.charAccess, data.current.index)
                Perms()
            end
            
        end,function(data, menu)
            OpenLockMenu()
        end
    )
end

function JobPerms()
    MenuData.CloseAll()

    local CustomLabel = '%s <span style="float: right; position: relative; right: 5vh; top: 3px; color: red;"><i class="fas fa-trash"></i></span>'

    local MenuElements = {}

    for k, v in next, Data.jobAccess do
        table.insert(MenuElements, {
            label = CustomLabel:format(v),
            value = 'remove',
            index = k,
            desc = ('remove_access'):format(v),
        })
    end

    table.insert(MenuElements, {
        label = _('add'),
        value = 'add',
        desc = _('add_job_perm'),
        input = {
            type = "enableinput",
            inputType = "input",
            placeholder = "sheriff",
            button = _('confirm'),
            style = "block",
            attributes = {
                type = "text",
                inputHeader = _('job_permission'),
                pattern = ".*",
                style = "border-radius: 10px; background-color: ; border:none;"
            }
        }
    })

    table.insert(MenuElements, {
        label = _('clear'),
        value = 'clear',
        desc = _('clear_desc'),
    })

    MenuData.Open("default",GetCurrentResourceName(),"OpenJobPermsMenu",
        {
            title = _('job_lockperms'),
            subtext = _('add_job_perm'),
            align = "align",
            elements = MenuElements,
            itemHeight = "2vh",
            lastmenu = "OpenLockMenu",
        },

        function(data, menu)
            if (data.current == "backup") then 
                return _G[data.trigger]()
            end

            if data.current.value == 'clear' then
                Data.jobAccess = {}
                JobPerms()
            end

            if data.current.input then
                local result = exports.vorp_inputs:advancedInput(data.current.input)
                if result and result ~= '' then
                    table.insert(Data.jobAccess, result)
                    JobPerms()
                end
            end

            if data.current.value == 'remove' then
                table.remove(Data.jobAccess, data.current.index)
                JobPerms()
            end
            
        end,function(data, menu)
            OpenLockMenu()
        end
    )
end


AddEventHandler('onResourceStop', function(resource)
    if resource ~= U.Cache.Resource then return end
    MenuData.CloseAll()
end)