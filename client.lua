
local ox_inventory = exports.ox_inventory
local locales = Config.Locales[Config.Language]
local isLoaded = false 
local inPrison = false 
local inTime = 0
local inPos = 0
local isworking = false 
local prisonbreak = false 

Citizen.CreateThread(function()
    for k,v in pairs(Config.Locations) do 
        if v.showBlip then 

            blip = AddBlipForCoord(v.insidePosition)
            SetBlipSprite (blip, Config.Blip.id)
            SetBlipDisplay(blip, 4)
            SetBlipScale  (blip, Config.Blip.scale)
            SetBlipColour (blip, Config.Blip.color)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(v.name)
            EndTextCommandSetBlipName(blip)

        end 
    end 
end)

Citizen.CreateThread(function()
    while isLoaded == false do 
        Citizen.Wait(1000)
        local playerData = ESX.GetPlayerData()
        if ESX.IsPlayerLoaded(PlayerId) then 
            isLoaded = true
            loadPlayer()
        end
    end 
end)

function loadPlayer()
    ESX.TriggerServerCallback('fprison:getPlayerState', function(xState)
        xState = json.decode(xState)
        if xState.position ~= 0 and xState.time > 0 then 
            sendToJail(xState.position, xState.time, true)
        end 
    end)
end 


RegisterNetEvent('fprison:releaseClient')
AddEventHandler('fprison:releaseClient', function(pos)
    release(pos)
end)

RegisterNetEvent('fprison:arrestClient')
AddEventHandler('fprison:arrestClient', function(pos, time, teleport)
    sendToJail(pos, time, teleport)
end)

RegisterNetEvent('fprison:notify')
AddEventHandler('fprison:notify', function(notify)
    Config.Notifcation(notify)
end)

RegisterNetEvent('fprison:openJailMenu')
AddEventHandler('fprison:openJailMenu', function(xPlayers)

    local xJails = {}
    for k,v in pairs(Config.Locations) do 
        table.insert(xJails, {value = k, label = v.name})
    end 

    local input = lib.inputDialog(Config.SendJail.menu.header, {
        {type = 'select', label = Config.SendJail.menu.person, required = true, icon = 'user', options = xPlayers},
        {type = 'select', label = Config.SendJail.menu.position, required = true, icon = 'user', options = xJails},
        {type = 'number', label = Config.SendJail.menu.time, required = true, icon = 'user', min = 1, max = Config.SendJail.maxTime},
        {type = 'checkbox', label = Config.SendJail.menu.teleport, checked = false, icon = 'user'},
        {type = 'checkbox', label = Config.SendJail.menu.notify, checked = true, icon = 'user'},
    }) 
    if input ~= nil then 
        TriggerServerEvent('fprison:arrest', tonumber(input[1]), tonumber(input[2]), tonumber(input[3]), input[4])
        if input[5] then 

            local name = ''
            for k,v in pairs(xPlayers) do 
                if tonumber(v.value) == tonumber(input[1]) then 
                    name = v.label
                end 
            end 

            TriggerServerEvent('fprison:notifyArrest', name, tonumber(input[3]), tonumber(input[2]))
        end 
    end 
end)

RegisterNetEvent('fprison:openUnJailMenu')
AddEventHandler('fprison:openUnJailMenu', function(onlinePlayer, allPlayer)

    local options = {}
    for k,v in pairs(allPlayer) do 
        local jail = json.decode(v.jail)
        if jail.time > 0 then 
            for o,i in pairs(onlinePlayer) do 
                if i.identifier == v.identifier then 
                    table.insert(options, {value = v.identifier, label = (v.firstname .. ' ' .. v.lastname)})
                end 
            end 
        end 
    end 

    local input = lib.inputDialog(Config.ReleaseJail.menu.header, {
        {type = 'select', label = Config.ReleaseJail.menu.person, required = true, icon = 'user', options = options},
    }) 
    if input ~= nil then 
        local identifier = input[1]
        for k,v in pairs(allPlayer) do 
            if v.identifier == identifier then 
                local pos = json.decode(v.jail).position
                for o,i in pairs(onlinePlayer) do 
                    if i.identifier == v.identifier then 
                        TriggerServerEvent('fprison:release', i.id, pos)
                    end 
                end 
            end 
        end 
    end 
end)

Citizen.CreateThread(function()
    while true do 
        if inPrison then 
            inTime = inTime - 1
            if inTime > 0 then 
                TriggerServerEvent('fprison:setSql', inPos, inTime)
                Config.Notifcation({(locales['time_remaining'][1]):format(inTime), locales['time_remaining'][2]})
            else 
                release(inPos)
            end 
            Citizen.Wait(60000)
        else 
            Citizen.Wait(3000)
        end 
    end 
end)

function release(pos)
    TriggerServerEvent('fprison:setSql', 0, 0)
    isworking = false 
    inPrison = false 
    inTime = 0
    inPos = 0

    DoScreenFadeOut(500)
    Citizen.Wait(800)

    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
        TriggerEvent('skinchanger:loadSkin', skin)
    end)
    SetEntityCoords(PlayerPedId(), Config.Locations[pos].outsidePosition)

    Citizen.Wait(2000)
    DoScreenFadeIn(500)
    Config.Notifcation(locales['time_over'])
end 

function sendToJail(pos, time, teleport)
    local prison = Config.Locations[pos]
    if teleport then 
        DoScreenFadeOut(500)
        Citizen.Wait(800)
    end 
    TriggerServerEvent('fprison:setSql', pos, time)
    TriggerEvent('skinchanger:getSkin', function(skin)
        if skin.sex == 0 then
            TriggerEvent('skinchanger:loadClothes', skin, Config.Outfits.male)
        else
            TriggerEvent('skinchanger:loadClothes', skin, Config.Outfits.female)
        end
    end)
    if teleport then 
        SetEntityCoords(PlayerPedId(), prison.insidePosition)
        Citizen.Wait(2000)
        DoScreenFadeIn(500)
    end 


    if prison.societyWork.enabled then 
        Config.Notifcation({(locales['do_society_work'][1]):format(time), locales['do_society_work'][2]})
        societyWork(pos, time)
    else 
        Config.Notifcation({(locales['got_arrested'][1]):format(time), locales['got_arrested'][2]})
        inPrison = true 
        inTime = time
        inPos = pos

        prisonActivity(pos)
    end 
end 

local markeractive = false 
function societyWork(pos, time)
    local prison = Config.Locations[pos]
    local workPositions = prison.societyWork.positions
    local workPosition = GetRandomPos(workPositions)
    local marker = Config.workMarker

    isworking = true 

    while isworking do 
        local pedCoords = GetEntityCoords(PlayerPedId())

        if #(pedCoords - prison.insidePosition) > prison.radius then 
            SetEntityCoords(PlayerPedId(), prison.insidePosition)
        end 

        DrawMarker(
            marker.type, workPosition.position, 0.0, 0.0, 0.0, 0.0, 180, 0.0, marker.size, marker.size, marker.size, 
            marker.r,  marker.g,  marker.b, 100, false, true, 2, nil, nil, false
        )

        if #(pedCoords - workPosition.position) < 1.2 then 
            if not markeractive then 
                markeractive = true 
                Config.InfoBar(locales['interact_society_work'], true)
            end 
            if IsControlJustReleased(0, 38) then 

                if workPosition.action == 'brush' then
                    TaskStartScenarioInPlace(PlayerPedId(), 'WORLD_HUMAN_JANITOR', 0, true)
                else 
                    TaskStartScenarioInPlace(PlayerPedId(), 'WORLD_HUMAN_GARDENER_PLANT', 0, true)
                end 
                lib.progressCircle({
                    duration = 9000,
                    position = 'bottom',
                    useWhileDead = false,
                    canCancel = false,
                })
                ClearPedTasksImmediately(PlayerPedId())
                workPosition = GetRandomPos(workPositions)
                time = time - 1

                if time <= 0 then 
                    isworking = false 
                    release(pos)
                else 
                    Config.Notifcation({(locales['time_remaining'][1]):format(time), locales['time_remaining'][2]})
                    TriggerServerEvent('fprison:setSql', pos, time)
                end 

            end 
        else 
            if markeractive then 
                markeractive = false 
                Config.InfoBar(locales['interact_society_work'], false)
            end 
        end 

        Citizen.Wait(1)
    end 
end 

local storemarkeractive = false 
function prisonActivity(pos)
    local prison = Config.Locations[pos]
    while inPrison do 
        local ped = PlayerPedId()
        local pedCoords = GetEntityCoords(ped)


        if #(pedCoords - prison.insidePosition) > prison.radius then 
            if not prisonbreak then 
                SetEntityCoords(PlayerPedId(), prison.insidePosition)
            end 
        end 

        if prison.store ~= nil then 
            if prison.store.enabled then
                local marker = Config.StoreMarker
                DrawMarker(
                    marker.type, prison.store.position, 0.0, 0.0, 0.0, 0.0, 180, 0.0, marker.size, marker.size, marker.size, 
                    marker.r,  marker.g,  marker.b, 100, false, true, 2, nil, nil, false
                )

                if #(pedCoords - prison.store.position) < 1.5 then 
                    if not storemarkeractive then 
                        storemarkeractive = true 
                        Config.InfoBar(locales['interact_store'], true)
                    end 
                    if IsControlJustReleased(0, 38) then 
                        openStore(prison)
                    end 
                else 
                    if storemarkeractive then 
                        storemarkeractive = false 
                        Config.InfoBar(locales['interact_store'], false)
                    end 
                end 

            end 
        end 


        if prison.breakout ~= nil then
            if prison.breakout.enabled then 
                for k,v in pairs(prison.breakout.breakPositions) do 
                    if #(pedCoords - v) < 1.5 then 
                        if IsControlJustReleased(0, 38) then 
                            ESX.TriggerServerCallback('fprison:getBreakState', function(xState)
                                if xState then
                                    Config.Notifcation(locales['already_sabotaged'])
                                else 
                                    TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_HAMMERING', 0, true)
                                    lib.progressCircle({
                                        duration = 7000,
                                        position = 'bottom',
                                        useWhileDead = false,
                                        canCancel = false,
                                    })
                                    ClearPedTasksImmediately(ped)
                                    TriggerServerEvent('fprison:sabotage', pos, k)
                                end 
                            end, pos, k)
                        end 
                    end 
                end 
            end 
        end 


        Citizen.Wait(1)
    end 
end 

function GetRandomPos(workPositions)
    local ran = GetRandomIntInRange(1, #workPositions)
    return(workPositions[ran])
end 

function GetLabel(item)
    local label = ''
    for k,v in pairs(exports.ox_inventory:Items()) do 
        if v.name == item then 
            label = v.label
        end 
    end 
    return(label)
end 

function GetCount(item)
    local count = 0
    for k,v in pairs(exports.ox_inventory:Items()) do 
        if v.name == item then 
            count = v.count
        end 
    end 
    return(count)
end 

function openStore(prison)

    local options = {}
    for k,v in pairs(prison.store.items) do 
        table.insert(options, {
            title = GetLabel(v.item),
            description = (locales['store_item_text'][1]):format(v.price),
            onSelect = function()
                if GetCount('money') >= v.price then 
                    ESX.TriggerServerCallback('fprison:canCarryItem', function(xCanCarry)
                        if xCanCarry then 
                            TriggerServerEvent('fprison:addItem', v.item, 1, nil)
                            TriggerServerEvent('fprison:removeItem', 'money', v.price, nil)
                        else 
                            Config.Notifcation(locales['cant_carry'])
                        end 
                    end, v.item, 1, nil)
                else 
                    Config.Notifcation(locales['no_money'])
                end 
                openStore(prison)
            end,
        })
    end 
    lib.registerContext({
        id = 'f_prison_store',
        title = locales['store_header'][1],
        options = options,
    })
    lib.showContext('f_prison_store')

end 

RegisterNetEvent('fprison:broken')
AddEventHandler('fprison:broken', function(prison)
    if inPos == prison then 
        timer = 0
        Citizen.Wait(Config.Locations[prison].breakout.timer * 1000)
        Config.Notifcation(locales['prison_broken_now_open'])
        prisonbreak = true 
        while timer < 5 * 60 * 1000 do 
            
            for k,v in pairs(Config.Locations[prison].breakout.teleporter) do 
                local marker = Config.TeleporterMarker
                DrawMarker(
                    marker.type, v[1], 0.0, 0.0, 0.0, 0.0, 180, 0.0, marker.size, marker.size, marker.size, 
                    marker.r,  marker.g,  marker.b, 100, false, true, 2, nil, nil, false
                )
                DrawMarker(
                    marker.type, v[2], 0.0, 0.0, 0.0, 0.0, 180, 0.0, marker.size, marker.size, marker.size, 
                    marker.r,  marker.g,  marker.b, 100, false, true, 2, nil, nil, false
                )

                if #(GetEntityCoords(PlayerPedId()) - v[1]) < 1.5 then 
                    if IsControlJustReleased(0, 38) then 
                        SetEntityCoords(PlayerPedId(), v[2])
                        Citizen.Wait(1000)
                    end 
                end 

                if #(GetEntityCoords(PlayerPedId()) - v[2]) < 1.5 then 
                    if IsControlJustReleased(0, 38) then 
                        SetEntityCoords(PlayerPedId(), v[1])
                        Citizen.Wait(1000)
                    end 
                end 
            end 

            if #(GetEntityCoords(PlayerPedId()) - Config.Locations[prison].insidePosition) > Config.Locations[prison].radius then 

                TriggerServerEvent('fprison:setSql', 0, 0)
                isworking = false 
                inPrison = false 
                inTime = 0
                inPos = 0
            
                ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
                    TriggerEvent('skinchanger:loadSkin', skin)
                end)
            
                Config.Notifcation(locales['prison_broken_success'])
                timer = 1000000000000
            end 

            timer = timer + 1
            Citizen.Wait(1)
        end 
        prisonbreak = false 
    end 
end)