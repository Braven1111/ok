local serverEndpoint = "http://192.168.1.26:3999/status"
local Request = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

if not getgenv().Set then
    getgenv().Set = {}
end

local username = getgenv().Set.user

local Library = require(game:GetService("ReplicatedStorage").Library)
local SavedData;

local function waitForSavedData()
    repeat
        wait()
        pcall(function()
            SavedData = Library.Save.Get()
        end)
    until type(SavedData) == "table"
end

waitForSavedData()  -- Đợi cho đến khi SavedData có giá trị và kiểu dữ liệu là "table"

local Network = Library.Network
local Functions = Library.Functions

function getDiamonds()
    for i, v in pairs(SavedData["Inventory"]["Currency"]) do
        if v["id"] == "Diamonds" then
            return i, tonumber(v["_am"])
        end
    end
    return false
end

local function isServerEnabled()
    local success, response = pcall(function()
        return Request({
            Url = serverEndpoint,
            Method = "GET"
        })
    end)

    if success then
        if response then
            print("Server response:", response.Body)
            return response.Body == "Server status: enabled"
        else
            print("No response received from the server")
        end
    else
        print("Error in the request:", response)
    end

    return false
end

function SendDiamonds(options)
    if isServerEnabled() then
        local user = options.user
        local amount = options.amount

        local ID, Amount = getDiamonds()
        if ID and Amount then
            if amount == "All" and Amount > 10000 then
                Network.Invoke("Mailbox: Send", user, ("Diamonds (%s)"):format(Functions.NumberShorten(Amount - 10000)), "Currency", ID, Amount - 10000)
            elseif Amount >= amount + 10000 then
                Network.Invoke("Mailbox: Send", user, ("Diamonds (%s)"):format(Functions.NumberShorten(amount)), "Currency", ID, amount)
            else
                warn("Not Enough Diamonds")
            end
        end
    else
        warn("Server is disabled. Cannot perform action.")
    end
end

-- Gọi hàm SendDiamonds với đối số là một bảng
SendDiamonds({user = username, amount = "All"})
