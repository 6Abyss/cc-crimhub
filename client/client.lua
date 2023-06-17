QBCore = exports['qb-core']:GetCoreObject()

CreateThread(function()
    for k, v in pairs(Config.Peds) do
        exports[Config.Target]:SpawnPed({
            model = v.model,
            coords = v.coords,
            freeze = true,
            invincible = true,
            scenario = v.scenario,
            target = {
            options = {
                {
                num = 1,
                type = "client", 
                event = "cc-crimhub:cl:openmenu",
                icon = 'fas fa-building-columns', 
                label = Lang:t("target.open_menu"),
                action = function()
                    TriggerEvent('cc-crimhub:cl:openmenu')
                end,
                canInteract = function()
                    return true
                end,
                }
            },
            distance = 2.5,
            },
        })
    end
end)

RegisterCommand("c:menu", function()
    TriggerEvent('cc-crimhub:cl:openmenu')
end)


RegisterNetEvent('cc-crimhub:cl:openmenu', function()
    lib.registerContext({
        id = 'crimhubMenu',
        title = Lang:t("menu.header"),
        options = {
          {
            title = Lang:t("menu.availability"),
            description =  Lang:t("menu.availability_txt"),
            icon = 'fas fa-clock',
            event = "cc-crimhub:cl:checkavailability",
            arrow = true,
          },{
            title = Lang:t("menu.equipment"),
            description =  Lang:t("menu.availability_txt"),
            icon = 'fas fa-laptop-code',
            event = "cc-crimhub:cl:equipment",
            arrow = true,
          },
        }
      })
      lib.showContext('crimhubMenu')
end)

function AvailabilityLabel(bool)
    if bool then
        return Lang:t("menu.available")
    else
        return Lang:t("menu.not_available")
    end
end

RegisterNetEvent("cc-crimhub:cl:checkavailability", function()
    QBCore.Functions.TriggerCallback("cc-crimhub:server:getCops", function(enoughCops)
        local header = {}
        for k, v in pairs(Config.AvailableList) do
            if enoughCops >= v.minCops then
                header[#header+1] = {
                    title = v.Header,
                    description = "Available",
                    icon = v.icon,
                }
            else
                header[#header+1] = {
                    title = v.Header,
                    description = "Not Available",
                    icon = v.icon,
                }
            end
        end
            header[#header+1] = {
                title = Lang:t("menu.back"),
                icon = 'fa-solid fa-circle-chevron-left',
                event = "cc-crimhub:cl:openmenu",
                arrow = false,
            }
                lib.registerContext({
                    id = 'testing',
                    title = Lang:t("menu.equipment"),
                    onExit = function()
                    end,
                    options = header,
                })
          lib.showContext('testing')

    end)
end)

RegisterNetEvent("cc-crimhub:cl:equipment", function()
    local equipmentMenu = {}
        for i=1, #Config.EquipmentMenu do 
            v = Config.EquipmentMenu[i]
            equipmentMenu[#equipmentMenu + 1] = {
                title = v.label,
                icon = v.icon,
                description = v.txt,
                event = "cc-crimhub:cl:equipment2",
                args = { menu = i },
                arrow = false,
            }
        end
        equipmentMenu[#equipmentMenu + 1] = {
            title = Lang:t("menu.back"),
            icon = 'fa-solid fa-circle-chevron-left',
            event = "cc-crimhub:cl:openmenu",
            arrow = false,
        }
            lib.registerContext({
                id = 'equiptment',
                title = Lang:t("menu.equipment"),
                onExit = function()
                end,
                options = equipmentMenu,
            })
      lib.showContext('equiptment')
end)

RegisterNetEvent("cc-crimhub:cl:equipment2", function(data)
    local menu = Config.EquipmentMenu[data.menu]
    local items = menu.items
    local equipmentMenu = {}
    for i=1, #items do
        v = items[i]
        equipmentMenu[#equipmentMenu + 1] = {
            title = v.label,
            icon = v.icon,
            description = v.txt,
            event = "cc-crimhub:cl:buyequipment",
            args = { data = v },
            arrow = false,
        }
    end
        equipmentMenu[#equipmentMenu + 1] = {
            title = Lang:t("menu.back"),
            icon = 'fa-solid fa-circle-chevron-left',
            event = "cc-crimhub:cl:equipment",
            arrow = false,
        }
        lib.registerContext({
            id = 'equipmentMenu2',
            title = menu.label,
            options = equipmentMenu,
          })
          lib.showContext('equipmentMenu2')
end)

RegisterNetEvent("cc-crimhub:cl:buyequipment", function(data)
    local info = data.data
    if info.reqItem then
        local hasItem = QBCore.Functions.HasItem(info.reqItem)
        if not hasItem then
            TriggerEvent('inventory:client:requiredItems', {QBCore.Shared.Items[info.reqItem]}, true)
            Wait(2500)
            TriggerEvent('inventory:client:requiredItems', {QBCore.Shared.Items[info.reqItem]}, false)
            return
        end
    end
    QBCore.Functions.TriggerCallback("cc-crimhub:sv:buyitem", function(hasMoney)
        if hasMoney then
            QBCore.Functions.Notify(Lang:t("notify.success"), "success")
        else
            QBCore.Functions.Notify(Lang:t("notify.insufficient_funds"), "error")
        end
    end, data)
end)