config = {}

--------- leggenda ----------
-- id 1 = fleeca
-- id 2 = pacific
-- id 3 = blaine county
-----------------------------

-- example:
-- {x, y, z, bank_type}
-- x, y, z = these are the coords that creates marker on map
-- bank_type is the bank type that you want to assign to each marker

-- this is the list of markers that get assignet to the banker to let him create
-- and check bank accounts of users
config.bankierjob = {

    {309.49420166016, -279.62564086914, 53.26463470459, 1}, -- fleeca
    {145.22213745117, -1041.3226318359, 28.46792755127, 1},
    {-2960.7333984375, 478.62033081055, 14.796937561035, 1},

    {264.0068359375, 214.11714172363, 109.38677368164, 2}, -- pacific standard

    {-113.37410736084, 6472.169921875, 30.726707077026, 3} -- blaine county

}

-- this is the list of banks created in the game. with this markers, players can
-- get and deposit moneys from their accounts
config.banks = {

    {-2962.5671386719, 482.92181396484, 14.713107833862, 1}, -- fleeca
    {149.86595153809, -1040.7557373047, 28.384103546143, 1},
    {314.25192260742, -279.16720581055, 53.180803070068, 1},

    {251.80395507813, 221.64967346191, 105.1965447998, 2},

    {-111.99416351318, 6469.1772460938, 30.636720428467, 3} -- blain county

}

-- this last list is the list that players use to rob banks.
config.robbery = {

    {-2957.4677734375,480.94116210938,14.706848144531, 1}, --fleeca
    {146.13789367676, -1044.6154785156, 28.477822875977, 1},
    {310.40496826172, -282.97528076172, 53.374522399902, 1},

    {265.09210205078,213.62707519531,100.69336486816, 2}, --pacific standard

    {-103.53372955322,6477.8530273438,31.626726150513, 3} -- blain county

}

-- here there's the minimum amount of police online. Be carefoul that a policeman
-- is recognized only if the group has inside it the permission "cop.whitelisted"
config.minPolice = -1

-- this is the time in minutes that decice when all banks can be robbed
config.robbTime = 30

-- this is the max amount of banks type you want to create in the server
config.maxFleeca = 3
config.maxPacific = 1
config.maxBlaine = 1

-- this is the permission you must assign to the head of the banks
config.bankierPex = "banker.whitelisted"
