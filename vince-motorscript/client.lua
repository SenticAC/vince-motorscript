local Config = {
    spawnPoints = {
        vector3(-1043.3682, -854.8105, 4.8756)
    },
    model = "bati",
    cooldown = 10000,
    maxRange = 50.0
}

local ESX = nil
local lastSpawn = 0

Citizen.CreateThread(function()
    while not ESX do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(100)
    end
end)

RegisterCommand("motor", function()
    local player = PlayerPedId()
    local coords = GetEntityCoords(player)
    local currentTime = GetGameTimer()
    
    if currentTime - lastSpawn < Config.cooldown then
        local remaining = math.ceil((Config.cooldown - (currentTime - lastSpawn)) / 1000)
        exports["mythic_notify"]:SendAlert("error", "Wacht nog " .. remaining .. " seconden")
        return
    end
    
    local spawnPoint = nil
    for _, point in ipairs(Config.spawnPoints) do
        if #(coords - point) < Config.maxRange then
            spawnPoint = point
            break
        end
    end
    
    if not spawnPoint then
        exports["mythic_notify"]:SendAlert("error", "Je bent niet bij een spawnpunt")
        return
    end

    ESX.Game.SpawnVehicle(Config.model, spawnPoint, GetEntityHeading(player), function(vehicle)
        if DoesEntityExist(vehicle) then
            TaskWarpPedIntoVehicle(player, vehicle, -1)
            lastSpawn = currentTime
            exports['mythic_notify']:DoHudText('inform', 'Motor gespawned!')
        end
    end)
end, false)
