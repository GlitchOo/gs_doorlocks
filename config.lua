Config = {
    EnableDev = false, -- Enable/Disable Dev Mode

    Locale = 'en', -- Locale

    DoorDistance = 2.0, -- Distance to interact with doors

    EnableDrawSprite = true, -- Enable/Disable door sprites (Hidden when UIPrompt is hidden)

    Lockpick = {
        minigame = true, -- Enable/Disable lockpicking minigame client/functions.lua > LockpickGame()
        itemName = 'lockpick', -- Item name
        remove = false, -- Remove on use
        removeOnFail = true, -- Remove on fail
    },

    AlertJobs = { -- Alert jobs when a door is lockpicked
        AlertChance = 60, -- Chance to alert law enforcement (0-100) 100 = 100%
        AlertDistance = 500.0, -- Distance to alert law enforcement
        Jobs = { -- Jobs to alert
            'SDPolice',
            'ValSheriff',
            'RhoSheriff',
        },
        Notification = {
            title = 'Breakin Attempt',                          -- Notification title
            message = 'Someone is attempting to open a door',   -- Notification message
            dict = 'generic_textures',                          -- Notification texture dictionary
            icon = 'lock',                                      -- Notification icon
            color = 'COLOR_WHITE',                              -- Notification color
            duration = 8000,                                    -- Notification duration
        },
        Blip = {                                                -- Blip settings
            hash = -1282792512,                                 -- Blip hash
            radius = 5,                                         -- Blip radius
            duration = 60000,                                   -- Blip duration
        },
    },


    UnlockCommand = 'togglelock', -- Command to unlock a door (e.g. /unlock) allows doors to be unlocked when UIPrompt is hidden 
    
    UseIsControlJustReleased = false, -- Enable/Disable IsControlJustReleased for door interaction instead of UIPrompts

    OpenAllDoors = { -- Gives the ability to open all doors to a group or permission (Usually for staff only)
        Enabled = true, -- Enable/Disable opening all doors
        Permission = 'doorlocks.openall', -- Permission to open all doors
        Group = 'admin', -- Group to open all doors (VORP)
        ConsoleLog = true, -- Log to console when a door is opened by staff
    },

    CreateDoor = {
        Enabled = true, -- Enable/Disable door creation
        Command = 'createdoor', -- Command to create a door  (e.g. /createdoor)
        Permission = 'doorlocks.create', -- Permission to create a door
        Group = 'admin', -- Group to create a door (VORP)
    },

    EditDoor = {
        Enabled = true, -- Enable/Disable door editing
        Command = 'editdoor', -- Command to edit a door  (e.g. /editdoor)
        Permission = 'doorlocks.edit', -- Permission to edit a door
        Group = 'admin', -- Group to edit a door (VORP)
        DeleteConfirm = 'delete', -- Confirmation to delete a door
    },
    
    Keys = {
        adddoor = 0x17BEC168, -- E
        lock = 0x17BEC168, -- E 
        lockpick = 0x8CC9CD42, -- x
        edit = 0x760A9C6F, -- G
        cancel = 0x8CC9CD42, -- x
    },

    -- Manually add / configure doors here (Will update records in the database on server start)
    -- Note: It will NOT delete doors. You can do that manually in game using the /editdoor command
    Doors = {
        --{
        --    name = 'Door 1',                    -- Name of the door
        --    doorhash = 746387265,               -- Door hash (id)
        --    coords = vector3(0.0, 0.0, 0.0),    -- Door coords
        --    model = 'prop_door_01',             -- Door model
        --    locked = true,                      -- Locked on start
        --    jobAccess = {                       -- Job access (VORP [name rank])
        --        ['ValSheriff '] = 0,
        --        ['RhoSheriff  '] = 0,
        --    },                                  
        --    charAccess = {                      -- Character access (VORP [characteridentifier])
        --        1, 3, 10
        --    },
        --    itemNameAccess = 'SheriffKeys',     -- Item name to access (false to disable)
        --    canLockpick = true,                 -- Can lockpick
        --    showPrompt = true                   -- Show prompt
        --    alertLaw = true,                    -- Alert law enforcement
        --},
    }
}