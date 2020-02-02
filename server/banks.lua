local is_int = function(n)
    return (type(n) == "number") and (math.floor(n) == n)
end

local function money_withdraw(player, choice)
    vRP.prompt({player, "Quanto vuoi ritirare?", "", function(player, amount)
        local user_id = vRP.getUserId({player})
        local bank_money = vRP.getBankMoney({user_id})
        amount = tonumber(amount)
        check = is_int(amount)

        if check then
            if amount ~= nil and amount > 0 then
                if bank_money >= amount then
                    vRP.tryWithdraw({user_id, amount})
                    vRPclient.notify(player, {"~w~Hai ritirato ~g~"..amount.."$"})
                    vRP.updateBankMoney(user_id)
                else
                    vRPclient.notify(player, {"~r~Non hai abbatsanza soldi in banca da ritirare!"})
                end
            end
        else
            vRPclient.notify(player, {"~r~Inserisci un numero valido!"})
        end
    end})
end

local function money_deposit(player, choice)
    vRP.prompt({player, "Quanto vuoi depositare?", "", function(player, amount)
        local user_id = vRP.getUserId({player})
        local money = vRP.getMoney({user_id})
        amount = tonumber(amount)
        check = is_int(amount)

        if check then
            if amount ~= nil and amount > 0 then
                if money >= amount then
                    vRP.tryDeposit({user_id, amount})
                    vRPclient.notify(player, {"~w~Hai depositato ~g~"..amount.."$"})
                    vRP.updateBankMoney(user_id)
                else
                    vRPclient.notify(player, {"~r~Non hai abbatsanza soldi addosso da depositare!"})
                end
            end
        else
            vRPclient.notify(player, {"~r~Inserisci un numero valido!"})
        end
    end})
end

local function getBankName(bank_id)
    local nomebanca = ""
    if bank_id ~= 0 then
        if bank_id == 1 then
            nomebanca = "Fleeca"
        elseif bank_id == 2 then
            nomebanca = "Pacific Standard"
        elseif bank_id == 3 then
            nomebanca = "Blaine County"
        end
    end
    return nomebanca
end

local function updateBankInfo(user_id)
    local bank_id = vRP.getBankId(user_id)
    local bank_account = vRP.getBankAccount(user_id)
    local bank_name = getBankName(vRP.getBankId(user_id))
    if bank_id ~= nil and bank_account ~= nil and bank_name ~= nil then
        return bank_id, bank_account, bank_name
    end
    return 0, "", ""
end

--- menu ---

local function build_bank_menu(player)
    local user_id = vRP.getUserId({player})
    local bank_id = vRP.getBankId(user_id)
    local bank_account = vRP.getBankAccount(user_id)
    local bank_name = getBankName(vRP.getBankId(user_id))

    if user_id ~= nil then
        for k, v in pairs(config.banks) do
            local x, y, z, type = table.unpack(v)

            bank_enter = function(player, area)
                if user_id ~= nil then
                    local bank_id, bank_account, bank_name = updateBankInfo(user_id)
                    local bank_choice = {
                        name = "Banka",
                        css = {top = "75px", header_color = "rgba(0,255,255,0)"}
                    }

                    if bank_account ~= nil and bank_name ~= nil then
                        bank_choice["Account: "..bank_account] = {function() end, "Questo e' il tuo account bancario"}
                        bank_choice["Banca: "..bank_name] = {function() end, "Questo e' il nome della tua filiale"}
                    else
                        bank_choice["Account: Nessuno"] = {function() end, "Questo e' il tuo account bancario"}
                        bank_choice["Banca: Nessuna"] = {function() end, "Questo e' il nome della tua filiale"}
                    end
                    bank_choice["Ritira"] = {money_withdraw, "Ritira i soldi dal conto della tua filiale"}
                    bank_choice["Deposita"] = {money_deposit, "Deposita soldi nel conto della tua filiale"}

                    if type == bank_id then
                        vRP.openMenu({player, bank_choice})
                        vRPclient.disableF10(player, {true})
                    else
                        vRPclient.notify(player, {"~r~Non hai l'account registrato su questa filiale!"})
                    end
                end
            end

            bank_leave = function(player, area)
                if type == bank_id then
                    vRP.closeMenu({player})
            	    vRPclient.disableF10(player, {false})
                end
            end

            vRPclient.addMarker(player, {x, y, z, 0.7, 0.7, 0.5, 0, 102, 255, 102, 150}) --x, y, z, sx, sy, sz, r, g, b, a, visible_distance

            vRP.setArea({player, "vRP:banca"..k, x, y, z, 1.5, 1.5, bank_enter, bank_leave})
        end
    end
end

AddEventHandler("vRP:playerSpawn", function(user_id, source, first_spawn)
    if first_spawn then
        build_bank_menu(source)
    end
end)
