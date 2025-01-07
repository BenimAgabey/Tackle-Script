-- client.lua

local isTackling = false

-- Keybind for tackling (E by default)
local TACKLE_KEY = 38 -- E key (you can change this)

-- Tackle Function
function tacklePlayer()
    if isTackling then return end

    local player = PlayerPedId()
    local target, distance = GetClosestPlayer()

    if target ~= -1 and distance < 2.0 then
        isTackling = true

        -- Play push animation for tackler
        RequestAnimDict("missmic4premiere") -- A known reliable push animation dict
        while not HasAnimDictLoaded("missmic4premiere") do
            Citizen.Wait(0)
        end

        TaskPlayAnim(player, "missmic4premiere", "prem_act_armaround_f_a", 8.0, 8.0, 1000, 0, 0, false, false, false)

        Citizen.Wait(500) -- Wait for animation to play

        -- Trigger tackle event for target
        TriggerServerEvent('tackle:server', GetPlayerServerId(target))
        
        -- Tackler goes ragdoll for 2 seconds
        SetPedToRagdoll(player, 2000, 2000, 0, 0, 0, 0)
        
        Citizen.Wait(2000) -- Prevent spamming the tackle
        isTackling = false
    end
end

-- Detect Key Press
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlJustReleased(0, TACKLE_KEY) and not isTackling and not IsPedInAnyVehicle(PlayerPedId(), false) then
            tacklePlayer()
        end
    end
end)

-- Get Closest Player
function GetClosestPlayer()
    local players = GetActivePlayers()
    local closestPlayer = -1
    local closestDistance = -1
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    for _, player in ipairs(players) do
        local targetPed = GetPlayerPed(player)
        if targetPed ~= playerPed then
            local targetCoords = GetEntityCoords(targetPed)
            local distance = #(playerCoords - targetCoords)
            if closestDistance == -1 or distance < closestDistance then
                closestPlayer = player
                closestDistance = distance
            end
        end
    end

    return closestPlayer, closestDistance
end

-- Handle being tackled
RegisterNetEvent('tackle:client')
AddEventHandler('tackle:client', function()
    local player = PlayerPedId()
    SetPedToRagdoll(player, 5000, 5000, 0, 0, 0, 0) -- Target ragdolls for 5 seconds
end)
