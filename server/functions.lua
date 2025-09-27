giveStarterItems = function(source)
    local src = source
    local Player = Config.core.Functions.GetPlayer(src)
    if Config.inventory == 'ox_inventory' then
        while not exports.ox_inventory:GetInventory(src) do Wait(100) end
        for _, v in pairs(Config.starterItems) do
            local metadata = {}
            if v.name == "id_card" then
                metadata.citizenid = Player.PlayerData.citizenid
                metadata.firstname = Player.PlayerData.charinfo.firstname
                metadata.lastname = Player.PlayerData.charinfo.lastname
                metadata.birthdate = Player.PlayerData.charinfo.birthdate
                metadata.gender = Player.PlayerData.charinfo.gender
                metadata.nationality = Player.PlayerData.charinfo.nationality
            elseif v.name == "driver_license" then
                metadata.firstname = Player.PlayerData.charinfo.firstname
                metadata.lastname = Player.PlayerData.charinfo.lastname
                metadata.birthdate = Player.PlayerData.charinfo.birthdate
                metadata.type = "Class C Driver License"
            end
            exports.ox_inventory:AddItem(src, v.name, v.amount, metadata)
        end
    else
        for _, v in pairs(Config.starterItems) do
            local info = {}
            if v.name == "id_card" then
                info.citizenid = Player.PlayerData.citizenid
                info.firstname = Player.PlayerData.charinfo.firstname
                info.lastname = Player.PlayerData.charinfo.lastname
                info.birthdate = Player.PlayerData.charinfo.birthdate
                info.gender = Player.PlayerData.charinfo.gender
                info.nationality = Player.PlayerData.charinfo.nationality
            elseif v.name == "driver_license" then
                info.firstname = Player.PlayerData.charinfo.firstname
                info.lastname = Player.PlayerData.charinfo.lastname
                info.birthdate = Player.PlayerData.charinfo.birthdate
                info.type = "Class C Driver License"
            end
            Player.Functions.AddItem(v.name, v.amount, false, info)
        end
    end
end

getAllowedAmountOfCharacters = function(license)
    return Config.playersNumberOfCharacters[license] or Config.defaultNumberOfCharacters
end