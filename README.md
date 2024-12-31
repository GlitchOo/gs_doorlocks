# gs_doorlocks

An easy feature packed doorlock system for VORP/RedM.
No hashlist involved, as long as the door works within game, this resource will get that information for you upon creating the door.
Client side statebags are used (non networked) to verify doors and prevent duplicate doors from getting created by accident. 

Supports single and double doors

# Commands
/createdoor - Create a new door
  - Create single & double doors
  - Control what jobs can access the lock
  - Control what characters via their characterIdentifier can access the lock
  - Name your locks with custom names (which can be be used to grab locks via api)
  - Enable/Disable the UIPrompt for the lock (You can use the /togglelock command to still toggle the door lock)
  - Enable/Disable whether or not the door is locked automatically on startup
  - Enable/Disable whether or not the lock can be lockpicked (with item configured)

/editdoor - Edit the closest door
  - Change the door's name
  - Edit job permissions
  - Edit character permissions
  - Enable/Disable the UIPrompt for the lock (You can use the /togglelock command to still toggle the door lock)
  - Enable/Disable whether or not the door is locked automatically on startup
  - Enable/Disable whether or not the lock can be lockpicked (with item configured)
  - Delete the door

[Example Video](https://uploads.nbrp.city/projects/gs-doorlocks/example.mp4)

# API

### Client Side

CreateDoor | Opens the "create door" mennu and returns the door ID when completed or nil when canceled
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

Theres various class functions to update locks
```
local DoorLocks = exports.gs_doorlocks:GetAPI()

local Door = DoorLocks:Door(id:int)

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
  

All updates and changes are updated too all clients in real time (no need to relog)

# Dependencies
While this resource was built around VORP it could be modified for any framework.

[Vorp Core](https://github.com/VORPCORE/vorp_core-lua)

[Vorp Inventory](https://github.com/VORPCORE/vorp_inventory-lua)

[Feather-Menu](https://github.com/FeatherFramework/feather-menu)

Can be replaced with any skillcheck you prefer or disabled entirely

[lockpick by outsider31000](https://github.com/outsider31000/lockpick)

