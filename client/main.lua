local randomLocation = Config.locations[math.random(1, #Config.locations)]
local previewCam = nil

setupPreviewCam = function()
    DoScreenFadeIn(500)
    FreezeEntityPosition(PlayerPedId(), false)
    previewCam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", randomLocation.camCoords.x, randomLocation.camCoords.y, randomLocation.camCoords.z, 0.0 ,0.0, randomLocation.camCoords.w, 20.00, false, 0)
    SetCamActive(previewCam, true)
    RenderScriptCams(true, false, 1, true, true)
end

destroyPreviewCam = function()
    if not previewCam then return end
    SetTimecycleModifier('default')
    SetCamActive(previewCam, false)
    DestroyCam(previewCam, true)
    RenderScriptCams(false, false, 1, true, true)
    FreezeEntityPosition(PlayerPedId(), false)
end

loadMultichar = function()
    lib.callback('corex_multicharacter:server:getPlayerChars', false, function(chars, maxChars)
        local newChars = {}
        for k, v in pairs(chars) do
            local charinfo = json.decode(v.charinfo) or {}
            local money = json.decode(v.money) or {}
            local job = json.decode(v.job) or {}

            newChars[#newChars + 1] = {
                firstname = charinfo.firstname,
                lastname = charinfo.lastname,
                citizenid = v.citizenid,
                displayName = ((charinfo.firstname or "") .. " " .. (charinfo.lastname or "")):match("^%s*(.-)%s*$"),
                job = job.label or "Unemployed",
                money = {
                    cash = money.cash or 0,
                    bank = money.bank or 0
                }
            }
        end
        ShutdownLoadingScreen()
        ShutdownLoadingScreenNui()
        local localesFile = json.decode(LoadResourceFile(cache.resource, ('locales/%s.json'):format(Config.locale or 'en')))
        SendNUI('multichar', { characters = newChars, nationalities = Config.nationalities, deleteButton = Config.enableDeleteButton, canCreateChar = (maxChars > #chars), locales = localesFile })
        ShowNUI('setVisibleMultichar', true)
        Wait(1500)
        setupPreviewCam()
    end)
end

loadModel = function(model)
    local time = 1000
    if not HasModelLoaded(model) then
        while not HasModelLoaded(model) do
            if time > 0 then time = time - 1 RequestModel(model) else time = 1000 break end Wait(10)
        end
    end 
end

RegisterNuiCallback('selectChar', function(data)
    if GetDistanceBetweenCoords(vec3(GetEntityCoords(PlayerPedId()).x, GetEntityCoords(PlayerPedId()).y, GetEntityCoords(PlayerPedId()).z), vec3(randomLocation.pedCoords.x, randomLocation.pedCoords.y, randomLocation.pedCoords.z)) > 2.0 then
        SetEntityCoords(PlayerPedId(), randomLocation.pedCoords.x, randomLocation.pedCoords.y, randomLocation.pedCoords.z, true, false, false, false)
        SetEntityHeading(PlayerPedId(), randomLocation.pedCoords.w)
    end
    lib.callback('corex_multicharacter:server:getCharAppearance', false, function(appearance)
        loadModel(appearance.model)
        SetPlayerModel(PlayerId(), appearance.model)
        setClothing(PlayerPedId(), json.decode(appearance.skin))
        SetModelAsNoLongerNeeded(appearance.model)
        Wait(100)
        playRandomEmote()
    end, data.citizenid)
end)

RegisterNuiCallback('spawnChar', function(data)
    cancelEmote()
    lib.callback.await('corex_multicharacter:server:loadCharacter', false, data.citizenid)
    lib.callback.await('corex_multicharacter:server:setRoutingBucket', false, false)
    ShowNUI('setVisibleMultichar', false)
    if Config.spawnLastLocation then
        spawnLastLocation()
    else
        spawnSelector(data.citizenid)
    end
    if Config.hideRadar then DisplayRadar(true) end
    exports.devx_hud:visible(true) -- Show HUD when spawning
    destroyPreviewCam()
end)

RegisterNuiCallback('createChar', function(data)
    local chars, maxChars = lib.callback.await('corex_multicharacter:server:getPlayerChars', false)
    lib.callback('corex_multicharacter:server:createCharacter', false, function(newData)
        spawnCreateChar(newData)
        ShowNUI('setVisibleMultichar', false)
        if Config.hideRadar then DisplayRadar(true) end
        destroyPreviewCam()
    end, {
        firstname = data.firstname,
        lastname = data.lastname,
        nationality = data.nationality,
        gender = tonumber(data.gender),
        birthdate = string.match(data.birthdate, "^%d%d%d%d%-%d%d%-%d%d"),
        cid = #chars + 1
    })
end)

RegisterNuiCallback('deleteChar', function(data)
    lib.callback('corex_multicharacter:server:deleteCharacter', false, function()
        ShowNUI('setVisibleMultichar', false)
        DoScreenFadeOut(500)
        Wait(1000)
        loadMultichar()
        DoScreenFadeIn(250)
    end, data.citizenid)
end)

RegisterNetEvent('corex_multicharacter:client:chooseChar', function()
    DoScreenFadeOut(500)
    exports.spawnmanager:setAutoSpawn(false)
    SetNuiFocus(false, false)
    lib.callback.await('corex_multicharacter:server:setRoutingBucket', false, true)
    SetEntityCoords(PlayerPedId(), randomLocation.hiddenCoords.x, randomLocation.hiddenCoords.y, randomLocation.hiddenCoords.z, true, false, false, false)
    Wait(1500)
    if Config.hideRadar then DisplayRadar(false) end
    exports.devx_hud:visible(false) -- Hide HUD in character selection
    loadMultichar()
    return
end)

CreateThread(function()
	while true do
		Wait(0)
		if NetworkIsSessionStarted() then
            TriggerEvent('corex_multicharacter:client:chooseChar')
			return
		end
	end
end)