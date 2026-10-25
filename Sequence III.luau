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
local CurrentVersion   = "v3.0.1"
local LatestVersion    = "v3.0.1"
local BuildDate        = "2026.06.28"
local ServerOperational = true

local ValidCommand = "iris.27 /x c: start"

-- Every label that lives inside ScrollingFrame and must stay hidden
local OutputLabelNames = {
	InvalidText1 = true,
	InvalidText2 = true,
	StartText = true,
}
for I = 1, 10 do
	OutputLabelNames["CorrectText" .. I] = true
end

----------------------------------------------------
-- Helper: Quick Tween
----------------------------------------------------
local function Tween(Obj, Duration, Props)
	if not Obj then return end
	local T = TweenService:Create(
		Obj,
		TweenInfo.new(Duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		Props
	)
	T:Play()
	return T
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
		for _, V in ipairs(A.Terminal:GetDescendants()) do
			if V:IsA("ImageLabel") then
				V.ImageTransparency = 1
				V.Visible = true
			elseif V:IsA("TextLabel") then
				V.TextTransparency = 1
				V.Visible = true
			elseif V:IsA("TextBox") then
				V.TextTransparency = 1
				V.BackgroundTransparency = 1
				V.Visible = true
			end
		end
	end

	if A.TEXTS then
		for _, V in ipairs(A.TEXTS:GetDescendants()) do
			if V:IsA("TextLabel") then
				V.TextTransparency = 1
				V.Visible = true
			elseif V:IsA("TextBox") then
				V.TextTransparency = 1
				V.BackgroundTransparency = 1
				V.Visible = true
			end
		end

		for Name in pairs(OutputLabelNames) do
			local Obj = A.TEXTS:FindFirstChild(Name, true)
			if Obj then
				Obj.Visible = false
			end
		end
	end
end

----------------------------------------------------
-- ScanLine Loop
----------------------------------------------------
local function StartScanlineLoop(A)
	local A_ = A.ScanLinesA
	local B = A.ScanLinesB
	if not A_ or not B then return end

	A_.Visible = true
	B.Visible = true
	A_.Position = UDim2.new(0, 0, 0, 0)
	B.Position = UDim2.new(0, 0, 1, 0)

	local Speed = 0.15

	if ScanConnection then
		ScanConnection:Disconnect()
		ScanConnection = nil
	end

	ScanConnection = RunService.RenderStepped:Connect(function(Dt)
		local Move = Speed * Dt
		A_.Position = UDim2.new(0, 0, A_.Position.Y.Scale - Move, 0)
		B.Position = UDim2.new(0, 0, B.Position.Y.Scale - Move, 0)
		if A_.Position.Y.Scale <= -1 then
			A_.Position = UDim2.new(0, 0, A_.Position.Y.Scale + 2, 0)
		end
		if B.Position.Y.Scale <= -1 then
			B.Position = UDim2.new(0, 0, B.Position.Y.Scale + 2, 0)
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

	local Terminal = A.Terminal
	local Texts = A.TEXTS
	if not Terminal and not Texts then return end

	-- Capture the original rest positions (this is after everything is revealed)
	local TerminalRestPos = Terminal and Terminal.Position
	local TextsRestPos = Texts and Texts.Position

	-- Multiplier, Adjust to change the intensity of the Parallax  (Pixels per screen fraction)
	local Strength = 15  -- try values 8–20

	ParallaxConnection = RunService.Heartbeat:Connect(function()
		local MouseLoc = UserInputService:GetMouseLocation()
		local ScreenSize = workspace.CurrentCamera.ViewportSize
		local CenterX = ScreenSize.X / 2
		local CenterY = ScreenSize.Y / 2
		local DeltaX = (MouseLoc.X - CenterX) / CenterX   -- -1 to 1
		local DeltaY = (MouseLoc.Y - CenterY) / CenterY

		local OffsetX = DeltaX * Strength 
		local OffsetY = DeltaY * Strength

		if Terminal and TerminalRestPos then
			Terminal.Position = UDim2.new(
				TerminalRestPos.X.Scale,
				TerminalRestPos.X.Offset + OffsetX,
				TerminalRestPos.Y.Scale,
				TerminalRestPos.Y.Offset + OffsetY
			)
		end

		if Texts and TextsRestPos then
			Texts.Position = UDim2.new(
				TextsRestPos.X.Scale,
				TextsRestPos.X.Offset + OffsetX * 0.5,  
				TextsRestPos.Y.Scale,
				TextsRestPos.Y.Offset + OffsetY * 0.5
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
	Tween(A.PurpleLED, 0.6, { ImageTransparency = 0 })

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

		local function Set_(Name, Text)
			local Obj = T:FindFirstChild(Name)
			if Obj then Obj.Text = Text end
		end

		Set_("InfoText1", "STEREOTYPE-SC")
		Set_("InfoText6", "Roblox Cloud //" .. GetDeviceLabel() .. "// INSTANCE: m5.large\\")
		Set_("InfoText7", CurrentVersion .. " // BUILD: " .. BuildDate)
		Set_("InfoText8", "BevenHB/SurfaceClient")
		Set_("InfoText9", "Iris.27 /x C: START")

		local UserId = T:FindFirstChild("InfoText2")
		if UserId then
			local Digits = {}
			for I = 1, 13 do
				Digits[I] = tostring(math.random(0, 9))
			end
			UserId.Text = table.concat(Digits) .. " [RNG Due to Roblox's Recent Updates]"
		end
	end

	----------------------------------------------------
	-- Status Check
	----------------------------------------------------
	local function ApplyStatus(A)
		local T = A.TEXTS
		if not T then return end
		local Status = T:FindFirstChild("InfoText3")
		if not Status then return end
		if CurrentVersion == LatestVersion then
			Status.Text = "UP-TO-DATE ⚙"
			Status.TextColor3 = Color3.fromRGB(0, 255, 0)
		else
			Status.Text = "OUTDATED 📉"
			Status.TextColor3 = Color3.fromRGB(255, 60, 60)
		end
	end

	----------------------------------------------------
	-- CLIENT USER + DOTTED LINE
	----------------------------------------------------
	local function SetupClientUser(A)
		local T = A.TEXTS
		if not T then return end
		local ClientUser = T:FindFirstChild("ClientUser")
		local DottedLine  = T:FindFirstChild("DottedLine")
		local Player = Players.LocalPlayer

		if ClientUser then
			ClientUser.Text = Player.Name .. "@Iris.27"
		end
		if DottedLine and ClientUser then
			local Pieces = {}
			for I = 1, #ClientUser.Text do
				Pieces[I] = "-"
			end
			DottedLine.Text = table.concat(Pieces, " ")
		end
	end

	----------------------------------------------------
	-- RealTime Info Loop
	----------------------------------------------------
	local function StartRealtimeInfoLoop(A)
		local T = A.TEXTS
		if not T then return end
		local Timestamp = T:FindFirstChild("InfoText4")
		local Server = T:FindFirstChild("InfoText5")
		local StartTime = os.clock()
		local Acc = 0

		if InfoLoopConnection then
			InfoLoopConnection:Disconnect()
			InfoLoopConnection = nil
		end

		InfoLoopConnection = RunService.Heartbeat:Connect(function(Dt)
			Acc += Dt
			if Acc < 1 then return end
			Acc = 0

			if Timestamp then
				local Now = DateTime.now():ToUniversalTime()
				Timestamp.Text = string.format(
					"%04d-%02d-%02d %02d:%02d:%02d UTC",
					Now.Year, Now.Month, Now.Day, Now.Hour, Now.Minute, Now.Second
				)
			end

			if Server then
				if ServerOperational then
					local Elapsed = os.clock() - StartTime
					local H = math.floor(Elapsed / 3600)
					local M = math.floor((Elapsed % 3600) / 60)
					local S = math.floor(Elapsed % 60)
					Server.Text = string.format("OPERATIONAL  [RUNNING TIME ON CMU: %02d:%02d:%02d]", H, M, S)
				else
					Server.Text = "INOPERATIVE"
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

		local TextBox = T:FindFirstChild("TextBox")
		local Prefix  = T:FindFirstChild("Prefix")
		local ScrollFrame = T:FindFirstChild("ScrollingFrame")
		local Player = Players.LocalPlayer

		if Prefix then
			Prefix.Text = Player.Name .. "@Iris.27 ~ $"
		end

		if not TextBox or not ScrollFrame then return end

		TextBox.TextXAlignment = Enum.TextXAlignment.Left

		TextBox.Focused:Connect(function()
			TextBox.CursorPosition = #TextBox.Text + 1
		end)

		local ListLayout = ScrollFrame:FindFirstChildOfClass("UIListLayout")
		if ListLayout then
			ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		end

		local InvalidTemplate1 = ScrollFrame:FindFirstChild("InvalidText1")
		local InvalidTemplate2 = ScrollFrame:FindFirstChild("InvalidText2")
		if InvalidTemplate1 then InvalidTemplate1.Visible = false end
		if InvalidTemplate2 then InvalidTemplate2.Visible = false end

		local Submitted = false
		local OrderCounter = 0

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
			local AsciiArt = T and T:FindFirstChild("ASCIIArt")
			local LoadingSeq = A.LoadingSequence

			-- Helper to play a sound from an asset id string
			local function PlaySoundFromId(Id, Volume)
				if not Id then return end
				local Sound = Instance.new("Sound")
				Sound.SoundId = Id
				Sound.Volume = Volume or 1
				Sound.Parent = LoadingSeq or workspace
				Sound:Play()
				Sound.Ended:Connect(function()
					Sound:Destroy()
				end)
			end

			-- ASCIIArt downward tween (0.1s, Ts: Quint) + pause 0.04s --
			if AsciiArt then
				local DownPos  = UDim2.new(-1.63, -20, 0.631, 0)
				local RightPos = UDim2.new(-1.47, -20, 0.631, 0)
				local LeftPos  = UDim2.new(-1.79, -20, 0.631, 0)

				TweenService:Create(AsciiArt, TweenInfo.new(0.1, Enum.EasingStyle.Quint), {
					Position = DownPos
				}):Play()

				task.delay(.0 + 0, function()
					local JitterActive = true
					local Side = true 

					-- Stops jitter after fade completes
					task.delay(.14  + .5, function() JitterActive = false end)

					while JitterActive do
						AsciiArt.Position = Side and RightPos or LeftPos

						PlaySoundFromId(A.SOUNDS.JITTER, 0.6) 

						Side = not Side
						task.wait(0.04)  -- The delay between each flip
					end
				end)
			end

			-- Global fade‑out (starts 0.12s after jitter begins) --
			-- Jitter begins at t = 0.15 (0.1 + 0.05), so fade starts at t = 0.27
			task.delay(.2, function()
				if LoadingSeq then
					local TweenProps = TweenInfo.new(.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
					for _, Obj in ipairs(LoadingSeq:GetDescendants()) do
						if Obj:IsA("ImageLabel") then
							TweenService:Create(Obj, TweenProps, {ImageTransparency = 1}):Play()
						elseif Obj:IsA("Frame") then
							TweenService:Create(Obj, TweenProps, {BackgroundTransparency = 1}):Play()
						elseif Obj:IsA("TextLabel") or Obj:IsA("TextBox") then
							TweenService:Create(Obj, TweenProps, {TextTransparency = 1}):Play()
							if Obj:IsA("TextBox") then
								TweenService:Create(Obj, TweenProps, {BackgroundTransparency = 1}):Play()
							end
						end
					end
				end
			end)

			-- Waits for the fade to complete (fade starts at 0.27 + 0.5 = 0.77s total)
			task.wait(0.27 + 0.5)

			-- BlackScreen1 fade --
			if LoadingSeq then
				local BlackScreen = LoadingSeq.Parent
				if BlackScreen then
					if BlackScreen:IsA("ImageLabel") then
						TweenService:Create(BlackScreen, TweenInfo.new(0.5), {ImageTransparency = 1}):Play()
					elseif BlackScreen:IsA("Frame") then
						TweenService:Create(BlackScreen, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
					end
					task.wait(0.5)
				end
			end

			-- Color inversion --
			local Cc = Instance.new("ColorCorrectionEffect")
			Cc.Brightness = 1
			Cc.Contrast = -1
			Cc.Saturation = -1
			Cc.Parent = game.Lighting
			task.wait(1)
			Cc:Destroy()

		end

		local function RunCorrectSequence()
			Submitted = true
			TextBox.TextEditable = false
			TextBox.Text = ""

			-- Move TextBox away
			local OriginalPos = TextBox.Position
			TweenService:Create(
				TextBox,
				TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
				{ Position = UDim2.new(
					OriginalPos.X.Scale,
					OriginalPos.X.Offset + 2000,
					OriginalPos.Y.Scale,
					OriginalPos.Y.Offset
					)}
			):Play()

			for I = 1, 10 do
				local Label = ScrollFrame:FindFirstChild("CorrectText" .. I)
				if Label then
					OrderCounter += 1
					Label.LayoutOrder = OrderCounter
					Label.Visible = true
					Label.TextTransparency = 0
				end
				local Delay = 0.05 + (0.15 - 0.05) * (I - 1) / 9
				task.wait(Delay)
			end

			local StartText = ScrollFrame:FindFirstChild("StartText")
			if StartText then
				OrderCounter += 1
				StartText.LayoutOrder = OrderCounter
				StartText.Visible = true
				StartText.TextTransparency = 0
				for I = 5, 0, -1 do
					StartText.Text = "> START: (" .. I .. ")"
					task.wait(1)
				end
			end

			-- Countdown finishes > start outro
			StartOutro()
		end

		local function RunInvalidSequence(UserInput)
			if not InvalidTemplate1 or not InvalidTemplate2 then return end

			local Clone1 = InvalidTemplate1:Clone()
			OrderCounter += 1
			Clone1.LayoutOrder = OrderCounter
			Clone1.Text = "> C:/  " .. UserInput
			Clone1.Visible = true
			Clone1.TextTransparency = 0
			Clone1.Parent = ScrollFrame

			local Clone2 = InvalidTemplate2:Clone()
			OrderCounter += 1
			Clone2.LayoutOrder = OrderCounter
			Clone2.Text = "> bash: GetCommandName: Command not found"
			Clone2.Visible = true
			Clone2.TextTransparency = 0
			Clone2.Parent = ScrollFrame
		end

		TextBox.FocusLost:Connect(function(EnterPressed)
			if not EnterPressed or Submitted then return end
			local Input = TextBox.Text
			TextBox.Text = ""
			if Input:lower() == ValidCommand then
				RunCorrectSequence()
			else
				RunInvalidSequence(Input)
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

	local FadeTween = TweenService:Create(
		FadeOut,
		TweenInfo.new(3.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut),
		{ BackgroundTransparency = 1 }
	)
	FadeTween:Play()
	FadeTween.Completed:Wait()

	------------------------------------------------
	-- TERMINAL REVEAL
	------------------------------------------------
	if A.Terminal then
		A.Terminal.Visible = true
		for _, V in ipairs(A.Terminal:GetDescendants()) do
			if V:IsA("TextLabel") then
				V.Visible = true
				V.TextTransparency = 1
				Tween(V, 0.25, { TextTransparency = 0 })
			elseif V:IsA("ImageLabel") then
				V.Visible = true
				V.ImageTransparency = 1
				local Target = (V == A.Terminal) and 0.3 or (V.Name == "TerminalTheme" and 0.9 or 0)
				Tween(V, 0.25, { ImageTransparency = Target })
			elseif V:IsA("TextBox") then
				V.Visible = true
				V.TextTransparency = 1
				V.BackgroundTransparency = 1
				Tween(V, 0.5, { TextTransparency = 0, BackgroundTransparency = 1 })
			end
		end
	end

	------------------------------------------------
	-- TEXTS Block Reveal
	------------------------------------------------
	if A.TEXTS then
		A.TEXTS.Visible = true
		for _, V in ipairs(A.TEXTS:GetDescendants()) do
			if OutputLabelNames[V.Name] then
				-- still hidden
			elseif V:IsA("TextLabel") then
				V.Visible = true
				V.TextTransparency = 1
				Tween(V, 0.5, { TextTransparency = 0 })
			elseif V:IsA("TextBox") then
				V.Visible = true
				V.TextTransparency = 1
				V.BackgroundTransparency = 1
				Tween(V, 0.5, { TextTransparency = 0, BackgroundTransparency = 1 })
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
