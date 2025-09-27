lib.callback.register('corex_multicharacter:server:getPlayerChars', function(source)
    local src = source
    local license = GetPlayerIdentifierByType(src, Config.licenseType)
    local maxChars = getAllowedAmountOfCharacters(license)
    return MySQL.query.await('SELECT * FROM players WHERE license = ?', {license}), maxChars
end)

lib.callback.register('corex_multicharacter:server:setRoutingBucket', function(source, value)
    local src = source
    SetPlayerRoutingBucket(src, value and src or 0)
    return true
end)

lib.callback.register('corex_multicharacter:server:getCharAppearance', function(source, citizenid)
    local src = source
    return MySQL.single.await('SELECT * FROM playerskins WHERE citizenid = ? AND active = 1', {citizenid})
end)

lib.callback.register('corex_multicharacter:server:loadCharacter', function(source, citizenid)
    local src = source
    if Config.framework == 'qb' then
        Config.core.Player.Login(src, citizenid)
    elseif Config.framework == 'qbx' then
        exports.qbx_core:Login(src, citizenid)
    end
    lib.print.info(('%s (Citizen ID: %s) has loaded!'):format(GetPlayerName(src), citizenid))
end)

lib.callback.register('corex_multicharacter:server:createCharacter', function(source, data)
    local src = source
    local newData = {}
    newData.cid = data.cid
    newData.charinfo = data
    if Config.framework == 'qb' then
        Config.core.Player.Login(src, nil, newData)
    elseif Config.framework == 'qbx' then
        exports.qbx_core:Login(src, nil, newData)
    end
    giveStarterItems(src)
    lib.print.info(('%s has created a character'):format(GetPlayerName(src)))
    return newData
end)

lib.callback.register('corex_multicharacter:server:deleteCharacter', function(source, citizenid)
    local src = source
    if Config.framework == 'qb' then
        Config.core.Player.DeleteCharacter(src, citizenid)
    elseif Config.framework == 'qbx' then
        exports.qbx_core:DeleteCharacter(citizenid)
    end
    lib.print.info(('%s has deleted the %s character'):format(GetPlayerName(src), citizenid))
    return true
end)

Logout = function(source)
    local src = source
    if Config.framework == 'qb' then
        Config.core.Player.Logout(src)
    elseif Config.framework == 'qbx' then
        exports.qbx_core:Logout(src)
    end
    TriggerClientEvent('corex_multicharacter:client:chooseChar', src)
    lib.print.info(('%s has used the logout'):format(GetPlayerName(src)))
end

RegisterNetEvent('qb-multicharacter:server:disconnect', function()
    local src = source
    Logout(src)
end)

lib.addCommand(Config.logoutCommand.command, {
    help = "Logout character",
    restricted = Config.logoutCommand.perm,
}, Logout)