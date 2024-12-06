fx_version 'cerulean'
game 'gta5'
version '1.0.0'
author 'Sifuhlis'
description 'Court System, pretty basic and I advise that you check out wonderful AP-Court / AP-Government as they are far more in depth systems and are MUCH better!'

lua54 'yes' -- Enable Lua 5.4

dependencies {
    'qb-target',
	'ox_lib'
}

shared_scripts {
	'config.lua',
	'@ox_lib/init.lua'
}

server_scripts {
	'server/judgegavel.lua',
	'server/juryvoting.lua',
	'server/courtstatus.lua'
}

client_scripts {
	'client/judgegavel.lua',
	'client/juryvoting.lua',
    'client/judgeoptions.lua'
}

files {
    'html/index.html',
    'html/script.js',
    'html/sounds/gavel_strike.ogg'
}

ui_page 'html/index.html'