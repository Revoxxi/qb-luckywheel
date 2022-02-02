local QBCore = exports['qb-core']:GetCoreObject()
local _wheel = nil
local _lambo = nil
local _isShowCar = false
local _wheelPos = vector3(948.42, 44.67, 70.86) --vector3(925.13, 54.47, 71.26)
local _baseWheelPos = vector3(948.42, 44.67, 70.6) --vector3(925.13, 54.47, 71.0)
local playerUpdate = false
local casinoprops = {}

local showCar = 'furia'

Citizen.CreateThread(function()
    if playerUpdate == false then
        PlayerData = QBCore.Functions.GetPlayerData()
		playerUpdate = true
    end
end)

local Keys = {
    ["ESC"] = 322, ["BACKSPACE"] = 177, ["E"] = 38, ["ENTER"] = 18, ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173
}
local _isRolling = false

Citizen.CreateThread(function()
	

    if playerUpdate then
        local model = GetHashKey('vw_prop_vw_luckywheel_02a')
        local baseWheelModel = GetHashKey('vw_prop_vw_luckywheel_01a')

        Citizen.CreateThread(function()
            RequestModel(baseWheelModel)
            while not HasModelLoaded(baseWheelModel) do
                Citizen.Wait(0)
            end

            _basewheel = CreateObject(baseWheelModel, _baseWheelPos.x, _baseWheelPos.y, _baseWheelPos.z, false, false, true)
            SetEntityHeading(_basewheel, 0.0)
            SetModelAsNoLongerNeeded(baseWheelModel)
            RequestModel(model)
            while not HasModelLoaded(model) do
                Citizen.Wait(0)
            end

            _wheel = CreateObject(model, _wheelPos.x, _wheelPos.y, _wheelPos.z, false, false, true)
            SetEntityHeading(_wheel, 0.0)
            SetModelAsNoLongerNeeded(model)
            spawnveh()
            table.insert(casinoprops, _wheel)
            table.insert(casinoprops, _basewheel)
        end)
    end
end)

Citizen.CreateThread(function()
    while true do
        if _lambo ~= nil then
            local _heading = GetEntityHeading(_lambo)
            local _z = _heading - 0.3
            SetEntityHeading(_lambo, _z)
        end
        Citizen.Wait(5)
    end
end)

RegisterNetEvent("esx_tpnrp_luckywheel:doRoll")
AddEventHandler("esx_tpnrp_luckywheel:doRoll", function(_priceIndex)
    _isRolling = true
    SetEntityHeading(_wheel, 0.0)
    SetEntityRotation(_wheel, 0.0, 0.0, 0.0, 1, true)
    Citizen.CreateThread(function()
        local speedIntCnt = 1
        local rollspeed = 1.0
        -- local _priceIndex = math.random(1, 20)
        local _winAngle = (_priceIndex - 1) * 18
        local _rollAngle = _winAngle + (360 * 8)
        local _midLength = (_rollAngle / 2)
        local intCnt = 0
        while speedIntCnt > 0 do
            local retval = GetEntityRotation(_wheel, 1)
            if _rollAngle > _midLength then
                speedIntCnt = speedIntCnt + 1
            else
                speedIntCnt = speedIntCnt - 1
                if speedIntCnt < 0 then
                    speedIntCnt = 0
                    
                end
            end
            intCnt = intCnt + 1
            rollspeed = speedIntCnt / 10
            local _y = retval.y - rollspeed
            _rollAngle = _rollAngle - rollspeed
            -- if _rollAngle < 5.0 then
            --     if _y > _winAngle then
            --         _y = _winAngle
            --     end
            -- end
            SetEntityRotation(_wheel, 0.0, _y, 0.0, 1, true) --58.32
            Citizen.Wait(0)
        end
    end)
end)

RegisterNetEvent("esx_tpnrp_luckywheel:rollFinished")
AddEventHandler("esx_tpnrp_luckywheel:rollFinished", function()
    _isRolling = false
end)


function doRoll()
    if not _isRolling then
        _isRolling = true
        local playerPed = PlayerPedId()
        local _lib = 'anim_casino_a@amb@casino@games@lucky7wheel@female'
        if IsPedMale(playerPed) then
            _lib = 'anim_casino_a@amb@casino@games@lucky7wheel@male'
        end
        local lib, anim = _lib, 'enter_right_to_baseidle'
		
		
		if not HasAnimDictLoaded(lib) then
			RequestAnimDict(lib)
		repeat Wait(0) until HasAnimDictLoaded(lib)
		end
		
        if HasAnimDictLoaded(lib) then
            local _movePos = vector3(947.33, 43.82, 71.64)
            TaskGoStraightToCoord(playerPed, _movePos.x, _movePos.y, _movePos.z, 1.0, -1, 357.52, 0.0)
            local _isMoved = false
            while not _isMoved do
                local coords = GetEntityCoords(PlayerPedId())
                if coords.x >= (_movePos.x - 0.01) and coords.x <= (_movePos.x + 0.01) and coords.y >= (_movePos.y - 0.01) and coords.y <= (_movePos.y + 0.01) then
                    _isMoved = true
                end
                Citizen.Wait(400)
            end
            TaskPlayAnim(playerPed, lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
            while IsEntityPlayingAnim(playerPed, lib, anim, 3) do
                Citizen.Wait(0)
                DisableAllControlActions(0)
            end
            TaskPlayAnim(playerPed, lib, 'enter_to_armraisedidle', 8.0, -8.0, -1, 0, 0, false, false, false)
            while IsEntityPlayingAnim(playerPed, lib, 'enter_to_armraisedidle', 3) do
                Citizen.Wait(0)
                DisableAllControlActions(0)
            end
            TriggerServerEvent("esx_tpnrp_luckywheel:getLucky", showCar)
            TaskPlayAnim(playerPed, lib, 'armraisedidle_to_spinningidle_high', 8.0, -8.0, -1, 0, 0, false, false, false)
        end
    end
end

-- Menu Controls
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        local coords = GetEntityCoords(PlayerPedId())
        if(GetDistanceBetweenCoords(coords, _wheelPos.x, _wheelPos.y, _wheelPos.z, true) < 1.5) and not _isRolling then
			DrawText3Ds(_wheelPos.x, _wheelPos.y, _wheelPos.z + 0.5, 'Press ~g~E~w~ to spin the wheel for $5000')
            if IsControlJustReleased(0, Keys['E']) then
                doRoll()
            end
        end
    end
end)

function spawnveh()
    Zones = {
        VehicleSpawnPoint = {
            Pos   = {x = 935.01, y = 42.80, z = 72.13},
            Heading = 182.73
        }
    }
	local vehicle = nil
    local carmodel = GetHashKey(showCar)
    RequestModel(carmodel)
    while not HasModelLoaded(carmodel) do
        Citizen.Wait(0)
    end

	vehicle = CreateVehicle(carmodel, Zones.VehicleSpawnPoint.Pos.x, Zones.VehicleSpawnPoint.Pos.y, Zones.VehicleSpawnPoint.Pos.z, Zones.VehicleSpawnPoint.Heading, false, false)
	SetModelAsNoLongerNeeded(carmodel)
	Citizen.Wait(10)
    SetEntityAsMissionEntity(vehicle, true, true)
    SetVehicleHasBeenOwnedByPlayer(vehicle, true)
    SetVehicleOnGroundProperly(vehicle)
    Citizen.Wait(10)
    FreezeEntityPosition(vehicle, true)
    SetEntityInvincible(vehicle, true)
    SetVehicleDoorsLocked(vehicle, 2)
    _lambo = vehicle
    table.insert(casinoprops, _lambo)
	
end

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		for _,wheel in pairs(casinoprops) do
            DeleteEntity(_wheel)
            DeleteEntity(_basewheel)
            DeleteEntity(_lambo)
        end
	end
end)


function DrawText3Ds(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end