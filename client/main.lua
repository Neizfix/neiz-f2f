local QBCore = exports['qb-core']:GetCoreObject()
local isInDuel = false
local duelData = nil
local countdownActive = false
local playerFrozen = false
local originalPosition = nil

exports('InF2F', function()
    return isInDuel
end)

RegisterCommand('f2f', function(source, args)
    if #args < 1 then
        QBCore.Functions.Notify('Kullanım: /f2f [ID]', 'error')
        return
    end
    
    local targetId = tonumber(args[1])
    if not targetId then
        QBCore.Functions.Notify('Geçersiz ID!', 'error')
        return
    end
    
    local playerId = GetPlayerServerId(PlayerId())
    if targetId == playerId then
        QBCore.Functions.Notify('Kendine düello atamazsın!', 'error')
        return
    end
    
    originalPosition = GetEntityCoords(PlayerPedId())
    
    TriggerServerEvent('f2f:attimabi', targetId)
end)

RegisterNetEvent('f2f:receiveRequest')
AddEventHandler('f2f:receiveRequest', function(requesterId, requesterName)
    if lib and lib.alertDialog then
        local accept = lib.alertDialog({
            header = Config.NotifyTitle,
            content = string.format(Config.NotifyMessage, requesterId),
            centered = true,
            cancel = true,
            labels = {
                confirm = Config.NotifyAccept,
                cancel = Config.NotifyDecline
            },
            type = 'info'
        })
        
        if accept == 'confirm' then
            TriggerServerEvent('f2f:sagolabi', requesterId)
        else
            TriggerServerEvent('f2f:reddettinayip', requesterId)
        end
    else
        QBCore.Functions.Notify(string.format(Config.NotifyMessage, requesterId), 'primary', 10000)
    end
end)

RegisterNetEvent('f2f:kabul')
AddEventHandler('f2f:kabul', function(targetId, targetName)
    QBCore.Functions.Notify(targetName .. ' F2F teklifinizi kabul etti!', 'success')
end)

RegisterNetEvent('f2f:korktu')
AddEventHandler('f2f:korktu', function(targetId, targetName)
    QBCore.Functions.Notify(targetName .. ' F2F teklifinizi reddetti!', 'error')
end)

RegisterNetEvent('f2f:startDuel')
AddEventHandler('f2f:startDuel', function(targetId, targetName, position)
    if not originalPosition then
        originalPosition = GetEntityCoords(PlayerPedId())
    end
    
    StartDuel(targetId, position)
end)

function StartDuel(targetId, position)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    if not originalPosition then
        originalPosition = playerCoords
    end
    
    local duelPos1 = Config.DuelPos1
    local duelPos2 = Config.DuelPos2
    
    if position == 1 then
        SetEntityCoords(playerPed, duelPos1.x, duelPos1.y, duelPos1.z, false, false, false, true)
        SetEntityHeading(playerPed, 90.0)
    elseif position == 2 then
        SetEntityCoords(playerPed, duelPos2.x, duelPos2.y, duelPos2.z, false, false, false, true)
        SetEntityHeading(playerPed, 270.0)
    end
    
    duelData = {
        targetId = targetId,
        position1 = duelPos1,
        position2 = duelPos2,
        startTime = GetGameTimer()
    }
    
    isInDuel = true
    
    FreezePlayerForCountdown(true)
    
    SetPedArmour(playerPed, 100)
    
    StartCountdown()
end

function FreezePlayer(freeze)
    local playerPed = PlayerPedId()
    playerFrozen = freeze
    
    if freeze then
        FreezeEntityPosition(playerPed, true)
        SetPlayerControl(PlayerId(), false, 0)
        
        DisableControlAction(0, 24, true)
        DisableControlAction(0, 25, true)
        DisableControlAction(0, 140, true)
        DisableControlAction(0, 141, true)
        DisableControlAction(0, 142, true)
        DisableControlAction(0, 257, true)
        DisableControlAction(0, 263, true)
        DisableControlAction(0, 264, true)
        
        SetNuiFocus(false, false)
    else
        FreezeEntityPosition(playerPed, false)
        SetPlayerControl(PlayerId(), true, 0)
        
        EnableControlAction(0, 24, true)
        EnableControlAction(0, 25, true)
        EnableControlAction(0, 140, true)
        EnableControlAction(0, 141, true)
        EnableControlAction(0, 142, true)
        EnableControlAction(0, 257, true)
        EnableControlAction(0, 263, true)
        EnableControlAction(0, 264, true)
        
        SetNuiFocus(false, false)
    end
end

function FreezePlayerForCountdown(freeze)
    local playerPed = PlayerPedId()
    
    if freeze then
        FreezeEntityPosition(playerPed, true)
        
        DisableControlAction(0, 24, true)
        DisableControlAction(0, 25, true)
        DisableControlAction(0, 140, true)
        DisableControlAction(0, 141, true)
        DisableControlAction(0, 142, true)
        DisableControlAction(0, 257, true)
        DisableControlAction(0, 263, true)
        DisableControlAction(0, 264, true)
        
        SetNuiFocus(false, false)
    else
        FreezeEntityPosition(playerPed, false)
        
        EnableControlAction(0, 24, true)
        EnableControlAction(0, 25, true)
        EnableControlAction(0, 140, true)
        EnableControlAction(0, 141, true)
        EnableControlAction(0, 142, true)
        EnableControlAction(0, 257, true)
        EnableControlAction(0, 263, true)
        EnableControlAction(0, 264, true)
        
        SetNuiFocus(false, false)
    end
end

function StartCountdown()
    countdownActive = true
    
    SendNUIMessage({
        type = 'startCountdown',
        number = Config.CountdownTime
    })
    
    FreezePlayerForCountdown(true)
    
    TriggerServerEvent('f2f:albuseninsilah')
    
    CreateThread(function()
        local countdown = Config.CountdownTime
        
        while countdown > 0 and countdownActive do
            Wait(1000)
            countdown = countdown - 1
        end
        
        if countdownActive then
            countdownActive = false
            FreezePlayerForCountdown(false)
        end
    end)
    
    CreateThread(function()
        while countdownActive do
            Wait(0)
            DisableControlAction(0, 24, true)
            DisableControlAction(0, 25, true)
            DisableControlAction(0, 140, true)
            DisableControlAction(0, 141, true)
            DisableControlAction(0, 142, true)
            DisableControlAction(0, 257, true)
            DisableControlAction(0, 263, true)
            DisableControlAction(0, 264, true)
        end
    end)
end

RegisterNUICallback('countdownFinished', function(data, cb)
    countdownActive = false
    FreezePlayerForCountdown(false)
    
    cb('ok')
end)

RegisterNetEvent('f2f:tutsunu', function()
    GiveWeaponPlayer()
end)

function GiveWeaponPlayer()
    CreateThread(function()
        local playerPed = PlayerPedId()
        local weaponName = Config.Weapon
        local weaponHash = GetHashKey(weaponName)

        GiveWeaponToPed(playerPed, weaponHash, 999, false, true)
        SetCurrentPedWeapon(playerPed, weaponHash, true)

        SetPedAmmo(playerPed, weaponHash, 999)
        SetPedInfiniteAmmo(playerPed, true, weaponHash)

        SetPedCurrentWeaponVisible(playerPed, true, true, true, true)

        if GetSelectedPedWeapon(playerPed) ~= weaponHash then
            SetCurrentPedWeapon(playerPed, weaponHash, true)
        end

        StartWeaponProtection(weaponHash)
    end)
end

function StartWeaponProtection(weaponHash)
    CreateThread(function()
        while isInDuel do
            Wait(2000)
            
            if not isInDuel then
                break
            end
            
            local playerPed = PlayerPedId()

            if not HasPedGotWeapon(playerPed, weaponHash, false) then
                GiveWeaponToPed(playerPed, weaponHash, 999, false, true)
                SetCurrentPedWeapon(playerPed, weaponHash, true)
                SetPedAmmo(playerPed, weaponHash, 999)
                SetPedInfiniteAmmo(playerPed, true, weaponHash)
            end

            if GetSelectedPedWeapon(playerPed) ~= weaponHash then
                SetCurrentPedWeapon(playerPed, weaponHash, true)
            end
        end
        
        if not isInDuel then
            RemoveDuelWeapon()
        end
    end)
end

function RemoveDuelWeapon()
    local playerPed = PlayerPedId()
    local weaponHash = GetHashKey(Config.Weapon)

    RemoveWeaponFromPed(playerPed, weaponHash)
    
    SetCurrentPedWeapon(playerPed, GetHashKey('WEAPON_UNARMED'), true)
    
    SetPedInfiniteAmmo(playerPed, false, weaponHash)
    
    SetPedAmmo(playerPed, weaponHash, 0)
    
    SetPedCurrentWeaponVisible(playerPed, false, true, true, true)
    
    RemoveAllPedWeapons(playerPed, true)
    
    if HasPedGotWeapon(playerPed, weaponHash, false) then
        RemoveWeaponFromPed(playerPed, weaponHash)
    end
end

function ForceRemoveAllWeapons()
    local playerPed = PlayerPedId()
    local weaponHash = GetHashKey(Config.Weapon)
    
    RemoveAllPedWeapons(playerPed, true)
    
    SetCurrentPedWeapon(playerPed, GetHashKey('WEAPON_UNARMED'), true)
    
    SetPedInfiniteAmmo(playerPed, false, weaponHash)
    
    SetPedCurrentWeaponVisible(playerPed, false, true, true, true)
end

RegisterNetEvent('f2f:ellerinesaglik')
AddEventHandler('f2f:ellerinesaglik', function()
    isInDuel = false
    duelData = nil
    countdownActive = false
    
    RemoveDuelWeapon()
    
    FreezePlayer(false)
    
    SendNUIMessage({
        type = 'stopCountdown'
    })
    
    if originalPosition then
        local playerPed = PlayerPedId()
        SetEntityCoords(playerPed, originalPosition.x, originalPosition.y, originalPosition.z, false, false, false, true)
        originalPosition = nil
    end
    
    local playerPed = PlayerPedId()
    TriggerEvent('hospital:client:Revive')
    
    CreateThread(function()
        Wait(1000)
        RemoveDuelWeapon()
        Wait(500)
        ForceRemoveAllWeapons()
        Wait(500)
        RemoveDuelWeapon()
    end)
end)

CreateThread(function()
    while true do
        Wait(1000)
        if isInDuel then
            local playerPed = PlayerPedId()
            if IsEntityDead(playerPed) then
                TriggerServerEvent('f2f:gecmisolsund')
                
                isInDuel = false
                duelData = nil
                countdownActive = false
                
                RemoveDuelWeapon()
                
                FreezePlayer(false)
                
                if originalPosition then
                    SetEntityCoords(playerPed, originalPosition.x, originalPosition.y, originalPosition.z, false, false, false, true)
                    originalPosition = nil
                end
                
                CreateThread(function()
                    Wait(1000)
                    RemoveDuelWeapon()
                    Wait(500)
                    ForceRemoveAllWeapons()
                    Wait(500)
                    RemoveDuelWeapon()
                end)
            end
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName and isInDuel then
        TriggerServerEvent('f2f:playerDisconnected')
        
        RemoveDuelWeapon()
        
        FreezePlayer(false)
        
        if originalPosition then
            local playerPed = PlayerPedId()
            SetEntityCoords(playerPed, originalPosition.x, originalPosition.y, originalPosition.z, false, false, false, true)
            originalPosition = nil
        end
        
        ForceRemoveAllWeapons()
    end
end)






