local lastrobbed = 0

RegisterServerEvent("vrp_sharedbanking:robbank")
AddEventHandler("vrp_sharedbanking:robbank", function(player_source, type)

    local robtime = (config.robbTime*60000)
    if lastrobbed ~= 0 and robtime > (os.time() - lastrobbed) then
        vRPclient.notify(player_source, {"~r~Il sistema di banche di Los Santos e' in pausa. Aspetta "..(1200-(os.time()-lastrobbed)).." secondi."})
        return
    end
    lastrobbed = os.time()

    local user_id = vRP.getUserId({player_source})
    vRP.updateBankMoney(user_id)
    local bank_id = vRP.getBankId(user_id)
    for k, v in pairs(config.robbery) do
        local x, y, z, type = table.unpack(v)
    end
    if not vRP.hasPermission({user_id, "cop.whitelisted"}) then
        if type ~= nil and type ~= 0 and type < 4 then
            if bank_id ~= type then
                local daSottrarre, perc = 0, 0
                local cops = vRP.getUsersByPermission({"cop.whitelisted"})
                if #cops > config.minPolice then
                    if user_id ~= nil then
                        local money, numero = vRP.getMoneyFromBankId(type)
                        if money ~= nil and money > 0 then
                            perc = math.floor(((money * 5) / 100) + 0.5)
                            daSottrarre = math.floor((perc / numero) + 0.5)
                            TriggerEvent("vrp_sharedbanking:saveNewBalance", daSottrarre, numero, user_id, type, player_source)
                        end
                    end
                else
                    vRPclient.notify(player_source, {"~r~Non ci sono abbastanza poliziotti online!"})
                end
            else
                vRPclient.notify(player_source, {"~r~Non puoi rapinare la banca a cui sei iscritto!"})
            end
        else
            print("Type in robbank not valid. Check your config file!")
        end
    else
        vRPclient.notify(player_source, {"~r~La polizia non puo' rapinare le banche!"})
    end
end)

RegisterServerEvent("vrp_sharedbanking:saveNewBalance")
AddEventHandler("vrp_sharedbanking:saveNewBalance", function(money, numero, user_id, type, source)
    local outMoney = 0
    if money ~= nil and money > 0 and user_id ~= nil then
        for i=1, numero do
            local result = MySQL.Sync.fetchAll("SELECT * FROM vrp_sharedbanking WHERE bank_id = @bank_id", {['bank_id'] = type})
            outMoney = result[i].user_money
            if outMoney > 150 then
                local data = result[i].user_money
                local raped_id = result[i].user_id
                local update = data - money
                MySQL.Async.execute("UPDATE vrp_sharedbanking SET user_money = @user_money WHERE bank_id = @bank_id AND user_id = @user_id", {['user_money'] = update, ['bank_id'] = type, ['user_id'] = raped_id})
                MySQL.Async.execute("UPDATE vrp_user_moneys SET bank = @bank WHERE user_id = @user_id", {['bank'] = update, ['user_id'] = raped_id})
            end
        end
        if outMoney > 150 then
            local bank_money = vRP.getBankMoney({user_id})
            local updated = bank_money + (money*numero)
            MySQL.Async.execute("UPDATE vrp_sharedbanking SET user_money = @user_money WHERE user_id = @user_id", {['user_money'] = updated, ['user_id'] = user_id})
            vRP.setBankMoney({user_id, updated})
            vRPclient.notify(source, {"~w~Hai ottenuto ~g~"..(money*numero).."$"})
        else
            vRPclient.notify(source, {"~r~Hanno gia' svuotato tutti gli account di questa filiale!"})
        end
    end
end)
