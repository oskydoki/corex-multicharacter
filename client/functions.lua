playRandomEmote = function()
    local emote = Config.emotes[math.random(1, #Config.emotes)]
    ExecuteCommand('e '..emote)
end

cancelEmote = function()
    ExecuteCommand('e c')
end

setClothing = function(ped, clothing)
    if Config.clothing == 'qb-clothing' then
        TriggerEvent('qb-clothing:client:loadPlayerClothing', clothing, charPed)
    elseif Config.clothing == 'illenium-appearance' then
        exports['illenium-appearance']:setPedAppearance(ped, clothing)
    end
end

spawnSelector = function(citizenid)
    TriggerEvent('qb-spawn:client:setupSpawns', citizenid)
    TriggerEvent('qb-spawn:client:openUI', true)
end

spawnLastLocation = function()
    DoScreenFadeOut(500)
    destroyPreviewCam()
    local PlayerData = Config.core.Functions.GetPlayerData()
    exports.spawnmanager:spawnPlayer({ x = PlayerData.position.x, y = PlayerData.position.y, z = PlayerData.position.z, heading = PlayerData.position.w })
    TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
    TriggerEvent('QBCore:Client:OnPlayerLoaded')
    TriggerServerEvent('qb-houses:server:SetInsideMeta', 0, false)
    TriggerServerEvent('qb-apartments:server:SetInsideMeta', 0, 0, false)
    DoScreenFadeIn(500)
end

spawnDefault = function()
    DoScreenFadeOut(500)
    destroyPreviewCam()
    exports.spawnmanager:spawnPlayer({ x = Config.defaultSpawn.x, y = Config.defaultSpawn.y, z = Config.defaultSpawn.z, heading = Config.defaultSpawn.w })
    TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
    TriggerEvent('QBCore:Client:OnPlayerLoaded')
    TriggerServerEvent('qb-houses:server:SetInsideMeta', 0, false)
    TriggerServerEvent('qb-apartments:server:SetInsideMeta', 0, 0, false)
    TriggerEvent('qb-clothes:client:CreateFirstCharacter')
    DoScreenFadeIn(500)
end

spawnCreateChar = function(newData)
    lib.callback.await('corex_multicharacter:server:setRoutingBucket', false, false)
    if Config.startingApartment then
        TriggerEvent('apartments:client:setupSpawnUI', newData)
    else
        TriggerEvent('corex_multicharacter:client:spawnNoApartments')
    end
end

RegisterNetEvent('corex_multicharacter:client:spawnNoApartments', function()
    DoScreenFadeOut(500)
    Wait(2000)
    SetEntityCoords(cache.ped, Config.defaultSpawn.x, Config.defaultSpawn.y, Config.defaultSpawn.z, false, false, false, false)
    SetEntityHeading(cache.ped, Config.defaultSpawn.w)
    Wait(500)
    destroyPreviewCam()
    SetEntityVisible(cache.ped, true, false)
    Wait(500)
    DoScreenFadeIn(250)
    exports.devx_hud:visible(true) -- Show HUD when spawning
    TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
    TriggerEvent('QBCore:Client:OnPlayerLoaded')
    TriggerServerEvent('qb-houses:server:SetInsideMeta', 0, false)
    TriggerServerEvent('qb-apartments:server:SetInsideMeta', 0, 0, false)
    TriggerEvent('qb-weathersync:client:EnableSync')
    TriggerEvent('qb-clothes:client:CreateFirstCharacter')
end)