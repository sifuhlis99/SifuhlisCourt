local QBCore = exports['qb-core']:GetCoreObject()

local votingEnabled = false  -- Tracks if voting is enabled or disabled
local juryVotes = {}
local Config.JuryCount = 6 


RegisterNetEvent('court:updateJurySize', function(jurySize)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player or Player.PlayerData.job.name ~= "judge" then
        TriggerClientEvent("QBCore:Notify", src, "You are not authorized to perform this action.", "error")
        return
    end

    -- Check that the jury size is within valid range
    if type(jurySize) ~= "number" or jurySize < 1 or jurySize > 12 then
        TriggerClientEvent("QBCore:Notify", src, "Invalid jury size. Please enter a number between 1 and 12.", "error")
        return
    end

  
    Config.JuryCount = jurySize
    TriggerClientEvent("court:updateJurySize", -1, Config.JuryCount) 


    TriggerClientEvent("QBCore:Notify", -1, "The jury size has been updated to " .. jurySize, "inform")
end)



-- Handle enabling/disabling of voting
RegisterNetEvent("court:toggleVoting", function(enable)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player or Player.PlayerData.job.name ~= "judge" then
        TriggerClientEvent("QBCore:Notify", src, "You are not authorized to perform this action.", "error")
        return
    end

    votingEnabled = enable  -- Set the voting status

    -- Notify all players about the status
    if enable then
        TriggerClientEvent("QBCore:Notify", -1, "The jury voting process has been enabled by the judge.", "inform")
        TriggerClientEvent("court:votingStatus", -1, true)  -- Send the status to clients
        juryVotes = {}  -- Reset votes when voting is enabled
    else
        TriggerClientEvent("QBCore:Notify", -1, "The jury voting process has been disabled by the judge.", "inform")
        TriggerClientEvent("court:votingStatus", -1, false)  -- Send the status to clients
    end
end)

-- Collect a vote from a jury member
RegisterNetEvent("court:collectVote", function(verdict)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not votingEnabled then
        TriggerClientEvent("QBCore:Notify", src, "Voting is currently disabled.", "error")
        return
    end

    if not Player then return end

    local citizenid = Player.PlayerData.citizenid

    -- Prevent duplicate voting
    if juryVotes[citizenid] then
        TriggerClientEvent("QBCore:Notify", src, "You have already voted!", "error")
        return
    end

    -- Record the vote
    juryVotes[citizenid] = verdict

    -- Broadcast current tally to all jury members
    local results = {
        guilty = 0,
        not_guilty = 0
    }

    for _, vote in pairs(juryVotes) do
        results[vote] = (results[vote] or 0) + 1
    end

    TriggerClientEvent("court:updateVoteResults", -1, results)

    -- Check if all votes are in
    if tablelength(juryVotes) >= Config.JuryCount then
        local finalVerdict = (results.guilty > results.not_guilty) and "guilty" or "not_guilty"
        TriggerClientEvent("court:announceVerdict", -1, finalVerdict)
        votingEnabled = false -- Automatically disable voting after a verdict is reached
        juryVotes = {} -- Reset votes after verdict
    end
end)

-- Utility function to count table entries
function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

RegisterNetEvent("court:announceVerdict", function(verdict)
    -- Broadcast the final verdict to all players
    TriggerClientEvent("court:announceVerdict", -1, verdict)
end)

-- Utility function to count table entries
function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end
