U.Cache.PlayerId = PlayerId()
U.Cache.PlayerServerId = GetPlayerServerId(U.Cache.PlayerId)
U.Cache.Ped = PlayerPedId()
U.Cache.Coords = GetEntityCoords(U.Cache.Ped)

CreateThread(function()
    while true do
        U.Cache.Ped = PlayerPedId()
        U.Cache.Coords = GetEntityCoords(U.Cache.Ped)
        Wait(100)
    end
end)