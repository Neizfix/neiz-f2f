local QBCore = exports['qb-core']:GetCoreObject()
local activeDuels = {}
local originalBuckets = {}


RegisterNetEvent('f2f:attimabi')
AddEventHandler('f2f:attimabi', function(targetId)
    local source = source
    local requester = QBCore.Functions.GetPlayer(source)
    local target = QBCore.Functions.GetPlayer(targetId)
    if not requester or not target then
        TriggerClientEvent('QBCore:Notify', source, 'Oyuncu bulunamadı!', 'error')
        return
    end
    if source == targetId then
        TriggerClientEvent('QBCore:Notify', source, 'Kendine düello atamazsın!', 'error')
        return
    end
    local requesterCoords = GetEntityCoords(GetPlayerPed(source))
    local targetCoords = GetEntityCoords(GetPlayerPed(targetId))
    local distance = #(requesterCoords - targetCoords)
    if distance > Config.MaxDistance then
        TriggerClientEvent('QBCore:Notify', source, 'Oyuncu çok uzakta!', 'error')
        return
    end
    if activeDuels[source] or activeDuels[targetId] then
        TriggerClientEvent('QBCore:Notify', source, 'Zaten aktif bir düello var!', 'error')
        return
    end
    TriggerClientEvent('f2f:receiveRequest', targetId, source, requester.PlayerData.charinfo.firstname .. ' ' .. requester.PlayerData.charinfo.lastname)
end)

RegisterNetEvent('f2f:sagolabi')
AddEventHandler('f2f:sagolabi', function(requesterId)
    local source = source
    local requester = QBCore.Functions.GetPlayer(requesterId)
    local target = QBCore.Functions.GetPlayer(source)
    if not requester or not target then
        TriggerClientEvent('QBCore:Notify', source, 'Oyuncu bulunamadı!', 'error')
        return
    end
    if activeDuels[requesterId] or activeDuels[source] then
        TriggerClientEvent('QBCore:Notify', source, 'Zaten aktif bir düello var!', 'error')
        return
    end
    activeDuels[requesterId] = source
    activeDuels[source] = requesterId
    local duelBucket = math.random(50, 100)
    originalBuckets[requesterId] = GetPlayerRoutingBucket(requesterId)
    originalBuckets[source] = GetPlayerRoutingBucket(source)
    SetPlayerRoutingBucket(requesterId, duelBucket)
    SetPlayerRoutingBucket(source, duelBucket)
    TriggerClientEvent('f2f:kabul', requesterId, source, target.PlayerData.charinfo.firstname .. ' ' .. target.PlayerData.charinfo.lastname)
    TriggerClientEvent('f2f:startDuel', requesterId, source, target.PlayerData.charinfo.firstname .. ' ' .. target.PlayerData.charinfo.lastname, 1)
    TriggerClientEvent('f2f:startDuel', source, requesterId, requester.PlayerData.charinfo.firstname .. ' ' .. requester.PlayerData.charinfo.lastname, 2)
end)

RegisterNetEvent('f2f:reddettinayip')
AddEventHandler('f2f:reddettinayip', function(requesterId)
    local source = source
    local requester = QBCore.Functions.GetPlayer(requesterId)
    local target = QBCore.Functions.GetPlayer(source)
    if requester and target then
        TriggerClientEvent('f2f:korktu', requesterId, source, target.PlayerData.charinfo.firstname .. ' ' .. target.PlayerData.charinfo.lastname)
        
        TriggerClientEvent('QBCore:Notify', source, 'F2F teklifini reddettiniz!', 'info')
    end
end)

RegisterNetEvent('f2f:gecmisolsund')
AddEventHandler('f2f:gecmisolsund', function()
    local source = source
    if activeDuels[source] then
        local opponentId = activeDuels[source]
        local loser = QBCore.Functions.GetPlayer(source)
        local winner = QBCore.Functions.GetPlayer(opponentId)
        if loser and winner then
            local loserName = loser.PlayerData.charinfo.firstname .. ' ' .. loser.PlayerData.charinfo.lastname
            local winnerName = winner.PlayerData.charinfo.firstname .. ' ' .. winner.PlayerData.charinfo.lastname
            EndDuel(source, opponentId)
            TriggerClientEvent('QBCore:Notify', opponentId, 'Düelloyu kazandınız!', 'success')
            TriggerClientEvent('QBCore:Notify', source, 'Düelloyu kaybettiniz!', 'error')
        else
            EndDuel(source, opponentId)
            TriggerClientEvent('QBCore:Notify', opponentId, 'Düelloyu kazandınız!', 'success')
            TriggerClientEvent('QBCore:Notify', source, 'Düelloyu kaybettiniz!', 'error')
        end
    end
end)


function EndDuel(player1, player2)
    if activeDuels[player1] then
        activeDuels[player1] = nil
    end
    if activeDuels[player2] then
        activeDuels[player2] = nil
    end
    
    if originalBuckets[player1] then
        SetPlayerRoutingBucket(player1, originalBuckets[player1])
        originalBuckets[player1] = nil
    end
    if originalBuckets[player2] then
        SetPlayerRoutingBucket(player2, originalBuckets[player2])
        originalBuckets[player2] = nil
    end
    TriggerClientEvent('f2f:ellerinesaglik', player1)
    if player2 then
        TriggerClientEvent('f2f:ellerinesaglik', player2)
    end
end

AddEventHandler('playerDropped', function()
    local source = source
    if activeDuels[source] then
        local opponentId = activeDuels[source]
        EndDuel(source, opponentId)
        if opponentId then
            TriggerClientEvent('QBCore:Notify', opponentId, 'Rakip bağlantısı kesildi, düello bitti!', 'info')
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        for player1, player2 in pairs(activeDuels) do
            EndDuel(player1, player2)
        end
    end
end)

RegisterNetEvent('f2f:albuseninsilah')
AddEventHandler('f2f:albuseninsilah', function()
    local source = source
    
    if activeDuels[source] then
        local player = QBCore.Functions.GetPlayer(source)
        if player then
            TriggerClientEvent('f2f:tutsunu', source, Config.WeaponItem)
            
            TriggerClientEvent('QBCore:Notify', source, 'Silah verildi!', 'success')
        end
    end
end) 