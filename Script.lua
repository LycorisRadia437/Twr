-- Owner : brotha2
-- Upgraded : Lycorisradia437 & Gemini
-- Version : V5.9 (Fixed Zombie ESP: Only active & spawned zombies)
-- Game : Those Who Remain

-- ── Auto Clear Cache / Config on Startup ────────────────────────
pcall(function()
    if isfolder and isfolder("TWR_Config") then
        for _, file in ipairs(listfiles("TWR_Config")) do
            pcall(function() delfile(file) end)
        end
    end
end)

local Players              = game:GetService("Players")
local RunService           = game:GetService("RunService")
local ReplicatedStorage    = game:GetService("ReplicatedStorage")
local UserInputService     = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local TweenService         = game:GetService("TweenService")
local Lighting             = game:GetService("Lighting")
local StarterGui           = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local Camera      = workspace.CurrentCamera

local Config = {
    ESP_Players  = false,
    ESP_Zombies  = false,
    ESP_Items    = false,
    ShowNames    = false,

    BillboardTransparency     = 0.9,
    Chams_PlayerColor         = Color3.fromRGB(0, 120, 255),
    Chams_ZombieColor         = Color3.fromRGB(255, 40, 40),
    Chams_ItemColor           = Color3.fromRGB(0, 255, 255),
    Chams_FillTransparency    = 0.5,
    Chams_OutlineTransparency = 0.1,

    Hitbox_Enabled      = false,
    Hitbox_Size         = 15,
    Hitbox_Transparency = 0.7,
    Hitbox_Color        = Color3.fromRGB(255, 0, 80),

    InfAmmo      = false,

    Fly          = false,
    FlySpeed     = 50,
    Speed        = false,
    SpeedValue   = 40,
    InfiniteJump = false,

    FullBright   = false,
    AntiAFK      = true,

    AC_Bypass    = false,
}

local FBBackup = {}

-- ── Load Rayfield Gen2 ─────────────────────────────────────────
local Rayfield
local success, err = pcall(function()
    Rayfield = loadstring(game:HttpGet("https://sirius.menu/gen2"))()
end)

if not success or not Rayfield then
    pcall(function()
        Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Rayfield/main/source"))()
    end)
end

if not Rayfield then
    warn("[TWR Hub Error]: Không thể tải thư viện Rayfield!")
    return
end

local Window = Rayfield:CreateWindow({
    Name            = "TWR Hub  |  brotha2  ·  v5.9",
    LoadingTitle    = "Those Who Remain",
    LoadingSubtitle = "v5.9 - Optimized Zombie ESP",
    Theme           = "Default",
    ConfigurationSaving = {
        Enabled    = true,
        FolderName = "TWR_Config",
        FileName   = "twr_v59",
    },
    KeySystem = false,
})

-- ── Credit bar ─────────────────────────────────────────────────
do
    local pg = LocalPlayer:WaitForChild("PlayerGui")

    local holder = Instance.new("Frame")
    holder.Name = "TWR_Credit"
    holder.Size = UDim2.new(0, 240, 0, 40)
    holder.Position = UDim2.new(1, -256, 1, -52)
    holder.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
    holder.BackgroundTransparency = 0.15
    holder.BorderSizePixel = 0
    holder.Parent = pg

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = holder

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(95, 155, 255)
    stroke.Thickness = 1
    stroke.Transparency = 0.4
    stroke.Parent = holder
    
    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new(Color3.fromRGB(60, 120, 220), Color3.fromRGB(150, 200, 255))
    grad.Rotation = 45
    grad.Parent = stroke

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 12)
    pad.PaddingRight = UDim.new(0, 12)
    pad.PaddingTop = UDim.new(0, 4)
    pad.PaddingBottom = UDim.new(0, 4)
    pad.Parent = holder

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 0.55, 0)
    label.Text = "brotha2  ·  TWR v5.9"
    label.TextColor3 = Color3.fromRGB(235, 235, 245)
    label.TextStrokeTransparency = 0.8
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = holder
    
    local labelGrad = Instance.new("UIGradient")
    labelGrad.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(150, 200, 255))
    labelGrad.Rotation = 90
    labelGrad.Parent = label

    local sub = Instance.new("TextLabel")
    sub.BackgroundTransparency = 1
    sub.Size = UDim2.new(1, 0, 0.4, 0)
    sub.Position = UDim2.new(0, 0, 0.55, 0)
    sub.Text = "v5.9  ·  zombie esp fixed"
    sub.TextColor3 = Color3.fromRGB(140, 145, 165)
    sub.Font = Enum.Font.GothamMedium
    sub.TextSize = 10
    sub.TextXAlignment = Enum.TextXAlignment.Left
    sub.Parent = holder

    task.spawn(function()
        while holder.Parent do
            TweenService:Create(stroke, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Transparency = 0.15
            }):Play()
            task.wait(2)
            TweenService:Create(stroke, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Transparency = 0.55
            }):Play()
            task.wait(2)
        end
    end)
end

-- ── PC keybind ─────────────────────────────────────────────────
do
    local pg = LocalPlayer:WaitForChild("PlayerGui")

    local function toggleUI()
        pcall(function()
            for _, g in ipairs(pg:GetChildren()) do
                local n = g.Name:lower()
                if (n:find("rayfield") or n:find("sirius") or n:find("twr")) and g:IsA("ScreenGui") then
                    g.Enabled = not g.Enabled
                end
            end
        end)
    end

    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.RightShift then
            toggleUI()
        end
    end)
end

local ESP_UI = Instance.new("ScreenGui")
ESP_UI.Name           = "ESP_UI"
ESP_UI.ResetOnSpawn   = false
ESP_UI.IgnoreGuiInset = true
ESP_UI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ESP_UI.Parent         = LocalPlayer:WaitForChild("PlayerGui")

local ZombieList     = {}
local ItemList       = {}
local espObjects     = {}
local chamsObjects   = {}
local originalData   = {}
local hitboxOutlines = {}
local networkOwners  = {}
local acActive       = false
local flyBV          = nil
local flyBG          = nil

local realTimePulse = 0
task.spawn(function()
    while true do
        realTimePulse = (math.sin(tick() * 3) + 1) / 2
        RunService.Heartbeat:Wait()
    end
end)

local function isPlayer(model)
    if model == LocalPlayer.Character then return true end
    return Players:GetPlayerFromCharacter(model) ~= nil
end

-- Bộ lọc chuẩn: Chỉ nhận model có Humanoid, RootPart, còn sống, không phải player và loại bỏ các NPC cửa hàng/dummy
local function updateZombieList()
    local list = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") then
            local hum = obj:FindFirstChildOfClass("Humanoid")
            local hrp = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso")
            if hum and hrp and not isPlayer(obj) and hum.Health > 0 then
                local name = obj.Name:lower()
                -- Loại bỏ các NPC không phải zombie (shop, merchant, dummy, tutorial, v.v.)
                if not name:find("shop") and not name:find("merchant") and not name:find("dummy") and not name:find("tutorial") and not name:find("bank") then
                    list[obj] = true
                end
            end
        end
    end
    ZombieList = list
end

local function getItemsFolder()
    local ignore = workspace:FindFirstChild("Ignore")
    if ignore then
        return ignore:FindFirstChild("Items")
    end
    return nil
end

local function updateItemList()
    local list = {}
    local itemsFolder = getItemsFolder()
    if itemsFolder then
        for _, obj in ipairs(itemsFolder:GetDescendants()) do
            if obj:IsA("Model") then
                local topModel = obj
                while topModel.Parent and topModel.Parent ~= itemsFolder and topModel.Parent ~= workspace do
                    if topModel.Parent:IsA("Model") then
                        topModel = topModel.Parent
                    else
                        break
                    end
                end
                list[topModel] = true
            end
        end
    end
    ItemList = list
end

updateZombieList()
updateItemList()
task.spawn(function()
    while true do
        task.wait(3) -- Quét lại danh sách zombie nhanh hơn để bắt kịp các đợt spawn mới
        updateZombieList()
        updateItemList()
    end
end)

local function applyChams(model, color, rawFillTrans, outlineTrans)
    local fillTrans = math.clamp(1 - rawFillTrans, 0, 1)

    local existing = chamsObjects[model]
    if not (existing and existing.Parent) then
        local highlight = Instance.new("Highlight")
        highlight.Name                = "Chams"
        highlight.Adornee             = model
        highlight.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.FillColor           = color
        highlight.OutlineColor        = color
        highlight.FillTransparency    = fillTrans
        highlight.OutlineTransparency = outlineTrans
        highlight.Parent              = model
        chamsObjects[model]           = highlight
        existing = highlight
    end

    local pulseFill    = math.clamp(fillTrans    + realTimePulse * 0.1,  0, 1)
    local pulseOutline = math.clamp(outlineTrans + (1 - realTimePulse) * 0.05, 0, 1)

    existing.FillColor           = color
    existing.OutlineColor        = color
    existing.FillTransparency    = pulseFill
    existing.OutlineTransparency = pulseOutline
end

local function removeChams(model)
    local existing = chamsObjects[model]
    if existing then
        existing:Destroy()
        chamsObjects[model] = nil
    end
end

local function getClientContainer()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return nil end
    local container = playerGui:FindFirstChild("TWR_ClientESP_Storage")
    if not container then
        container = Instance.new("Folder")
        container.Name = "TWR_ClientESP_Storage"
        container.Parent = playerGui
    end
    return container
end

local function applyClapBombBox(topModel, mainPart)
    local container = getClientContainer()
    if not container then return end
    local itemID = tostring(topModel:GetDebugId())

    local targetColor = Config.Chams_ItemColor
    pcall(function()
        if Rayfield.Flags and Rayfield.Flags.Chams_ItemColor then
            targetColor = Rayfield.Flags.Chams_ItemColor.Color
        end
    end)

    local rawFillTrans = Config.Chams_FillTransparency
    pcall(function()
        if Rayfield.Flags and Rayfield.Flags.Chams_FillTransparency then
            rawFillTrans = Rayfield.Flags.Chams_FillTransparency.Value
        end
    end)

    local fillTrans = math.clamp(1 - rawFillTrans, 0, 1)

    local BOX_X, BOX_Y, BOX_Z = 0.555, 1.945, 0.74
    local targetSize = mainPart.Size + Vector3.new(BOX_X, BOX_Y, BOX_Z)
    local targetOffset = CFrame.new(0, BOX_Y / 4, 0)

    local boxName = "Box_" .. itemID
    local clientBox = container:FindFirstChild(boxName)
    if not clientBox then
        clientBox = Instance.new("BoxHandleAdornment")
        clientBox.Name = boxName
        clientBox.Adornee = mainPart
        clientBox.AlwaysOnTop = true
        clientBox.Size = targetSize
        clientBox.CFrame = targetOffset
        clientBox.ZIndex = 9
        clientBox.Parent = container
    end

    clientBox.Transparency = math.clamp(fillTrans + (realTimePulse * 0.08), 0, 1)
    clientBox.Color3 = targetColor

    local outlineName = "Outline_" .. itemID
    local outlineFolder = container:FindFirstChild(outlineName)
    if not outlineFolder then
        outlineFolder = Instance.new("Folder")
        outlineFolder.Name = outlineName
        outlineFolder.Parent = container

        local THICKNESS = 0.06
        local sx, sy, sz = targetSize.X / 2, targetSize.Y / 2, targetSize.Z / 2
        local corners = {
            Vector3.new(-sx, -sy, -sz), Vector3.new(sx, -sy, -sz), 
            Vector3.new(sx, -sy, sz), Vector3.new(-sx, -sy, sz),
            Vector3.new(-sx, sy, -sz), Vector3.new(sx, sy, -sz), 
            Vector3.new(sx, sy, sz), Vector3.new(-sx, sy, sz)
        }
        local edges = {
            {1,2,1}, {2,3,3}, {3,4,1}, {4,1,3},
            {5,6,1}, {6,7,3}, {7,8,1}, {8,5,3},
            {1,5,2}, {2,6,2}, {3,7,2}, {4,8,2}
        }

        for i, edge in ipairs(edges) do
            local p1, p2 = corners[edge[1]], corners[edge[2]]
            local axis = edge[3]
            local length = (p2 - p1).Magnitude
            local midPoint = (p1 + p2) / 2
            
            local line = Instance.new("BoxHandleAdornment")
            line.Name = "L" .. i
            local sizeX, sizeY, sizeZ = THICKNESS, THICKNESS, THICKNESS
            if axis == 1 then sizeX = length + THICKNESS
            elseif axis == 2 then sizeY = length + THICKNESS
            elseif axis == 3 then sizeZ = length + THICKNESS end
            
            line.Size = Vector3.new(sizeX, sizeY, sizeZ)
            line.CFrame = targetOffset * CFrame.new(midPoint)
            line.AlwaysOnTop = true
            line.ZIndex = 10
            line.Adornee = mainPart
            line.Parent = outlineFolder
        end
    end

    for _, line in ipairs(outlineFolder:GetChildren()) do
        if line:IsA("BoxHandleAdornment") then
            line.Color3 = targetColor
            line.Transparency = realTimePulse * 0.3
        end
    end
end

local function removeClapBombBox(topModel)
    local container = getClientContainer()
    if not container then return end
    local itemID = tostring(topModel:GetDebugId())
    pcall(function()
        local box = container:FindFirstChild("Box_" .. itemID)
        if box then box:Destroy() end
        local outline = container:FindFirstChild("Outline_" .. itemID)
        if outline then outline:Destroy() end
    end)
end

local function createESP(model, targetType)
    if espObjects[model] then return end

    local accentA, accentB
    if targetType == "Player" then
        accentA, accentB = Color3.fromRGB(80, 160, 255), Color3.fromRGB(150, 205, 255)
    elseif targetType == "Zombie" then
        accentA, accentB = Color3.fromRGB(255, 70, 70), Color3.fromRGB(255, 150, 130)
    else 
        accentA, accentB = Color3.fromRGB(0, 255, 255), Color3.fromRGB(150, 255, 255)
    end

    local objs = {}

    local plate = Instance.new("Frame")
    plate.BackgroundColor3       = Color3.fromRGB(8, 8, 12)
    plate.BackgroundTransparency = Config.BillboardTransparency
    plate.BorderSizePixel        = 0
    plate.Visible                = false
    plate.ZIndex                 = 10
    plate.Parent                 = ESP_UI
    
    local plateCorner = Instance.new("UICorner")
    plateCorner.CornerRadius = UDim.new(0, 4)
    plateCorner.Parent = plate

    local plateStroke = Instance.new("UIStroke")
    plateStroke.Color        = accentA
    plateStroke.Thickness    = 1
    plateStroke.Transparency = 0.5
    plateStroke.Parent       = plate
    
    local plateGrad = Instance.new("UIGradient")
    plateGrad.Color    = ColorSequence.new(accentA, accentB)
    plateGrad.Parent   = plateStroke

    local platePad = Instance.new("UIPadding")
    platePad.PaddingLeft  = UDim.new(0, 5)
    platePad.PaddingRight = UDim.new(0, 5)
    platePad.Parent       = plate

    local nameLabel = Instance.new("TextLabel")
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text                   = model.Name
    nameLabel.TextColor3             = Color3.fromRGB(240, 245, 255)
    nameLabel.TextStrokeTransparency = 0.75
    nameLabel.TextStrokeColor3       = Color3.fromRGB(0, 0, 0)
    nameLabel.TextSize               = 11
    nameLabel.Font                   = Enum.Font.GothamBold
    nameLabel.Size                   = UDim2.new(1, 0, 1, 0)
    nameLabel.ZIndex                 = 11
    nameLabel.Parent                 = plate
    
    local nameGrad = Instance.new("UIGradient")
    nameGrad.Color    = ColorSequence.new(Color3.fromRGB(255, 255, 255), accentB)
    nameGrad.Rotation = 90
    nameGrad.Parent   = nameLabel

    objs.Plate  = plate
    objs.Name   = nameLabel
    objs.Stroke = plateStroke

    espObjects[model] = objs

    model.AncestryChanged:Connect(function(_, parent)
        if not parent then
            for _, o in pairs(objs) do
                if o then o:Destroy() end
            end
            espObjects[model] = nil
            removeClapBombBox(model)
        end
    end)
end

local function removeESP(model)
    local objs = espObjects[model]
    if objs then
        for _, o in pairs(objs) do
            if o then o:Destroy() end
        end
        espObjects[model] = nil
    end
    removeClapBombBox(model)
end

local function updateESP(model, objs, targetPart, topOffset)
    if not objs or not targetPart or not targetPart.Parent then
        if objs.Plate then objs.Plate.Visible = false end
        return
    end

    local showNames = Config.ShowNames
    pcall(function()
        if Rayfield.Flags and Rayfield.Flags.ShowNames ~= nil then
            showNames = Rayfield.Flags.ShowNames.Value
        end
    end)

    local rawBgTrans = Config.BillboardTransparency
    pcall(function()
        if Rayfield.Flags and Rayfield.Flags.BillboardTransparency ~= nil then
            rawBgTrans = Rayfield.Flags.BillboardTransparency.Value
        end
    end)

    local bgTrans = math.clamp(1 - rawBgTrans, 0, 1)

    if not showNames then
        if objs.Plate then objs.Plate.Visible = false end
        return
    end

    if objs.Plate and objs.Stroke then
        objs.Plate.BackgroundTransparency = bgTrans
        objs.Stroke.Transparency = math.clamp(bgTrans + 0.25, 0, 1)
    end

    local pos, onScreen = Camera:WorldToViewportPoint(targetPart.Position + (topOffset or Vector3.new(0, 0, 0)))

    if not onScreen or pos.Z <= 0 then
        if objs.Plate then objs.Plate.Visible = false end
        return
    end

    local viewport = Camera.ViewportSize
    if pos.X < -100 or pos.X > viewport.X + 100 or pos.Y < -100 or pos.Y > viewport.Y + 100 then
        if objs.Plate then objs.Plate.Visible = false end
        return
    end

    if objs.Plate and objs.Name then
        objs.Name.Text = model.Name

        local textWidth   = objs.Name.TextBounds.X
        local plateWidth  = math.max(textWidth + 14, 56)
        local plateHeight = 18

        objs.Plate.Visible  = true
        objs.Plate.Size     = UDim2.fromOffset(plateWidth, plateHeight)
        objs.Plate.Position = UDim2.fromOffset(pos.X - plateWidth / 2, pos.Y - plateHeight / 2)
    end
end

-- ── Hitbox với Real-time Pulse ───────────────────────────────
local function applyHitbox(model, size, transparency)
    if not ZombieList[model] then return end
    if isPlayer(model) then return end

    local humanoid = model:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    local head = model:FindFirstChild("Head")
    if not head then return end

    if not originalData[model] then
        originalData[model] = {
            Size         = head.Size,
            Color        = head.Color,
            Transparency = head.Transparency,
            CanCollide   = head.CanCollide,
            Massless     = head.Massless,
            Material     = head.Material,
        }
    end

    local color = Config.Hitbox_Color
    local alpha = math.clamp(transparency + (realTimePulse * 0.15), 0, 1)

    head.Size         = Vector3.new(size, size, size)
    head.Transparency = alpha
    head.Color        = color
    head.Material     = Enum.Material.Neon
    head.CanCollide   = false
    head.Massless     = true

    pcall(function()
        if not networkOwners[model] then
            head:SetNetworkOwner(LocalPlayer)
            networkOwners[model] = true
        end
    end)

    local outlineAlpha = math.clamp(alpha + 0.15, 0, 1)

    local box = hitboxOutlines[model]
    if not (box and box.Parent) then
        box = Instance.new("SelectionBox")
        box.Name                = "HitboxOutline"
        box.Adornee             = head
        box.LineThickness       = 0.03
        box.Color3              = color
        box.Transparency        = outlineAlpha
        box.SurfaceColor3       = color
        box.SurfaceTransparency = 1
        box.Parent              = head
        hitboxOutlines[model]   = box
    else
        box.Adornee        = head
        box.Color3         = color
        box.SurfaceColor3  = color
        box.Transparency   = outlineAlpha
    end
end

local function restoreHitbox(model)
    if originalData[model] then
        local head = model:FindFirstChild("Head")
        if head then
            head.Size         = originalData[model].Size
            head.Color        = originalData[model].Color
            head.Transparency = originalData[model].Transparency
            head.CanCollide   = originalData[model].CanCollide
            head.Massless     = originalData[model].Massless
            head.Material     = originalData[model].Material
        end
        originalData[model] = nil
    end
    if hitboxOutlines[model] then
        pcall(function() hitboxOutlines[model]:Destroy() end)
        hitboxOutlines[model] = nil
    end
    networkOwners[model] = nil
end

local function restoreAllHitboxes()
    Config.Hitbox_Enabled = false
    for model in pairs(originalData) do
        restoreHitbox(model)
    end
    hitboxOutlines = {}
    networkOwners  = {}
end

local function setupAmmoHook()
    pcall(function()
        local module = require(LocalPlayer.PlayerScripts.Client.Interact)
        if not module then return end

        local originalUpdate = module.Update
        if type(originalUpdate) ~= "function" then return end

        module.Update = function(self, ...)
            local args = {...}
            if args[1] and args[1].Equipped then
                local weapon      = args[3][args[1].Equipped]
                local weaponStats = args[1].WeaponModule.Stats
                if weaponStats and weapon then
                    if weaponStats.Mag  and Config.InfAmmo then weapon.Mag  = weaponStats.Mag  end
                    if weaponStats.Pool and Config.InfAmmo then weapon.Pool = weaponStats.Pool end
                end
            end
            return originalUpdate(self, unpack(args))
        end
    end)
end

local function startFly()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if flyBV then flyBV:Destroy() end
    if flyBG then flyBG:Destroy() end

    pcall(function() hrp:SetNetworkOwner(LocalPlayer) end)

    flyBV = Instance.new("BodyVelocity")
    flyBV.Name     = "FlyBV"
    flyBV.Velocity = Vector3.new(0, 0, 0)
    flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    flyBV.P        = 1250
    flyBV.Parent   = hrp

    flyBG = Instance.new("BodyGyro")
    flyBG.Name      = "FlyBG"
    flyBG.P         = 9e4
    flyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    flyBG.CFrame    = hrp.CFrame
    flyBG.Parent    = hrp
end

local function stopFly()
    if flyBV then flyBV:Destroy(); flyBV = nil end
    if flyBG then flyBG:Destroy(); flyBG = nil end
end

local function updateFly()
    if not Config.Fly then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    hum.PlatformStand = true

    if not flyBV or not flyBV.Parent then
        startFly()
        return
    end

    local cam = workspace.CurrentCamera
    local lookVec  = cam.CFrame.LookVector
    local rightVec = cam.CFrame.RightVector

    local flatLookRaw = Vector3.new(lookVec.X, 0, lookVec.Z)
    local flatLook = flatLookRaw.Magnitude < 0.01 and Vector3.new(0, 0, -1) or flatLookRaw.Unit

    local moveDir = hum.MoveDirection
    local forwardAmt = moveDir:Dot(flatLook)
    local rightAmt   = moveDir:Dot(rightVec)

    local dir = lookVec * forwardAmt + rightVec * rightAmt

    if dir.Magnitude > 0.01 then
        flyBV.Velocity = dir.Unit * Config.FlySpeed
    else
        flyBV.Velocity = Vector3.new(0, 0, 0)
    end

    flyBG.CFrame = CFrame.new(hrp.Position, hrp.Position + flatLook)
end

local function updateSpeed()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    if Config.Fly then return end

    if Config.Speed then
        hum.WalkSpeed = Config.SpeedValue
    else
        hum.WalkSpeed = 16
    end
end

local function applyFullBright(state)
    if state then
        FBBackup.OutdoorAmbient = Lighting.OutdoorAmbient
        FBBackup.Ambient        = Lighting.Ambient
        FBBackup.Brightness     = Lighting.Brightness
        FBBackup.ClockTime      = Lighting.ClockTime
        FBBackup.FogEnd         = Lighting.FogEnd
        FBBackup.FogStart       = Lighting.FogStart

        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.Ambient        = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness     = 3
        Lighting.ClockTime      = 14
        Lighting.FogEnd         = 1e6
        Lighting.FogStart       = 0
    else
        if FBBackup.OutdoorAmbient then
            Lighting.OutdoorAmbient = FBBackup.OutdoorAmbient
            Lighting.Ambient        = FBBackup.Ambient
            Lighting.Brightness     = FBBackup.Brightness
            Lighting.ClockTime      = FBBackup.ClockTime
            Lighting.FogEnd         = FBBackup.FogEnd
            Lighting.FogStart       = FBBackup.FogStart
        end
    end
end

UserInputService.JumpRequest:Connect(function()
    if Config.InfiniteJump then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(60)
        if Config.AntiAFK then
            pcall(function()
                local vu = game:GetService("VirtualUser")
                vu:CaptureController()
                vu:ClickButton1(Vector2.new(0, 0))
            end)
        end
    end
end)

local unloaded = false
local function unloadScript()
    unloaded = true

    pcall(function() restoreAllHitboxes() end)
    pcall(function() stopFly() end)
    pcall(function() applyFullBright(false) end)
    pcall(function()
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = 16 end
        end
    end)

    local container = getClientContainer()
    if container then container:ClearAllChildren() end

    for model in pairs(espObjects) do
        pcall(function() removeESP(model) end)
    end
    for model in pairs(chamsObjects) do
        pcall(function() removeChams(model) end)
    end

    pcall(function() ESP_UI:Destroy() end)
end

-- ── Modern AC Bypass ──────────────────────────────────────────
local function enableACBypass()
    if acActive then return end
    acActive = true

    pcall(function() LocalPlayer.Kick = function() end end)

    if hookmetamethod then
        local oldNC
        oldNC = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if method == "FireServer" or method == "InvokeServer" then
                local args = {...}
                if args[1] == "CheatKick" or args[1] == "Kick" or args[1] == "Ban" then
                    return
                end
                for _, arg in ipairs(args) do
                    if type(arg) == "string" then
                        local lower = arg:lower()
                        if lower:find("anticheat") or lower:find("detect")
                        or lower:find("ban")       or lower:find("kick")
                        or lower:find("exploit")   or lower:find("cheat")
                        or lower:find("hack")      or lower:find("report") then
                            return
                        end
                    end
                end
            end
            return oldNC(self, ...)
        end))
    end
end

local function disableACBypass()
    acActive = false
end

task.spawn(function()
    task.wait(3)
    setupAmmoHook()
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if Config.Fly then startFly() end
    if Config.Speed then updateSpeed() end
end)

local frameCounter = 0
RunService.RenderStepped:Connect(function()
    if unloaded then return end

    frameCounter = frameCounter + 1

    if Config.Fly then
        updateFly()
    elseif flyBV then
        stopFly()
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.PlatformStand = false end
        end
    end

    local anyHitbox = Config.Hitbox_Enabled

    -- Player ESP
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local model = player.Character

            if Config.ESP_Players then
                local objs = espObjects[model]
                if not objs then createESP(model, "Player"); objs = espObjects[model] end
                if objs then
                    local head = model:FindFirstChild("Head")
                    local hrp = model:FindFirstChild("HumanoidRootPart")
                    local hum = model:FindFirstChildOfClass("Humanoid")
                    if head and hrp and hum and hum.Health > 0 then
                        updateESP(model, objs, head, Vector3.new(0, 2.8, 0))
                    else
                        if objs.Plate then objs.Plate.Visible = false end
                    end
                end
                applyChams(model, Config.Chams_PlayerColor, Config.Chams_FillTransparency, Config.Chams_OutlineTransparency)
            else
                if espObjects[model] then removeESP(model) end
                if chamsObjects[model] then removeChams(model) end
            end
        end
    end

    -- Zombie ESP & Hitbox (Chỉ xử lý các zombie hợp lệ đã được lọc)
    for model in pairs(ZombieList) do
        if Config.ESP_Zombies then
            local objs = espObjects[model]
            if not objs then createESP(model, "Zombie"); objs = espObjects[model] end
            if objs then
                local head = model:FindFirstChild("Head")
                local hrp = model:FindFirstChild("HumanoidRootPart")
                local hum = model:FindFirstChildOfClass("Humanoid")
                if head and hrp and hum and hum.Health > 0 then
                    updateESP(model, objs, head, Vector3.new(0, 2.8, 0))
                else
                    if objs.Plate then objs.Plate.Visible = false end
                end
            end
            applyChams(model, Config.Chams_ZombieColor, Config.Chams_FillTransparency, Config.Chams_OutlineTransparency)
        else
            if espObjects[model] and not ItemList[model] then removeESP(model) end
            if chamsObjects[model] and not ItemList[model] then removeChams(model) end
        end

        if anyHitbox then
            if Config.Hitbox_Enabled then
                applyHitbox(model, Config.Hitbox_Size, Config.Hitbox_Transparency)
            elseif originalData[model] then
                restoreHitbox(model)
            end
        end
    end

    -- Item ESP & Exclusive Clap Bomb Box
    for model in pairs(ItemList) do
        if Config.ESP_Items then
            local objs = espObjects[model]
            if not objs then createESP(model, "Item"); objs = espObjects[model] end
            if objs then
                local mainPart = model:FindFirstChild("Handle", true) or model:FindFirstChildWhichIsA("BasePart", true)
                if mainPart then
                    updateESP(model, objs, mainPart, Vector3.new(0, 2.5, 0))
                    
                    local isClapBomb = (model.Name == "Clap Bomb" or model:FindFirstChild("ClapBomb", true))
                    if isClapBomb then
                        applyClapBombBox(model, mainPart)
                        removeChams(model)
                    else
                        removeChams(model)
                        applyChams(model, Config.Chams_ItemColor, Config.Chams_FillTransparency, Config.Chams_OutlineTransparency)
                    end
                else
                    if objs.Plate then objs.Plate.Visible = false end
                end
            end
        else
            if espObjects[model] then removeESP(model) end
            removeClapBombBox(model)
            if chamsObjects[model] then removeChams(model) end
        end
    end

    if frameCounter % 30 == 0 then
        for model in pairs(espObjects) do
            if not model.Parent then
                removeESP(model)
            end
        end
        for model in pairs(chamsObjects) do
            if not model.Parent then
                removeChams(model)
            end
        end
        for model in pairs(hitboxOutlines) do
            if not model.Parent or not model:FindFirstChild("Head") then
                pcall(function() hitboxOutlines[model]:Destroy() end)
                hitboxOutlines[model] = nil
            end
        end
    end
end)

-- ══════════════════════════════════════════════════════════════
--  TABS (Rayfield Gen2 Interface)
-- ══════════════════════════════════════════════════════════════

local ESPTab = Window:CreateTab({ Name = "ESP" })
ESPTab:CreateSection("Targets")
ESPTab:CreateToggle({Name = "ESP Players", CurrentValue = false, Flag = "ESP_Players", Callback = function(v) Config.ESP_Players = v end})
ESPTab:CreateToggle({Name = "ESP Zombies", CurrentValue = false, Flag = "ESP_Zombies", Callback = function(v) Config.ESP_Zombies = v end})
ESPTab:CreateToggle({Name = "ESP Items",   CurrentValue = false, Flag = "ESP_Items",   Callback = function(v) Config.ESP_Items = v end})
ESPTab:CreateToggle({
    Name = "Show Names",
    CurrentValue = false,
    Flag = "ShowNames",
    Callback = function(v)
        Config.ShowNames = v
    end
})

ESPTab:CreateSection("Style & Colors")
ESPTab:CreateColorPicker({Name = "Player Chams Color", Color = Color3.fromRGB(0, 120, 255), Flag = "Chams_PlayerColor", Callback = function(v) Config.Chams_PlayerColor = v end})
ESPTab:CreateColorPicker({Name = "Zombie Chams Color", Color = Color3.fromRGB(255, 40, 40), Flag = "Chams_ZombieColor", Callback = function(v) Config.Chams_ZombieColor = v end})
ESPTab:CreateColorPicker({Name = "Item Chams Color",   Color = Color3.fromRGB(0, 255, 255), Flag = "Chams_ItemColor",   Callback = function(v) Config.Chams_ItemColor = v end})
ESPTab:CreateSlider({Name = "Fill Transparency",    Range = {0, 1}, Increment = 0.05, CurrentValue = 0.5, Flag = "Chams_FillTransparency",    Callback = function(v) Config.Chams_FillTransparency    = v end})
ESPTab:CreateSlider({Name = "Outline Transparency", Range = {0, 1}, Increment = 0.05, CurrentValue = 0.1, Flag = "Chams_OutlineTransparency", Callback = function(v) Config.Chams_OutlineTransparency = v end})
ESPTab:CreateSlider({
    Name = "Billboard Transparency",
    Range = {0, 1},
    Increment = 0.05,
    CurrentValue = 0.1,
    Flag = "BillboardTransparency",
    Callback = function(v)
        Config.BillboardTransparency = v
    end
})

-- Nút Clear ESP Cache (Dùng cú pháp chuẩn Gen2: name & callback)
ESPTab:CreateButton({
    name = "Clear ESP Cache",
    callback = function()
        pcall(function()
            local container = getClientContainer()
            if container then container:ClearAllChildren() end
            for model in pairs(espObjects) do
                removeESP(model)
            end
            for model in pairs(chamsObjects) do
                removeChams(model)
            end
            Rayfield:Notify({
                Title = "TWR Hub",
                Content = "ESP cache cleared successfully!",
                Duration = 3,
            })
        end)
    end
})

local HitboxTab = Window:CreateTab({ Name = "Hitbox" })
HitboxTab:CreateSection("Zombie Hitbox")
HitboxTab:CreateToggle({Name = "Enable Hitbox", CurrentValue = false, Flag = "Hitbox_Enabled", Callback = function(v) Config.Hitbox_Enabled = v; if not v then restoreAllHitboxes() end end})
HitboxTab:CreateSlider({Name = "Size",         Range = {3, 60}, Increment = 1,    Suffix = " studs", CurrentValue = 15,  Flag = "Hitbox_Size",         Callback = function(v) Config.Hitbox_Size         = v end})
HitboxTab:CreateSlider({Name = "Transparency", Range = {0, 1},  Increment = 0.05, CurrentValue = 0.7, Flag = "Hitbox_Transparency", Callback = function(v) Config.Hitbox_Transparency = v end})
HitboxTab:CreateSection("Style")
HitboxTab:CreateColorPicker({Name = "Color", Color = Color3.fromRGB(255, 0, 80), Flag = "Hitbox_Color", Callback = function(v) Config.Hitbox_Color = v end})

-- Nút Restore (Dùng cú pháp chuẩn Gen2: name & callback)
HitboxTab:CreateButton({
    name = "Restore",
    callback = function()
        restoreAllHitboxes()
        pcall(function()
            Rayfield:Notify({
                Title = "TWR Hub",
                Content = "All hitboxes reset and restored!",
                Duration = 3,
            })
        end)
    end
})

local WeaponTab = Window:CreateTab({ Name = "Weapon" })
WeaponTab:CreateToggle({Name = "Infinite Ammo", CurrentValue = false, Flag = "InfAmmo", Callback = function(v) Config.InfAmmo = v end})

local MovementTab = Window:CreateTab({ Name = "Movement" })
MovementTab:CreateSection("Fly")
MovementTab:CreateToggle({Name = "Fly", CurrentValue = false, Flag = "Fly", Callback = function(v) Config.Fly = v end})
MovementTab:CreateSlider({Name = "Fly Speed", Range = {10, 200}, Increment = 5, CurrentValue = 50, Flag = "FlySpeed", Callback = function(v) Config.FlySpeed = v end})
MovementTab:CreateSection("Speed")
MovementTab:CreateToggle({Name = "Speed", CurrentValue = false, Flag = "Speed", Callback = function(v)
    Config.Speed = v
    updateSpeed()
end})
MovementTab:CreateSlider({Name = "Speed Value", Range = {16, 100}, Increment = 1, CurrentValue = 40, Flag = "SpeedValue", Callback = function(v)
    Config.SpeedValue = v
    if Config.Speed then updateSpeed() end
end})
MovementTab:CreateSection("Jump")
MovementTab:CreateToggle({Name = "Infinite Jump", CurrentValue = false, Flag = "InfiniteJump", Callback = function(v) Config.InfiniteJump = v end})

local MiscTab = Window:CreateTab({ Name = "Misc" })
MiscTab:CreateSection("Utility")
MiscTab:CreateToggle({Name = "Full Bright", CurrentValue = false, Flag = "FullBright", Callback = function(v)
    Config.FullBright = v
    applyFullBright(v)
end})
MiscTab:CreateToggle({Name = "Anti-AFK", CurrentValue = true, Flag = "AntiAFK", Callback = function(v) Config.AntiAFK = v end})

-- Nút Unload Script (Dùng cú pháp chuẩn Gen2: name & callback)
MiscTab:CreateButton({
    name = "Unload Script",
    callback = function()
        unloadScript()
        pcall(function()
            Rayfield:Notify({
                Title = "TWR Hub",
                Content = "Script unloaded successfully!",
                Duration = 3,
            })
        end)
    end
})

MiscTab:CreateSection("Keybinds")
MiscTab:CreateKeybind({
    Name = "Toggle UI",
    CurrentKeybind = "RightShift",
    HoldToInteract = false,
    Flag = "UI_Toggle",
    Callback = function()
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        if pg then
            for _, g in ipairs(pg:GetChildren()) do
                local n = g.Name:lower()
                if (n:find("rayfield") or n:find("sirius") or n:find("twr")) and g:IsA("ScreenGui") then
                    g.Enabled = not g.Enabled
                end
            end
        end
    end
})

local ACTab = Window:CreateTab({ Name = "Anti Cheat Bypass" })
ACTab:CreateToggle({Name = "Enable", CurrentValue = false, Flag = "AC_Bypass", Callback = function(v) Config.AC_Bypass = v; if v then enableACBypass() else disableACBypass() end end})

-- Safe notification wrapper
pcall(function()
    if Rayfield and type(Rayfield.Notify) == "function" then
        Rayfield:Notify({
            Title = "TWR Hub v5.9",
            Content = "Loaded successfully with filtered Zombie ESP!",
            Duration = 6.5,
        })
    end
end)
