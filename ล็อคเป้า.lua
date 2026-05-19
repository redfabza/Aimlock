local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local Aimlock = false
local ShowFOV = true
local FOVPercent = 20
local LockedTarget = nil

-- ระยะห่างของกล้อง (ตั้งค่ามาตรฐานตามมุมกล้องปกติของ Roblox)
local CameraOffset = Vector3.new(0, 2.5, 12) 

-- =========================
-- GUI MAIN CONTAINER
-- =========================
local Gui = Instance.new("ScreenGui")
Gui.Name = "WackShop_Aimlock_Final"
Gui.IgnoreGuiInset = true
Gui.ResetOnSpawn = false
Gui.Parent = CoreGui

-- =========================
-- FOV CIRCLE & CENTER DOT
-- =========================
local FOVFrame = Instance.new("Frame")
FOVFrame.Name = "FOV_Circle"
FOVFrame.AnchorPoint = Vector2.new(0.5, 0.5)
FOVFrame.BackgroundTransparency = 1
FOVFrame.Visible = false
FOVFrame.Parent = Gui

local FOVStroke = Instance.new("UIStroke")
FOVStroke.Thickness = 2
FOVStroke.Transparency = 0.2
FOVStroke.Parent = FOVFrame

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1, 0)
FOVCorner.Parent = FOVFrame

local CenterDot = Instance.new("Frame")
CenterDot.Name = "CenterDot"
CenterDot.Size = UDim2.fromOffset(6, 6)
CenterDot.AnchorPoint = Vector2.new(0.5, 0.5)
CenterDot.Visible = false
CenterDot.Parent = Gui

local DotCorner = Instance.new("UICorner")
DotCorner.CornerRadius = UDim.new(1, 0)
DotCorner.Parent = CenterDot

local function GetFOVRadius()
    local vp = Camera.ViewportSize
    return (math.min(vp.X, vp.Y) / 2) * (FOVPercent / 100)
end

local function UpdateCircle()
    local vp = Camera.ViewportSize
    if vp.X == 0 or vp.Y == 0 then return end
    
    local radius = GetFOVRadius()
    FOVFrame.Size = UDim2.fromOffset(radius * 2, radius * 2)
    FOVFrame.Position = UDim2.fromOffset(vp.X / 2, vp.Y / 2)
    CenterDot.Position = UDim2.fromOffset(vp.X / 2, vp.Y / 2)
end

local function GetRGBColor()
    local tickTime = tick()
    local r = (math.sin(tickTime * 2.5) + 1) / 2
    local g = (math.sin(tickTime * 2.5 + 2) + 1) / 2
    local b = (math.sin(tickTime * 2.5 + 4) + 1) / 2
    return Color3.new(r, g, b)
end

local function IsTargetAlive(character)
    if not character or not character.Parent then return false end
    local hum = character:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function FindNewTarget()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local closest, closestDist = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local head = p.Character:FindFirstChild("Head")
            if head and IsTargetAlive(p.Character) then
                local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen and pos.Z > 0 then
                    local mag = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if mag <= GetFOVRadius() and mag < closestDist then
                        closest = p.Character
                        closestDist = mag
                    end
                end
            end
        end
    end
    return closest
end

local syncUI = function(state) end

local function updateToggle(state)
    Aimlock = state
    if not state then
        LockedTarget = nil
        Camera.CameraType = Enum.CameraType.Custom
    end
    syncUI(state)
end

-- =========================
-- MAIN LOOP
-- =========================
RunService.RenderStepped:Connect(function()
    UpdateCircle()
    
    local dynamicColor = GetRGBColor()
    FOVStroke.Color = dynamicColor
    CenterDot.BackgroundColor3 = dynamicColor

    local isVisible = Aimlock and ShowFOV
    FOVFrame.Visible = isVisible
    CenterDot.Visible = isVisible

    -- คืนค่ากล้องปกติเมื่อไม่ได้เปิด Aimlock
    if not Aimlock then
        if Camera.CameraType ~= Enum.CameraType.Custom then
            Camera.CameraType = Enum.CameraType.Custom
        end
        return
    end

    -- ตรวจสอบเป้าหมาย
    if LockedTarget and not IsTargetAlive(LockedTarget) then
        LockedTarget = nil
        updateToggle(false)
        return
    end

    if not LockedTarget then
        LockedTarget = FindNewTarget()
    end

    -- ระบบล็อกแบบกล้องเกาะหลังตัวเรา (Fixed Camera Follow + Hard Lock)
    if LockedTarget and LocalPlayer.Character then
        local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local enemyHead = LockedTarget:FindFirstChild("Head")
        
        if myRoot and enemyHead then
            Camera.CameraType = Enum.CameraType.Scriptable
            
            -- คำนวณหาทิศทางจากศัตรูมาหาตัวเรา เพื่อสร้างมุมกล้องที่มองจากด้านหลังตัวเราไปหาศัตรู
            local direction = (myRoot.Position - enemyHead.Position).Unit
            
            -- บังคับพิกัดกล้องให้อยู่ด้านหลังตัวผู้เล่น (เกาะตัวเราตลอดเวลา ไม่หลุดแน่นอน)
            local targetCamPos = myRoot.Position + (direction * CameraOffset.Z) + Vector3.new(0, CameraOffset.Y, 0)
            
            -- สั่งให้กล้องอยู่ที่พิกัดหลังตัวเรา และหันหน้าไปที่หัวศัตรูตรงๆ
            Camera.CFrame = CFrame.lookAt(targetCamPos, enemyHead.Position)
        else
            Camera.CameraType = Enum.CameraType.Custom
        end
    else
        Camera.CameraType = Enum.CameraType.Custom
    end
end)

-- =========================
-- DRAGGABLE UI SYSTEM
-- =========================
local function MakeDraggable(frame, handle)
    local dragging, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = frame.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
end

-- =========================
-- GUI PANELS
-- =========================
local Main = Instance.new("Frame", Gui)
Main.Size = UDim2.fromOffset(260, 340)
Main.Position = UDim2.fromOffset(80, 160)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
Main.BorderSizePixel = 0
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 14)
Instance.new("UIStroke", Main).Color = Color3.fromRGB(40, 40, 50)

local TitleBar = Instance.new("Frame", Main)
TitleBar.Size = UDim2.new(1, 0, 0, 42)
TitleBar.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
TitleBar.BorderSizePixel = 0
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 14)

local TitleLabel = Instance.new("TextLabel", TitleBar)
TitleLabel.Size = UDim2.new(1, -45, 1, 0)
TitleLabel.Position = UDim2.new(0, 14, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "⚡ WackShop Aimlock"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 14
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

RunService.RenderStepped:Connect(function() TitleLabel.TextColor3 = GetRGBColor() end)

local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Size = UDim2.fromOffset(28, 28)
CloseBtn.Position = UDim2.new(1, -36, 0, 7)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 13
CloseBtn.BorderSizePixel = 0
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

MakeDraggable(Main, TitleBar)

local FloatBtn = Instance.new("TextButton", Gui)
FloatBtn.Size = UDim2.fromOffset(44, 44)
FloatBtn.Position = UDim2.fromOffset(20, 120)
FloatBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
FloatBtn.Text = "W"
FloatBtn.TextColor3 = Color3.fromRGB(0, 200, 255)
FloatBtn.Font = Enum.Font.GothamBold
FloatBtn.TextSize = 18
FloatBtn.Visible = false
FloatBtn.BorderSizePixel = 0
Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", FloatBtn).Color = Color3.fromRGB(0, 170, 255)
MakeDraggable(FloatBtn, FloatBtn)

CloseBtn.MouseButton1Click:Connect(function() Main.Visible = false; FloatBtn.Visible = true end)
FloatBtn.MouseButton1Click:Connect(function() Main.Visible = true; FloatBtn.Visible = false end)

local toggleBox = Instance.new("Frame", Main)
toggleBox.Size = UDim2.new(1, -20, 0, 55)
toggleBox.Position = UDim2.new(0, 10, 0, 52)
toggleBox.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
toggleBox.BorderSizePixel = 0
Instance.new("UICorner", toggleBox).CornerRadius = UDim.new(0, 10)
local tbs = Instance.new("UIStroke", toggleBox)
tbs.Color = Color3.fromRGB(0, 180, 255)
tbs.Thickness = 1
tbs.Transparency = 0.6

local tlbl = Instance.new("TextLabel", toggleBox)
tlbl.Size = UDim2.new(1, -65, 0, 24)
tlbl.Position = UDim2.new(0, 10, 0, 6)
tlbl.BackgroundTransparency = 1
tlbl.Text = "🔵 ระบบ Aimlock"
tlbl.TextColor3 = Color3.fromRGB(220, 220, 220)
tlbl.Font = Enum.Font.GothamBold
tlbl.TextSize = 13
tlbl.TextXAlignment = Enum.TextXAlignment.Left

local tdesc = Instance.new("TextLabel", toggleBox)
tdesc.Size = UDim2.new(1, -65, 0, 18)
tdesc.Position = UDim2.new(0, 10, 0, 30)
tdesc.BackgroundTransparency = 1
tdesc.Text = "ล็อคเป้าแม่นยำ + กล้องตามหลังปกติ"
tdesc.TextColor3 = Color3.fromRGB(90, 120, 150)
tdesc.Font = Enum.Font.Gotham
tdesc.TextSize = 11
tdesc.TextXAlignment = Enum.TextXAlignment.Left

local switchBG = Instance.new("Frame", toggleBox)
switchBG.Size = UDim2.fromOffset(44, 24)
switchBG.Position = UDim2.new(1, -54, 0.5, -12)
switchBG.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
switchBG.BorderSizePixel = 0
Instance.new("UICorner", switchBG).CornerRadius = UDim.new(1, 0)

local knob = Instance.new("Frame", switchBG)
knob.Size = UDim2.fromOffset(18, 18)
knob.Position = UDim2.new(0, 3, 0.5, -9)
knob.BackgroundColor3 = Color3.fromRGB(160, 160, 180)
knob.BorderSizePixel = 0
Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

local toggleClickArea = Instance.new("TextButton", toggleBox)
toggleClickArea.Size = UDim2.new(1, 0, 1, 0)
toggleClickArea.BackgroundTransparency = 1
toggleClickArea.Text = ""

local fovToggleBox = Instance.new("Frame", Main)
fovToggleBox.Size = UDim2.new(1, -20, 0, 50)
fovToggleBox.Position = UDim2.new(0, 10, 0, 114)
fovToggleBox.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
fovToggleBox.BorderSizePixel = 0
Instance.new("UICorner", fovToggleBox).CornerRadius = UDim.new(0, 10)

local ftlbl = Instance.new("TextLabel", fovToggleBox)
ftlbl.Size = UDim2.new(1, -65, 1, 0)
ftlbl.Position = UDim2.new(0, 10, 0, 0)
ftlbl.BackgroundTransparency = 1
ftlbl.Text = "👁️ แสดงวงกลม FOV"
ftlbl.TextColor3 = Color3.fromRGB(220, 220, 220)
ftlbl.Font = Enum.Font.GothamSemibold
ftlbl.TextSize = 12
ftlbl.TextXAlignment = Enum.TextXAlignment.Left

local fswitchBG = Instance.new("Frame", fovToggleBox)
fswitchBG.Size = UDim2.fromOffset(44, 24)
fswitchBG.Position = UDim2.new(1, -54, 0.5, -12)
fswitchBG.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
fswitchBG.BorderSizePixel = 0
Instance.new("UICorner", fswitchBG).CornerRadius = UDim.new(1, 0)

local fknob = Instance.new("Frame", fswitchBG)
fknob.Size = UDim2.fromOffset(18, 18)
fknob.Position = UDim2.new(1, -21, 0.5, -9)
fknob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
fknob.BorderSizePixel = 0
Instance.new("UICorner", fknob).CornerRadius = UDim.new(1, 0)

local fovClickArea = Instance.new("TextButton", fovToggleBox)
fovClickArea.Size = UDim2.new(1, 0, 1, 0)
fovClickArea.BackgroundTransparency = 1
fovClickArea.Text = ""

fovClickArea.MouseButton1Click:Connect(function()
    ShowFOV = not ShowFOV
    TweenService:Create(fswitchBG, TweenInfo.new(0.2), {
        BackgroundColor3 = ShowFOV and Color3.fromRGB(0,180,255) or Color3.fromRGB(40,40,55)
    }):Play()
    TweenService:Create(fknob, TweenInfo.new(0.2), {
        Position = ShowFOV and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9)
    }):Play()
end)

local LockBtn, lps
syncUI = function(state)
    TweenService:Create(switchBG, TweenInfo.new(0.2), {
        BackgroundColor3 = state and Color3.fromRGB(0,180,255) or Color3.fromRGB(40,40,55)
    }):Play()
    TweenService:Create(knob, TweenInfo.new(0.2), {
        Position = state and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9),
        BackgroundColor3 = state and Color3.fromRGB(255,255,255) or Color3.fromRGB(160,160,180)
    }):Play()
    tbs.Transparency = state and 0 or 0.6
    tlbl.TextColor3 = state and Color3.fromRGB(0,200,255) or Color3.fromRGB(220,220,220)
    if LockBtn then
        TweenService:Create(LockBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = state and Color3.fromRGB(0,150,255) or Color3.fromRGB(160,30,30)
        }):Play()
        LockBtn.Text = state and "🔒 ล็อคอยู่!" or "🔓 ล็อคเป้า"
        lps.Color = state and Color3.fromRGB(0,170,255) or Color3.fromRGB(255,60,60)
    end
end

toggleClickArea.MouseButton1Click:Connect(function() updateToggle(not Aimlock) end)

local StatusLabel = Instance.new("TextLabel", Main)
StatusLabel.Size = UDim2.new(1, -20, 0, 28)
StatusLabel.Position = UDim2.new(0, 10, 0, 172)
StatusLabel.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
StatusLabel.Font = Enum.Font.GothamSemibold
StatusLabel.TextSize = 12
StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
StatusLabel.Text = "เป้าหมาย : ไม่มี"
StatusLabel.BorderSizePixel = 0
Instance.new("UICorner", StatusLabel).CornerRadius = UDim.new(0, 8)

RunService.Heartbeat:Connect(function()
    if LockedTarget and LockedTarget.Parent then
        local p = Players:GetPlayerFromCharacter(LockedTarget)
        if p then
            StatusLabel.Text = "🔒 ล็อค : " .. p.Name
            StatusLabel.TextColor3 = Color3.fromRGB(0, 220, 120)
            return
        end
    end
    StatusLabel.Text = "เป้าหมาย : ไม่มี"
    StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
end)

local FovTitle = Instance.new("TextLabel", Main)
FovTitle.Position = UDim2.new(0, 10, 0, 212)
FovTitle.Size = UDim2.new(1, -20, 0, 18)
FovTitle.BackgroundTransparency = 1
FovTitle.Text = "🎯 ขนาด FOV : " .. FOVPercent .. "%"
FovTitle.TextColor3 = Color3.fromRGB(150, 210, 255)
FovTitle.Font = Enum.Font.GothamSemibold
FovTitle.TextSize = 13
FovTitle.TextXAlignment = Enum.TextXAlignment.Left

local BarBG = Instance.new("Frame", Main)
BarBG.Position = UDim2.new(0, 10, 0, 235)
BarBG.Size = UDim2.new(1, -20, 0, 12)
BarBG.BackgroundColor3 = Color3.fromRGB(28, 35, 55)
BarBG.BorderSizePixel = 0
Instance.new("UICorner", BarBG).CornerRadius = UDim.new(0, 8)

local Fill = Instance.new("Frame", BarBG)
Fill.Size = UDim2.new(FOVPercent/100, 0, 1, 0)
Fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
Fill.BorderSizePixel = 0
Instance.new("UICorner", Fill).CornerRadius = UDim.new(0, 8)

local SliderKnob = Instance.new("Frame", BarBG)
SliderKnob.Size = UDim2.fromOffset(18, 18)
SliderKnob.AnchorPoint = Vector2.new(0.5, 0.5)
SliderKnob.Position = UDim2.new(FOVPercent/100, 0, 0.5, 0)
SliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SliderKnob.BorderSizePixel = 0
Instance.new("UICorner", SliderKnob).CornerRadius = UDim.new(1, 0)

local sliding = false
local function UpdateSlider(inputX)
    local pct = math.clamp((inputX - BarBG.AbsolutePosition.X) / BarBG.AbsoluteSize.X, 0, 1)
    FOVPercent = math.floor(pct * 100)
    Fill.Size = UDim2.new(pct, 0, 1, 0)
    SliderKnob.Position = UDim2.new(pct, 0, 0.5, 0)
    FovTitle.Text = "🎯 ขนาด FOV : " .. FOVPercent .. "%"
    UpdateCircle()
end

BarBG.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then sliding = true; UpdateSlider(i.Position.X) end
end)
UIS.InputChanged:Connect(function(i)
    if sliding and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then UpdateSlider(i.Position.X) end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then sliding = false end
end)

local Credit = Instance.new("TextLabel", Main)
Credit.Position = UDim2.new(0, 0, 1, -22)
Credit.Size = UDim2.new(1, 0, 0, 18)
Credit.BackgroundTransparency = 1
Credit.Text = "WackShop — Clean & Stable"
Credit.TextColor3 = Color3.fromRGB(80, 100, 120)
Credit.Font = Enum.Font.Gotham
Credit.TextSize = 11

-- =========================
-- SEPARATE LOCK PANEL
-- =========================
local LockPanel = Instance.new("Frame", Gui)
LockPanel.Size = UDim2.fromOffset(120, 80)
LockPanel.AnchorPoint = Vector2.new(1, 1)
LockPanel.Position = UDim2.new(1, -20, 1, -20)
LockPanel.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
LockPanel.BorderSizePixel = 0
Instance.new("UICorner", LockPanel).CornerRadius = UDim.new(0, 12)
lps = Instance.new("UIStroke", LockPanel)
lps.Color = Color3.fromRGB(255, 60, 60)
lps.Thickness = 1.5

local DragHandle = Instance.new("Frame", LockPanel)
DragHandle.Size = UDim2.new(1, 0, 0, 22)
DragHandle.BackgroundColor3 = Color3.fromRGB(20, 20, 32)
DragHandle.BorderSizePixel = 0
Instance.new("UICorner", DragHandle).CornerRadius = UDim.new(0, 12)

local DragLabel = Instance.new("TextLabel", DragHandle)
DragLabel.Size = UDim2.new(1, -55, 1, 0)
DragLabel.BackgroundTransparency = 1
DragLabel.Text = "· · · ลาก"
DragLabel.TextColor3 = Color3.fromRGB(100, 100, 130)
DragLabel.Font = Enum.Font.GothamSemibold
DragLabel.TextSize = 11

local lockDrag = false
local lockDragBtn = Instance.new("TextButton", DragHandle)
lockDragBtn.Size = UDim2.fromOffset(48, 18)
lockDragBtn.Position = UDim2.new(1, -52, 0, 2)
lockDragBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
lockDragBtn.Text = "🔓ลาก"
lockDragBtn.TextColor3 = Color3.fromRGB(180, 180, 200)
lockDragBtn.Font = Enum.Font.GothamSemibold
lockDragBtn.TextSize = 10
lockDragBtn.BorderSizePixel = 0
Instance.new("UICorner", lockDragBtn).CornerRadius = UDim.new(0, 4)

lockDragBtn.MouseButton1Click:Connect(function()
    lockDrag = not lockDrag
    lockDragBtn.Text = lockDrag and "🔒ลาก" or "🔓ลาก"
    lockDragBtn.BackgroundColor3 = lockDrag and Color3.fromRGB(0, 120, 200) or Color3.fromRGB(40, 40, 60)
end)

local draggingPanel, dragStartPanel, startPosPanel
DragHandle.InputBegan:Connect(function(input)
    if lockDrag then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingPanel = true; dragStartPanel = input.Position; startPosPanel = LockPanel.Position
    end
end)
UIS.InputChanged:Connect(function(input)
    if draggingPanel and not lockDrag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local d = input.Position - dragStartPanel
        LockPanel.Position = UDim2.new(startPosPanel.X.Scale, startPosPanel.X.Offset + d.X, startPosPanel.Y.Scale, startPosPanel.Y.Offset + d.Y)
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingPanel = false end
end)

LockBtn = Instance.new("TextButton", LockPanel)
LockBtn.Size = UDim2.new(1, -10, 0, 46)
LockBtn.Position = UDim2.new(0, 5, 0, 26)
LockBtn.BackgroundColor3 = Color3.fromRGB(160, 30, 30)
LockBtn.Text = "🔓 ล็อคเป้า"
LockBtn.TextColor3 = Color3.new(1,1,1)
LockBtn.Font = Enum.Font.GothamBold
LockBtn.TextSize = 13
LockBtn.BorderSizePixel = 0
Instance.new("UICorner", LockBtn).CornerRadius = UDim.new(0, 8)

LockBtn.MouseButton1Click:Connect(function() updateToggle(not Aimlock) end)

print("✅ WackShop Aimlock Loaded! (Clean UI Version)")