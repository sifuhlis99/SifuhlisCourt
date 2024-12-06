local QBCore = exports['qb-core']:GetCoreObject()

-- Function to open the judge's menu
local function openJudgeMenu()
    lib.registerContext({
        id = 'judge_menu',
        title = 'Judge Options',
        options = {
            {
                title = 'Enable Jury Voting',
                description = 'Start the jury voting process',
                event = 'court:enableVoting',
            },
            {
                title = 'Disable Jury Voting',
                description = 'End the jury voting process',
                event = 'court:disableVoting',
            },
            {
                title = 'Set Jury Size',
                description = 'Set the number of jurors for the case',
                event = 'court:showJurySizeInput',
            },
            {
                title = 'Set Court Status',
                description = 'Change the current court session status',
                event = 'court:showCourtStatusMenu',
            }
        }
    })

    lib.showContext('judge_menu')
end

-- Create a target interaction point for the judge to open the menu
exports['qb-target']:AddBoxZone("JudgeVotingMenu", Config.JudgeOptions, 2.0, 2.0, {  
    name = "JudgeVotingMenu",
    heading = 317.68, 
    debugPoly = false, -- CHECK TO TRUE IF YOU LOVE RED LINE BOXES YIPPEEEE
    minZ = 37.0,
    maxZ = 39.0,
}, {
    options = {
        {
            type = "client",
            event = "court:openJudgeVotingMenu",
            icon = "fas fa-gavel",
            label = "Judge Options",
            job = "judge",
        },
    },
    distance = 2.0
})

-- Event to trigger the judge menu 
RegisterNetEvent('court:openJudgeVotingMenu', function()
    local PlayerData = QBCore.Functions.GetPlayerData()

    if PlayerData and PlayerData.job.name == 'judge' then
        openJudgeMenu()
    else
        QBCore.Functions.Notify("You must be a judge to use this menu.", "error")
    end
end)

-- Event to show court status options
RegisterNetEvent('court:showCourtStatusMenu', function()
    lib.registerContext({
        id = 'court_status_menu',
        title = 'Set Court Status',
        options = {
            {
                title = 'In Session',
                description = 'Set the court status to In Session',
                event = 'court:setCourtStatus',
                args = { status = 'In Session' }  -- Sends 'in_session' status
            },
            {
                title = 'Recess',
                description = 'Set the court status to Recess',
                event = 'court:setCourtStatus',
                args = { status = 'Recess' }  -- Sends 'recess' status
            },
            {
                title = 'Dismissed',
                description = 'Set the court status to Dismissed',
                event = 'court:setCourtStatus',
                args = { status = 'Dismissed' }  -- Sends 'dismissed' status
            }
        }
    })
    lib.showContext('court_status_menu')
end)

-- Listen for court status updates and notify the player
RegisterNetEvent('court:updateCourtStatus', function(status)
    -- Display the updated court status to all players
    lib.notify({
        title = "Court Status Updated",
        description = "The court is now: " .. status,
        type = "inform"
    })
end)

-- Event handler for enabling voting
RegisterNetEvent('court:enableVoting', function()
    TriggerServerEvent('court:toggleVoting', true) 
end)

-- Event handler for disabling voting
RegisterNetEvent('court:disableVoting', function()
    TriggerServerEvent('court:toggleVoting', false)  
end)

local currentCourtStatus = "Dismissed"  -- Default status
local textPosition = Config.textPosition

-- Function to draw 3D text in the world
function Draw3DText(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local scale = 0.35  -- Adjust the scale of the text

    if onScreen then
        SetTextScale(scale, scale)
        SetTextFont(4)
        SetTextProportional(true)
        SetTextColour(255, 255, 255, 255)
        SetTextEntry("STRING")
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

-- Listen for court status updates and update the court status
RegisterNetEvent('court:drawCourtStatusText', function(status)
    currentCourtStatus = status  -- Update the current court status
end)

-- Always draw the court status text on the screen
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)  -- Always run this thread

        -- Check if the current court status has been set and then draw it
        if currentCourtStatus then
            Draw3DText(textPosition.x, textPosition.y, textPosition.z, "Court Status: " .. currentCourtStatus)
        else
            print("No court status to display")  -- Debugging to ensure the status exists
        end
    end
end)

-- Event to trigger the court status change (used by the judge)
RegisterNetEvent('court:setCourtStatus', function(data)
    -- Trigger the server event to update the status
    TriggerServerEvent('court:setCourtStatus', data)
end)