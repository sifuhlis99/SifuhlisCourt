local QBCore = exports['qb-core']:GetCoreObject()
-- Handle server-side gavel sound broadcasting
RegisterNetEvent("court:playGavelSound", function(coords)
    TriggerClientEvent("court:playGavelSoundToClients", -1, coords)
end)
