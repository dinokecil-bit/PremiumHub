-- =====================================================================
-- REVISI V15: FIXED LOCK COORD + AUTO EAT SECURITY & DRAGGABLE UI
-- =====================================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local localPlayer = Players.LocalPlayer

local sampahDitahan = {}
local fiturAutoEat = true -- Ubah ke false jika ingin mematikan auto eat saja

-- [1. SENSOR UTAMA: Mencari Bonfire Rakit]
local function cariBonfireRakitAwal(playerRoot)
    local targetBonfire = nil
    local jarakTerdekat = math.huge
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name == "Bonfire" then
            local part = obj:IsA("BasePart") and obj or obj:FindFirstChildOfClass("BasePart")
            if part then
                local jarak = (part.Position - playerRoot.Position).Magnitude
                if jarak < jarakTerdekat then
                    jarakTerdekat = jarak
                    targetBonfire = part
                end
            end
        end
    end
    return targetBonfire
end

-- [2. OTOT OTOMATIS: Sistem Pemakan Makanan Mandiri]
local function cekDanMakanOtomatis(char)
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local backpack = localPlayer:FindFirstChildOfClass("Backpack")
    
    if humanoid and humanoid.Health < (humanoid.MaxHealth * 0.4) and fiturAutoEat then
        -- Mencari makanan murni lautan di inventory/tas
        local makanan = backpack:FindFirstChild("Biscuit") or backpack:FindFirstChild("Potato") or char:FindFirstChild("Biscuit") or char:FindFirstChild("Potato")
        
        if makanan then
            -- Pasang makanan ke tangan karakter
            if makanan.Parent == backpack then
                makanan.Parent = char
            end
            task.wait(0.1)
            -- Simulasi klik layar pintar untuk memakan makanan secara instan
            VirtualUser:Button1Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
            task.wait(0.1)
            VirtualUser:Button1Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
        end
    end
end

-- [3. MAIN ENGINE: Fitur Tarik Magnet Pro]
local function jalankanFiturMagnet(statusAktif)
    _G.AutoCollectDebris = statusAktif
    if _G.AutoCollectDebris then
        print("[Delta Hub]: Menimbun sampah & mengaktifkan Sensor Nutrisi...")
        sampahDitahan = {}
        task.spawn(function()
            local targetBonfirePart = nil
            while _G.AutoCollectDebris do
                task.wait(0.4) -- Delay optimal anti-lag
                pcall(function()
                    local char = localPlayer.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if root then
                        -- Jalankan pengecekan darah dan makan otomatis di latar belakang
                        cekDanMakanOtomatis(char)

                        if not targetBonfirePart or not targetBonfirePart.Parent then
                            targetBonfirePart = cariBonfireRakitAwal(root)
                        end
                        
                        local folderSampah = Workspace:FindFirstChild("Debris") or Workspace:FindFirstChild("Items") or Workspace
                        local objekTarget = folderSampah:GetChildren()
                        if folderSampah == Workspace then objekTarget = Workspace:GetDescendants() end
                        
                        for _, obj in pairs(objekTarget) do
                            if not _G.AutoCollectDebris then break end
                            if obj:IsA("BasePart") then
                                if obj:IsDescendantOf(char) or (obj.Parent and obj.Parent.Name == "WoodenFloor") then continue end
                                local namaObjek = string.lower(obj.Name)
                                local parentName = obj.Parent and string.lower(obj.Parent.Name) or ""
                                if string.find(parentName, "model") or string.find(parentName, "crafting") or string.find(parentName, "wheel") or string.find(parentName, "bonfireframe") or string.find(parentName, "base") then continue end
                                if string.find(namaObjek, "plank") or string.find(namaObjek, "scrap") or string.find(namaObjek, "biscuit") or string.find(namaObjek, "potato") or string.find(namaObjek, "propeller") or string.find(namaObjek, "waterskirt") or string.find(namaObjek, "wood") then
                                    local jarak = (obj.Position - root.Position).Magnitude
                                    if jarak < 500 then
                                        if targetBonfirePart and targetBonfirePart.Parent then
                                            obj.CFrame = targetBonfirePart.CFrame * CFrame.new(0, 5, 0)
                                            obj.Anchored = true
                                            if not table.find(sampahDitahan, obj) then table.insert(sampahDitahan, obj) end
                                        else
                                            obj.Anchored = false
                                            obj.CFrame = root.CFrame * CFrame.new(0, 0, -3)
                                        end
                                    end
                                end
                            end
                        end
                        for i = #sampahDitahan, 1, -1 do
                            local part = sampahDitahan[i]
                            if not part or not part.Parent then table.remove(sampahDitahan, i) end
                        end
                    end
                end)
            end
        end)
    else
        print("[Delta Hub]: OFF! Menjatuhkan semua material laut...")
        for _, part in pairs(sampahDitahan) do
            if part and part.Parent then pcall(function() part.Anchored = false end) end
        end
        sampahDitahan = {}
    end
end

if type(_G.BuatTombolPremium) == "function" then
    _G.BuatTombolPremium("Auto Collect Debris", jalankanFiturMagnet)
else
    local CoreGui = game:GetService("CoreGui")
    if CoreGui:FindFirstChild("DebrisMagnetUI") then CoreGui.DebrisMagnetUI:Destroy() end
    local sg = Instance.new("ScreenGui")
    sg.Name = "DebrisMagnetUI"
    sg.Parent = CoreGui
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 180, 0, 45)
    btn.Position = UDim2.new(0.05, 0, 0.4, 0)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    btn.TextColor3 = Color3.fromRGB(255, 65, 65)
    btn.Text = "Magnet Debris: OFF"
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Active = true
    btn.Draggable = true
    btn.Parent = sg
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
    local aktif = false
    btn.MouseButton1Click:Connect(function()
        aktif = not aktif
        if aktif then
            btn.Text = "Magnet Debris: ON"
            btn.TextColor3 = Color3.fromRGB(65, 255, 65)
            jalankanFiturMagnet(true)
        else
            btn.Text = "Magnet Debris: OFF"
            btn.TextColor3 = Color3.fromRGB(255, 65, 65)
            jalankanFiturMagnet(false)
        end
    end)
end
