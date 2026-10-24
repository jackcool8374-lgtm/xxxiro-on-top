--!nocheck
-- OXIRO — UNSTOPPABLE TRACKING CHASE
-- Delta / Mobile Compatible
local MAX_ATTEMPTS = 3
local CORRECT_KEY = "hello"

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TextChatService = game:GetService("TextChatService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local attempts = 0

local AIMBOT_ENABLED = false
local AIMBOT_STRENGTH = 0.95
local AIMBOT_SMOOTH = 0.08

local immunePlayers = {}

--========================================================--
-- IMMUNE HOOK FUNCTIONS
--========================================================--
local function getHRP(plr)
    local p = plr or Player
    return p.Character and p.Character:FindFirstChild("HumanoidRootPart")
end

local function isProtected(targetPlayer)
    if not targetPlayer then return false end
    if type(targetPlayer) == "string" then
        for p, safe in pairs(immunePlayers) do
            if safe and (p.Name == targetPlayer or p.DisplayName == targetPlayer) then return true end
        end
    elseif typeof(targetPlayer) == "Instance" then
        if targetPlayer:IsA("Player") then return immunePlayers[targetPlayer] == true
        elseif targetPlayer:IsA("Model") then
            local p = Players:GetPlayerFromCharacter(targetPlayer)
            return p and immunePlayers[p] == true
        end
    end
    return false
end

pcall(function()
    local gmt = getrawmetatable(game)
    local oldNamecall = gmt.__namecall
    setreadonly(gmt, false)
    gmt.__namecall = newcclosure(function(self, ...)
        local args = {...}
        local method = getnamecallmethod()
        if method == "FireServer" or method == "InvokeServer" then
            for p, isSafe in pairs(immunePlayers) do
                if isSafe and p and p.Character then
                    for _, arg in pairs(args) do
                        if arg == p or arg == p.Character or (type(arg) == "table" and rawget(arg, "Instance") == p) then
                            return nil
                        end
                    end
                end
            end
        end
        return oldNamecall(self, ...)
    end)
    setreadonly(gmt, true)
end)

local function isPlayerSafe(plr) return isProtected(plr) end

-- KEY UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "OXIROGATE"
ScreenGui.Parent = Player:WaitForChild("PlayerGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 16)
MainFrame.Position = UDim2.new(0.5, -185, 0.5, -125)
MainFrame.Size = UDim2.new(0, 370, 0, 250)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 16)

local OuterStroke = Instance.new("UIStroke")
OuterStroke.Name = "OuterGlow"
OuterStroke.Parent = MainFrame
OuterStroke.Color = Color3.fromRGB(60, 220, 255)
OuterStroke.Thickness = 3
local glowPulse = TweenService:Create(OuterStroke, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
	Color = Color3.fromRGB(140, 240, 255),
	Thickness = 5
})
glowPulse:Play()

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 0, 0, 18)
Title.Size = UDim2.new(1, 0, 0, 55)
Title.Font = Enum.Font.GothamBold
Title.Text = "OXIRO GATE"
Title.TextColor3 = Color3.fromRGB(80, 240, 255)
Title.TextSize = 36

local SubTitle = Instance.new("TextLabel")
SubTitle.Parent = MainFrame
SubTitle.BackgroundTransparency = 1
SubTitle.Position = UDim2.new(0, 0, 0, 70)
SubTitle.Size = UDim2.new(1, 0, 0, 22)
SubTitle.Font = Enum.Font.GothamMedium
SubTitle.Text = "SECURITY VERIFICATION"
SubTitle.TextColor3 = Color3.fromRGB(160, 200, 220)
SubTitle.TextSize = 13

local KeyBox = Instance.new("TextBox")
KeyBox.Parent = MainFrame
KeyBox.BackgroundColor3 = Color3.fromRGB(12, 18, 30)
KeyBox.Position = UDim2.new(0.07, 0, 0, 100)
KeyBox.Size = UDim2.new(0.86, 0, 0, 50)
KeyBox.Font = Enum.Font.Gotham
KeyBox.PlaceholderText = "Enter access key..."
KeyBox.Text = ""
KeyBox.TextColor3 = Color3.fromRGB(220, 250, 255)
KeyBox.TextSize = 16
Instance.new("UICorner", KeyBox).CornerRadius = UDim.new(0, 10)

local SubmitBtn = Instance.new("TextButton")
SubmitBtn.Parent = MainFrame
SubmitBtn.BackgroundColor3 = Color3.fromRGB(20, 130, 200)
SubmitBtn.Position = UDim2.new(0.18, 0, 0, 165)
SubmitBtn.Size = UDim2.new(0.64, 0, 0, 45)
SubmitBtn.Font = Enum.Font.GothamBold
SubmitBtn.Text = "VERIFY"
SubmitBtn.TextColor3 = Color3.fromRGB(240, 255, 255)
SubmitBtn.TextSize = 17
Instance.new("UICorner", SubmitBtn).CornerRadius = UDim.new(0, 10)

local Status = Instance.new("TextLabel")
Status.Parent = MainFrame
Status.BackgroundTransparency = 1
Status.Position = UDim2.new(0, 0, 0, 218)
Status.Size = UDim2.new(1, 0, 0, 20)
Status.Font = Enum.Font.GothamMedium
Status.Text = ""
Status.TextColor3 = Color3.fromRGB(255, 90, 90)
Status.TextSize = 12

local function runMainScript()
	ScreenGui:Destroy()

	local OWNER_USERNAME = "Markarenoob"
	local isOwner = Player.Name == OWNER_USERNAME

	local blockedUsernames = {}
	for _, name in ipairs(blockedUsernames) do
		if Player.Name:lower() == name:lower() then
			Player:Kick("Blocked from using this script")
			return
		end
	end

	local permanentControllers = {}
	local tempControllers = {}

	local function isAuthorized(plr)
		if not plr then return false end
		if plr.Name == OWNER_USERNAME then return true end
		if permanentControllers[plr.UserId] then return true end
		if tempControllers[plr.UserId] then return true end
		return false
	end

	local HVH_MODE = false
	local HVH_TARGET_USERID = nil
	local HVH_VOID = false
	local HVH_NOCLIP = false

	local function findPlayerByFuzzy(str)
		if not str or str == "" then return nil end
		str = str:lower()
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr.DisplayName:lower():find(str) or plr.Name:lower():find(str) then return plr end
		end
		return nil
	end

	local mode = "idle"
	local attackTarget = nil
	local savedTargetUserId = nil
	local HITBOX_SIZE = 100
	local BLOCK_ENABLED = true
	local UNLIMITED_M1_ENABLED = true
	local M2_SPAM_ENABLED = true
	local NOCLIP_ENABLED = false
	local playerButtons = {}
	local currentTab = "target"

	-- === UNSTOPPABLE TRACKING CHASE ===
	local CHASE_DISTANCE = 3.5
	local PREDICTION = 0.2

	local chaseTarget = nil
	local chaseConnection = nil
	local isChasing = false

	local function stopChase()
	    isChasing = false
	    chaseTarget = nil
	    if chaseConnection then
	        chaseConnection:Disconnect()
	        chaseConnection = nil
	    end
	    if Player.Character then
	        for _, v in ipairs(Player.Character:GetDescendants()) do
	            if v:IsA("BasePart") then v.CanCollide = true end
	        end
	    end
	end

	local function startChase(target)
	    if chaseConnection then chaseConnection:Disconnect() end
	    chaseTarget = target
	    isChasing = true
	    
	    chaseConnection = RunService.RenderStepped:Connect(function()
	        if not isChasing or not chaseTarget or not chaseTarget.Character then
	            stopChase()
	            return
	        end
	        
	        local myHRP = getHRP(Player)
	        local tHRP = getHRP(chaseTarget)
	        local tHum = chaseTarget.Character:FindFirstChildOfClass("Humanoid")
	        
	        if not myHRP or not tHRP or not tHum or tHum.Health <= 0 then
	            stopChase()
	            return
	        end
	        
	        for _, v in ipairs(Player.Character:GetDescendants()) do
	            if v:IsA("BasePart") then v.CanCollide = false end
	        end
	        
	        local targetVelocity = tHRP.Velocity
	        local predictedPos = tHRP.Position + (targetVelocity * PREDICTION)
	        
	        local targetLook = tHRP.CFrame.LookVector
	        local desiredPos = predictedPos - (targetLook * CHASE_DISTANCE) + Vector3.new(0, 1, 0)
	        
	        local distance = (desiredPos - myHRP.Position).Magnitude
	        
	        if distance > 1 then
	            myHRP.CFrame = CFrame.new(desiredPos, tHRP.Position)
	            myHRP.Velocity = Vector3.zero
	            myHRP.RotVelocity = Vector3.zero
	        else
	            myHRP.Velocity = targetVelocity
	        end
	    end)
	end
	-- ==========================================

	-- === YOUR EXACT VOID SYSTEM ===
	local isVoiding = false
	local VOID_MODE_ENABLED = false
	local FALL_SPEED = -3500
	local FALL_CHECK_Y = -4900
	local ATTACK_RESET_INTERVAL = 4

	local function goVoid(target)
	    if isVoiding or not VOID_MODE_ENABLED or isPlayerSafe(target) then return end
	    if not target or not target.Character then return end
	    
	    local myChar = Player.Character
	    if not myChar then return end
	    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
	    if not myHRP then return end
	    
	    local tHRP = target.Character:FindFirstChild("HumanoidRootPart")
	    if not tHRP then return end
	    
	    isVoiding = true
	    myHRP.CFrame = CFrame.new(tHRP.Position.X, myHRP.Position.Y, tHRP.Position.Z)
	    
	    task.spawn(function()
	        for i = 1, 8 do
	            task.wait(0.015)
	            if not myHRP or not isVoiding then break end
	            myHRP.Velocity = Vector3.new(0, FALL_SPEED, 0)
	        end
	    end)
	    
	    task.delay(0.5, function() isVoiding = false end)
	end

	task.spawn(function()
	    while true do
	        task.wait(0.03)
	        if not VOID_MODE_ENABLED or mode ~= "attack" or not attackTarget or isPlayerSafe(attackTarget) then continue end
	        local c = Player.Character
	        if not c then continue end
	        local hrp = c:FindFirstChild("HumanoidRootPart")
	        if hrp and hrp.Position.Y < FALL_CHECK_Y then
	            local hum = c:FindFirstChild("Humanoid")
	            if hum then hum.Health = 0 end
	        end
	    end
	end)

	task.spawn(function()
	    while true do
	        task.wait(ATTACK_RESET_INTERVAL)
	        if VOID_MODE_ENABLED and mode == "attack" and attackTarget and not isPlayerSafe(attackTarget) then
	            goVoid(attackTarget)
	        end
	    end
	end)
	-- === END YOUR VOID SYSTEM ===

	local function setNoclip(enabled)
		NOCLIP_ENABLED = enabled
		if noclipConnection then noclipConnection:Disconnect() end
		if enabled then
			noclipConnection = RunService.Stepped:Connect(function()
				local c = Player.Character if not c then return end
				for _, p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
			end)
		end
	end

	-- M1 Spam
	task.spawn(function()
		while true do
			task.wait()
			if UNLIMITED_M1_ENABLED then
				pcall(function()
					local rem = ReplicatedStorage:FindFirstChild("CombatRemote")
					if rem then rem:FireServer("M1") end
				end)
			end
		end
	end)

	-- M2 Spam
	task.spawn(function()
	    while task.wait() do
	        if M2_SPAM_ENABLED then
	            pcall(function()
	                local Remote = ReplicatedStorage:FindFirstChild("CombatRemote")
	                if Remote then
	                    Remote:FireServer("M2")
	                end
	            end)
	        end
	    end
	end)

	TextChatService.MessageReceived:Connect(function(msg)
		local sender = Players:GetPlayerByUserId(msg.PlayerUserId)
		if not sender then return end
		local message = msg.Message:lower()
		local args = string.split(message, " ")
		local cmd = args[1] or ""
		local arg = table.concat(args, " ", 2)

		if isOwner then
			if cmd == "hvh" and arg == "on" then HVH_MODE = true return
			elseif cmd == "hvh" and arg == "off" then
				HVH_MODE = false; HVH_TARGET_USERID = nil; HVH_VOID = false; HVH_NOCLIP = false
				stopChase()
				return
			elseif cmd == "attack" and arg ~= "" then
				local t = findPlayerByFuzzy(arg)
				if t and not isPlayerSafe(t) then
					HVH_TARGET_USERID = t.UserId; HVH_MODE = true; selectTarget(t)
				end
				return
			elseif cmd == "addperm" and arg ~= "" then local t = findPlayerByFuzzy(arg) if t then permanentControllers[t.UserId]=true end return
			elseif cmd == "addctrl" and arg ~= "" then local t = findPlayerByFuzzy(arg) if t then tempControllers[t.UserId]=true end return
			elseif cmd == "revoke" and arg ~= "" then local t = findPlayerByFuzzy(arg) if t then permanentControllers[t.UserId]=nil; tempControllers[t.UserId]=nil end return
			elseif cmd == "void" and arg == "all" then HVH_VOID = true; VOID_MODE_ENABLED = true return
			elseif cmd == "voidoff" and arg == "all" then HVH_VOID = false; VOID_MODE_ENABLED = false return
			elseif cmd == "noclip" and arg == "all" then HVH_NOCLIP = true; setNoclip(true) return
			elseif cmd == "noclipoff" and arg == "all" then HVH_NOCLIP = false; setNoclip(false) return
			end
		end

		if HVH_MODE and HVH_TARGET_USERID then
			local t = Players:GetPlayerByUserId(HVH_TARGET_USERID)
			if t and t ~= attackTarget and not isPlayerSafe(t) then selectTarget(t) end
			if HVH_VOID then VOID_MODE_ENABLED = true end
			if HVH_NOCLIP then setNoclip(true) end
		end

		if isAuthorized(sender) or isOwner then
			if cmd == "sv" and arg ~= "" then local t = findPlayerByFuzzy(arg) if t then immunePlayers[t]=true end refreshPlayerList() return
			elseif cmd == "stop" then stopChase()
			elseif cmd == "void" then VOID_MODE_ENABLED = true
			elseif cmd == "voidoff" then VOID_MODE_ENABLED = false
			elseif cmd == "noclip" then setNoclip(true)
			elseif cmd == "noclipoff" then setNoclip(false)
			elseif cmd == "attack" and arg ~= "" then local t = findPlayerByFuzzy(arg) if t and not isPlayerSafe(t) then selectTarget(t) end
			end
		end
	end)

	local function restoreTargetAfterRespawn()
		if HVH_MODE and HVH_TARGET_USERID then
			local t = Players:GetPlayerByUserId(HVH_TARGET_USERID)
			if t and not isPlayerSafe(t) then
				attackTarget = t; savedTargetUserId = t.UserId
				if HVH_VOID then VOID_MODE_ENABLED = true end
				if HVH_NOCLIP then setNoclip(true) end
				task.wait(0.05); if not isChasing then startChase(t) end
			end
			return
		end
		if not savedTargetUserId then return end
		local t = Players:GetPlayerByUserId(savedTargetUserId)
		if t and not isPlayerSafe(t) then attackTarget = t; task.wait(0.05); if not isChasing then startChase(t) end end
	end

	Player.CharacterAdded:Connect(function() task.wait(0.05) restoreTargetAfterRespawn() end)

	RunService.Heartbeat:Connect(function()
		for _, plr in ipairs(Players:GetPlayers()) do
			local hrp = getHRP(plr)
			if hrp then
				hrp.Size = (plr ~= Player and not isPlayerSafe(plr)) and Vector3.new(HITBOX_SIZE, HITBOX_SIZE, HITBOX_SIZE) or Vector3.new(2,2,2)
			end
		end
	end)

	function selectTarget(plr)
		if plr == Player or isPlayerSafe(plr) then return end
		mode = "attack"; attackTarget = plr; savedTargetUserId = plr.UserId
		startChase(plr)
	end

	pcall(function() if CoreGui:FindFirstChild("OxiroGui") then CoreGui.OxiroGui:Destroy() end end)

	local ScreenGuiMain = Instance.new("ScreenGui")
	ScreenGuiMain.Name = "OxiroGui"
	ScreenGuiMain.Parent = Player:WaitForChild("PlayerGui")
	ScreenGuiMain.ResetOnSpawn = false
	ScreenGuiMain.DisplayOrder = 99999

	local OpenBtn = Instance.new("TextButton")
	OpenBtn.Size = UDim2.new(0,160,0,55)
	OpenBtn.Position = UDim2.new(0.82,0,0.88,0)
	OpenBtn.BackgroundColor3 = Color3.fromRGB(20,30,45)
	OpenBtn.Text = isOwner and "OXIRO [OWNER]" or "OXIRO"
	OpenBtn.Font = Enum.Font.GothamBold
	OpenBtn.TextColor3 = Color3.fromRGB(80,240,255)
	OpenBtn.TextSize = 22
	OpenBtn.Parent = ScreenGuiMain
	Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(0,12)

	local MainFrame = Instance.new("Frame")
	MainFrame.Size = UDim2.new(0,420,0,720)
	MainFrame.Position = UDim2.new(0.20,0,0.03,0)
	MainFrame.BackgroundColor3 = Color3.fromRGB(8,12,24)
	MainFrame.Active = true; MainFrame.Draggable = true; MainFrame.Visible = false
	MainFrame.Parent = ScreenGuiMain
	Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0,14)

	local CloseBtn = Instance.new("TextButton")
	CloseBtn.Size = UDim2.new(0,50,0,36)
	CloseBtn.Position = UDim2.new(1,-55,0,5)
	CloseBtn.BackgroundColor3 = Color3.fromRGB(50,20,30)
	CloseBtn.Text = "X"
	CloseBtn.Font = Enum.Font.GothamBold
	CloseBtn.TextColor3 = Color3.fromRGB(220,180,180)
	CloseBtn.TextSize = 22
	CloseBtn.Parent = MainFrame
	Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0,10)

	local Title = Instance.new("TextLabel")
	Title.Size = UDim2.new(1,-60,0,40)
	Title.Position = UDim2.new(0,15,0,8)
	Title.BackgroundTransparency = 1
	Title.Text = isOwner and "OXIRO — OWNER PANEL" or "OXIRO"
	Title.Font = Enum.Font.GothamBold
	Title.TextColor3 = Color3.fromRGB(80,240,255)
	Title.TextSize = 20; Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.Parent = MainFrame

	local TabContainer = Instance.new("Frame")
	TabContainer.Size = UDim2.new(1,-30,0,40)
	TabContainer.Position = UDim2.new(0,15,0,55)
	TabContainer.BackgroundTransparency = 1; TabContainer.Parent = MainFrame
	local TabLayout = Instance.new("UIListLayout")
	TabLayout.FillDirection = Enum.FillDirection.Horizontal
	TabLayout.Padding = UDim.new(0,8); TabLayout.Parent = TabContainer

	local TargetTabBtn = Instance.new("TextButton")
	TargetTabBtn.Size = UDim2.new(0,100,1,0)
	TargetTabBtn.BackgroundColor3 = Color3.fromRGB(25,60,90)
	TargetTabBtn.Text = "TARGET"
	TargetTabBtn.Font = Enum.Font.GothamBold
	TargetTabBtn.TextColor3 = Color3.fromRGB(120,240,255)
	TargetTabBtn.TextSize = 13; TargetTabBtn.Parent = TabContainer
	Instance.new("UICorner", TargetTabBtn).CornerRadius = UDim.new(0,8)

	local SettingsTabBtn = Instance.new("TextButton")
	SettingsTabBtn.Size = UDim2.new(0,100,1,0)
	SettingsTabBtn.BackgroundColor3 = Color3.fromRGB(25,35,55)
	SettingsTabBtn.Text = "SETTINGS"
	SettingsTabBtn.Font = Enum.Font.GothamBold
	SettingsTabBtn.TextColor3 = Color3.fromRGB(180,200,220)
	SettingsTabBtn.TextSize = 13; SettingsTabBtn.Parent = TabContainer
	Instance.new("UICorner", SettingsTabBtn).CornerRadius = UDim.new(0,8)

	local ControlTabBtn = nil
	if isOwner then
		ControlTabBtn = Instance.new("TextButton")
		ControlTabBtn.Size = UDim2.new(0,100,1,0)
		ControlTabBtn.BackgroundColor3 = Color3.fromRGB(25,35,55)
		ControlTabBtn.Text = "CONTROL"
		ControlTabBtn.Font = Enum.Font.GothamBold
		ControlTabBtn.TextColor3 = Color3.fromRGB(180,200,220)
		ControlTabBtn.TextSize = 13; ControlTabBtn.Parent = TabContainer
		Instance.new("UICorner", ControlTabBtn).CornerRadius = UDim.new(0,8)
	end

	local ImmuneTabBtn = Instance.new("TextButton")
	ImmuneTabBtn.Size = UDim2.new(0,100,1,0)
	ImmuneTabBtn.BackgroundColor3 = Color3.fromRGB(25,35,55)
	ImmuneTabBtn.Text = "IMMUNE"
	ImmuneTabBtn.Font = Enum.Font.GothamBold
	ImmuneTabBtn.TextColor3 = Color3.fromRGB(180,200,220)
	ImmuneTabBtn.TextSize = 13; ImmuneTabBtn.Parent = TabContainer
	Instance.new("UICorner", ImmuneTabBtn).CornerRadius = UDim.new(0,8)

	local ContentContainer = Instance.new("Frame")
	ContentContainer.Size = UDim2.new(1,-30,1,-125)
	ContentContainer.Position = UDim2.new(0,15,0,105)
	ContentContainer.BackgroundTransparency = 1; ContentContainer.Parent = MainFrame

	local TargetPage = Instance.new("Frame")
	TargetPage.Size = UDim2.new(1,0,1,0); TargetPage.BackgroundTransparency = 1; TargetPage.Visible = true
	TargetPage.Parent = ContentContainer
	local PlayerScroll = Instance.new("ScrollingFrame")
	PlayerScroll.Size = UDim2.new(1,0,1,0); PlayerScroll.BackgroundTransparency = 1
	PlayerScroll.ScrollBarThickness = 8; PlayerScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	PlayerScroll.Parent = TargetPage
	Instance.new("UIListLayout", PlayerScroll).Padding = UDim.new(0,7)

	local SettingsPage = Instance.new("Frame")
	SettingsPage.Size = UDim2.new(1,0,1,0); SettingsPage.BackgroundTransparency = 1; SettingsPage.Visible = false
	SettingsPage.Parent = ContentContainer
	local SettingsScroll = Instance.new("ScrollingFrame")
	SettingsScroll.Size = UDim2.new(1,0,1,0); SettingsScroll.BackgroundTransparency = 1
	SettingsScroll.ScrollBarThickness = 8; SettingsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	SettingsScroll.Parent = SettingsPage
	Instance.new("UIListLayout", SettingsScroll).Padding = UDim.new(0,12)

	local ControlPage, ControlScroll = nil, nil
	if isOwner then
		ControlPage = Instance.new("Frame")
		ControlPage.Size = UDim2.new(1,0,1,0); ControlPage.BackgroundTransparency = 1; ControlPage.Visible = false
		ControlPage.Parent = ContentContainer
		ControlScroll = Instance.new("ScrollingFrame")
		ControlScroll.Size = UDim2.new(1,0,1,0); ControlScroll.BackgroundTransparency = 1
		ControlScroll.ScrollBarThickness = 8; ControlScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
		ControlScroll.Parent = ControlPage
		Instance.new("UIListLayout", ControlScroll).Padding = UDim.new(0,12)
	end

	local ImmunePage = Instance.new("Frame")
	ImmunePage.Size = UDim2.new(1,0,1,0); ImmunePage.BackgroundTransparency = 1; ImmunePage.Visible = false
	ImmunePage.Parent = ContentContainer
	local ImmuneScroll = Instance.new("ScrollingFrame")
	ImmuneScroll.Size = UDim2.new(1,0,1,0); ImmuneScroll.BackgroundTransparency = 1
	ImmuneScroll.ScrollBarThickness = 8; ImmuneScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	ImmuneScroll.Parent = ImmunePage
	Instance.new("UIListLayout", ImmuneScroll).Padding = UDim.new(0,12)

	local function switchTab(name)
		currentTab = name
		TargetPage.Visible = name == "target"
		SettingsPage.Visible = name == "settings"
		ImmunePage.Visible = name == "immune"
		if isOwner then ControlPage.Visible = name == "control" end
		TargetTabBtn.BackgroundColor3 = name == "target" and Color3.fromRGB(25,60,90) or Color3.fromRGB(25,35,55)
		SettingsTabBtn.BackgroundColor3 = name == "settings" and Color3.fromRGB(25,60,90) or Color3.fromRGB(25,35,55)
		ImmuneTabBtn.BackgroundColor3 = name == "immune" and Color3.fromRGB(25,60,90) or Color3.fromRGB(25,35,55)
		if ControlTabBtn then ControlTabBtn.BackgroundColor3 = name == "control" and Color3.fromRGB(25,60,90) or Color3.fromRGB(25,35,55) end
	end
	TargetTabBtn.MouseButton1Click:Connect(function() switchTab("target") end)
	SettingsTabBtn.MouseButton1Click:Connect(function() switchTab("settings") end)
	ImmuneTabBtn.MouseButton1Click:Connect(function() switchTab("immune") end)
	if ControlTabBtn then ControlTabBtn.MouseButton1Click:Connect(function() switchTab("control") end) end

	OpenBtn.MouseButton1Click:Connect(function() MainFrame.Visible = true end)
	CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

	function refreshPlayerList()
		for _,b in ipairs(playerButtons) do b:Destroy() end
		table.clear(playerButtons)
		for _,plr in ipairs(Players:GetPlayers()) do
			if plr ~= Player then
				local safe = isPlayerSafe(plr)
				local btn = Instance.new("TextButton")
				btn.Size = UDim2.new(1,0,0,36)
				btn.BackgroundColor3 = safe and Color3.fromRGB(20,60,40) or Color3.fromRGB(25,40,65)
				btn.Font = Enum.Font.Gotham
				btn.Text = (safe and "✅ " or "")..plr.DisplayName.." (@"..plr.Name..")"
				btn.TextColor3 = safe and Color3.fromRGB(120,255,170) or Color3.fromRGB(180,220,255)
				btn.TextSize = 12; btn.Parent = PlayerScroll
				Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
				btn.MouseButton1Click:Connect(function()
					if safe then return end
					if isOwner then HVH_MODE = true; HVH_TARGET_USERID = plr.UserId end
					selectTarget(plr)
				end)
				table.insert(playerButtons, btn)
			end
		end
	end
	Players.PlayerAdded:Connect(refreshPlayerList)
	Players.PlayerRemoving:Connect(refreshPlayerList)
	task.spawn(refreshPlayerList)

	local function mkNum(lbl, def, cb, p)
		local c = Instance.new("Frame")
		c.Size = UDim2.new(1,0,0,42); c.BackgroundColor3 = Color3.fromRGB(20,30,50); c.Parent = p or SettingsScroll
		Instance.new("UICorner", c).CornerRadius = UDim.new(0,8)
		local l = Instance.new("TextLabel")
		l.Size = UDim2.new(0,160,1,0); l.Position = UDim2.new(0,15,0,0); l.BackgroundTransparency = 1
		l.Text = lbl; l.Font = Enum.Font.Gotham; l.TextColor3 = Color3.fromRGB(180,220,255); l.TextSize = 13; l.Parent = c
		local b = Instance.new("TextBox")
		b.Size = UDim2.new(1,-180,1,-8); b.Position = UDim2.new(0,170,0,4)
		b.BackgroundColor3 = Color3.fromRGB(25,45,70); b.Font = Enum.Font.Gotham; b.Text = tostring(def)
    b.TextColor3 = Color3.fromRGB(200,240,255); b.TextSize = 13; b.Parent = c
		Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
		b.FocusLost:Connect(function(e) if e then local v = tonumber(b.Text) if v then cb(v) end end end)
	end

	local function mkToggle(lbl, get, set, p)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1,0,0,42)
		local function u()
			local s = get()
			btn.BackgroundColor3 = s and Color3.fromRGB(20,60,50) or Color3.fromRGB(25,35,55)
			btn.Text = lbl.." — "..(s and "ON" or "OFF")
		end
		u(); btn.Font = Enum.Font.GothamSemibold
		btn.TextColor3 = Color3.fromRGB(180,240,255); btn.TextSize = 14; btn.Parent = p or SettingsScroll
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
		btn.MouseButton1Click:Connect(function() set(not get()) u() end)
	end

	local function mkBtn(lbl, cb, p)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1,0,0,42); btn.BackgroundColor3 = Color3.fromRGB(20,40,70)
		btn.Text = lbl; btn.Font = Enum.Font.Gotham; btn.TextColor3 = Color3.fromRGB(180,240,255); btn.TextSize = 14; btn.Parent = p or SettingsScroll
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
		btn.MouseButton1Click:Connect(cb)
	end

	mkNum("Chase Distance", CHASE_DISTANCE, function(v) CHASE_DISTANCE = v end)
	mkNum("Prediction", PREDICTION, function(v) PREDICTION = v end)
	mkNum("Hitbox Size", HITBOX_SIZE, function(v) HITBOX_SIZE = v end)

	mkToggle("Aimbot (Sticky)", function() return AIMBOT_ENABLED end, function(v) AIMBOT_ENABLED = v end)
	mkToggle("VOID MODE", function() return VOID_MODE_ENABLED end, function(v) VOID_MODE_ENABLED = v end)
	mkToggle("NOCLIP", function() return NOCLIP_ENABLED end, function(v) setNoclip(v) end)
	mkToggle("M1 Spam", function() return UNLIMITED_M1_ENABLED end, function(v) UNLIMITED_M1_ENABLED = v end)
	mkToggle("M2 Spam", function() return M2_SPAM_ENABLED end, function(v) M2_SPAM_ENABLED = v end)
	mkToggle("Auto Block", function() return BLOCK_ENABLED end, function(v) BLOCK_ENABLED = v end)
	mkBtn("Stop / Idle", function() stopChase() end)

	if isOwner then
		mkToggle("HVH GROUP MODE", function() return HVH_MODE end, function(v)
        HVH_MODE = v
			if not v then HVH_TARGET_USERID = nil; HVH_VOID = false; HVH_NOCLIP = false end
		end, ControlScroll)
		mkBtn("Stop All / HVH OFF", function()
			HVH_MODE = false; HVH_TARGET_USERID = nil; HVH_VOID = false; HVH_NOCLIP = false
			stopChase()
		end, ControlScroll)
	end

	local SafeInputFrame = Instance.new("Frame")
	SafeInputFrame.Size = UDim2.new(1,0,0,42); SafeInputFrame.BackgroundColor3 = Color3.fromRGB(25,50,40); SafeInputFrame.Parent = ImmuneScroll
	Instance.new("UICorner", SafeInputFrame).CornerRadius = UDim.new(0,8)
	local SafeLabel = Instance.new("TextLabel")
	SafeLabel.Size = UDim2.new(0,100,1,0); SafeLabel.Position = UDim2.new(0,12,0,0); SafeLabel.BackgroundTransparency = 1
	SafeLabel.Text = "Safe Player:"; SafeLabel.Font = Enum.Font.GothamBold; SafeLabel.TextColor3 = Color3.fromRGB(150,255,200); SafeLabel.TextSize = 13
	SafeLabel.TextXAlignment = Enum.TextXAlignment.Left; SafeLabel.Parent = SafeInputFrame
	local SafeBox = Instance.new("TextBox")
	SafeBox.Size = UDim2.new(1,-115,1,-8); SafeBox.Position = UDim2.new(0,105,0,4)
	SafeBox.BackgroundColor3 = Color3.fromRGB(40,70,55); SafeBox.Font = Enum.Font.Gotham
	SafeBox.PlaceholderText = "Username → ENTER"; SafeBox.Text = ""
	SafeBox.TextColor3 = Color3.fromRGB(200,255,220); SafeBox.TextSize = 13; SafeBox.Parent = SafeInputFrame
	Instance.new("UICorner", SafeBox).CornerRadius = UDim.new(0,6)
	SafeBox.FocusLost:Connect(function(enterPressed)
		if enterPressed and SafeBox.Text ~= "" then
			local t = findPlayerByFuzzy(SafeBox.Text)
			if t then immunePlayers[t] = true end
			SafeBox.Text = ""; refreshPlayerList()
		end
	end)

	local RemoveSafeBox = Instance.new("TextBox")
	RemoveSafeBox.Size = UDim2.new(1,-115,1,-8); RemoveSafeBox.Position = UDim2.new(0,105,0,4)
	RemoveSafeBox.BackgroundColor3 = Color3.fromRGB(70,40,55); RemoveSafeBox.Font = Enum.Font.Gotham
	RemoveSafeBox.PlaceholderText = "Remove Safe → ENTER"; RemoveSafeBox.Text = ""
	RemoveSafeBox.TextColor3 = Color3.fromRGB(255,200,200); RemoveSafeBox.TextSize = 13; RemoveSafeBox.Parent = ImmuneScroll
	Instance.new("UICorner", RemoveSafeBox).CornerRadius = UDim.new(0,6)
	RemoveSafeBox.FocusLost:Connect(function(enterPressed)
		if enterPressed and RemoveSafeBox.Text ~= "" then
			local t = findPlayerByFuzzy(RemoveSafeBox.Text)
			if t then immunePlayers[t] = nil end
			RemoveSafeBox.Text = ""; refreshPlayerList()
		end
	end)
end

local function checkKey()
	local input = KeyBox.Text
	if input == CORRECT_KEY then
		Status.Text = "SUCCESS UNLOCKING..."
		task.wait(0.5)
		runMainScript()
		return
	end
	attempts += 1
	Status.Text = "WRONG KEY! Attempts: "..attempts.."/"..MAX_ATTEMPTS
	if attempts >= MAX_ATTEMPTS then
		Status.Text = "TOO MANY — KICKING..."
		task.wait(1.5)
		Player:Kick("Too many wrong key attempts")
	end
end

SubmitBtn.MouseButton1Click:Connect(checkKey)
KeyBox.FocusLost:Connect(function(enterPressed) if enterPressed then checkKey() end end)
