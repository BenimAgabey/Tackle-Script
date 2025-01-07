-- server.lua

RegisterServerEvent('tackle:server')
AddEventHandler('tackle:server', function(targetPlayer)
    local src = source

    if targetPlayer then
        TriggerClientEvent('tackle:client', targetPlayer)
    end
end)