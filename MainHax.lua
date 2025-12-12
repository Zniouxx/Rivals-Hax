--// FULL CHEAT SCRIPT (ALL‑IN‑ONE)
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--------------------------------------------------------------
-- SETTINGS
--------------------------------------------------------------
local Settings = {
    Aimbot = false,
    ESP = false,
    Fly = false,
    Noclip = false,
    Speed = false,
    Jump = false,
    Gravity = false,
    Smoothness = 0.25,
    FOV = 150,
    FlySpeed = 4,
    WalkSpeed = 50,
}

--------------------------------------------------------------
-- UI MENU
--------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 260, 0, 330)
Frame.Position = UDim2.new(0.5, -130, 0.5, -165)
Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Frame.Active = true
Frame.Draggable = true
Frame.Visible = false

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Title.Text = "Cheat Menu"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextScaled = true

local function MakeToggle(name, ypos, key)
    local btn = Instance.new("TextButton", Frame)
    btn.Size = UDim2.new(1, -20, 0, 40)
    btn.Position = UDim2.new(0, 10, 0, ypos)
    btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Text = name .. ": OFF"

    btn.MouseButton1Click:Connect(function()
        Settings[key] = not Settings[key]
        btn.Text = name .. ": " .. (Settings[key] and "ON" or "OFF")
    end)
end

MakeToggle("Aimbot", 50, "Aimbot")
MakeToggle("ESP", 100, "ESP")
MakeToggle("Fly", 150, "Fly")
MakeToggle("Noclip", 200, "Noclip")
MakeToggle("Speed Hack", 250, "Speed")
MakeToggle("Infinite Jump", 300, "Jump")

--------------------------------------------------------------
-- TOGGLE MENU (PRESS M)
--------------------------------------------------------------
UIS.InputBegan:Connect(function(key)
    if key.KeyCode == Enum.KeyCode.M then
        Frame.Visible = not Frame.Visible
    end
end)

--------------------------------------------------------------
-- ESP (THROUGH WALLS)
--------------------------------------------------------------
local function ApplyESP(character)
    if character:FindFirstChild("Highlight") then return end
    local hl = Instance.new("Highlight", character)
    hl.FillColor = Color3.fromRGB(255, 0, 0)
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency = 0.25
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
end

local function HandleESP()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and Settings.ESP then
            if plr.Character then ApplyESP(plr.Character) end
            plr.CharacterAdded:Connect(ApplyESP)
        end
    end
end

RunService.RenderStepped:Connect(HandleESP)

--------------------------------------------------------------
-- AIMBOT
--------------------------------------------------------------
local function GetClosest()
    local closest = nil
    local shortest = math.huge

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
            local head = plr.Character.Head
            local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local dist = (Vector2.new(pos.X, pos.Y) - UIS:GetMouseLocation()).Magnitude
                if dist < shortest and dist < Settings.FOV then
                    closest = head
                    shortest = dist
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    if Settings.Aimbot and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = GetClosest()
        if target then
            local newCF = CFrame.lookAt(Camera.CFrame.Position, target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(newCF, Settings.Smoothness)
        end
    end
end)

--------------------------------------------------------------
-- FLY
--------------------------------------------------------------
local vel = Instance.new("BodyVelocity")
vel.MaxForce = Vector3.new(9e9, 9e9, 9e9)

RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    if Settings.Fly then
        vel.Parent = char.HumanoidRootPart

        local move = Vector3.new()
        if UIS:IsKeyDown(Enum.KeyCode.W) then move += Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then move -= Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then move -= Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then move += Camera.CFrame.RightVector end

        vel.Velocity = move * Settings.FlySpeed
    else
        vel.Parent = nil
    end
end)

--------------------------------------------------------------
-- NOCLIP
--------------------------------------------------------------
RunService.Stepped:Connect(function()
    if Settings.Noclip and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

--------------------------------------------------------------
-- SPEED HACK
--------------------------------------------------------------
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        if Settings.Speed then
            char.Humanoid.WalkSpeed = Settings.WalkSpeed
        end
    end
end)

--------------------------------------------------------------
-- INFINITE JUMP
--------------------------------------------------------------
UIS.JumpRequest:Connect(function()
    if Settings.Jump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

--------------------------------------------------------------
-- GRAVITY (G KEY)
--------------------------------------------------------------
UIS.InputBegan:Connect(function(key)
    if key.KeyCode == Enum.KeyCode.G then
        if Settings.Gravity then
            workspace.Gravity = 196.2
        else
            workspace.Gravity = 25 -- moon gravity
        end
        Settings.Gravity = not Settings.Gravity
    end
end)
