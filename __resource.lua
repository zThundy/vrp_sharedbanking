resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

dependency "vrp"

files {
    "config.lua"
}

client_scripts {
    "client/client.lua",
    "config.lua"
}

server_scripts {
    "@mysql-async/lib/MySQL.lua",
    "@vrp/lib/utils.lua",
    "server/banks.lua",
    "server/robbery.lua",
    "server/funzioni.lua",
    "config.lua"
}
