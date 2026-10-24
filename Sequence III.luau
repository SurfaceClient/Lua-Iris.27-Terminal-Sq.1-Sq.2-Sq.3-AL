-- Also Takes Place Right after Seq 2

----------------------------------------------------
-- SEQUENCE THREE (REBUILT SYSTEM)
----------------------------------------------------

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local ScanConnection
local InfoLoopConnection
local ParallaxConnection   -- new: mouse parallax loop

----------------------------------------------------
-- Configs
----------------------------------------------------
local CURRENT_VERSION   = "v3.0.1"
local LATEST_VERSION    = "v3.0.1"
local BUILD_DATE        = "2026.06.28"
local SERVER_OPERATIONAL = true

local VALID_COMMAND = "iris.27 /x c: start"

-- Every label that lives inside ScrollingFrame and must stay hidden
local OUTPUT_LABEL_NAMES = {
	InvalidText1 = true,
	InvalidText2 = true,
	StartText = true,
}
for i = 1, 10 do
	OUTPUT_LABEL_NAMES["CorrectText" .. i] = true
end

----------------------------------------------------
-- Helper: Quick Tween
----------------------------------------------------
local function tween(obj, duration, props)
	if not obj then return end
	local t = TweenService:Create(
		obj,
		TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		props
	)
	t:Play()
	return t
end

----------------------------------------------------
-- RESET TERMINAL
----------------------------------------------------
local function ResetTerminal(A)
	local FadeOut = A.FadeOut
	if FadeOut then
		FadeOut.Visible = true
		FadeOut.BackgroundTransparency = 1
		FadeOut.ZIndex = 9999
	end
	
	task.wait(0.15)
	
	if A.PurpleLED then
		A.PurpleLED.Visible = true
		A.PurpleLED.ImageTransparency = 1
	end

	if A.FadeOut then
		A.FadeOut.Visible = false
		A.FadeOut.BackgroundTransparency = 0
	end

	if A.Terminal then
		for _, v in ipairs(A.Terminal:GetDescendants()) do
			if v:IsA("ImageLabel") then
				v.ImageTransparency = 1
				v.Visible = true
			elseif v:IsA("TextLabel") then
				v.TextTransparency = 1
				v.Visible = true
			elseif v:IsA("TextBox") then
				v.TextTransparency = 1
				v.BackgroundTransparency = 1
				v.Visible = true
			end
		end
	end

	if A.TEXTS then
		for _, v in ipairs(A.TEXTS:GetDescendants()) do
			if v:IsA("TextLabel") then
				v.TextTransparency = 1
				v.Visible = true
			elseif v:IsA("TextBox") then
				v.TextTransparency = 1
				v.BackgroundTransparency = 1
				v.Visible = true
			end
		end

		for name in pairs(OUTPUT_LABEL_NAMES) do
			local obj = A.TEXTS:FindFirstChild(name, true)
			if obj then
				obj.Visible = false
			end
		end
	end
end

----------------------------------------------------
-- ScanLine Loop
----------------------------------------------------
local function StartScanlineLoop(A)
	local a = A.ScanLinesA
	local b = A.ScanLinesB
	if not a or not b then return end

	a.Visible = true
	b.Visible = true
	a.Position = UDim2.new(0, 0, 0, 0)
	b.Position = UDim2.new(0, 0, 1, 0)

	local speed = 0.15

	if ScanConnection then
		ScanConnection:Disconnect()
		ScanConnection = nil
	end

	ScanConnection = RunService.RenderStepped:Connect(function(dt)
		local move = speed * dt
		a.Position = UDim2.new(0, 0, a.Position.Y.Scale - move, 0)
		b.Position = UDim2.new(0, 0, b.Position.Y.Scale - move, 0)
		if a.Position.Y.Scale <= -1 then
			a.Position = UDim2.new(0, 0, a.Position.Y.Scale + 2, 0)
		end
		if b.Position.Y.Scale <= -1 then
			b.Position = UDim2.new(0, 0, b.Position.Y.Scale + 2, 0)
		end
	end)
end

----------------------------------------------------
-- Parallax (UPDATED. keeps original centering)
----------------------------------------------------
local function StartParallax(A)
	if ParallaxConnection then
		ParallaxConnection:Disconnect()
		ParallaxConnection = nil
	end

	local terminal = A.Terminal
	local texts = A.TEXTS
	if not terminal and not texts then return end

	-- Capture the original rest positions (this is after everything is revealed)
	local terminalRestPos = terminal and terminal.Position
	local textsRestPos = texts and texts.Position

	-- Multiplier, Adjust to change the intensity of the Parallax  (Pixels per screen fraction)
	local STRENGTH = 15  -- try values 8–20

	ParallaxConnection = RunService.Heartbeat:Connect(function()
		local mouseLoc = UserInputService:GetMouseLocation()
		local screenSize = workspace.CurrentCamera.ViewportSize
		local centerX = screenSize.X / 2
		local centerY = screenSize.Y / 2
		local deltaX = (mouseLoc.X - centerX) / centerX   -- -1 to 1
		local deltaY = (mouseLoc.Y - centerY) / centerY

		local offsetX = deltaX * STRENGTH 
		local offsetY = deltaY * STRENGTH

		if terminal and terminalRestPos then
			terminal.Position = UDim2.new(
				terminalRestPos.X.Scale,
				terminalRestPos.X.Offset + offsetX,
				terminalRestPos.Y.Scale,
				terminalRestPos.Y.Offset + offsetY
			)
		end

		if texts and textsRestPos then
			texts.Position = UDim2.new(
				textsRestPos.X.Scale,
				textsRestPos.X.Offset + offsetX * 0.5,  
				textsRestPos.Y.Scale,
				textsRestPos.Y.Offset + offsetY * 0.5
			)
		end
	end)
end
----------------------------------------------------
-- START TERMINAL
----------------------------------------------------
function SequenceManipulator.StartTerminal(A)
	print("Sequence Three Started")

	-- RESET STATE
	ResetTerminal(A)
	task.wait(1)

	if A.PurpleLED then
		A.PurpleLED.Visible = true
		A.PurpleLED.ImageTransparency = 1
	end
	tween(A.PurpleLED, 0.6, { ImageTransparency = 0 })

	----------------------------------------------------
	-- Device Detection (InfoText 6)
	----------------------------------------------------
	local function GetDeviceLabel()
		if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
			return "Mobile"
		elseif UserInputService.GamepadEnabled and not UserInputService.KeyboardEnabled then
			return "Console"
		else
			return "Desktop"
		end
	end

	----------------------------------------------------
	-- Static Info
	----------------------------------------------------
	local function PopulateStaticInfo(A)
		local T = A.TEXTS
		if not T then return end

		local function set(name, text)
			local obj = T:FindFirstChild(name)
			if obj then obj.Text = text end
		end

		set("InfoText1", "STEREOTYPE-SC")
		set("InfoText6", "Roblox Cloud //" .. GetDeviceLabel() .. "// INSTANCE: m5.large\\")
		set("InfoText7", CURRENT_VERSION .. " // BUILD: " .. BUILD_DATE)
		set("InfoText8", "BevenHB/SurfaceClient")
		set("InfoText9", "Iris.27 /x C: START")

		local userId = T:FindFirstChild("InfoText2")
		if userId then
			local digits = {}
			for i = 1, 13 do
				digits[i] = tostring(math.random(0, 9))
			end
			userId.Text = table.concat(digits) .. " [RNG Due to Roblox's Recent Updates]"
		end
	end

	----------------------------------------------------
	-- Status Check
	----------------------------------------------------
	local function ApplyStatus(A)
		local T = A.TEXTS
		if not T then return end
		local status = T:FindFirstChild("InfoText3")
		if not status then return end
		if CURRENT_VERSION == LATEST_VERSION then
			status.Text = "UP-TO-DATE ⚙"
			status.TextColor3 = Color3.fromRGB(0, 255, 0)
		else
			status.Text = "OUTDATED 📉"
			status.TextColor3 = Color3.fromRGB(255, 60, 60)
		end
	end

	----------------------------------------------------
	-- CLIENT USER + DOTTED LINE
	----------------------------------------------------
	local function SetupClientUser(A)
		local T = A.TEXTS
		if not T then return end
		local clientUser = T:FindFirstChild("ClientUser")
		local dottedLine  = T:FindFirstChild("DottedLine")
		local player = Players.LocalPlayer

		if clientUser then
			clientUser.Text = player.Name .. "@Iris.27"
		end
		if dottedLine and clientUser then
			local pieces = {}
			for i = 1, #clientUser.Text do
				pieces[i] = "-"
			end
			dottedLine.Text = table.concat(pieces, " ")
		end
	end

	----------------------------------------------------
	-- RealTime Info Loop
	----------------------------------------------------
	local function StartRealtimeInfoLoop(A)
		local T = A.TEXTS
		if not T then return end
		local timestamp = T:FindFirstChild("InfoText4")
		local server = T:FindFirstChild("InfoText5")
		local startTime = os.clock()
		local acc = 0

		if InfoLoopConnection then
			InfoLoopConnection:Disconnect()
			InfoLoopConnection = nil
		end

		InfoLoopConnection = RunService.Heartbeat:Connect(function(dt)
			acc += dt
			if acc < 1 then return end
			acc = 0

			if timestamp then
				local now = DateTime.now():ToUniversalTime()
				timestamp.Text = string.format(
					"%04d-%02d-%02d %02d:%02d:%02d UTC",
					now.Year, now.Month, now.Day, now.Hour, now.Minute, now.Second
				)
			end

			if server then
				if SERVER_OPERATIONAL then
					local elapsed = os.clock() - startTime
					local h = math.floor(elapsed / 3600)
					local m = math.floor((elapsed % 3600) / 60)
					local s = math.floor(elapsed % 60)
					server.Text = string.format("OPERATIONAL  [RUNNING TIME ON CMU: %02d:%02d:%02d]", h, m, s)
				else
					server.Text = "INOPERATIVE"
				end
			end
		end)

		return InfoLoopConnection
	end

	----------------------------------------------------
	-- COMMAND TERMINAL
	----------------------------------------------------
	local function SetupCommandTerminal(A)
		local T = A.TEXTS
		if not T then return end

		local textBox = T:FindFirstChild("TextBox")
		local prefix  = T:FindFirstChild("Prefix")
		local scrollFrame = T:FindFirstChild("ScrollingFrame")
		local player = Players.LocalPlayer

		if prefix then
			prefix.Text = player.Name .. "@Iris.27 ~ $"
		end

		if not textBox or not scrollFrame then return end

		-- Fix alignment once and for all
		textBox.TextXAlignment = Enum.TextXAlignment.Left

		textBox.Focused:Connect(function()
			textBox.CursorPosition = #textBox.Text + 1
		end)

		local listLayout = scrollFrame:FindFirstChildOfClass("UIListLayout")
		if listLayout then
			listLayout.SortOrder = Enum.SortOrder.LayoutOrder
		end

		local invalidTemplate1 = scrollFrame:FindFirstChild("InvalidText1")
		local invalidTemplate2 = scrollFrame:FindFirstChild("InvalidText2")
		if invalidTemplate1 then invalidTemplate1.Visible = false end
		if invalidTemplate2 then invalidTemplate2.Visible = false end

		local submitted = false
		local orderCounter = 0

		-- Outro helper – called after countdown finishes
		local function StartOutro()
			-- Stop all ongoing loops
			if ScanConnection then
				ScanConnection:Disconnect()
				ScanConnection = nil
			end
			if InfoLoopConnection then
				InfoLoopConnection:Disconnect()
				InfoLoopConnection = nil
			end
			if ParallaxConnection then
				ParallaxConnection:Disconnect()
				ParallaxConnection = nil
			end

			local T = A.TEXTS
			local asciiArt = T and T:FindFirstChild("ASCIIArt")
			local loadingSeq = A.LoadingSequence

			-- Helper to play a sound from an asset id string
			local function playSoundFromId(id, volume)
				if not id then return end
				local sound = Instance.new("Sound")
				sound.SoundId = id
				sound.Volume = volume or 1
				sound.Parent = loadingSeq or workspace
				sound:Play()
				sound.Ended:Connect(function()
					sound:Destroy()
				end)
			end

			-- ASCIIArt downward tween (0.1s, Ts: Quint) + pause 0.04s --
			if asciiArt then
				local downPos  = UDim2.new(-1.63, -20, 0.631, 0)
				local rightPos = UDim2.new(-1.47, -20, 0.631, 0)
				local leftPos  = UDim2.new(-1.79, -20, 0.631, 0)

				TweenService:Create(asciiArt, TweenInfo.new(0.1, Enum.EasingStyle.Quint), {
					Position = downPos
				}):Play()

				task.delay(.0 + 0, function()
					local jitterActive = true
					local side = true 

					-- Stops jitter after fade completes
					task.delay(.14  + .5, function() jitterActive = false end)

					while jitterActive do
						asciiArt.Position = side and rightPos or leftPos

						playSoundFromId(A.SOUNDS.JITTER, 0.6) 

						side = not side
						task.wait(0.04)  -- The delay between each flip
					end
				end)
			end

			-- Global fade‑out (starts 0.12s after jitter begins) --
			-- Jitter begins at t = 0.15 (0.1 + 0.05), so fade starts at t = 0.27
			task.delay(.2, function()
				if loadingSeq then
					local tweenProps = TweenInfo.new(.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
					for _, obj in ipairs(loadingSeq:GetDescendants()) do
						if obj:IsA("ImageLabel") then
							TweenService:Create(obj, tweenProps, {ImageTransparency = 1}):Play()
						elseif obj:IsA("Frame") then
							TweenService:Create(obj, tweenProps, {BackgroundTransparency = 1}):Play()
						elseif obj:IsA("TextLabel") or obj:IsA("TextBox") then
							TweenService:Create(obj, tweenProps, {TextTransparency = 1}):Play()
							if obj:IsA("TextBox") then
								TweenService:Create(obj, tweenProps, {BackgroundTransparency = 1}):Play()
							end
						end
					end
				end
			end)

			-- Waits for the fade to complete (fade starts at 0.27 + 0.5 = 0.77s total)
			task.wait(0.27 + 0.5)

			-- BlackScreen1 fade --
			if loadingSeq then
				local blackScreen = loadingSeq.Parent
				if blackScreen then
					if blackScreen:IsA("ImageLabel") then
						TweenService:Create(blackScreen, TweenInfo.new(0.5), {ImageTransparency = 1}):Play()
					elseif blackScreen:IsA("Frame") then
						TweenService:Create(blackScreen, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
					end
					task.wait(0.5)
				end
			end

			-- Color inversion --
			local cc = Instance.new("ColorCorrectionEffect")
			cc.Brightness = 1
			cc.Contrast = -1
			cc.Saturation = -1
			cc.Parent = game.Lighting
			task.wait(1)
			cc:Destroy()

		end

		local function RunCorrectSequence()
			submitted = true
			textBox.TextEditable = false
			textBox.Text = ""

			-- Move TextBox away
			local originalPos = textBox.Position
			TweenService:Create(
				textBox,
				TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
				{ Position = UDim2.new(
					originalPos.X.Scale,
					originalPos.X.Offset + 2000,
					originalPos.Y.Scale,
					originalPos.Y.Offset
					)}
			):Play()

			for i = 1, 10 do
				local label = scrollFrame:FindFirstChild("CorrectText" .. i)
				if label then
					orderCounter += 1
					label.LayoutOrder = orderCounter
					label.Visible = true
					label.TextTransparency = 0
				end
				local delay = 0.05 + (0.15 - 0.05) * (i - 1) / 9
				task.wait(delay)
			end

			local startText = scrollFrame:FindFirstChild("StartText")
			if startText then
				orderCounter += 1
				startText.LayoutOrder = orderCounter
				startText.Visible = true
				startText.TextTransparency = 0
				for i = 5, 0, -1 do
					startText.Text = "> START: (" .. i .. ")"
					task.wait(1)
				end
			end

			-- Countdown finishes > start outro
			StartOutro()
		end

		local function RunInvalidSequence(userInput)
			if not invalidTemplate1 or not invalidTemplate2 then return end

			local clone1 = invalidTemplate1:Clone()
			orderCounter += 1
			clone1.LayoutOrder = orderCounter
			clone1.Text = "> C:/  " .. userInput
			clone1.Visible = true
			clone1.TextTransparency = 0
			clone1.Parent = scrollFrame

			local clone2 = invalidTemplate2:Clone()
			orderCounter += 1
			clone2.LayoutOrder = orderCounter
			clone2.Text = "> bash: GetCommandName: Command not found"
			clone2.Visible = true
			clone2.TextTransparency = 0
			clone2.Parent = scrollFrame
		end

		textBox.FocusLost:Connect(function(enterPressed)
			if not enterPressed or submitted then return end
			local input = textBox.Text
			textBox.Text = ""
			if input:lower() == VALID_COMMAND then
				RunCorrectSequence()
			else
				RunInvalidSequence(input)
			end
		end)
	end

	------------------------------------------------
	-- Start ScanLines
	------------------------------------------------
	StartScanlineLoop(A)

	------------------------------------------------
	-- FadeOut Phase
	------------------------------------------------
	local FadeOut = A.FadeOut
	if not FadeOut then
		warn("FadeOut missing")
		return
	end

	FadeOut.ZIndex = 999
	FadeOut.BackgroundTransparency = 0
	FadeOut.Visible = true

	task.wait(0.8)

	local fadeTween = TweenService:Create(
		FadeOut,
		TweenInfo.new(3.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut),
		{ BackgroundTransparency = 1 }
	)
	fadeTween:Play()
	fadeTween.Completed:Wait()

	------------------------------------------------
	-- TERMINAL REVEAL
	------------------------------------------------
	if A.Terminal then
		A.Terminal.Visible = true
		for _, v in ipairs(A.Terminal:GetDescendants()) do
			if v:IsA("TextLabel") then
				v.Visible = true
				v.TextTransparency = 1
				tween(v, 0.25, { TextTransparency = 0 })
			elseif v:IsA("ImageLabel") then
				v.Visible = true
				v.ImageTransparency = 1
				local target = (v == A.Terminal) and 0.3 or (v.Name == "TerminalTheme" and 0.9 or 0)
				tween(v, 0.25, { ImageTransparency = target })
			elseif v:IsA("TextBox") then
				v.Visible = true
				v.TextTransparency = 1
				v.BackgroundTransparency = 1
				tween(v, 0.5, { TextTransparency = 0, BackgroundTransparency = 1 })
			end
		end
	end

	------------------------------------------------
	-- TEXTS Block Reveal
	------------------------------------------------
	if A.TEXTS then
		A.TEXTS.Visible = true
		for _, v in ipairs(A.TEXTS:GetDescendants()) do
			if OUTPUT_LABEL_NAMES[v.Name] then
				-- still hidden
			elseif v:IsA("TextLabel") then
				v.Visible = true
				v.TextTransparency = 1
				tween(v, 0.5, { TextTransparency = 0 })
			elseif v:IsA("TextBox") then
				v.Visible = true
				v.TextTransparency = 1
				v.BackgroundTransparency = 1
				tween(v, 0.5, { TextTransparency = 0, BackgroundTransparency = 1 })
			end
		end
	end

	------------------------------------------------
	-- Info Panel
	------------------------------------------------
	PopulateStaticInfo(A)
	ApplyStatus(A)
	SetupClientUser(A)
	SetupCommandTerminal(A)
	StartRealtimeInfoLoop(A)

	------------------------------------------------
	-- Start Parallax
	------------------------------------------------
	StartParallax(A)

end

return SequenceManipulator
