local url = 'http://192.168.1.26:3999/api'
local Request = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

-- Wait for necessary elements to load
repeat wait() until game:FindFirstChild("CoreGui") and game.Players.LocalPlayer
repeat wait() until game:IsLoaded()
repeat wait() until game.Players.LocalPlayer
local plr = game.Players.LocalPlayer
repeat wait() until plr.Character
repeat wait() until plr.Character:FindFirstChild("HumanoidRootPart")
repeat wait() until plr.Character:FindFirstChild("Humanoid")

local function printDiamondDifference(newDiamonds, oldDiamonds)
    local diamondsPer60s = (newDiamonds and oldDiamonds) and (newDiamonds.Value - oldDiamonds.Value) or 0
    print("Trung bình diamonds farm sau 60s:", diamondsPer60s)
end

local function checkPlayerStats()
    local leaderstats = plr and plr:FindFirstChild("leaderstats")

    -- Check for Diamonds stat
    local Diamonds = leaderstats and leaderstats:FindFirstChild("\240\159\146\142 Diamonds")

    -- Check for Rank stat
    local Rank = leaderstats and leaderstats:FindFirstChild("\226\173\144 Rank")

    -- Now you can use Diamonds and Rank directly without an explicit check
end

-- Spawn a new thread to periodically check and print Diamond difference
spawn(function()
    local currentDiamonds = plr.leaderstats and plr.leaderstats["\240\159\146\142 Diamonds"]
    while wait(60) do 
        pcall(function()
            local newDiamonds = plr.leaderstats and plr.leaderstats["\240\159\146\142 Diamonds"]
            if currentDiamonds and newDiamonds then
                printDiamondDifference(newDiamonds, currentDiamonds)
                currentDiamonds = newDiamonds
            end
        end)
    end
end)

checkPlayerStats()

-- Load required modules and services
local SaveModule = require(game:GetService("ReplicatedStorage").Library.Client.Save)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SaveFile = SaveModule.Get(Players.LocalPlayer)
local UnlockedAreas = SaveFile.UnlockedZones

local areaModules = ReplicatedStorage:WaitForChild("__DIRECTORY"):WaitForChild("Zones")

local currentAreaIndex = 0
local areaToUnlock = ""

-- Populate the areaList table with zone information
local areaList = {}
for _, moduleScript in pairs(areaModules:GetDescendants()) do
    if moduleScript:IsA("ModuleScript") then
        local info = string.split(moduleScript.Name, " | ")
        areaList[tonumber(info[1])] = info[2]
    end
end

-- Find the current area and the next area to unlock
for area, _ in pairs(UnlockedAreas) do
    local areaNum = table.find(areaList, area)
    if areaNum and areaNum > currentAreaIndex then
        currentAreaIndex = areaNum
        areaToUnlock = areaList[currentAreaIndex + 1]
    end
end
if not getgenv().Set then
    getgenv().Set = {}
end

local key = getgenv().Set.key
local note = getgenv().Set.note
-- Capture relevant data for the POST request
local newDiamonds = plr.leaderstats and plr.leaderstats["\240\159\146\142 Diamonds"]
local currentDiamonds = plr.leaderstats and plr.leaderstats["\240\159\146\142 Diamonds"]
local Rank = plr:FindFirstChild("leaderstats") and plr:FindFirstChild("leaderstats"):FindFirstChild("\226\173\144 Rank")
local diamondsPer60s = (newDiamonds and currentDiamonds) and (newDiamonds.Value - currentDiamonds.Value) or 0



local trimmedData = {
    key = key,
    Note = note,
    userName = game:GetService('Players').LocalPlayer.Name,
    playerId = game:GetService('Players').LocalPlayer.UserId,
    Diamonds = (currentDiamonds and currentDiamonds.Value) or 0,
    Rank = (Rank and Rank.Value) or 0,
    S60 = diamondsPer60s,
    UnlockedArea = areaToUnlock
}

-- Make the POST request with error handling
local function makeHttpRequest()
    local success, response = pcall(function()
        return Request({
            Url = url,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = game:GetService("HttpService"):JSONEncode(trimmedData)
        })
    end)

    if success then
        print("Send to server DisplayBlox", response)
    else
        warn("Cannot send to server DisplayBlox", response)
    end
end

makeHttpRequest()
