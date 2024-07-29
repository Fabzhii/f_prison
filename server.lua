
local ox_inventory = exports.ox_inventory
local locales = Config.Locales[Config.Language]
local sabutaged = {}

Citizen.CreateThread(function()
    while true do 
        for k,v in pairs(Config.Locations) do 
            sabutaged[k] = {}
            if v.breakout  ~= nil then 
                if v.breakout.enabled then 
                    for o,i in pairs(v.breakout.breakPositions) do 
                        sabutaged[k][o] = false 
                    end 
                end 
            end 
        end 

        Citizen.Wait(10 * 60 * 1000)
    end 
end)

ESX.RegisterServerCallback('fprison:getPlayerState', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.fetchAll('SELECT * FROM users WHERE identifier = @identifier', {
        ['@identifier'] = xPlayer.identifier,
    }, function(data)
        cb(data[1].jail)
    end)
end)

ESX.RegisterCommand({Config.SendJail.command}, 'user', function(xPlayer, args, showError)
    local job = xPlayer.getJob().name
    for k,v in pairs(Config.SendJail.jobs) do 
        if v == job then 
            local players = {}
            for k,v in pairs(ESX.GetPlayers()) do 
                table.insert(players, {value = v, label = ESX.GetPlayerFromId(v).getName()})
            end 
            TriggerClientEvent('fprison:openJailMenu', xPlayer.source, players)
        end 
    end 
end, false, {help = locales['command_help'][1]})

ESX.RegisterCommand({Config.ReleaseJail.command}, 'user', function(xPlayer, args, showError)
    local job = xPlayer.getJob().name
    for k,v in pairs(Config.ReleaseJail.jobs) do 
        if v == job then 

            MySQL.Async.fetchAll('SELECT * FROM users', {
            }, function(data)
                local players = {}
                for k,v in pairs(ESX.GetPlayers()) do 
                    table.insert(players, {id = v, identifier = ESX.GetPlayerFromId(v).identifier})
                end 
                TriggerClientEvent('fprison:openUnJailMenu', xPlayer.source, players, data)
            end)
        end 
    end 
end, false, {help = locales['command_help'][1]})

RegisterServerEvent('fprison:arrest')
AddEventHandler('fprison:arrest', function(id, pos, time, teleport)
    TriggerClientEvent('fprison:arrestClient', id, pos, time, teleport)
end)

RegisterServerEvent('fprison:release')
AddEventHandler('fprison:release', function(id, pos)
    TriggerClientEvent('fprison:releaseClient', id, pos)
end)

RegisterServerEvent('fprison:notifyArrest')
AddEventHandler('fprison:notifyArrest', function(name, time, pos)
    if Config.Locations[pos].societyWork.enabled then 
        TriggerClientEvent('fprison:notify', -1, {(locales['society_work_notify'][1]):format(name, time), locales['society_work_notify'][2]})
    else 
        TriggerClientEvent('fprison:notify', -1, {(locales['arrest_notify'][1]):format(name, time), locales['arrest_notify'][2]})
    end 
end)

RegisterServerEvent('fprison:setSql')
AddEventHandler('fprison:setSql', function(pos, time)
    MySQL.Async.execute('UPDATE users SET jail = @jail WHERE identifier = @identifier', {
        ['@identifier']  = ESX.GetPlayerFromId(source).identifier,
        ['@jail'] = json.encode({position = pos, time = time}),
    })
end)

RegisterServerEvent('fprison:addItem')
AddEventHandler('fprison:addItem', function(item, count, metadata)
    exports.ox_inventory:AddItem(source, item, count, metadata)
end)

RegisterServerEvent('fprison:removeItem')
AddEventHandler('fprison:removeItem', function(item, count, metadata)
    exports.ox_inventory:RemoveItem(source, item, count, metadata)
end)

ESX.RegisterServerCallback('fprison:canCarryItem', function(source, cb, item, count, metadata)
    cb(exports.ox_inventory:CanCarryItem(source, item, count, metadata))
end)

ESX.RegisterServerCallback('fprison:getBreakState', function(source, cb, prison, pos)
    cb(sabutaged[prison][pos])
end)

RegisterServerEvent('fprison:sabotage')
AddEventHandler('fprison:sabotage', function(prison, pos)
    sabutaged[prison][pos] = true 
end)

Citizen.CreateThread(function()
    while true do 

        for k,v in pairs(Config.Locations) do 
            if v.breakout  ~= nil then 
                if v.breakout.enabled then 

                    local broken = true 

                    for o,i in pairs(v.breakout.breakPositions) do 
                        if sabutaged[k][o] == false then
                            broken = false 
                        end 
                    end 

                    if broken then 
                        brokenPrison(k)
                    end 
                end 
            end 
        end 

        Citizen.Wait(1000)
    end 
end)

function brokenPrison(prison)

    for o,i in pairs(Config.Locations[prison].breakout.breakPositions) do 
        sabutaged[prison][o] = false 
    end 

    for k,v in pairs(ESX.GetPlayers()) do 
        for o, i in pairs(Config.SendJail.jobs) do 
            if ESX.GetPlayerFromId(v).getJob().name == i then 
                TriggerClientEvent('fprison:notify', v, {(locales['prison_broken'][1]):format(Config.Locations[prison].name), locales['prison_broken'][2]})
            end 
        end 
    end 

    TriggerClientEvent('fprison:broken', -1, prison)

end 