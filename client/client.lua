function DisplayHelpText(str)
	SetTextComponentFormat("STRING")
	AddTextComponentString(str)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

function addBlip(x, y, z, name, color)
	local blip = AddBlipForCoord(x, y, z)
	SetBlipSprite(blip, 108)
	SetBlipScale(blip, 0.9)
	SetBlipColour(blip, color)
	SetBlipAsShortRange(blip, true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString(name)
	EndTextCommandSetBlipName(blip)
end

--------- leggenda ----------
-- id 1 = fleeca
-- id 2 = pacific
-- id 3 = blaine county
-----------------------------
local fcreated = 0
local pscreated = 0
local bcreated = 0

Citizen.CreateThread(function()
	while true do
		for k, v in pairs(config.banks) do
			local x, y, z, type = table.unpack(v)
			Citizen.Wait(10)
			if type == 1 then
				if fcreated ~= config.maxFleeca then
					fcreated = fcreated + 1
					addBlip(x, y, z, "Fleeca", 2)
				end
			elseif type == 2 then
				if pscreated ~= config.maxPacific then
					pscreated = pscreated + 1
					addBlip(x, y, z, "Pacific Standard", 5)
				end
			elseif type == 3 then
				if bcreated ~= config.maxBlaine then
					bcreated = bcreated + 1
					addBlip(x, y, z, "Blaine County", 1)
				end
			end
		end
	end
end)

-- create marker from type
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5)
        for k, blip in pairs(config.robbery) do
            x, y, z, type = table.unpack(blip)
			local usedType = 0
			local source = GetPlayerServerId()
			local pos = GetEntityCoords(GetPlayerPed(-1), true)
			local distance = Vdist(pos.x, pos.y, pos.z, x, y, z)
            if type == 1 then --fleeca
                DrawMarker(27, x, y, z, 0, 0, 0, 0, 0, 0, 0.7, 0.7, 0.7, 0, 255, 0, 100, false, false, 2, false, false, false, false) --green marker
				if distance < 1 then
	                DisplayHelpText('Premi ~INPUT_TALK~ per rapinare la banca')
	                if IsControlJustPressed(0, 38) then
						usedType = 1
	                    TriggerServerEvent("vrp_sharedbanking:robbank", source, usedType)
	                end
	            end
            elseif type == 2 then --pacific standard
                DrawMarker(27, x, y, z, 0, 0, 0, 0, 0, 0, 0.7, 0.7, 0.7, 255, 255, 0, 100, false, false, 2, false, false, false, false) --yellow marker
				if distance < 1 then
	                DisplayHelpText('Premi ~INPUT_TALK~ per rapinare la banca')
	                if IsControlJustPressed(0, 38) then
						usedType = 2
	                    TriggerServerEvent("vrp_sharedbanking:robbank", source, usedType)
	                end
	            end
            elseif type == 3 then --blaine county
                DrawMarker(27, x, y, z, 0, 0, 0, 0, 0, 0, 0.7, 0.7, 0.7, 255, 0, 0, 100, false, false, 2, false, false, false, false) --red marker
				if distance < 1 then
	                DisplayHelpText('Premi ~INPUT_TALK~ per rapinare la banca')
	                if IsControlJustPressed(0, 38) then
						usedType = 3
	                    TriggerServerEvent("vrp_sharedbanking:robbank", source, usedType)
	                end
	            end
            end
        end
    end
end)
