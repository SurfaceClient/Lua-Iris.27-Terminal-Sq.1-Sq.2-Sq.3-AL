-- SequenceManipulator (ModularScript) All and the animations and sequences for the 
-- Iris.27 Terminal testing takes place here
-- By SurfaceClient (BevenHB)

-- Seq.1: [Chronals + HexBars + Inversion] In total: 479 Lines of code (including comments and whitespace)
-- Seq.2: [Brackets Idle & Opening + Stereotype + Lens] In total: 196 Lines of code; Begins on Line 485 Ends on 677
-- seq.3: [Terminal + RealTime Info+ Command execution + Outro] In total: 645 Lines of code; Begins on Line 682, Ends on 1323

-- a Message From Surf --
-- now if you haven't noticed already, this is Luau (Roblox's Implementation of lua), I initially planned to create this on Unreal
--  But During the same period i was stagnated on this engine, so i just decided to make it here,
-- one thing to note is that some of the values i mentioned in comments for the holds, delays and
-- intital runtimes may be outdated, so take a look at it yourself. and also, you'll have to create your own images and insert their id
-- in AssetLibrary (the other code) for the actual animations to display.
-- besides all this, 
-- you can use the code freely, just keep the credits in.

-- Oh and also the terminal can only execute that one singular Command lol (cause this is actually a loading screen in disguise)


local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")

local SequenceManipulator = {}

----------------------------------------------------
-- Sound (No Drift)
----------------------------------------------------

local function Play(Id, Volume)
	if not Id or Id == "" then return end

	local S = Instance.new("Sound")
	S.SoundId = Id
	S.Volume = Volume or 1.7
	S.Parent = SoundService

	S:Play()
	Debris:AddItem(S, 8)
	return S
end

----------------------------------------------------
-- Ui Helpers
----------------------------------------------------

local function Set(Obj, V)
	if Obj and Obj:IsA("GuiObject") then
		Obj.Visible = V
	end
end

local function Tween(Obj, T, Props)
	if not Obj then return end

	local Tw = TweenService:Create(
		Obj,
		TweenInfo.new(T, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		Props
	)

	Tw:Play()
	return Tw
end


local ContentProvider = game:GetService("ContentProvider")

local LoadedSounds = {}

local function PreloadSounds(SoundTable)

	local Assets = {}

	for Name,Id in pairs(SoundTable) do

		if typeof(Id) == "string" and Id ~= "" then

			local S = Instance.new("Sound")

			S.Name = Name
			S.SoundId = Id
			S.Volume = 1
			S.Parent = SoundService

			LoadedSounds[Name] = S
			table.insert(Assets,S)
		end
	end

	ContentProvider:PreloadAsync(Assets)
end

local function PlayCached(Name, Volume)

	local Source = LoadedSounds[Name]

	if not Source then
		return
	end

	local Clone = Source:Clone()

	Clone.Volume = Volume or 1
	Clone.Parent = SoundService

	Clone:Play()

	Debris:AddItem(Clone,8)

	return Clone
end
----------------------------------------------------
-- HexBar System
----------------------------------------------------

local HexMap = {
	Undo = {8,10},
	Gate = {4,5,10},
	Cast = {5,7},
	Hint = {1,5,7,8,10},
	Cell = {1,8,9},
	Dirt = {8,9,10},
	Sand = {2,4,7,10},
	Tear = {4,8,10},
	Zero = {4,8,9,10},
	Rush = {4,6,8,10},
	Zion = {6,7,8,10},
	Swap = {1,2,8,10},
	Word = {3,4,6,7,8,10},
	Jump = {7,8,9},
	Page = {1,2,3,4,5,6,7,8,9,10}
}

local HexColor = {
	Undo = Color3.fromRGB(179,0,255),
	Gate = Color3.fromRGB(255,255,255),
	Cast = Color3.fromRGB(0,27,177),
	Hint = Color3.fromRGB(0,119,231),
	Cell = Color3.fromRGB(130, 187, 190),
	Dirt = Color3.fromRGB(225, 90, 0),
	Sand = Color3.fromRGB(67,0,0),
	Tear = Color3.fromRGB(0,217,203),
	Zero = Color3.fromRGB(51, 0, 217),
	Rush = Color3.fromRGB(220,205,0),
	Zion = Color3.fromRGB(80,0,159),
	Swap = Color3.fromRGB(195, 0, 120),
	Word = Color3.fromRGB(0,1,68),
	Jump = Color3.fromRGB(68,68,68),
	Page = Color3.fromRGB(9, 9, 9)
}

local function ResetHex(HexFrame)
	if not HexFrame then return end
	for I = 1,10 do
		local B = HexFrame:FindFirstChild("HexBar"..I)
		if B then
			B.Visible = false
		end
	end
end

local function ApplyHex(HexFrame, ChronalName, FadeInTime)

	if not HexFrame then
		return
	end

	ResetHex(HexFrame)

	local Map = HexMap[ChronalName]
	local Col = HexColor[ChronalName]

	if not Map then
		return
	end

	for _,I in ipairs(Map) do

		local B = HexFrame:FindFirstChild("HexBar"..I)

		if B then

			B.Visible = true
			B.ZIndex = 20

			if B:IsA("ImageLabel") then

				B.ImageTransparency = 1
				B.ImageColor3 = Col

				Tween(B, FadeInTime,{
					ImageTransparency = 0
				})

			else

				B.BackgroundTransparency = 1
				B.BackgroundColor3 = Col

				Tween(B, FadeInTime,{
					BackgroundTransparency = 0
				})

			end
		end
	end
end

----------------------------------------------------
--  Sync Flicker (for Brackets, Stereotype, Lens)
----------------------------------------------------

local function Flick(Objects, Count, SoundId)
	for I = 1, Count do

		for _,O in ipairs(Objects) do
			Set(O,true)
		end

		Play(SoundId,1)
		task.wait(0.033)

		for _,O in ipairs(Objects) do
			Set(O,false)
		end

		task.wait(0.033)
	end

	for _,O in ipairs(Objects) do
		Set(O,true)
	end

	Play(SoundId,1)
end

----------------------------------------------------
-- Chronals (UPDATED. Fixed Visibility and Timing)
----------------------------------------------------

local function RunChronals(A)
	local Order = {
		"Undo","Gate","Cast","Hint","Cell",
		"Dirt","Sand","Tear","Zero","Rush",
		"Zion","Swap","Word","Jump","Page"
	}

	local Timings = {
		{0.15,0.6},{0.15,0.45},{0.15,0.3},{0.15,0.1},{0.15,0.09},
		{0.15,0.08},{0.15,0.07},{0.15,0.06},{0.15,0.05},{0.1,0.04},
		{0.1,0.04},{0.1,0.04},{0.08,0.03},{0.08,0.03},{0.08,0.03}
	}

	local HexFrame = A.HexaColors

	for I,Name in ipairs(Order) do
		local Obj = A.Chronals:FindFirstChild(Name)
		if Obj then

			Obj.Visible = true
			Obj.ImageTransparency = 1

			ApplyHex(
				HexFrame,
				Name,
				Timings[I][1]
			)

			Play(A.SOUND.CHRONAL,0.2)
			Play(A.SOUNDS.CHRONAL,0.7)
			Play(A.SOUND.CHRONAL,0.3)

			Tween(Obj,Timings[I][1],{ImageTransparency = 0}).Completed:Wait()

			if Name == "Page" then

				for _,Img in ipairs(A.Chronals:GetChildren()) do
					if Img:IsA("ImageLabel") then
						Img.ImageColor3 = Color3.fromRGB(0,255,183)
						Img.ZIndex = 25
					end
				end

				A.BlackScreen1.BackgroundColor3 =
					Color3.fromRGB(255,255,255)

				task.delay(1,function()

					Tween(
						A.BlackScreen1,
						1,{
							BackgroundColor3 =
								Color3.fromRGB(0,0,0)
						}
					)

				end)

				return Obj
			end

			local Map = HexMap[Name]

			if Map then

				for _,Id in ipairs(Map) do

					local B = HexFrame:FindFirstChild(
						"HexBar"..Id
					)

					if B then

						if B:IsA("ImageLabel") then

							Tween(
								B,
								Timings[I][2],{
									ImageTransparency = 1
								})

						else

							Tween(
								B,
								Timings[I][2],{
									BackgroundTransparency = 1
								})

						end
					end
				end
			end

			Tween(Obj,Timings[I][2],{ImageTransparency = 1}).Completed:Wait()
			Obj.Visible = false
		end
	end
end

----------------------------------------------------
-- Page Glitch
----------------------------------------------------
local function PageGlitch(A,Page)

	if not Page then
		return
	end


	local P0 = UDim2.new(0.47,0,0.424,0)
	local P1 = UDim2.new(0.60,0,0.424,0)
	local P2 = UDim2.new(0.34,0,0.424,0)
	local P3 = UDim2.new(0.62,0,0.424,0)
	local P4 = UDim2.new(0.33,0,0.424,0)

	Page.Position = P0

	task.wait(0.8)

	Play(A.SOUNDS.PAGEGLITCH,1)

	Tween(Page,0.06,{Position=P1}).Completed:Wait()
	Tween(Page,0.06,{Position=P2}).Completed:Wait()
	Tween(Page,0.06,{Position=P3}).Completed:Wait()
	Tween(Page,0.06,{Position=P4}).Completed:Wait()

	task.wait(0.03)
end
----------------------------------------------------
-- Main
----------------------------------------------------

function SequenceManipulator.Start(A)
	PreloadSounds(A.SOUNDS)
	------------------------------------------------
	-- RESET STATE (Do not Change any of the settings unless you know what you're doing)
	------------------------------------------------

	Set(A.BlackScreen1,true)
	Set(A.PurpleLED,false)

	Set(A.StereotypeText,false)
	Set(A.Lens,false)

	Set(A.LeftBracket,false)
	Set(A.RightBracket,false)

	local HexFrame = A.HexaColors
	if HexFrame then ResetHex(HexFrame) end

	------------------------------------------------
	-- Hold Sound
	------------------------------------------------
	task.wait(2)

	Play(A.SOUNDS.MUSIC,0.6)
	------------------------------------------------
	-- Chronals
	------------------------------------------------
	local Page = RunChronals(A)

	task.wait(0.1)

	Play(A.SOUNDS.PAGE,1)

	task.wait(1)

	if Page then
		PageGlitch(A,Page)

		local OriginalColors = {}

		for _,Img in ipairs(A.Chronals:GetChildren()) do
			if Img:IsA("ImageLabel") then

				OriginalColors[Img] = Img.ImageColor3

				Img.ZIndex = 25
				Img.ImageColor3 = Color3.fromRGB(0,255,183)
			end
		end

		A.BlackScreen1.BackgroundColor3 = Color3.fromRGB(255,255,255)

		task.delay(1,function()

			for Img,Color in pairs(OriginalColors) do

				if Img ~= Page and Img.Parent then
					Img.ImageColor3 = Color
				end

			end

			Tween(
				A.BlackScreen1,
				1,
				{
					BackgroundColor3 = Color3.fromRGB(0,0,0)
				}
			)

		end)

		for I = 1,10 do

			local B = HexFrame:FindFirstChild(
				"HexBar"..I
			)

			if B then

				if B:IsA("ImageLabel") then

					Tween(B,0.1,{
						ImageTransparency = 1
					})

				else

					Tween(B,0.1,{
						BackgroundTransparency = 1
					})

				end
			end
		end

		task.wait(0.1)

		Page.Visible = false

		if A.Inversion then
			A.Inversion.BackgroundColor3 = Color3.fromRGB(0,0,0)
			A.Inversion.Visible = false
		end

		for _,Img in ipairs(A.Chronals:GetChildren()) do
			if Img:IsA("ImageLabel") then
				Img.ImageColor3 = Color3.fromRGB(255,255,255)
			end
		end

	end

	------------------------------------------------
	-- Indicator
	------------------------------------------------

	task.wait(3)
	Play(A.SOUNDS.INDICATOR)

	task.wait(0.7)

	local Surface = A.SurfaceClient

	if Surface then

		Surface.Visible = true
		Surface.ImageTransparency = 1

		local Grad = Surface:FindFirstChildOfClass("UIGradient")

		if Grad then

			Grad.Offset = Vector2.new(-1,0)

			Tween(Surface,0.7,{
				ImageTransparency = 0
			})

			TweenService:Create(
				Grad,
				TweenInfo.new(
					1.5,
					Enum.EasingStyle.Linear
				),
				{
					Offset = Vector2.new(1,0)
				}
			):Play()
		end
	end

	task.delay(0.2,function()

		Tween(
			A.BlackScreen1,
			0.7,
			{
				BackgroundColor3 =
					Color3.fromRGB(9,9,9)
			}
		)

	end)
	------------------------------------------------
	-- Bracket Sequence
	------------------------------------------------
	local ClosedL = UDim2.new(0.459,0,0.378,0)
	local ClosedR = UDim2.new(0.474,0,0.378,0)

	local OpenL = UDim2.new(0.242,0,0.378,0)
	local OpenR = UDim2.new(0.682,0,0.378,0)

	task.wait(0.7)

	A.LeftBracket.Position = ClosedL
	A.RightBracket.Position = ClosedR

	Flick({A.LeftBracket,A.RightBracket},2,A.SOUNDS.FLICK)

	task.wait(1)

	local Ghosts = {

		A.LeftBracketAfterImage,
		A.LeftBracketAfterImageCopy,

		A.RightBracketAfterImage,
		A.RightBracketAfterImageCopy
	}

	for _,G in ipairs(Ghosts) do

		G.Visible = true
		G.ImageTransparency = 1
	end

	Play(A.SOUNDS.SLIDE)

	for _,G in ipairs(Ghosts) do

		Tween(
			G,
			0.01,
			{
				ImageTransparency = 0
			}
		)
	end

	task.delay(0.005,function()

		for _,G in ipairs(Ghosts) do

			Tween(
				G,
				0.05,
				{
					ImageTransparency = 1
				}
			)
		end
	end)

	Tween(A.LeftBracket,0.1,{Position=OpenL})
	Tween(A.RightBracket,0.1,{Position=OpenR}).Completed:Wait()

	------------------------------------------------
	-- STEREOTYPE + Lens
	------------------------------------------------

	task.wait(.5)

	Flick({A.StereotypeText},2,A.SOUNDS.FLICK)

	Set(A.Lens,true)

	task.wait(.7)

	Play(A.SOUNDS.ROTATE)
	Tween(A.Lens,0.9,{Rotation=-70}).Completed:Wait()
	Tween(A.Lens,0.8,{Rotation=120}).Completed:Wait()

	task.wait(3)

	Flick({A.StereotypeText,A.Lens},2,A.SOUNDS.FLICK)

	task.wait(.5)

	Set(A.StereotypeText,false)
	Set(A.Lens,false)


	------------------------------------------------
	-- Close Brackets + Fade Out
	------------------------------------------------

	task.wait(.1)

	Tween(
		A.BlackScreen1,
		.7,
		{
			BackgroundColor3 =
				Color3.fromRGB(0,0,0)
		}
	)

	Tween(
		A.SurfaceClient,
		.4,
		{
			ImageTransparency = 1
		}
	)

	Play(A.SOUNDS.SLIDE)

	if A.SurfaceClient then
		Tween(
			A.SurfaceClient,
			.4,
			{
				ImageTransparency = 1
			}
		)
	end

	Tween(A.LeftBracket,.2,{Position=ClosedL})
	Tween(A.RightBracket,.2,{Position=ClosedR}).Completed:Wait()

	Set(A.LeftBracket,false)
	Set(A.RightBracket,false)
	if A.SurfaceClient then
		A.SurfaceClient.Visible = false
	end

	task.wait(.5)

	print("Sequence 2 Finished")
	print("Starting Sequence 3")

	SequenceManipulator.StartTerminal(A)

end



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
