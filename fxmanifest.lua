fx_version 'cerulean'
description 'FiveM Multicharacter script'
author 'oskydoki'
lua54 'yes'
game 'gta5'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

client_scripts {
    '@qbx_core/modules/playerdata.lua',
    'client/**/*',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/**/*',
}

ui_page 'web/index.html'

files {
    'locales/*',
    'web/index.html',
    'web/*',
}


dependency '/assetpacks'