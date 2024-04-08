ESX = nil
local cooldown = 10 * 1000 
local lastSpawnTime = 0

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) 
            ESX = obj 
        end)
        Citizen.Wait(0)
    end
end)

local SpawnPunten = {
    vector3(-1043.3682, -854.8105, 4.8756), 
}

local VoertuigSpawner = {}
VoertuigSpawner.__index = VoertuigSpawner

function VoertuigSpawner.new(SpawnPunten)
    local self = setmetatable({}, VoertuigSpawner)
    self.SpawnPunten = SpawnPunten
    return self
end

function VoertuigSpawner:SpawnMotor(speler, spelercoords)
    local currentTime = GetGameTimer()
    local canSpawn = (currentTime - lastSpawnTime) >= cooldown
    local spawnPointGevonden = false

    for _, spawnPunt in next, (self.SpawnPunten) do
        local afstand = #(spelercoords - spawnPunt)
        if afstand < 50.0 then
            spawnPointGevonden = true
            if canSpawn then
                self:spawnVehicle(speler, spawnPunt)
                exports['mythic_notify']:DoHudText('inform',  'Je hebt een motor gespawned!')
                lastSpawnTime = currentTime
            else
                local remainingCooldown = math.ceil((lastSpawnTime + cooldown - currentTime) / 1000)
                exports["mythic_notify"]:SendAlert("error", "Je moet " .. remainingCooldown .. " seconden wachten om een nieuwe motor te spawnen")
            end
        end
    end

    if not spawnPointGevonden then
        exports["mythic_notify"]:SendAlert("error", "Je bent niet in de buurt van een spawnpoint")
    end
end

function VoertuigSpawner:spawnVehicle(speler, spawnPunt)
    local motorcycleModel = "bati"
    local heading = GetEntityHeading(speler)
    ESX.Game.SpawnVehicle(motorcycleModel, spawnPunt, heading, function(vehicle) 
        if DoesEntityExist(vehicle) then
            TaskWarpPedIntoVehicle(speler, vehicle, -1)
            lastSpawnTime = GetGameTimer()
        end
    end)
end

local voertuigSpawner = VoertuigSpawner.new(SpawnPunten)

RegisterCommand("motor", function()
    local speler = PlayerPedId()
    local spelercoords = GetEntityCoords(speler)
    voertuigSpawner:SpawnMotor(speler, spelercoords)
end, false)
