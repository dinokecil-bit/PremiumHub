-- [[ PREMIUM HUB V5: OFFICIALLY FIXED BY AI ]]
-- File ini wajib dinamai: Smart_PremiumHub.lua

local OrionLib = loadstring(game:HttpGet(('https://githubusercontent.com')))()

local Window = OrionLib:MakeWindow({
    Name = "PremiumHub - 100 Hari Di Laut", 
    HidePremium = false, 
    SaveConfig = true, 
    ConfigFolder = "PremiumHubConfig"
})

_G.AutoMagnetDebris = false
_G.AutoReturnToBase = false
_G.AutoHumanChest = false
_G.AutoAttackHitbox = false

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

local BaseSpawnPosition = nil
if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
    BaseSpawnPosition = LocalPlayer.Character.HumanoidRootPart.CFrame
end

local function isSafeItem(obj)
    if not obj or not obj:IsA("BasePart") and not obj:IsA("Model") then return false end
    if obj:FindFirstChild("Companion") or obj:FindFirstChild("Humanoid") or obj.Name == "NPC" then return false end
    if Players:GetPlayerFromCharacter(obj.Parent) or Players:GetPlayerFromCharacter(obj) then return false end
    if LocalPlayer.Character and obj:IsDescendantOf(LocalPlayer.Character) then return false end
    return true
end

local FarmTab = Window:MakeTab({
    Name = "Main Farm",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

FarmTab:AddToggle({
    Name = "Smart Magnet Debris",
    Default = false,
    Callback = function(Value)
        _G.AutoMagnetDebris = Value
    end    
})

FarmTab:AddToggle({
    Name = "Lock Position to Base Rakit",
    Default = false,
    Callback = function(Value)
        _G.AutoReturnToBase = Value
    end    
})

FarmTab:AddToggle({
    Name = "Auto Smart Chest Open & Claim",
    Default = false,
    Callback = function(Value)
        _G.AutoHumanChest = Value
    end    
})

FarmTab:AddToggle({
    Name = "Smart Target Kill Hitbox",
    Default = false,
    Callback = function(Value)
        _G.AutoAttackHitbox = Value
    end    
})

task.spawn(function()
    while true do
        task.wait(0.4)
        if _G.AutoMagnetDebris then
            pcall(function()
                if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
                local currentTarget = LocalPlayer.Character.HumanoidRootPart.CFrame
                if _G.AutoReturnToBase and BaseSpawnPosition then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = BaseSpawnPosition
                    currentTarget = BaseSpawnPosition
                end
                for _, item in pairs(Workspace:GetChildren()) do
                    if isSafeItem(item) then
                        if item:IsA("BasePart") then
                            item.CFrame = currentTarget * CFrame.new(0, 3, 0)
                        elseif item:IsA("Model") and item.PrimaryPart then
                            item:SetPrimaryPartCFrame(currentTarget * CFrame.new(0, 3, 0))
                        end
                    end
                end
            end)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(1)
        if _G.AutoHumanChest then
            pcall(function()
                if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if not _G.AutoHumanChest then break end
                    if obj:IsA("Model") or obj:IsA("BasePart") then
                        if string.find(string.lower(obj.Name), "chest") or string.find(string.lower(obj.Name), "treasure") or string.find(string.lower(obj.Name), "kotak") then
                            local chestCFrame = obj:IsA("BasePart") and obj.CFrame or obj.PrimaryPart and obj.PrimaryPart.CFrame
                            if chestCFrame then
                                LocalPlayer.Character.HumanoidRootPart.CFrame = chestCFrame * CFrame.new(0, 3, 0)
                                task.wait(2.5) 
                                local prompt = obj:FindFirstChildOfClass("ProximityPrompt") or obj:GetComponentOfClass("ProximityPrompt")
                                if prompt then
                                    fireproximityprompt(prompt)
                                end
                                task.wait(1.5)
                                local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
                                if PlayerGui then
                                    for _, guiElement in pairs(PlayerGui:GetDescendants()) do
                                        if guiElement:IsA("TextButton") or guiElement:IsA("ImageButton") then
                                            local labelText = guiElement:FindFirstChildOfClass("TextLabel") and guiElement:FindFirstChildOfClass("TextLabel").Text or guiElement.Name
                                            if string.find(string.lower(labelText), "claim") or string.find(string.lower(labelText), "take") or string.find(string.lower(labelText), "ok") or string.find(string.lower(labelText), "buka") then
                                                guiElement:Activate()
                                                task.wait(0.5)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.1)
        if _G.AutoAttackHitbox then
            pcall(function()
                if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
                for _, target in pairs(Workspace:GetDescendants()) do
                    if target.Name == "Hitbox" and (target:IsA("BasePart") or target:IsA("MeshPart")) then
                        local jarak = (LocalPlayer.Character.HumanoidRootPart.Position - target.Position).Magnitude
                        if jarak < 100 then
                            if LocalPlayer.Character:FindFirstChildOfClass("Tool") then
                                LocalPlayer.Character:FindFirstChildOfClass("Tool"):Activate()
                                target.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -2)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

OrionLib:Init()
