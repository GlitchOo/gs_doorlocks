---Loads an animation dictionary into memory
---@param dict string
---@param time number | nil
---@return boolean
local function LoadDict(dict, time)
    RequestAnimDict(dict)

    local timeout = GetGameTimer() + (time or 5000)

    while not HasAnimDictLoaded(dict) do
        if GetGameTimer() > timeout then
            print('Failed to load animation dictionary', dict)
            return false
        end

        Wait(100)
    end

    return true
end

---Loads a model into memory
---@param model string
---@param time number | nil
---@return boolean
local function LoadModel(model, time)
    RequestModel(model)

    local timeout = GetGameTimer() + (time or 5000)

    while not HasModelLoaded(model) do
        if GetGameTimer() > timeout then
            print('Failed to load model', model)
            return false
        end

        Wait(100)
    end

    return true
end

U.LoadDict = LoadDict
U.LoadModel = LoadModel
