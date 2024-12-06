local QBCore = exports['qb-core']:GetCoreObject()

-- Gavel Location
exports['qb-target']:AddBoxZone("JudgeGavel", Config.JudgeGavel, 2.0, 2.0, {
    name = "JudgeGavel",
    heading = 317.68,
    debugPoly = false, -- CHECK TO TRUE IF YOU LOVE RED LINE BOXES YIPPEEEE
    minZ = 36.63, -- I'll have to change these shortly
    maxZ = 38.63,
}, {
    options = {
        {
            type = "client",
            event = "court:gavelStrike",
            icon = "fas fa-gavel",
            label = "Strike Gavel",
            job = 'judge', -- Set to Judge only
        },
    },
    distance = 2.0 -- Interaction distance
})

-- Event for gavel strike
RegisterNetEvent("court:gavelStrike", function()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    TriggerServerEvent("court:playGavelSound", coords)

end)

-- Event to receive and play sound
RegisterNetEvent("court:playGavelSoundToClients", function(coords)
    local playerCoords = GetEntityCoords(PlayerPedId())
    local distance = #(playerCoords - coords)

    if distance < 50.0 then 
        SendNUIMessage({
            type = "playSound",
            soundFile = "gavel_strike",
            volume = 1.0 - (distance / 50.0), -- Volume decreases with distance ???? Better work or i'm suing a hamster
        })
    end
end)
