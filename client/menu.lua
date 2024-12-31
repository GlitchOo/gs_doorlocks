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

local LockMenu = Menu:RegisterMenu('gs-doorlocks:menu', {
    top = '20%',
    left = '20%',
    ['720width'] = '500px',
    ['1080width'] = '600px',
    ['2kwidth'] = '700px',
    ['4kwidth'] = '900px',
    style = {},
    font = {},
    contentslot = {
        style = {
            ['height'] = '400px',
            ['min-height'] = '400px'
        }
    },
    draggable = true,
}, {})

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

--- Opens the doorlock menu
--- @param fresh table | boolean
--- @param isExport boolean
function OpenLockMenu(fresh, isExport)
    LockMenu:Close()

    if type(fresh) == 'table' then
        Editing = true
        Data = fresh
    elseif fresh == true then
        Editing = false
        IsExport = isExport
        ResetData()
    end

    local MainPage = LockMenu:RegisterPage('main:page')

    MainPage:RegisterElement('header', {
        value = _('new_edit'),
        slot = "header",
        style = {}
    })

    MainPage:RegisterElement('line', {
        slot = "header",
    })

    MainPage:RegisterElement('input', {
        label = _('name'),
        placeholder = _('door_name'),
        persist = true,
        value = Data.name
    }, function(data)
        Data.name = data.value
    end)

    MainPage:RegisterElement('button', {
        label = _('lockperms'),
        style = {}
    }, function()
        PermissionsMenu()
    end)

    MainPage:RegisterElement('button', {
        label = _('job_lockperms'),
        style = {}
    }, function()
        PermissionsJobMenu()
    end)

    MainPage:RegisterElement("checkbox", {
        label = _('locked_on_start'),
        start = Data.lockedOnStart
    }, function(data)
        Data.lockedOnStart = data.value
        DevPrint('Locked On Start:', Data.lockedOnStart)
    end)

    MainPage:RegisterElement("checkbox", {
        label = _('lockpickable'),
        start = Data.canLockpick
    }, function(data)
        Data.canLockpick = data.value
        DevPrint('Can Lockpick:', Data.canLockpick)
    end)

    if not Editing then
        MainPage:RegisterElement("checkbox", {
            label = _('is_double'),
            start = Data.isDouble
        }, function(data)
            Data.isDouble = data.value
            DevPrint('Is Double:', Data.isDouble)
        end)
    end

    MainPage:RegisterElement("checkbox", {
        label = _('show_prompt'),
        start = Data.showPrompt
    }, function(data)
        Data.showPrompt = data.value
        DevPrint('Show Prompt:', Data.showPrompt)
    end)


    MainPage:RegisterElement('line', {
        slot = "footer",
    })
    
    if not Editing then
        MainPage:RegisterElement('button', {
            label = _('select_door_save'),
            slot = "footer",
            style = {}
        }, function()
            SelectionActive = true

            LockMenu:Close()

            Data.door = SelectDoorThread(Data.isDouble) or {}

            if next(Data.door) then
                DevPrint('Saving Data', json.encode(Data, {indent = true}))
                TriggerServerEvent('gs-doorlocks:server:CreateDoor', Data, IsExport)
                ResetData()
            else
                DevPrint('No Door Selected')
                OpenLockMenu()
            end
        end)
    else
        MainPage:RegisterElement('button', {
            label = _('update_door'),
            slot = "footer",
            style = {}
        }, function()
            LockMenu:Close()
            DevPrint('Updating Data', json.encode(Data, {indent = true}))
            TriggerServerEvent('gs-doorlocks:server:UpdateDoor', Data)
            ResetData()
        end)

        MainPage:RegisterElement('button', {
            label = _('delete_door'),
            slot = "footer",
            style = {
                ['background-color'] = 'red'
            }
        }, function()
            LockMenu:Close()
            DevPrint('Deleting Data', json.encode(Data, {indent = true}))
            TriggerServerEvent('gs-doorlocks:server:DeleteDoor', Data.doorid)
            ResetData()
        end)
    end

    MainPage:RegisterElement('button', {
        label = _('cancel'),
        slot = "footer",
        style = {
            ['background-color'] = 'red'
        }
    }, function()
        LockMenu:Close()
        ResetData()
    end)

    MainPage:RegisterElement('line', {
        slot = "footer",
    })

    LockMenu:Open({
        startupPage = MainPage
    })
end

function PermissionsMenu()
    local PermsPage = LockMenu:RegisterPage('perms:page')

    PermsPage:RegisterElement('header', {
        value = _('lockperms'),
        slot = "header",
        style = {}
    })

    PermsPage:RegisterElement('line', {
        slot = "header",
    })

    for k, v in next, Data.charAccess do
        PermsPage:RegisterElement('button', {
            label = v,
        }, function()
            DevPrint('Removing Permission:', v)
            table.remove(Data.charAccess, k)
            PermissionsMenu()
        end)
    end


    PermsPage:RegisterElement('line', {
        slot = "footer",
    })

    PermsPage:RegisterElement('button', {
        label = _('clear'),
        slot = "footer",
        style = {
            ['background-color'] = 'red'
        }
    }, function()
        Data.charAccess = {}
        PermissionsMenu()
    end)

    PermsPage:RegisterElement('button', {
        label = _('add'),
        slot = "footer",
        style = {}
    }, function()
        OpenAddPermMenu()
    end)

    PermsPage:RegisterElement('button', {
        label = _('return'),
        slot = "footer",
        style = {}
    }, function()
        OpenLockMenu()
    end)

    PermsPage:RegisterElement('line', {
        slot = "footer",
    })

    LockMenu:Open({
        startupPage = PermsPage
    })
end

function OpenAddPermMenu()
    local AddPermPage = LockMenu:RegisterPage('addperm:page')

    local perm = 0

    AddPermPage:RegisterElement('header', {
        value = _('add_perm'),
        slot = "header",
        style = {}
    })

    AddPermPage:RegisterElement('line', {
        slot = "header",
    })

    AddPermPage:RegisterElement('input', {
        label = _('permission'),
        placeholder = _('permission_desc'),
        persist = true,
    }, function(data)
        perm = tonumber(data.value)
    end)

    AddPermPage:RegisterElement('line', {
        slot = "footer",
    })

    AddPermPage:RegisterElement('button', {
        label = _('add'),
        slot = "footer",
        style = {}
    }, function()
        if perm and perm ~= 0 then
            DevPrint('Adding Permission:', perm)
            table.insert(Data.charAccess, perm)
        else
            DevPrint('No Permission Entered')
        end

        PermissionsMenu()
    end)

    AddPermPage:RegisterElement('button', {
        label = _('cancel'),
        slot = "footer",
        style = {}
    }, function()
        PermissionsMenu()
    end)

    AddPermPage:RegisterElement('line', {
        slot = "footer",
    })

    LockMenu:Open({
        startupPage = AddPermPage
    })
end

function PermissionsJobMenu()
    local PermsPage = LockMenu:RegisterPage('jobperms:page')

    PermsPage:RegisterElement('header', {
        value = _('job_lockperms'),
        slot = "header",
        style = {}
    })

    PermsPage:RegisterElement('line', {
        slot = "header",
    })

    for k, v in next, Data.jobAccess do
        PermsPage:RegisterElement('button', {
            label = v,
        }, function()
            DevPrint('Removing Permission:', v)
            table.remove(Data.jobAccess, k)
            PermissionsJobMenu()
        end)
    end

    PermsPage:RegisterElement('line', {
        slot = "footer",
    })

    PermsPage:RegisterElement('button', {
        label = _('clear'),
        slot = "footer",
        style = {
            ['background-color'] = 'red'
        }
    }, function()
        Data.jobAccess = {}
        PermissionsMenu()
    end)

    PermsPage:RegisterElement('button', {
        label = _('add'),
        slot = "footer",
        style = {}
    }, function()
        OpenAddJobPermMenu()
    end)

    PermsPage:RegisterElement('button', {
        label = _('return'),
        slot = "footer",
        style = {}
    }, function()
        OpenLockMenu()
    end)

    PermsPage:RegisterElement('line', {
        slot = "footer",
    })

    LockMenu:Open({
        startupPage = PermsPage
    })
end

function OpenAddJobPermMenu()
    local AddPermPage = LockMenu:RegisterPage('addjobperm:page')

    local perm = ''

    AddPermPage:RegisterElement('header', {
        value = _('add_job_perm'),
        slot = "header",
        style = {}
    })

    AddPermPage:RegisterElement('line', {
        slot = "header",
    })

    AddPermPage:RegisterElement('input', {
        label = _('job_permission'),
        placeholder = _('job_permission_desc'),
        persist = true,
    }, function(data)
        perm = data.value
    end)

    AddPermPage:RegisterElement('line', {
        slot = "footer",
    })

    AddPermPage:RegisterElement('button', {
        label = _('add'),
        slot = "footer",
        style = {}
    }, function()
        if perm ~= '' then
            DevPrint('Adding Permission:', perm)
            table.insert(Data.jobAccess, perm)
        else
            DevPrint('No Permission Entered')
        end

        PermissionsJobMenu()
    end)

    AddPermPage:RegisterElement('button', {
        label = _('cancel'),
        slot = "footer",
        style = {}
    }, function()
        PermissionsJobMenu()
    end)

    AddPermPage:RegisterElement('line', {
        slot = "footer",
    })

    LockMenu:Open({
        startupPage = AddPermPage
    })
end

AddEventHandler('onResourceStop', function(resource)
    if resource ~= U.Cache.Resource then return end
    LockMenu:Close()
end)