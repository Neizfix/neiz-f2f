fx_version 'cerulean'
game 'gta5'

author 'Neiz'
description 'f2fabisi'
version '1.0.0'
lua54 'yes'
shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

exports {
    'InF2F'
}

dependencies {
    'ox_lib'
} 