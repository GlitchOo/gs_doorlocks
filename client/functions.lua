SelectionActive = false

--- Lockpicking minigame - https://github.com/outsider31000/lockpick
--- @param cb function
function LockpickGame(cb)
	local result = exports.lockpick:startLockpick(1)
	cb(result)
end

--- Animation that plays when player lockpicks a door
--- @param coords vector3
function LockpickAnimation(coords)
	local dict = 'mech_doors@locked@door_knob@generic@handle_l@hand_l@try_door'
	if not U.LoadDict(dict) then return end

	TaskTurnPedToFaceCoord(U.Cache.Ped, coords.x, coords.y, coords.z, -1)
	Wait(1000)

	TaskPlayAnim(U.Cache.Ped, dict, 'lockpick', 8.0, -8.0, -1, 1, 0, true, false, false)
	RemoveAnimDict(dict)
end

--- Animation that plays when player locks and unlocks a door
--- @param coords vector3
function LockAnimation(coords)
	local model = 'P_KEY02X'
	local dict = 'script_common@jail_cell@unlock@key'

	if not U.LoadDict(dict) then return end
	if not U.LoadModel(model) then return end

	TaskTurnPedToFaceCoord(U.Cache.Ped, coords.x, coords.y, coords.z, -1)
	Wait(1000)

	local prop = CreateObject(joaat(model), U.Cache.Coords.x, U.Cache.Coords.y, U.Cache.Coords.y - 1.0, true, true, true)

	TaskPlayAnim(U.Cache.Ped, dict, 'action', 8.0, -8.0, 2500, 31, 0, true, false, false)

	-- Wait for the animation to play then attach key as player is pulling their hand out of pocket
	Wait(750)
	local bone = GetEntityBoneIndexByName(U.Cache.Ped, 'SKEL_R_Finger12')
	AttachEntityToEntity(prop, U.Cache.Ped, bone, 0.02, 0.0120, -0.00850, 0.024, -160.0, 200.0, true, true, false, true, 1, true)
	
	Wait(2000)

	DeleteEntity(prop)
	ClearPedTasksImmediately(U.Cache.Ped)
	RemoveAnimDict(dict)
	SetModelAsNoLongerNeeded(model)
end

--- Draw a sprite on the screen
--- @param coords vector3
--- @param locked boolean
function DrawLock(coords, locked)
	local onScreen, screenX, screenY = GetScreenCoordFromWorldCoord(coords.x, coords.y, coords.z)

	if not onScreen then return end

	if locked then
		DrawSprite("generic_textures", "lock", screenX, screenY + 0.0125, 0.025, 0.04, 0.1, 100, 1, 1, 200)
	else
		DrawSprite("generic_textures", "lock", screenX, screenY + 0.0125, 0.025, 0.04, 0.1, 67, 160, 71, 200)
	end
end

--- Calculates the center point of the model
--- @param entity number
--- @param model number | nil
--- @return vector2
function CalculateModelCenterPoint(entity, model)
	-- If the model is not provided or is invalid, get the model from the entity
	if not model or not IsModelValid(model) then
		model = GetEntityModel(entity)
	end

	local minimum, maximum = GetModelDimensions(model)
                            
	local corners = {}
	-- Get the offset of 8 corners of the object in 3D space
	corners[1] = GetOffsetFromEntityInWorldCoords(entity, minimum.x, minimum.y, minimum.z).xy
	corners[2] = GetOffsetFromEntityInWorldCoords(entity, minimum.x, minimum.y, maximum.z).xy
	corners[3] = GetOffsetFromEntityInWorldCoords(entity, minimum.x, maximum.y, maximum.z).xy
	corners[4] = GetOffsetFromEntityInWorldCoords(entity, minimum.x, maximum.y, minimum.z).xy
	corners[5] = GetOffsetFromEntityInWorldCoords(entity, maximum.x, minimum.y, minimum.z).xy
	corners[6] = GetOffsetFromEntityInWorldCoords(entity, maximum.x, minimum.y, maximum.z).xy
	corners[7] = GetOffsetFromEntityInWorldCoords(entity, maximum.x, maximum.y, maximum.z).xy
	corners[8] = GetOffsetFromEntityInWorldCoords(entity, maximum.x, maximum.y, minimum.z).xy

	local center = vec2(0, 0)
	
	for i = 1, 8 do
		center += corners[i]
	end

	return center / 8
end

---Checks if an entity is a door
---@param entity number
---@return number | boolean
function IsDoor(entity)
	if not entity then return false end

	local doorid = DoorEnities[entity]

	if doorid and Doors[doorid] then
		return doorid
	end

	return false
end

--- comment Calculate the direction of a rotation
--- @param rotation vector3
--- @return table
local function RotationToDirection(rotation)
	local adjustedRotation = 
	{ 
		x = (math.pi / 180) * rotation.x, 
		y = (math.pi / 180) * rotation.y, 
		z = (math.pi / 180) * rotation.z 
	}
	local direction = 
	{
		x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)), 
		y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)), 
		z = math.sin(adjustedRotation.x)
	}
	return direction
end

--- Raycasts and shapetests from players cam position to "endpoint" to check if the player is at a valid entity
--- @return boolean
--- @return integer
function RayCastGamePlayCamera()
	local maxDist = 20.0 -- I think 10.0 meters is a good distance
	
	local cameraCoord = GetFinalRenderedCamCoord()
	local direction = RotationToDirection(GetFinalRenderedCamRot(2))
	local endCoords = {
        x = cameraCoord.x + direction.x * maxDist,
        y = cameraCoord.y + direction.y * maxDist,
        z = cameraCoord.z + direction.z * maxDist
    }

	local handle = StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, endCoords.x, endCoords.y, endCoords.z, 511, U.Cache.Ped, 4)
    local _, hit, _, _, _, entityHit = GetShapeTestResultIncludingMaterial(handle)

	return hit, entityHit
end

---Checks if a door is registered
---@param entity number
---@return number | boolean
function IsRegisteredDoor(entity)
	local HashToEntity = DoorSystemGetActive()

	for i = 1, #HashToEntity do
		if HashToEntity[i][2] == entity then
			return HashToEntity[i][1]
		end
	end

	return false
end

---Looks up the door hash in the door system table
---@param hash number
---@return number | boolean
function GetSytemDoorId(hash)
	for doorid, data in next, Doors do
		if data.doors then
			if data.doors[1].hash == hash or data.doors[2].hash == hash then
				return doorid
			end
		else
			if data.door.hash == hash then
				return doorid
			end
		end
	end

	return false
end

---Adds a door to the door system
---AddDoorToSystemNew Native https://rdr3natives.com/?_0xD99229FE93B46286
---@param hash number
---@param p1 boolean
---@param p2 boolean
---@param p3 boolean
---@param threadId number
---@param p5 number
---@param p6 boolean
function AddDoorToSystem(hash, p1, p2, p3, threadId, p5, p6)
	Citizen.InvokeNative(0xD99229FE93B46286, hash, p1, p2, p3, threadId, p5, p6)
end

---Sets the state of a door
---DoorSystemSetDoorState Native https://rdr3natives.com/?_0x6BAB9442830C7F53
---@param hash number
---@param state number
function DoorSystemSetDoorState(hash, state)
	Citizen.InvokeNative(0x6BAB9442830C7F53, hash, state)
end

---Starts the door creation process
---@param isDouble boolean
---@return any
function SelectDoorThread(isDouble)
	local SelectedDoor = nil
	local DoubleDoors = {}
	local PromptGroup = U.Prompts:SetupPromptGroup()
	local AddDoorPrompt = PromptGroup:RegisterPrompt(_('add_door'), Config.Keys.adddoor, false, true, false, 'click', {})
	local CancelDoorPrompt = PromptGroup:RegisterPrompt(_('cancel'), Config.Keys.cancel, true, true, false, 'click', {})

	while SelectionActive and not IsPedDeadOrDying(U.Cache.Ped, false) do
		Wait(5)
		
		PromptGroup:ShowGroup(_('doorlock'))

		if CancelDoorPrompt:HasCompleted() then
			SelectionActive = false
			SelectedDoor = nil
			Core.NotifyAvanced(_('canceled'), 'BLIPS', 'blip_proc_home_locked', 'COLOR_RED', 1500)
			break
		end

		if IsPlayerFreeAiming(U.Cache.PlayerId) then

			local retval, entity = RayCastGamePlayCamera()

			if retval then
				local model = GetEntityModel(entity)
				local isDoor = IsDoor(entity)
				local isRegistered = IsRegisteredDoor(entity)

				DevPrint('Entity:', entity, 'Model:', model, 'IsDoor:', isDoor, 'IsRegistered:', isRegistered)
				
				if not isDoor and not DoubleDoors[entity] and isRegistered then
					AddDoorPrompt:EnabledPrompt(true)

					if AddDoorPrompt:HasCompleted() then
						if not isDouble then

							SelectedDoor = {
								hash = isRegistered,
								model = GetEntityModel(entity),
								coords = GetEntityCoords(entity),
								heading = GetEntityHeading(entity)
							}

							break
						else
							DoubleDoors[entity] = true

							SelectedDoor = SelectedDoor or {}

							table.insert(SelectedDoor, {
								hash = isRegistered,
								model = GetEntityModel(entity),
								coords = GetEntityCoords(entity),
								heading = GetEntityHeading(entity)
							})

							if #SelectedDoor == 2 then
								break
							end
						end
						
					end
				else
					AddDoorPrompt:EnabledPrompt(false)
				end

			else
				AddDoorPrompt:EnabledPrompt(false)
			end
		else
			AddDoorPrompt:EnabledPrompt(false)
		end
	end

	SelectionActive = false

	AddDoorPrompt:DeletePrompt()

	DevPrint('IsDouble:', isDouble, 'Selected Door:', json.encode(SelectedDoor))

	if SelectedDoor then
		Core.NotifyAvanced(_('selected'), 'BLIPS', 'blip_proc_home_locked', 'COLOR_GREEN', 1500)
	end

	return SelectedDoor
end

---Starts the select door thread
---@return any
function SelectDoorIdThread()
	local SelectedDoor = nil
	local PromptGroup = U.Prompts:SetupPromptGroup()
	local AddDoorPrompt = PromptGroup:RegisterPrompt(_('select_door'), Config.Keys.adddoor, false, true, false, 'click', {})
	local CancelDoorPrompt = PromptGroup:RegisterPrompt(_('cancel'), Config.Keys.cancel, true, true, false, 'click', {})

	while not IsPedDeadOrDying(U.Cache.Ped, false) do
		Wait(5)
		
		PromptGroup:ShowGroup(_('doorlock'))

		if CancelDoorPrompt:HasCompleted() then
			SelectedDoor = nil
			Core.NotifyAvanced(_('canceled'), 'BLIPS', 'blip_proc_home_locked', 'COLOR_RED', 1500)
			break
		end

		local retval, entity = GetEntityPlayerIsFreeAimingAt(PlayerId())

		if retval then
			local isDoor = IsDoor(entity)

			if isDoor then
				AddDoorPrompt:EnabledPrompt(true)

				if AddDoorPrompt:HasCompleted() then
					local doorid = DoorEnities[entity]
					print('Selected DoorID:', doorid)
					SelectedDoor = doorid
					break
				end
			else
				AddDoorPrompt:EnabledPrompt(false)
			end

		else
			AddDoorPrompt:EnabledPrompt(false)
		end
	end

	AddDoorPrompt:DeletePrompt()

	if SelectedDoor then
		Core.NotifyAvanced(_('selected_id', SelectedDoor), 'BLIPS', 'blip_proc_home_locked', 'COLOR_GREEN', 1500)
	end

	return SelectedDoor
end

---Sets the door up in the door system
---@param data table
function SetupDoor(data)
	if data.doors then
		for i = 1, 2 do
			AddDoorToSystem(data.doors[i].hash, true, true, false, 0, 0, false)
			if data.locked then
				DoorSystemSetDoorState(data.doors[i].hash, 1)
				DoorSystemSetOpenRatio(data.doors[i].hash, 0, false, false)
			else
				DoorSystemSetDoorState(data.doors[i].hash, 0)
			end
		end
	else
		AddDoorToSystem(data.door.hash, true, true, false, 0, 0, false)
		if data.locked then
			DoorSystemSetDoorState(data.door.hash, 1)
			DoorSystemSetOpenRatio(data.door.hash, 0, false, false)
		else
			DoorSystemSetDoorState(data.door.hash, 0)
		end
	end
end

---Updates the state of a door
---@param doorid number
function UpdateDoorState(doorid)
	if not Doors[doorid] then return end

	local data = Doors[doorid]

	if data.doors then
		for i = 1, 2 do
			DoorSystemSetDoorState(data.doors[i].hash, data.locked and 1 or 0)
			if data.locked then
				DoorSystemSetOpenRatio(data.doors[i].hash, 0, false, false)
			end
		end
	else
		DoorSystemSetDoorState(data.door.hash, data.locked and 1 or 0)
		if data.locked then
			DoorSystemSetOpenRatio(data.door.hash, 0, false, false)
		end
	end
end

---Removes a door from the door system
---@param doorid number
function RemoveDoor(doorid)
	if not Doors[doorid] then return end

	local data = Doors[doorid]

	if data.doors then
		for i = 1, 2 do
			DoorSystemSetDoorState(data.doors[i].hash, 0)
			Wait(100) -- Wait for the door to be removed?
			RemoveDoorFromSystem(data.doors[i].hash)
		end
	else
		DoorSystemSetDoorState(data.door.hash, 0)
		Wait(100) -- Wait for the door to be removed?
		RemoveDoorFromSystem(data.door.hash)
	end
end