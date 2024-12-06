local QBCore = exports['qb-core']:GetCoreObject()

local votingEnabled = false  -- Track if voting is enabled or disabled locally
local juryVotes = {}         -- Store jury votes, indexed by citizenid.. it works!
local juryCount = 0          -- Store the current jury count

-- Listen for the server to send the updated voting status
RegisterNetEvent('court:votingStatus', function(status)
    votingEnabled = status
end)

RegisterNetEvent('court:updateJurySize', function(count)
    juryCount = count  -- Update the jury size dynamically
end)

-- Jury Voting point! Set in Config.lua
exports['qb-target']:AddBoxZone("JuryVotingPoint", Config.JuryVoting, 2.0, 2.0, {  
    name = "JuryVotingPoint",
    heading = 317.68,
    debugPoly = false,  -- CHECK TO TRUE IF YOU LOVE RED LINE BOXES YIPPEEEE
    minZ = 37.0,
    maxZ = 39.0,
}, {
    options = {
        {
            type = "client",
            event = "court:castVote",
            icon = "fas fa-vote-yea",
            label = "Cast Your Vote",
        },
    },
    distance = 2.0
})

-- Event to trigger the voting process for the jury members
RegisterNetEvent('court:castVote', function()
    local PlayerData = QBCore.Functions.GetPlayerData()

    -- Check if voting is enabled
    if not votingEnabled then
        lib.notify({
            title = "Voting Disabled",
            description = "Voting is currently disabled. Please wait for the judge to enable it.",
            type = "error"
        })
        return
    end

    -- Open the voting menu
    lib.registerContext({
        id = 'jury_vote_menu',
        title = 'Jury Voting',
        options = {
            {
                title = 'Vote Guilty',
                description = 'Vote for a guilty verdict',
                event = 'court:submitVote',
                args = { vote = 'guilty' }
            },
            {
                title = 'Vote Not Guilty',
                description = 'Vote for a not guilty verdict',
                event = 'court:submitVote',
                args = { vote = 'not_guilty' }
            },
        }
    })
    lib.showContext('jury_vote_menu')
end)

RegisterNetEvent('court:submitVote', function(data)
    local PlayerData = QBCore.Functions.GetPlayerData()
    local citizenid = PlayerData.citizenid

    -- Prevent duplicate voting, should work in theory
    if juryVotes[citizenid] then
        lib.notify({
            title = "You have already voted",
            description = "You cannot vote more than once.",
            type = "error"
        })
        return
    end

    -- Record the vote
    juryVotes[citizenid] = data.vote

    -- Count votes
    local results = { guilty = 0, not_guilty = 0 }
    for _, vote in pairs(juryVotes) do
        results[vote] = (results[vote] or 0) + 1
    end

    -- Check if all votes are collected
    if tablelength(juryVotes) == juryCount then
        -- Determine the verdict
        local finalVerdict = (results.guilty > results.not_guilty) and "guilty" or "not_guilty"

        -- Announce the verdict
        TriggerServerEvent("court:announceVerdict", finalVerdict)

        -- Reset voting
        votingEnabled = false
        juryVotes = {}  -- Clear all votes
    else
        -- Notify jury members about the current vote tally
        lib.notify({
            title = "Vote Recorded",
            description = string.format("Votes collected: %d/%d", tablelength(juryVotes), juryCount),
            type = "inform"
        })
    end
end)

-- Utility function to count table entries
function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

-- Display the verdict
RegisterNetEvent("court:announceVerdict", function(verdict)
    lib.notify({
        title = "Verdict Announced",
        description = "The final verdict is: " .. verdict,
        type = "inform"
    })
end)
