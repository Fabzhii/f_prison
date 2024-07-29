Config = {}

Config.SendJail = {
    jobs = {'police', 'marshall'},
    command = 'jail',
    maxTime = 180,
    menu = {
        header = 'Person Inhaftieren',
        person = 'Person',
        position = 'Position',
        time = 'Zeit',
        teleport = 'Teleportieren',
        notify = 'Bürger Informieren',
    }
}

Config.ReleaseJail = {
    jobs = {'police', 'marshall'},
    command = 'unjail',
    menu = {
        header = 'Person Freilassen',
        person = 'Person',
    }
}

Config.Locations = {
    {
        name = 'Sozial Arbeit',
        showBlip = false,
        insidePosition = vector3(208.6958, -933.0023, 30.6861),
        outsidePosition = vector3(208.6958, -933.0023, 30.6861),
        radius = 60,
        societyWork = {
            enabled = true,
            positions = {
                {position = vector3(201.3174, -945.6351, 30.6871), action = 'brush'},
                {position = vector3(210.9283, -938.8336, 30.6868), action = 'brush'},
                {position = vector3(189.6269, -936.4004, 30.6868), action = 'brush'},
                {position = vector3(187.2615, -922.7469, 30.6868), action = 'brush'},
                {position = vector3(198.4380, -919.4473, 30.6926), action = 'brush'},
                {position = vector3(212.5175, -920.0704, 30.6920), action = 'brush'},
                {position = vector3(213.1201, -956.4892, 30.4417), action = 'plant'},
                {position = vector3(222.9345, -942.9830, 29.7917), action = 'plant'},
                {position = vector3(200.1638, -910.7285, 30.6929), action = 'plant'},
                {position = vector3(190.5383, -911.2053, 30.6778), action = 'plant'},
                {position = vector3(192.2758, -919.8402, 30.6631), action = 'plant'},
            }
        }
    },
    {
        name = 'MRPD Zelle 1',
        showBlip = false,
        insidePosition = vector3(458.5932, -990.5310, 30.6895),
        outsidePosition = vector3(478.3077, -978.8776, 27.9839),
        radius = 6,
        societyWork = {enabled = false,},
    },
    {
        name = 'Staatsgefängnis',
        showBlip = true,
        insidePosition = vector3(1691.4170, 2566.1567, 45.5648),
        outsidePosition = vector3(1845.6417, 2585.9275, 45.6720),
        radius = 140,
        societyWork = {enabled = false},
        store = {
            enabled = true,
            position = vector3(1765.6365, 2566.0354, 45.5650),
            items = {
                {item = 'burger', price = 15},
                {item = 'water', price = 10},
            }
        },
        breakout = {
            enabled = true,
            timer = 10,
            breakPositions = {
                vector3(1652.4011, 2564.3723, 45.5648),
                vector3(1630.0503, 2564.3887, 45.5649),
                vector3(1608.9504, 2567.0259, 45.5649),
                vector3(1609.8494, 2539.6667, 45.5649),
                vector3(1622.4604, 2507.4500, 45.5649),
                vector3(1644.0706, 2490.8442, 45.5649),
                vector3(1679.5948, 2480.3423, 45.5649),
                vector3(1700.1910, 2474.8516, 45.5649),
                vector3(1706.9507, 2481.1360, 45.5649),
                vector3(1737.3778, 2504.5920, 45.5649),
                vector3(1760.6655, 2518.9202, 45.5650),
            },
            teleporter = {
                {vector3(1775.6466, 2551.8643, 45.5650), vector3(1792.0859, 2551.9434, 45.5650)},
                {vector3(1818.6477, 2594.3076, 45.7176), vector3(1845.6484, 2585.9893, 45.6732)},
            }
        }
    },
}

Config.Language = 'DE'
Config.Locales = {
    ['DE'] = {
        ['interact_society_work'] = {'[E] - Sozialarbeit Leisten', nil},
        ['interact_store'] = {'[E] - Mit Kantine interagieren', nil},
        ['command_help'] = {'Sende eine Person in das Gefängnis', nil},

        ['store_header'] = {'Gefängnis Kantine', nil},
        ['store_item_text'] = {'Diesen Gegenstand für %s$ kaufen', nil},

        ['arrest_notify'] = {'%s wurde zu %s Hafteinheiten Gefängnis veruteilt.', 'info'},
        ['society_work_notify'] = {'%s wurde zu %s Hafteinheiten Sozialarbeit veruteilt.', 'info'},
        ['time_remaining'] = {'Noch %s Hafteinheiten verbleibend.', 'info'},
        ['got_arrested'] = {'Du wurdest für %s Hafteinheiten inhaftiert.', 'info'},
        ['do_society_work'] = {'Du musst für %s Hafteinheiten Sozialarbeit leisten.', 'info'},
        ['prison_broken'] = {'Das %s wird gerade aufgebrochen.', 'info'},
        ['prison_broken_now_open'] = {'Die Sicherungen sind burchgebrannt und die Türen sind nun offen.', 'info'},

        ['time_over'] = {'Du hast deine Zeit abgesessen.', 'success'},
        ['prison_broken_success'] = {'Du bist erfolgreich aus dem Gefängnis ausgebrochen.', 'success'},

        ['no_money'] = {'Du hast nicht genügend Geld dabei.', 'error'},
        ['cant_carry'] = {'Du kannst diesen Gegenstand nicht tragen.', 'error'},
        ['already_sabotaged'] = {'Du kannst diesen Gegenstand nicht tragen.', 'error'},
    },
    ['EN'] = {
    },
}


Config.Outfits = {
    male = {
        ['torso_1'] = 0,
        ['torso_2'] = 1,
    },
    female = {
        ['torso_1'] = 0,
        ['torso_2'] = 1,
    },
}

Config.Blip =  {
    id = 188,
    color = 26,
    scale = 0.8,
}

Config.StoreMarker = {
    type = 2,
    size = 0.5,
    r = 118,
    g = 241,
    b = 149,
}

Config.workMarker = {
    type = 2,
    size = 0.5,
    r = 118,
    g = 241,
    b = 149,
}

Config.TeleporterMarker = {
    type = 2,
    size = 0.5,
    r = 118,
    g = 241,
    b = 149,
}

Config.Notifcation = function(notify)
    local message = notify[1]
    local notify_type = notify[2]
    lib.notify({
        position = 'top-right',
        description = message,
        type = notify_type,
    })
end 

Config.InfoBar = function(info, toggle)
    local message = info[1]
    local notify_type = info[2]
    if toggle then 
        lib.showTextUI(message, {position = 'left-center'})
    else 
        lib.hideTextUI()
    end
end 