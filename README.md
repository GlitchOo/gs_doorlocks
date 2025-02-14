﻿# gs_doorlocks

An easy feature packed doorlock system for VORP/RedM.
No hashlist involved, as long as the door works within game, this resource will get that information for you upon creating the door.

Supports single and double doors

# Commands
/createdoor - Create a new door
  - Create single & double doors
  - Control what jobs and rank can access the lock
  - Control what characters via their characterIdentifier can access the lock
  - control what item is required to access the lock
  - Name your locks with custom names (which can be be used to grab locks via api)
  - Enable/Disable police notification when door is lockpicked
  - Enable/Disable the UIPrompt for the lock (You can use the /togglelock command to still toggle the door lock)
  - Enable/Disable whether or not the door is locked automatically on startup
  - Enable/Disable whether or not the lock can be lockpicked (with item configured)

/editdoor - Edit the closest door
  - Change the door's name
  - Edit job permissions
  - Edit character permissions
  - Change item requirement
  - Enable/Disable the UIPrompt for the lock (You can use the /togglelock command to still toggle the door lock)
  - Enable/Disable whether or not the door is locked automatically on startup
  - Enable/Disable whether or not the lock can be lockpicked (with item configured)
  - Enable/Disable police notification when door is lockpicked
  - Delete the door

/togglelock - Toggle the closest doorlock (This will allow you to open doors with hidden UIPrompts)

[Create Double Door](https://uploads.nbrp.city/projects/gs-doorlocks/CreateDoubleDoor.mp4)

[Create Single Door](https://uploads.nbrp.city/projects/gs-doorlocks/CreateSingleDoor.mp4)

[Create Gate(s)](https://uploads.nbrp.city/projects/gs-doorlocks/Gates.mp4)

[Edit Door](https://uploads.nbrp.city/projects/gs-doorlocks/EditDoor.mp4)

[UIPrompt Interactions](https://uploads.nbrp.city/projects/gs-doorlocks/PromptInteraction.mp4)

[Lockpick Door](https://uploads.nbrp.city/projects/gs-doorlocks/LockpickDoor.mp4)

[ToogleLock Command](https://uploads.nbrp.city/projects/gs-doorlocks/toggledoor.mp4)

# API

### Client Side

CreateDoor | Opens the "create door" menu and returns the door ID when completed or nil when canceled
```
exports.gs_doorlocks:CreateDoor() 
```

GetDoorId | Returns the door id or nil if canceled (works great for existing doors that have already been created)
```
exports.gs_doorlocks:GetDoorId() 
```

ClosestDoor | Returns the closest door or nil if none
```
exports.gs_doorlocks:ClosestDoor()
```


## Server Side

GetAPI | Returns the doorlock class containing functions to easily update door locks
```
local DoorLocks = exports.gs_doorlocks:GetAPI()
```

Example of the API:
```
local DoorLocks = exports.gs_doorlocks:GetAPI()

-- Best method to return a door class. Requires no loop overhead
local Door = DoorLocks:Door(id:int) -- Returns the door class from door id

-- Not ideal but can also return a door by its door hash
local Door = DoorLocks:DoorByHash(id:int) -- Returns the door class from door hash

-- Never use this method unless you want to update multple doors with the same name (Eg. bank doors, shop doors)
local Door = DoorLocks:DoorsByName(name:str) -- Returns a table of door classes from the door name

-- With the returned door class you can trigger functions within the class or get the doors data

-- Data Class
Door.Data.doorid            -- Door ID (number)
Door.Data.name              -- Door Name (string)
Door.Data.locked            -- Door lock status (boolean)
Door.Data.coords            -- Door coords (vec3)
Door.Data.charAcces         -- Door character access table (table[])
Door.Data.jobAccess         -- Door job access table (table[])
Door.Data.canLockpick       -- Door lockpick permission (boolean)

-- Function Class
Door.fn.SetLock(true|false) -- Lock/Unlock Door
Door.fn.SetName(name:str) -- Set the locks name
Door.fn.SetLockOnStart(true|false) -- Enable/Disable automatic lock on startup
Door.fn.SetCanLockpick(true|false) -- Enable/Disable lockpick functionality
Door.fn.ShowUIPrompt(true|false) -- Enable/Disable UIPrompt when player is within range

-- Job Access / Permissions
Door.fn.SetJobAccess(access:table) -- Replaces the job access table. Eg. {'name1', 'name2', ...}
Door.fn.AddJob(name:str) -- Add a job name to existing table
Door.fn.RemoveJob(name:str) -- Remove a job name from existing table

-- Character Access / Permissions
Door.fn.SetCharAccess(access:table) -- Replaces the character access table. Eg. {1, 4, 2, ...}
Door.fn.AddChar(characterIdenntifer:int) -- Add a character to existing table
Door.fn.RemoveChar(characterIdenntifer:int) -- Remove a character from existing table

```

## Add Doors (Server Side)

```
local DoorLocks = exports.gs_doorlocks:GetAPI()

local doorid = DoorLocks:AddNewDoor({
  {
      name = 'Doctor Office Front',
      lockedOnStart = false,
      jobAccess = {
          ['ValDoctor'] = 0,
      },
      charAccess = {},
      itemNameAccess = false,
      canLockpick = false,
      alertLaw = false,
      showPrompt = true,
      door = {
          coords = vector3(-282.8079528808594, 803.954833984375, 118.39317321777344),
          hash = 3588026089,
          model = 'p_door62x',
      }
  }
})
```

## Update Doors (Server Side)

```
local DoorLocks = exports.gs_doorlocks:GetAPI()

local Door = DoorLocks:Door(10)

if Door then
    All values are optional, it will default to the settings already in place for the door
    Door.fn.Update({
        name = 'Door' -- (OPTIONAL)
        locked = true -- (OPTIONAL)
        coords = vec3(0, 0, 0) -- (OPTIONAL)
        charAccess = {} -- (OPTIONAL)
        jobAccess = {} -- (OPTIONAL)
        lockedOnStart = true -- (OPTIONAL)
        canLockpick = true -- (OPTIONAL)
        showPrompt = true -- (OPTIONAL)
    })
end
```

All updates and changes are updated too all clients in real time (no need to relog)


# Manually Configure Doors (On Startup)

You can manually configure doors via the config file following the format outline below
Note: Any changes made to the config will override the save innfo about he door to the database (based on the door hash)
```
{
    name = 'Door 1',                    -- Name of the door
    lockedOnStart = true,               -- Locked on start
    jobAccess = {                       -- Job access (VORP [name rank])
        ['ValSheriff '] = 0,
        ['RhoSheriff  '] = 0,
    },                                  
    charAccess = {                      -- Character access (VORP [characteridentifier])
        1, 3, 10
    },
    itemNameAccess = 'SheriffKeys',     -- Item name to access (false to disable)
    canLockpick = true,                 -- Can lockpick
    alertLaw = true,                    -- Alert law enforcement
    showPrompt = true                   -- Show prompt
    doors = {                           -- Double doors
        {
            coords = vector3(0.0, 0.0, 0.0), -- Door 1 coords
            hash = 0,                        -- Door 1 hash
            model = 'prop_door',             -- Door 1 model
        },
        {
            coords = vector3(0.0, 0.0, 0.0), -- Door 2 coords
            hash = 0,                        -- Door 2 hash
            model = 'prop_door',             -- Door 2 model
        },
    },
    door = {                            -- Single door
        coords = vector3(0.0, 0.0, 0.0), -- Door coords
        hash = 0,                        -- Door hash
        model = 'prop_door',             -- Door model
    },
},
```


# Events 


## Server-Side 

```
AddEventHandler('gs-doorlocks:Ready', function()
    -- Locks are loaded.. do some logic
end)
```

# Door Isnt Detected?

Doors are automatically detected by this resource without needing to have it added to some "hash list"
It just needs to have a propper ID assigned to it inside of the YMAP the door is located in. 
If it doesnt have an id then you can add one and stream the modified ymap on your server

```
<Item type="CExtensionDefScriptEntityId">
  <name>some_model_name</name>
  .....
  <Id>needs_an_id_here</Id>
</Item>
```
Once an ID has been defined inside of the ymap and streamed, it will work with this resource.


# Dependencies
While this resource was built around VORP it could be modified for any framework.

[Vorp Core](https://github.com/VORPCORE/vorp_core-lua)

[Vorp Inventory](https://github.com/VORPCORE/vorp_inventory-lua)

[Vorp Menu](https://github.com/VORPCORE/vorp_menu)

[Vorp Inputs](https://github.com/VORPCORE/vorp_inputs-lua)

Can be replaced with any skillcheck you prefer or disabled entirely

[lockpick by outsider31000](https://github.com/outsider31000/lockpick)

