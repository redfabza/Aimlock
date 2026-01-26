-- RedFabza Loading Screen (Responsive + RGB Border + Avatar Fit) - ห้ามแก้ไขเด็ดขาด
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local UserId = LocalPlayer.UserId
local Username = LocalPlayer.Name
local JoinTime = os.time()

-- ScreenGui
local LoadingGui = Instance.new("ScreenGui")
LoadingGui.Name = "RedFabzaLoading"
LoadingGui.Parent = CoreGui
LoadingGui.ResetOnSpawn = false
LoadingGui.IgnoreGuiInset = true

-- Background
local Background = Instance.new("Frame")
Background.Size = UDim2.fromScale(1, 1)
Background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Background.BorderSizePixel = 0
Background.Parent = LoadingGui

-- MainFrame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.fromScale(0.85, 0.8)
MainFrame.Position = UDim2.fromScale(0.5, 0.5)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = Background

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 16)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Thickness = 3
MainStroke.Transparency = 0.2

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.fromScale(1, 0.12)
Title.Position = UDim2.fromScale(0, 0.02)
Title.BackgroundTransparency = 1
Title.Text = "Redfabfaza Hub"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBlack
Title.Parent = MainFrame

-- Avatar (กรอบ = รูป = วงกลมเป๊ะ)
local AvatarFrame = Instance.new("Frame")
AvatarFrame.Size = UDim2.fromScale(0.35, 0.35)
AvatarFrame.Position = UDim2.fromScale(0.5, 0.32)
AvatarFrame.AnchorPoint = Vector2.new(0.5, 0.5)
AvatarFrame.BackgroundTransparency = 1
AvatarFrame.Parent = MainFrame

local Aspect = Instance.new("UIAspectRatioConstraint", AvatarFrame)
Aspect.AspectRatio = 1

local AvatarImage = Instance.new("ImageLabel")
AvatarImage.Size = UDim2.fromScale(1, 1)
AvatarImage.Position = UDim2.fromScale(0, 0)
AvatarImage.BackgroundTransparency = 1
AvatarImage.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. UserId .. "&width=420&height=420&format=png"
AvatarImage.ScaleType = Enum.ScaleType.Crop
AvatarImage.Parent = AvatarFrame

local AvatarCorner = Instance.new("UICorner", AvatarImage)
AvatarCorner.CornerRadius = UDim.new(1, 0)

local AvatarStroke = Instance.new("UIStroke", AvatarImage)
AvatarStroke.Thickness = 3
AvatarStroke.Transparency = 0.2

-- InfoText
local InfoText = Instance.new("TextLabel")
InfoText.Size = UDim2.fromScale(0.9, 0.22)
InfoText.Position = UDim2.fromScale(0.05, 0.58)
InfoText.BackgroundTransparency = 1
InfoText.TextWrapped = true
InfoText.TextYAlignment = Enum.TextYAlignment.Top
InfoText.TextXAlignment = Enum.TextXAlignment.Left
InfoText.TextScaled = false
InfoText.TextSize = 16
InfoText.Font = Enum.Font.Gotham
InfoText.TextColor3 = Color3.fromRGB(210, 210, 255)
InfoText.Parent = MainFrame

-- Button
local EnterButton = Instance.new("TextButton")
EnterButton.Size = UDim2.fromScale(0.8, 0.12)
EnterButton.Position = UDim2.new(0.1, 0, 1, -70)
EnterButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
EnterButton.BorderSizePixel = 0
EnterButton.Text = "เข้าสคริปต์"
EnterButton.TextColor3 = Color3.new(1,1,1)
EnterButton.TextScaled = true
EnterButton.Font = Enum.Font.GothamBlack
EnterButton.Parent = MainFrame

local ButtonCorner = Instance.new("UICorner", EnterButton)
ButtonCorner.CornerRadius = UDim.new(0, 12)

local ButtonStroke = Instance.new("UIStroke", EnterButton)
ButtonStroke.Thickness = 2
ButtonStroke.Transparency = 0.2

-- Update เวลาเล่น
RunService.Heartbeat:Connect(function()
	local minutes = math.floor((os.time() - JoinTime) / 60)
	InfoText.Text = 
		"ชื่อ: " .. Username ..
		"\nUserId: " .. UserId ..
		"\nเซิร์ฟ: ไทย" ..
		"\nเวลาเล่น: " .. minutes .. " นาที"
end)

-- RGB Border
local hue = 0
RunService.RenderStepped:Connect(function(dt)
	hue = (hue + dt * 0.25) % 1
	local c = Color3.fromHSV(hue, 1, 1)

	MainStroke.Color = c
	AvatarStroke.Color = c
	ButtonStroke.Color = c
end)

-- Click เข้าสคริปต์ครั้งเดียวเด้งเลย ไม่มีปิดเปิด
EnterButton.MouseButton1Click:Connect(function()
	LoadingGui:Destroy()
	
	-- Rayfield Hub หลัก (ไม่มีปุ่มปิดเปิดสคริปต์แล้ว)
	local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

	local Window = Rayfield:CreateWindow({
	    Name = "RedFabza 👑",
	    LoadingTitle = "RedFabza Hub",
	    LoadingSubtitle = "โหลดเสร็จว่ะไอ้สัส",
	    ConfigurationSaving = {
	        Enabled = true,
	        FolderName = nil,
	        FileName = "RedFabza"
	    },
	    KeySystem = false
	})

	-- Tab การเคลื่อนที่
	local MovementTab = Window:CreateTab("🏃 การเคลื่อนที่", nil)

	MovementTab:CreateToggle({
	    Name = "🚀 บิน / fly",
	    CurrentValue = false,
	    Flag = "FlyToggle",
	    Callback = function(Value)
	        if Value then loadstring(game:HttpGet("https://pastebin.com/raw/iUVERBrs"))() end
	    end
	})

	MovementTab:CreateToggle({
	    Name = "🔥 วาป / คลิก",
	    CurrentValue = false,
	    Flag = "TeleportToggle",
	    Callback = function(Value)
	        if Value then loadstring(game:HttpGet("https://pastebin.com/raw/K5FYvtvN"))() end
	    end
	})

	MovementTab:CreateToggle({
	    Name = "🦴 ทะลุกำแพง / ปุ่ม",
	    CurrentValue = false,
	    Flag = "NoclipToggle",
	    Callback = function(Value)
	        if Value then loadstring(game:HttpGet("https://pastebin.com/raw/7Qab6kg9"))() end
	    end
	})

	-- Tab Movement Pro
	local MovementProTab = Window:CreateTab("🏃‍♂️ Movement Pro", nil)

	local currentWalkSpeed = 16
	MovementProTab:CreateSlider({
	    Name = "ความเร็ววิ่ง",
	    Range = {16, 500},
	    Increment = 1,
	    Suffix = "Speed",
	    CurrentValue = 16,
	    Flag = "WalkSpeedSlider",
	    Callback = function(Value)
	        currentWalkSpeed = Value
	        local char = LocalPlayer.Character
	        if char and char:FindFirstChild("Humanoid") then
	            char.Humanoid.WalkSpeed = Value
	        end
	    end
	})

	local currentJumpPower = 50
	MovementProTab:CreateSlider({
	    Name = "กระโดดสูง",
	    Range = {50, 500},
	    Increment = 1,
	    Suffix = "Power",
	    CurrentValue = 50,
	    Flag = "JumpPowerSlider",
	    Callback = function(Value)
	        currentJumpPower = Value
	        local char = LocalPlayer.Character
	        if char and char:FindFirstChild("Humanoid") then
	            char.Humanoid.JumpPower = Value
	        end
	    end
	})

	local infJumpEnabled = false
	local infJumpConn
	MovementProTab:CreateToggle({
	    Name = "กระโดดไม่จำกัด",
	    CurrentValue = false,
	    Flag = "InfJumpToggle",
	    Callback = function(Value)
	        infJumpEnabled = Value
	        local UIS = game:GetService("UserInputService")
	        if Value then
	            if infJumpConn then infJumpConn:Disconnect() end
	            infJumpConn = UIS.JumpRequest:Connect(function()
	                local char = LocalPlayer.Character
	                if char and char:FindFirstChild("Humanoid") then
	                    char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	                end
	            end)
	        else
	            if infJumpConn then infJumpConn:Disconnect() end
	        end
	    end
	})

	LocalPlayer.CharacterAdded:Connect(function(char)
	    char:WaitForChild("Humanoid")
	    char.Humanoid.WalkSpeed = currentWalkSpeed
	    char.Humanoid.JumpPower = currentJumpPower
	end)

	local playerChar = LocalPlayer.Character
	if playerChar and playerChar:FindFirstChild("Humanoid") then
	    playerChar.Humanoid.WalkSpeed = currentWalkSpeed
	    playerChar.Humanoid.JumpPower = currentJumpPower
	end

	-- Tab การโจมตี
	local CombatTab = Window:CreateTab("⚔️ การโจมตี", nil)

	CombatTab:CreateToggle({
	    Name = "ฆ่าบอททุกตัว",
	    CurrentValue = false,
	    Flag = "KillBotToggle",
	    Callback = function(Value)
	        if Value then loadstring(game:HttpGet("https://pastebin.com/raw/DczvQZyU"))() end
	    end
	})

	CombatTab:CreateToggle({
	    Name = "ล็อคหัวผู้เล่น",
	    CurrentValue = false,
	    Flag = "AimbotToggle",
	    Callback = function(Value)
	        if Value then loadstring(game:HttpGet("https://pastebin.com/raw/W46s2cTh"))() end
	    end
	})

	-- Tab เครื่องมือช่วยเล่น
	local ToolsTab = Window:CreateTab("🔧 เครื่องมือช่วยเล่น", nil)

	ToolsTab:CreateToggle({
	    Name = "เสกของ",
	    CurrentValue = false,
	    Flag = "GiveToolToggle",
	    Callback = function(Value)
	        if Value then loadstring(game:HttpGet("https://raw.githubusercontent.com/yofriendfromschool1/Sky-Hub-Backup/main/gametoolgiver.lua"))() end
	    end
	})

	ToolsTab:CreateToggle({
	    Name = "บูส FPS",
	    CurrentValue = false,
	    Flag = "FPSBoostToggle",
	    Callback = function(Value)
	        if Value then loadstring(game:HttpGet("https://pastebin.com/raw/mXhbHDVk"))() end
	    end
	})

	ToolsTab:CreateToggle({
	    Name = "Hitbox 32%",
	    CurrentValue = false,
	    Flag = "HitboxToggle",
	    Callback = function(Value)
	        if Value then loadstring(game:HttpGet("https://pastebin.com/raw/iRyTtfmf"))() end
	    end
	})

	ToolsTab:CreateToggle({
	    Name = "อมตะ",
	    CurrentValue = false,
	    Flag = "GodmodeToggle",
	    Callback = function(Value)
	        if Value then loadstring(game:HttpGet("https://pastebin.com/raw/EjrTrMwC"))() end
	    end
	})

	ToolsTab:CreateToggle({
	    Name = "คีย์บอร์ด",
	    CurrentValue = false,
	    Flag = "KeyboardToggle",
	    Callback = function(Value)
	        if Value then loadstring(game:HttpGet("https://raw.githubusercontent.com/Xxtan31/Ata/main/deltakeyboardcrack.txt"))() end
	    end
	})

	ToolsTab:CreateToggle({
	    Name = "หายตัว",
	    CurrentValue = false,
	    Flag = "InvisibleToggle",
	    Callback = function(Value)
	        if Value then loadstring(game:HttpGet("https://pastebin.com/raw/3Rnd9rHf"))() end
	    end
	})

	-- Tab ปั่นประสาท
	local TrollTab = Window:CreateTab("😈 ปั่นประสาท", nil)

	TrollTab:CreateToggle({
	    Name = "หลุมดำ",
	    CurrentValue = false,
	    Flag = "BlackholeToggle",
	    Callback = function(Value)
	        if Value then loadstring(game:HttpGet("https://pastebin.com/raw/pkZnU5P5"))() end
	    end
	})

	TrollTab:CreateToggle({
	    Name = "ชักว่าว",
	    CurrentValue = false,
	    Flag = "JerkOffToggle",
	    Callback = function(Value)
	        if Value then loadstring(game:HttpGet("https://pastefy.app/wa3v2Vgm/raw"))() end
	    end
	})

	TrollTab:CreateToggle({
	    Name = "F3X",
	    CurrentValue = false,
	    Flag = "F3XToggle",
	    Callback = function(Value)
	        if Value then loadstring(game:HttpGet("https://pastebin.com/raw/FZmTykdY"))() end
	    end
	})

	TrollTab:CreateToggle({
	    Name = "ดึงคน false",
	    CurrentValue = false,
	    Flag = "PullFalseToggle",
	    Callback = function(Value)
	        if Value then loadstring(game:HttpGet("https://pastebin.com/raw/CuDBzSm6"))() end
	    end
	})

	-- Tab ESP
	local ESPTab = Window:CreateTab("🔍 ESP", nil)

	local ESPSettings = {
	    Players = {
	        Enabled = false,
	        Color = Color3.fromRGB(255, 0, 0),
	        TeamCheck = true,
	        tracers = true,
	        boxes = true,
	        names = true,
	        health = true
	    },
	    NPCs = {
	        Enabled = false,
	        Color = Color3.fromRGB(0, 255, 0),
	        tracers = false,
	        boxes = true,
	        names = true
	    }
	}

	local playerDrawings = {}
	local npcDrawings = {}

	local function createESP(playerOrNPC, isPlayer)
	    local drawings = {}
	    local settings = isPlayer and ESPSettings.Players or ESPSettings.NPCs

	    if settings.boxes then
	        local box = Drawing.new("Square")
	        box.Thickness = 2
	        box.Filled = false
	        box.Transparency = 1
	        drawings.box = box
	    end

	    if settings.tracers then
	        local tracer = Drawing.new("Line")
	        tracer.Thickness = 1
	        tracer.Transparency = 1
	        drawings.tracer = tracer
	    end

	    if settings.names then
	        local nameTag = Drawing.new("Text")
	        nameTag.Size = 13
	        nameTag.Center = true
	        nameTag.Outline = true
	        drawings.name = nameTag
	    end

	    if settings.health and isPlayer then
	        local healthBar = Drawing.new("Line")
	        healthBar.Thickness = 3
	        drawings.health = healthBar
	    end

	    return drawings
	end

	local function updateESP()
	    for _, player in ipairs(Players:GetPlayers()) do
	        if player == LocalPlayer then continue end
	        if ESPSettings.Players.TeamCheck and player.Team == LocalPlayer.Team then continue end

	        local char = player.Character
	        if not char or not char:FindFirstChild("Humanoid") or not char:FindFirstChild("HumanoidRootPart") or char.Humanoid.Health <= 0 then
	            if playerDrawings[player] then
	                for _, d in pairs(playerDrawings[player]) do d.Visible = false end
	            end
	            continue
	        end

	        local root = char.HumanoidRootPart
	        local head = char:FindFirstChild("Head")
	        if not head then continue end

	        local drawings = playerDrawings[player] or createESP(player, true)
	        playerDrawings[player] = drawings

	        local rootPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(root.Position)
	        local headPos = workspace.CurrentCamera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
	        local legPos = workspace.CurrentCamera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))

	        local size = (headPos - legPos).Magnitude * 1.2
	        local color = ESPSettings.Players.Color

	        if drawings.box then
	            drawings.box.Size = Vector2.new(size * 1.2, size * 2)
	            drawings.box.Position = Vector2.new(rootPos.X - drawings.box.Size.X / 2, rootPos.Y - drawings.box.Size.Y / 2)
	            drawings.box.Color = color
	            drawings.box.Visible = onScreen and ESPSettings.Players.Enabled
	        end

	        if drawings.tracer then
	            drawings.tracer.From = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y)
	            drawings.tracer.To = Vector2.new(rootPos.X, rootPos.Y)
	            drawings.tracer.Color = color
	            drawings.tracer.Visible = onScreen and ESPSettings.Players.Enabled
	        end

	        if drawings.name then
	            drawings.name.Text = player.Name .. " [" .. math.floor(char.Humanoid.Health) .. "]"
	            drawings.name.Position = Vector2.new(rootPos.X, rootPos.Y - size - 15)
	            drawings.name.Color = color
	            drawings.name.Visible = onScreen and ESPSettings.Players.Enabled
	        end

	        if drawings.health then
	            local healthPct = char.Humanoid.Health / char.Humanoid.MaxHealth
	            drawings.health.From = Vector2.new(rootPos.X - size/2 - 8, rootPos.Y + size/2)
	            drawings.health.To = Vector2.new(rootPos.X - size/2 - 8, rootPos.Y + size/2 - (size * healthPct))
	            drawings.health.Color = Color3.fromRGB(255 * (1 - healthPct), 255 * healthPct, 0)
	            drawings.health.Visible = onScreen and ESPSettings.Players.Enabled
	        end
	    end

	    for _, obj in ipairs(workspace:GetDescendants()) do
	        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") and not Players:GetPlayerFromCharacter(obj) then
	            local char = obj
	            local root = char.HumanoidRootPart
	            local head = char:FindFirstChild("Head") or root

	            local rootPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(root.Position)
	            local size = 80

	            local drawings = npcDrawings[obj] or createESP(obj, false)
	            npcDrawings[obj] = drawings

	            local color = ESPSettings.NPCs.Color

	            if drawings.box then
	                drawings.box.Size = Vector2.new(size, size * 1.8)
	                drawings.box.Position = Vector2.new(rootPos.X - drawings.box.Size.X / 2, rootPos.Y - drawings.box.Size.Y / 2)
	                drawings.box.Color = color
	                drawings.box.Visible = onScreen and ESPSettings.NPCs.Enabled
	            end

	            if drawings.name then
	                drawings.name.Text = obj.Name or "NPC"
	                drawings.name.Position = Vector2.new(rootPos.X, rootPos.Y - size - 10)
	                drawings.name.Color = color
	                drawings.name.Visible = onScreen and ESPSettings.NPCs.Enabled
	            end
	        end
	    end
	end

	Players.PlayerRemoving:Connect(function(player)
	    if playerDrawings[player] then
	        for _, d in pairs(playerDrawings[player]) do d:Remove() end
	        playerDrawings[player] = nil
	    end
	end)

	local runConn
	local function startNewESP()
	    if runConn then runConn:Disconnect() end
	    runConn = RunService.RenderStepped:Connect(updateESP)
	end

	ESPTab:CreateSection("ESP ใหม่")
	ESPTab:CreateToggle({
	    Name = "เปิด ESP Players",
	    CurrentValue = false,
	    Flag = "NewESPPlayers",
	    Callback = function(Value)
	        ESPSettings.Players.Enabled = Value
	        if Value and not runConn then startNewESP() end
	    end
	})

	ESPTab:CreateColorpicker({
	    Name = "สี Players",
	    Color = ESPSettings.Players.Color,
	    Flag = "NewPlayersColor",
	    Callback = function(Value)
	        ESPSettings.Players.Color = Value
	    end
	})

	ESPTab:CreateToggle({
	    Name = "เปิด ESP BOT/NPC",
	    CurrentValue = false,
	    Flag = "NewESPNPC",
	    Callback = function(Value)
	        ESPSettings.NPCs.Enabled = Value
	        if Value and not runConn then startNewESP() end
	    end
	})

	ESPTab:CreateColorpicker({
	    Name = "สี BOT/NPC",
	    Color = ESPSettings.NPCs.Color,
	    Flag = "NewNPCsColor",
	    Callback = function(Value)
	        ESPSettings.NPCs.Color = Value
	    end
	})

	ESPTab:CreateToggle({
	    Name = "Team Check",
	    CurrentValue = true,
	    Callback = function(Value)
	        ESPSettings.Players.TeamCheck = Value
	    end
	})

	ESPTab:CreateSection("ESP เก่า")
	ESPTab:CreateToggle({
	    Name = "ESP Players (เก่า)",
	    CurrentValue = false,
	    Flag = "OldESPPlayersToggle",
	    Callback = function(Value)
	        if Value then loadstring(game:HttpGet("https://raw.githubusercontent.com/wackshopr-tech/script-roblox-all/refs/heads/main/SCRIPT-ALL-BY-WACK-SHOP/EPS-MAP-ALL/EPS-MAP-ALL.lua"))() end
	    end
	})

	ESPTab:CreateToggle({
	    Name = "ESP BOT/NPC (เก่า)",
	    CurrentValue = false,
	    Flag = "OldESPNPCToggle",
	    Callback = function(Value)
	        if Value then loadstring(game:HttpGet("https://pastebin.com/raw/q26QuUBF"))() end
	    end
	})

	-- Notify สุดท้าย
	Rayfield:Notify({
	    Title = "เข้าสำเร็จว่ะไอ้เอิร์ท",
	    Content = "ปุ่มเปิดปิดหายไปหมดแล้วตามที่มึงสั่ง กดครั้งเดียวเด้งเข้าหลักเลย UI สะอาดขึ้นเยอะ ไปโกงให้มันส์เลยไอ้สัส ถ้า UI ยังรกอยู่ก็สมน้ำหน้าเองที่เคยขอปุ่มกาก ๆ นั้นมา 5555",
	    Duration = 6,
	})
end)
