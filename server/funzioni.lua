local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP","vRP_sharedbanking")

--[[RegisterCommand("testBank", function(source, args)
    if args[1] ~= nil then
		local money, numero = vRP.getMoneyFromBankId(tonumber(args[1]))
		print(money)
		local perc = (money*5)/100
		print(math.floor(perc + 0.5))
		local daSottrarre = (perc/numero)
		print(numero)
		daSottrarre = math.floor(daSottrarre + 0.5)
		print(daSottrarre)
    end
end)]]

function vRP.updateBankMoney(user_id)
	local bankmoney = vRP.getBankMoney({user_id})
	if bankmoney ~= nil and bankmoney > 0 then
		MySQL.Sync.execute("UPDATE vrp_sharedbanking SET user_money = @user_money WHERE user_id = @user_id", {['user_money'] = bankmoney, ['user_id'] = user_id})
	end
end

function vRP.getMoneyFromBankId(bank_id)
	local sum, sumk = 0, 0
	local result = MySQL.Sync.fetchAll("SELECT * FROM vrp_sharedbanking WHERE bank_id = @bank_id", {['@bank_id'] = bank_id})
	if result ~= nil then
		for k, v in ipairs(result) do
			sum = sum + result[k].user_money
			sumk = sumk + 1
        end
		return sum, sumk
	end
	return 0, 0
end

function vRP.getBankAccount(user_id)
	local result = MySQL.Sync.fetchAll("SELECT * FROM vrp_sharedbanking WHERE user_id = @user_id", {['@user_id'] = user_id})
	if result[1] ~= nil then
		return result[1].bank_account
	end
	return ""
end

function vRP.getBankId(user_id)
	local result = MySQL.Sync.fetchAll("SELECT * FROM vrp_sharedbanking WHERE user_id = @user_id", {['@user_id'] = user_id})
   	if result[1] ~= nil then
        return result[1].bank_id
    end
    return 0
end

local function ch_createaccount(player, choice)
    local user_id = vRP.getUserId({player})
    vRP.prompt({player, "A chi vuoi creare l'account? [ID]:", "", function(player, id_scelto)
        local account = MySQL.Sync.fetchAll("SELECT * FROM vrp_sharedbanking WHERE user_id = @user_id", {['@user_id'] = id_scelto})
        if id_scelto ~= nil or id_scelto ~= 0 then
			if account[1].bank_id ~= 0 then
            	if account[1].bank_account == nil then
                	local bank_account = vRP.generateStringNumber({"DDDDLLLL"})
                	MySQL.Async.execute("UPDATE vrp_sharedbanking SET bank_account = @bank_account WHERE user_id = @user_id", {['@user_id'] = id_scelto, ['@bank_account'] = bank_account})
					vRPclient.notify(player, {"Account creato con successo! ID account: ~g~"..bank_account})
                	--vMySQL.execute("vRP/save_bank_account", {bank_account = bank_account, user_id = user_id})
            	else
                	vRPclient.notify(player, {"~r~Il giocatore possiede gia' un account bancario!"})
            	end
			else
				vRPclient.notify(player, {"~r~Il giocatore non risulta registrato a nessuna banca!"})
			end
        else
            vRPclient.notify(player, {"~r~Inserisci un id valido!"})
        end
    end})
end

local function ch_checkaccount(player, choice)
    local nomebanca = nil
    vRP.prompt({player, "A chi vuoi controllare la banca? [ID]:", "", function(player, id_scelto)
		if id_scelto ~= nil and id_scelto ~= 0 then
        	MySQL.Async.fetchAll("SELECT * FROM vrp_sharedbanking WHERE user_id = @user_id", {['@user_id'] = id_scelto}, function(result)
				if result ~= nil then
            		local bank_id = result[1].bank_id
            		if result[1] ~= nil and bank_id ~= 0 then
                		if bank_id == 1 then
                    		nomebanca = "Fleeca"
                		elseif bank_id == 2 then
                    		nomebanca = "Pacific Standard"
                		elseif bank_id == 3 then
                    		nomebanca = "Blaine County"
                		end
            		end

            		if nomebanca ~= nil and bank_id ~= 0 then
                		vRPclient.notify(player, {"Il giocatore ha l'account registrato alla ~g~"..nomebanca})
            		else
                		vRPclient.notify(player, {"~r~Il tuo account non e' registrato su nessuna banca!"})
            		end
				end
        	end)
		else
			vRPclient.notify(player, {"~r~Inserisci un id valido!"})
		end
    end})
end

local function ch_changebank(player, choice)
	local nomebanca = nil
	local user_id = vRP.getUserId({player})
	if user_id ~= nil then
		vRP.prompt({player, "Inserisci il giocatore a cui cambiare la banca [ID]:", "", function(player, id_scelto)
			if id_scelto ~= nil and id_scelto ~= 0 then
				vRP.prompt({player, "Inserisci l'ID della banca da cambiare: 1 Fleeca, 2 Pacific, 3 Blaine", "", function(player, bankid_scelto)
					if bankid_scelto ~= 0 and bankid_scelto ~= nil then
						bankid_scelto = tonumber(bankid_scelto)
	                	if bankid_scelto == 1 then
	                    	nomebanca = "Fleeca"
	                	elseif bankid_scelto == 2 then
	                    	nomebanca = "Pacific Standard"
	                	elseif bankid_scelto == 3 then
	                    	nomebanca = "Blaine County"
	                	end
						vRPclient.notify(player, {"Filiale aggiornata alla ~g~"..nomebanca})
						MySQL.Sync.execute("UPDATE vrp_sharedbanking SET bank_id = @bank_id WHERE user_id = @user_id", {['bank_id'] = bankid_scelto, ['user_id'] = id_scelto})
					else
						vRPclient.notify(player, {"~r~Inserisci un ID banca valido!"})
					end
				end})
			else
				vRPclient.notify(player, {"~r~Inserisci un ID utente valido!"})
			end
		end})
	end
end

local function build_banker_menu(player)
    local user_id = vRP.getUserId({player})
    if user_id ~= nil then
        for k, v in pairs(config.bankierjob) do
            local x, y, z, type = table.unpack(v)

			local bank_menu = {
			    name = "Banca",
			    css = {top = "75px", header_color = "rgba(0,255,255,0)"}
			}

			bank_menu["Crea account"] = {ch_createaccount, "Crea un'account bancario ad un giocatore"}
			bank_menu["Controlla banca"] = {ch_checkaccount, "Controlla l'account bancario di un giocatore"}
			bank_menu["Cambia filiale"] = {ch_changebank, "Cambia la filiale di un giocatore"}

            banker_enter = function(player, area)
				if vRP.hasPermission({user_id, config.bankierPex}) then
                	local user_id = vRP.getUserId({player})
                	if user_id ~= nil then
                    	vRP.openMenu({player, bank_menu})
                    	vRPclient.disableF10(player, {true})
                	end
				else
					vRPclient.notify(player, {"~r~Non sei un banchiere!"})
				end
			end

            banker_leave = function(player, area)
                vRP.closeMenu({player})
            	vRPclient.disableF10(player, {false})
            end

            vRPclient.addMarker(player, {x, y, z, 0.7, 0.7, 0.5, 255, 128, 0, 102, 150}) --x, y, z, sx, sy, sz, r, g, b, a, visible_distance
            vRP.setArea({player, "vRP:banchiere"..k, x, y, z, 1.5, 1.5, banker_enter, banker_leave})
        end
    end
end

AddEventHandler("vRP:playerSpawn", function(user_id, source, first_spawn)
    local bankmoney = vRP.getBankMoney({user_id})
	local result = MySQL.Sync.fetchAll("SELECT * FROM vrp_sharedbanking WHERE user_id = @user_id", {['@user_id'] = user_id})
   	if result[1] == nil then
		MySQL.Sync.fetchAll("INSERT INTO vrp_sharedbanking(user_id, user_money) VALUES(@user_id, @user_money)",
    	   {["@user_id"] = user_id, ["@user_money"] = bankmoney}, function(resultmoney)
        end)
	end
    if first_spawn then
        build_banker_menu(source)
    end
end)
