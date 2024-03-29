local serverEndpoint = "http://192.168.1.26:3999/status"
local Request = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

if not getgenv().Set then
    getgenv().Set = {}
end



local Library = require(game:GetService("ReplicatedStorage").Library)
local SavedData;

repeat
    wait()
    pcall(function()
        SavedData = Library.Save.Get()
    end)
until type(SavedData) == "table";

local function isServerEnabled()
    local success, result = pcall(function()
        return Request({
            Url = serverEndpoint,
            Method = "GET"
        })
    end)

    if success then
        if result and result.Body then
            print("Server response:", result.Body)
            return result.Body == "Server status: enabled"
        else
            print("No response received from the server")
        end
    else
        print("Error in the request:", result)
    end

    return false
end
local username = getgenv().Set.user
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
