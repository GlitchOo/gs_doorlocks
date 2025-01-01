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
    }   
}