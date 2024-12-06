-- Event to handle setting the court status
RegisterNetEvent('court:setCourtStatus', function(data)
    local src = source
    local status = data.status

    -- Broadcast the updated status to all clients
    TriggerClientEvent('court:drawCourtStatusText', -1, status)  -- -1 sends to all players

    print("Court status set to: " .. status)  -- Debugging to check if the server is receiving the status
end)
