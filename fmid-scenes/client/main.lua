local EditPrompt
local ColorPrompt
local DeletePrompt
local FontPrompt
local BGPrompt
local MovePrompt
local MoverightPrompt
local MovebackPrompt
local ScalePrompt
local SceneGroup = GetRandomIntInRange(0, 0xffffff)


local Scenes = {}
local CurrentScene = {}

SceneTarget = function()
    local Cam = GetGameplayCamCoord()
    local handle = Citizen.InvokeNative(0x377906D8A31E5586, Cam, GetCoordsFromCam(10.0, Cam), -1, PlayerPedId(), 4)
    local _, Hit, Coords, _, Entity = GetShapeTestResult(handle)
    return Coords
end

GetCoordsFromCam = function(distance, coords)
    local rotation = GetGameplayCamRot()
    local adjustedRotation = vector3((math.pi / 180) * rotation.x, (math.pi / 180) * rotation.y, (math.pi / 180) * rotation.z)
    local direction = vector3(-math.sin(adjustedRotation[3]) * math.abs(math.cos(adjustedRotation[1])), math.cos(adjustedRotation[3]) * math.abs(math.cos(adjustedRotation[1])), math.sin(adjustedRotation[1]))
    return vector3(coords[1] + direction[1] * distance, coords[2] + direction[2] * distance, coords[3] + direction[3] * distance)
end

function DrawText3D(x, y, z, text, type, font, bg, scale)
    local onScreen, _x, _y = GetScreenCoordFromWorldCoord(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoord())
    local str = CreateVarString(10, "LITERAL_STRING", text)
    if onScreen then
        SetTextColor(Config.Colors[type][1], Config.Colors[type][2], Config.Colors[type][3], 215)
        SetTextScale(scale, scale)
        SetTextFontForCurrentCommand(font) -- 0,1,5,6, 9, 11, 12, 15, 18, 19, 20, 22, 24, 25, 28, 29
        SetTextCentre(1)
        -- DisplayText(str, _x, _y - 0.13)
        DisplayText(str, _x, _y - 0.0)
        
        if bg > 0 then
            local factor = (string.len(text)) / 225
            -- DrawSprite("feeds", "hud_menu_4a", _x, _y - (0.12 + (scale / 200)), (scale / 20) + factor, scale / 5, 0.1,
            --     Config.Colors[bg][1], Config.Colors[bg][2], Config.Colors[bg][3], 190, 0)
            
            DrawSprite("feeds", "hud_menu_4a", _x, _y  + scale / 50, (scale / 20) + factor, scale / 5, 0.1,
                Config.Colors[bg][1], Config.Colors[bg][2], Config.Colors[bg][3], 190, 0)
        end
    end
end

function whenKeyJustPressed(key)
    if Citizen.InvokeNative(0x580417101DDB492F, 0, key) then
        return true
    else
        return false
    end
end

local addMode = false
local editing = false
local moving = false
local closest = nil

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1500)
        if editing == true then
            editing = false
        end
    end
end)

-- Citizen.CreateThread(function()
--     while true do
--         Citizen.Wait(1)
--         local tidur = false
--         if Config.HotKeysEnabled == true then
--             if whenKeyJustPressed(Config.HotKeys.Scene) then
--                 if addMode then
--                     addMode = false
--                 elseif not addMode then
--                     addMode = true
--                 end
--             end

--             if whenKeyJustPressed(Config.HotKeys.Place) then
--                 if addMode then
--                     TriggerEvent("fmid-scenes:start")
--                 else
--                     if Config.PakaiFramework == 'vorp' then
--                         TriggerEvent("vorp:TipBottom", Config.Texts.SceneErr, 3000)
--                     elseif Config.PakaiFramework == 'qbr' then
--                         exports['qbr-core']:Notify(9, Config.Texts.SceneErr, 300, 0, 'ability_cards', 'menu_icon_ability_combat', 'COLOR_RED')
--                     end
--                 end
--             end
--         end
--     end
-- end)



Citizen.CreateThread(function()
    WarMenu.CreateMenu('scenemenu', Config.Texts.MenuTitle)

    local str = Config.Prompts.Edit[1]
    EditPrompt = PromptRegisterBegin()
    PromptSetControlAction(EditPrompt, Config.Prompts.Edit[2])
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(EditPrompt, str)
    PromptSetEnabled(EditPrompt, 1)
    PromptSetVisible(EditPrompt, 1)
    PromptSetStandardMode(EditPrompt, 1)
    PromptSetGroup(EditPrompt, SceneGroup)
    Citizen.InvokeNative(0xC5F428EE08FA7F2C, EditPrompt, true)
    PromptRegisterEnd(EditPrompt)

    TriggerServerEvent("fmid-scenes:getscenes")
    while true do
        Citizen.Wait(0)
        local tidur = false
        local x, y, z
        if addMode == true then
            tidur = true
            x, y, z = table.unpack(SceneTarget())
            Citizen.InvokeNative(0x2A32FAA57B937173, 0x50638AB9, x, y, z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.15, 0.15, 0.15, 93, 17, 100, 255, false, false, 2, false, false)
        end

        if Scenes[1] ~= nil then
            
            local closest = {
                dist = 99999999
            }
            for i, v in pairs(Scenes) do
                local cc = GetEntityCoords(PlayerPedId())
                local edist =  Config.EditDistance
                if addMode == true then
                    cc = {
                        x = x,
                        y = y,
                        z = z
                    }
                    edist = 0.1
                end

                local sc = Scenes[i].coords
                -- GetDistanceBetweenCoords(x1, y1, z1, x2, y2, z2, useZ)
                local dist = GetDistanceBetweenCoords(cc.x, cc.y, cc.z, sc.x, sc.y, sc.z, 1)
                if dist < Config.ViewDistance then
                    tidur = true
                    if (dist < edist) and dist <= closest.dist then
                        
                        closest = {
                            dist = dist
                        }

                        local label = CreateVarString(10, 'LITERAL_STRING', Scenes[i].text)
                        PromptSetActiveGroupThisFrame(SceneGroup, label)
                        if Citizen.InvokeNative(0xC92AC953F0A982AE, EditPrompt) then
                            WarMenu.SetSubTitle('scenemenu',  Config.Texts.MenuSubCompliment..Scenes[i].text) 
                            WarMenu.OpenMenu('scenemenu')
                        end
                        
                        if editing == false then                       
                            if WarMenu.IsMenuOpened('scenemenu') then
                                if WarMenu.Button(Config.Texts.Delete) then
                                    TriggerServerEvent("fmid-scenes:delete", i)
                                    WarMenu.CloseMenu()
                                end

                                if WarMenu.Button(Config.Texts.Edit) then
                                    TriggerServerEvent("fmid-scenes:edit", i)
                                    WarMenu.CloseMenu()
                                end

                                if WarMenu.Button(Config.Texts.Font) then
                                    TriggerServerEvent("fmid-scenes:font", i)
                                end

                                if WarMenu.Button(Config.Texts.Scale) then
                                    TriggerServerEvent("fmid-scenes:scale", i)
                                end

                                if WarMenu.Button(Config.Texts.Color) then
                                    TriggerServerEvent("fmid-scenes:color", i)
                                end

                                if WarMenu.Button(Config.Texts.BackgroundColor) then
                                    TriggerServerEvent("fmid-scenes:background", i)
                                end

                                if WarMenu.Button(Config.Texts.Exit) then
                                    WarMenu.CloseMenu()
                                end

                                WarMenu.Display()
                            end
                        end
                    end

                    local outtext = Scenes[i].text

                    if Config.TextAsterisk == true then
                         outtext = "*" .. Scenes[i].text .. "*"
                    end

                    DrawText3D(sc.x, sc.y, sc.z, outtext, Scenes[i].color, Scenes[i].font,
                        Scenes[i].bg, Scenes[i].scale)
                end
            end
        end

        if not tidur then
            Citizen.Wait(1500)
        end
    end
end)

RegisterCommand('scene', function(source, args, raw)
    if addMode then
        addMode = false
    elseif not addMode then
        addMode = true
    end
end)

RegisterCommand('scene:place', function(source, args, raw)
    if addMode then
        TriggerEvent("fmid-scenes:start")
    else
        if Config.PakaiFramework == 'vorp' then
            TriggerEvent("vorp:TipBottom", Config.Texts.SceneErr, 3000)
        elseif Config.PakaiFramework == 'qbr' then
            exports['qbr-core']:Notify(9, Config.Texts.SceneErr, 300, 0, 'ability_cards', 'menu_icon_ability_combat', 'COLOR_RED')
        end
    end
end)

RegisterNetEvent('fmid-scenes:sendscenes')
AddEventHandler('fmid-scenes:sendscenes', function(scenes)
    Scenes = scenes
    -- for i, v in pairs(Scenes) do
    --     print(Scenes[i])
    -- end
end)

RegisterNetEvent('fmid-scenes:client_edit')
AddEventHandler('fmid-scenes:client_edit', function(nr)
    local scenetext = ""
    Citizen.CreateThread(function()
        AddTextEntry('FMMC_MPM_NA', Config.Texts.AddDetails)
        DisplayOnscreenKeyboard(0, "FMMC_MPM_NA", "", "", "", "", "", 50)
        while (UpdateOnscreenKeyboard() == 0) do
            DisableAllControlActions(0);
            Citizen.Wait(5);
        end
        if (GetOnscreenKeyboardResult()) then
            scenetext = GetOnscreenKeyboardResult()

            TriggerServerEvent("fmid-scenes:edited", scenetext, nr)
            CancelOnscreenKeyboard()
        end
    end)
end)

RegisterNetEvent('fmid-scenes:start')
AddEventHandler('fmid-scenes:start', function()
    local scenetext = ""
    Citizen.CreateThread(function()
        AddTextEntry('FMMC_MPM_NA', Config.Texts.AddDetails)
        DisplayOnscreenKeyboard(0, "FMMC_MPM_NA", "", "", "", "", "", 50)
        while (UpdateOnscreenKeyboard() == 0) do
            DisableAllControlActions(0);
            Citizen.Wait(5);
        end
        if (GetOnscreenKeyboardResult()) then
            scenetext = GetOnscreenKeyboardResult()

            -- player: 
            -- GetEntityCoords(PlayerPedId())
            addMode = false
            print(scenetext)
            TriggerServerEvent("fmid-scenes:add", scenetext, SceneTarget())
            CancelOnscreenKeyboard()
        end
    end)
end)

RegisterNetEvent('fmid-scenes:notifikasi')
AddEventHandler('fmid-scenes:notifikasi', function(status,msg,durasi)
    local txd1 = 'mp_lobby_textures'
    local txd2
    if status then
        txd2 = 'check'
    else
        txd2 = 'cross'
    end
    exports['qbr-core']:Notify(9, msg, durasi, 0, txd1, txd2, 'COLOR_WHITE')
end)