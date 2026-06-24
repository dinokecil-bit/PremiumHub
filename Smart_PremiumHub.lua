-- [[ PREMIUM HUB V10: ULTIMATE MOBILE EDITION ]]
-- BAGIAN 1: SISTEM INTEGRASI TAMPILAN MENU (FLUENT UI MINI)

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua')))()

-- PEMBUATAN WINDOW UTAMA (UKURAN MINI & TRANSPARAN BLUR SEPERTI ZHUB)
local Window = Fluent:CreateWindow({
    Title = "PremiumHub | 100 Days At Sea",
    SubTitle = "by dinokecil-bit",
    TabWidth = 140,
    Size = UDim2.fromOffset(440, 275), -- Ukuran pas tidak memenuhi layar HP
    Acrylic = true,                    -- Efek transparan blur aktif seperti ZHUB
    Theme = "Dark", 
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- MANAGEMENT STATE / VARIABEL UTAMA
_G.AutoMagnetDebris = false
_G.AutoReturnToBase = false
_G.AutoHumanChest = false
_G.AutoAttackHitbox = false
_G.InfiniteHarpoonRange = false
_G.AutoAttackNearest = false
_G.AttackDelayValue = 0.3          -- Jeda default serangan otomatis (Slider)
_G.AntiAfkActive = false           -- Fitur anti-disconnect

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

-- MEMBUAT DAFTAR TAB UTAMA
local Tabs = {
    MainFarm = Window:AddTab({ Title = "Main Farm", Icon = "home" }),
    Weapon = Window:AddTab({ Title = "Weapon", Icon = "sword" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- FITUR PADA TAB MAIN FARM
Tabs.MainFarm:AddToggle("MagnetDebrisToggle", {
    Title = "Smart Magnet Debris",
    Default = false,
    Callback = function(Value) _G.AutoMagnetDebris = Value end
})

Tabs.MainFarm:AddToggle("LockBaseToggle", {
    Title = "Lock Position to Base Rakit",
    Default = false,
    Callback = function(Value) _G.AutoReturnToBase = Value end
})

Tabs.MainFarm:AddToggle("ChestToggle", {
    Title = "Auto Smart Chest Open & Claim",
    Default = false,
    Callback = function(Value) _G.AutoHumanChest = Value end
})

Tabs.MainFarm:AddToggle("HitboxToggle", {
    Title = "Smart Target Kill Hitbox",
    Default = false,
    Callback = function(Value) _G.AutoAttackHitbox = Value end
})

Tabs.MainFarm:AddToggle("AutoAttackNearestToggle", {
    Title = "Auto Attack (Nearest Mob)",
    Default = false,
    Callback = function(Value) _G.AutoAttackNearest = Value end
})

-- SLIDER PENGATUR JEDA KECEPATAN SERANGAN (SEPERTI DI GAMBAR ZHUB)
Tabs.MainFarm:AddSlider("AttackDelaySlider", {
    Title = "Auto Attack Delay",
    Description = "Mengatur jeda kecepatan serangan otomatis",
    Default = 0.3,
    Min = 0.1,
    Max = 2.0,
    Rounding = 1,
    Callback = function(Value)
        _G.AttackDelayValue = Value
    end
})

-- FITUR PADA TAB WEAPON
Tabs.Weapon:AddToggle("InfiniteHarpoonToggle", {
    Title = "Infinite Harpoon Range",
    Default = false,
    Callback = function(Value) _G.InfiniteHarpoonRange = Value end
})

-- FITUR PADA TAB SETTINGS
Tabs.Settings:AddToggle("AntiAfkToggle", {
    Title = "Anti-AFK (Anti Disconnect)",
    Default = false,
    Callback = function(Value) _G.AntiAfkActive = Value end
})
-- =======================================================================
-- 🛠️ SISTEM TOMBOL MELAYANG CUSTOM (ANTI-HILANG SAAT DI-MINIMIZE)
-- =======================================================================
local CoreGui = game:GetService("CoreGui")
local ToggleGui = Instance.new("ScreenGui")
local ToggleButton = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

ToggleGui.Name = "PremiumHubToggleGui"
ToggleGui.Parent = CoreGui
ToggleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = ToggleGui
ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleButton.BackgroundTransparency = 0.2
ToggleButton.Position = UDim2.new(0, 10, 0.4, 0) -- Letak di kiri tengah layar HP
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.Text = "PH"
ToggleButton.TextColor3 = Color3.fromRGB(0, 150, 255) -- Warna teks biru estetik
ToggleButton.TextSize = 18

UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = ToggleButton

ToggleButton.MouseButton1Click:Connect(function()
    Window:Minimize()
end)
-- =======================================================================

-- 7. LOGIKA PROSES LATAR BELAKANG: SMART MAGNET DEBRIS & LOCK BASE
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
-- 8. LOGIKA PROSES LATAR BELAKANG: AUTO HUMAN CHEST OPEN & CLAIM
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
                                if prompt then fireproximityprompt(prompt) end
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

-- 9. LOGIKA PROSES LATAR BELAKANG: SMART AUTO ATTACK HITBOX & NEAREST MOB
task.spawn(function()
    while true do
        task.wait(_G.AttackDelayValue) -- Menggunakan delay dinamis dari slider
        if _G.AutoAttackHitbox or _G.AutoAttackNearest then
            pcall(function()
                if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
                local closestMob = nil
                local shortestDistance = 100
                for _, target in pairs(Workspace:GetDescendants()) do
                    if target.Name == "Hitbox" and (target:IsA("BasePart") or target:IsA("MeshPart")) then
                        local jarak = (LocalPlayer.Character.HumanoidRootPart.Position - target.Position).Magnitude
                        if _G.AutoAttackHitbox and jarak < 100 then
                            if LocalPlayer.Character:FindFirstChildOfClass("Tool") then
                                LocalPlayer.Character:FindFirstChildOfClass("Tool"):Activate()
                                target.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -2)
                            end
                        elseif _G.AutoAttackNearest and jarak < shortestDistance then
                            closestMob = target
                            shortestDistance = jarak
                        end
                    end
                end
                if _G.AutoAttackNearest and closestMob and LocalPlayer.Character:FindFirstChildOfClass("Tool") then
                    LocalPlayer.Character:FindFirstChildOfClass("Tool"):Activate()
                    closestMob.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -2)
                end
            end)
        end
    end
end)

-- 10. LOGIKA PROSES LATAR BELAKANG: INFINITE HARPOON RANGE
task.spawn(function()
    while true do
        task.wait(0.5)
        if _G.InfiniteHarpoonRange then
            pcall(function()
                local harpoon = LocalPlayer.Backpack:FindFirstChild("Harpoon") or LocalPlayer.Character:FindFirstChild("Harpoon")
                if harpoon then
                    if harpoon:FindFirstChild("MaxDistance") then harpoon.MaxDistance.Value = 999999
                    elseif harpoon:FindFirstChild("Range") then harpoon.Range.Value = 999999 end
                end
            end)
        end
    end
end)

-- 11. LOGIKA PROSES LATAR BELAKANG: ANTI-AFK SYSTEM
task.spawn(function()
    local VirtualUser = game:GetService("VirtualUser")
    LocalPlayer.Idled:Connect(function()
        if _G.AntiAfkActive then
            VirtualUser:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
            task.wait(1)
            VirtualUser:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
        end
    end)
end)

-- NOTIFIKASI AKHIR PEMUATAN MENU FLUENT
Fluent:Notify({
    Title = "PremiumHub V10 Loaded",
    Content = "Skrip Ultimate Edition Berhasil Dijalankan!",
    Duration = 5
})
