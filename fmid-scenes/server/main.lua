TriggerEvent("getCore",function(core)
    VorpCore = core
end)

Citizen.CreateThread(function()
    if Config.RestartDelete == true then
        local Scenes_a = {}
        SaveResourceFile(GetCurrentResourceName(), "./scenes.json", json.encode(Scenes_a))
    end
end)

RegisterServerEvent("fmid-scenes:add")
AddEventHandler("fmid-scenes:add", function(text,coords)
	local _source = source
    local _text = tostring(text)
    local User, Character, identi, charid
    if Config.PakaiFramework == 'vorp' then
        User = VorpCore.getUser(source)
        Character = User.getUsedCharacter
        identi = Character.identifier
        charid = Character.charIdentifier
    elseif Config.PakaiFramework == 'qbr' then
        User = exports['qbr-core']:GetPlayer(source)
        Character = User.PlayerData
        identi = Character.license
        charid = Character.cid
    end
    local scene = {id = identi, charid = charid, text = _text, coords = coords, font = Config.Defaults.Font, color = Config.Defaults.Color, bg = Config.Defaults.BackgroundColor, scale = Config.StartingScale}
    local edata = LoadResourceFile(GetCurrentResourceName(), "./scenes.json")
    local datas = json.decode(edata)
    datas[#datas+1] = scene
    SaveResourceFile(GetCurrentResourceName(), "./scenes.json", json.encode(datas))
    TriggerClientEvent("fmid-scenes:sendscenes", -1, datas)
end)

RegisterServerEvent("fmid-scenes:getscenes")
AddEventHandler("fmid-scenes:getscenes", function(text)
	local _source = source
    local edata = LoadResourceFile(GetCurrentResourceName(), "./scenes.json")
    local datas = json.decode(edata)
    TriggerClientEvent("fmid-scenes:sendscenes", _source, datas)
end)

RegisterServerEvent("fmid-scenes:delete")
AddEventHandler("fmid-scenes:delete", function(nr)
	local _source = source
    local edata = LoadResourceFile(GetCurrentResourceName(), "./scenes.json")
    local datas = json.decode(edata)
    local User, Character
    if Config.PakaiFramework == 'vorp' then
        User = VorpCore.getUser(source)
        Character = User.getUsedCharacter
        if tostring(datas[nr].id) == Character.identifier and tonumber(datas[nr].charid) == Character.charIdentifier then
            table.remove( datas, nr)
            SaveResourceFile(GetCurrentResourceName(), "./scenes.json", json.encode(datas))
            TriggerClientEvent("fmid-scenes:sendscenes", -1, datas)
            return
        else
            TriggerClientEvent("vorp:TipBottom", _source, Config.Texts.NoAuth, 2000)
        end
    elseif Config.PakaiFramework == 'qbr' then
        User = exports['qbr-core']:GetPlayer(source)
        Character = User.PlayerData
        if tostring(datas[nr].id) == Character.license and tonumber(datas[nr].charid) == Character.cid then
            table.remove( datas, nr)
            SaveResourceFile(GetCurrentResourceName(), "./scenes.json", json.encode(datas))
            TriggerClientEvent("fmid-scenes:sendscenes", -1, datas)
            return
        else
            -- TriggerClientEvent("vorp:TipBottom", _source, Config.Texts.NoAuth, 2000)
            -- print(Config.Texts.NoAuth)
            TriggerClientEvent('fmid-scenes:notifikasi', _source, false, Config.Texts.NoAuth, 2000)
        end
    end
    
end)

RegisterServerEvent("fmid-scenes:edit")
AddEventHandler("fmid-scenes:edit", function(nr)
	local _source = source
    local edata = LoadResourceFile(GetCurrentResourceName(), "./scenes.json")
    local datas = json.decode(edata)
    local User, Character
    if Config.PakaiFramework == 'vorp' then
        User = VorpCore.getUser(source)
        Character = User.getUsedCharacter
        if tostring(datas[nr].id) == Character.identifier and tonumber(datas[nr].charid) == Character.charIdentifier then
            TriggerClientEvent("fmid-scenes:client_edit", _source, nr)
            return
        else
            TriggerClientEvent("vorp:TipBottom", _source, Config.Texts.NoAuth, 2000)
        end
    elseif Config.PakaiFramework == 'qbr' then
        User = exports['qbr-core']:GetPlayer(source)
        Character = User.PlayerData
        if tostring(datas[nr].id) == Character.license and tonumber(datas[nr].charid) == Character.cid then
            TriggerClientEvent("fmid-scenes:client_edit", _source, nr)
            return
        else
            -- TriggerClientEvent("vorp:TipBottom", _source, Config.Texts.NoAuth, 2000)
            -- print(Config.Texts.NoAuth)
            TriggerClientEvent('fmid-scenes:notifikasi', _source, false, Config.Texts.NoAuth, 2000)
        end
    end
end)

RegisterServerEvent("fmid-scenes:moveright")
AddEventHandler("fmid-scenes:moveright", function(nr)
	local _source = source
    local edata = LoadResourceFile(GetCurrentResourceName(), "./scenes.json")
    local datas = json.decode(edata)
    if Config.PakaiFramework == 'vorp' then
        local User = VorpCore.getUser(source)
        local Character = User.getUsedCharacter
        if tostring(datas[nr].id) == Character.identifier and tonumber(datas[nr].charid) == Character.charIdentifier then
            datas[nr].coords.y = datas[nr].coords.x + 0.005
            SaveResourceFile(GetCurrentResourceName(), "./scenes.json", json.encode(datas))
            TriggerClientEvent("fmid-scenes:sendscenes", -1, datas)
            return
        end
    elseif Config.PakaiFramework == 'qbr' then
        local User = exports['qbr-core']:GetPlayer(source)
        local Character = User.PlayerData
        if tostring(datas[nr].id) == Character.license and tonumber(datas[nr].charid) == Character.cid then
            datas[nr].coords.y = datas[nr].coords.x + 0.005
            SaveResourceFile(GetCurrentResourceName(), "./scenes.json", json.encode(datas))
            TriggerClientEvent("fmid-scenes:sendscenes", -1, datas)
            return
        end
    end
end)

RegisterServerEvent("fmid-scenes:color")
AddEventHandler("fmid-scenes:color", function(nr)
	local _source = source
    local edata = LoadResourceFile(GetCurrentResourceName(), "./scenes.json")
    local datas = json.decode(edata)
    if Config.PakaiFramework == 'vorp' then
        local User = VorpCore.getUser(source)
        local Character = User.getUsedCharacter
        if tostring(datas[nr].id) == Character.identifier and tonumber(datas[nr].charid) == Character.charIdentifier then
            datas[nr].color = datas[nr].color + 1
            if datas[nr].color > #Config.Colors then
                datas[nr].color = 1
            end
            SaveResourceFile(GetCurrentResourceName(), "./scenes.json", json.encode(datas))
            TriggerClientEvent("fmid-scenes:sendscenes", -1, datas)
            return
        else
            -- TriggerClientEvent("vorp:TipBottom", _source, Config.Texts.NoAuth, 2000)
            TriggerClientEvent('fmid-scenes:notifikasi', _source, false, Config.Texts.NoAuth, 2000)
        end
    elseif Config.PakaiFramework == 'qbr' then
        local User = exports['qbr-core']:GetPlayer(source)
        local Character = User.PlayerData
        if tostring(datas[nr].id) == Character.license and tonumber(datas[nr].charid) == Character.cid then
            datas[nr].color = datas[nr].color + 1
            if datas[nr].color > #Config.Colors then
                datas[nr].color = 1
            end
            SaveResourceFile(GetCurrentResourceName(), "./scenes.json", json.encode(datas))
            TriggerClientEvent("fmid-scenes:sendscenes", -1, datas)
            return
        else
            -- TriggerClientEvent("vorp:TipBottom", _source, Config.Texts.NoAuth, 2000)
            TriggerClientEvent('fmid-scenes:notifikasi', _source, false, Config.Texts.NoAuth, 2000)
        end
    end
end)

RegisterServerEvent("fmid-scenes:background")
AddEventHandler("fmid-scenes:background", function(nr)
	local _source = source
    local edata = LoadResourceFile(GetCurrentResourceName(), "./scenes.json")
    local datas = json.decode(edata)
    if Config.PakaiFramework == 'vorp' then
        local User = VorpCore.getUser(source)
        local Character = User.getUsedCharacter
        if tostring(datas[nr].id) == Character.identifier and tonumber(datas[nr].charid) == Character.charIdentifier then
            datas[nr].bg = datas[nr].bg + 1
            if datas[nr].bg > #Config.Colors then
                datas[nr].bg = 1
            end
            SaveResourceFile(GetCurrentResourceName(), "./scenes.json", json.encode(datas))
            TriggerClientEvent("fmid-scenes:sendscenes", -1, datas)
            return
        else
            TriggerClientEvent("vorp:TipBottom", _source, Config.Texts.NoAuth, 2000)
        end
    elseif Config.PakaiFramework == 'qbr' then
        local User = exports['qbr-core']:GetPlayer(source)
        local Character = User.PlayerData
        if tostring(datas[nr].id) == Character.license and tonumber(datas[nr].charid) == Character.cid then
            datas[nr].bg = datas[nr].bg + 1
            if datas[nr].bg > #Config.Colors then
                datas[nr].bg = 1
            end
            SaveResourceFile(GetCurrentResourceName(), "./scenes.json", json.encode(datas))
            TriggerClientEvent("fmid-scenes:sendscenes", -1, datas)
            return
        else
            -- TriggerClientEvent("vorp:TipBottom", _source, Config.Texts.NoAuth, 2000)
            TriggerClientEvent('fmid-scenes:notifikasi', _source, false, Config.Texts.NoAuth, 2000)
        end
    end
end)

RegisterServerEvent("fmid-scenes:font")
AddEventHandler("fmid-scenes:font", function(nr)
	local _source = source
    local edata = LoadResourceFile(GetCurrentResourceName(), "./scenes.json")
    local datas = json.decode(edata)
    if Config.PakaiFramework == 'vorp' then
        local User = VorpCore.getUser(source)
        local Character = User.getUsedCharacter

        if tostring(datas[nr].id) == Character.identifier and tonumber(datas[nr].charid) == Character.charIdentifier then
            datas[nr].font = datas[nr].font + 1
            if datas[nr].font > #Config.Fonts then
                datas[nr].font = 1
            end
            
            SaveResourceFile(GetCurrentResourceName(), "./scenes.json", json.encode(datas))
            TriggerClientEvent("fmid-scenes:sendscenes", -1, datas)
            return
        else
            TriggerClientEvent("vorp:TipBottom", _source, Config.Texts.NoAuth, 2000)
            -- TriggerClientEvent('fmid-scenes:notifikasi', _source, false, Config.Texts.NoAuth, 2000)
        end
    elseif Config.PakaiFramework == 'qbr' then
        local User = exports['qbr-core']:GetPlayer(source)
        local Character = User.PlayerData

        if tostring(datas[nr].id) == Character.license and tonumber(datas[nr].charid) == Character.cid then
            datas[nr].font = datas[nr].font + 1
            if datas[nr].font > #Config.Fonts then
                datas[nr].font = 1
            end
            
            SaveResourceFile(GetCurrentResourceName(), "./scenes.json", json.encode(datas))
            TriggerClientEvent("fmid-scenes:sendscenes", -1, datas)
            return
        else
            -- TriggerClientEvent("vorp:TipBottom", _source, Config.Texts.NoAuth, 2000)
            TriggerClientEvent('fmid-scenes:notifikasi', _source, false, Config.Texts.NoAuth, 2000)
        end
    end
end)

RegisterServerEvent("fmid-scenes:edited")
AddEventHandler("fmid-scenes:edited", function(text,nr)
	local _source = source
    local _text = tostring(text)
    local edata = LoadResourceFile(GetCurrentResourceName(), "./scenes.json")
    local datas = json.decode(edata)
    datas[nr].text = _text
    SaveResourceFile(GetCurrentResourceName(), "./scenes.json", json.encode(datas))
    TriggerClientEvent("fmid-scenes:sendscenes", -1, datas)
end)

RegisterServerEvent("fmid-scenes:scale")
AddEventHandler("fmid-scenes:scale", function(nr)
    local _source = source
    local edata = LoadResourceFile(GetCurrentResourceName(), "./scenes.json")
    local datas = json.decode(edata)
    if Config.PakaiFramework == 'vorp' then
        local User = VorpCore.getUser(source)
        local Character = User.getUsedCharacter
        if tostring(datas[nr].id) == Character.identifier and tonumber(datas[nr].charid) == Character.charIdentifier then
            datas[nr].scale = datas[nr].scale + 0.05
            if datas[nr].scale > Config.MaxScale then
                datas[nr].scale = Config.StartingScale
            end
            SaveResourceFile(GetCurrentResourceName(), "./scenes.json", json.encode(datas))
            TriggerClientEvent("fmid-scenes:sendscenes", -1, datas)
            return
        else
            TriggerClientEvent("vorp:TipBottom", _source, Config.Texts.NoAuth, 2000)
        end
    elseif Config.PakaiFramework == 'qbr' then
        local User = exports['qbr-core']:GetPlayer(source)
        local Character = User.PlayerData
        if tostring(datas[nr].id) == Character.license and tonumber(datas[nr].charid) == Character.cid then
            datas[nr].scale = datas[nr].scale + 0.05
            if datas[nr].scale > Config.MaxScale then
                datas[nr].scale = Config.StartingScale
            end
            SaveResourceFile(GetCurrentResourceName(), "./scenes.json", json.encode(datas))
            TriggerClientEvent("fmid-scenes:sendscenes", -1, datas)
            return
        else
            -- TriggerClientEvent("vorp:TipBottom", _source, Config.Texts.NoAuth, 2000)
            TriggerClientEvent('fmid-scenes:notifikasi', _source, false, Config.Texts.NoAuth, 2000)
        end
    end
end)

-- RegisterCommand('printpd', function(source)
--     local Player = exports['qbr-core']:GetPlayer(source)
--     print(json.encode(Player, {indent = true}))
-- end)