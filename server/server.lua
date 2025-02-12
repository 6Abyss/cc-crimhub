QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateCallback("cc-crimhub:sv:buyitem", function(source, cb, data)
    local table = data.data
    local item = table.item
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local hasMoney = false
    if table.phonecrypto then
        hasMoney = exports['qb-phone']:RemoveCrypto(src, table.payment, table.amount)
    else
        hasMoney = Player.Functions.RemoveMoney(table.payment, table.amount)
    end
    if hasMoney then
        if table.reqItem then
            RemoveItem(src, {
                item = table.reqItem, 
                amount = 1
            })
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[table.reqItem], "remove", 1)
        end
        AddItem(src, {
            item = item,
            amount = 1
        })
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], "add", 1)
        cb(true)
    else
        cb(false)
    end
end)

QBCore.Functions.CreateCallback('cc-crimhub:server:getCops', function(source, cb)
    local amount = 0
    local players = QBCore.Functions.GetQBPlayers()
    for _, Player in pairs(players) do
        if Player.PlayerData.job.name == "police" and Player.PlayerData.job.onduty then
            amount = amount + 1
        end
    end
    cb(amount)
end)