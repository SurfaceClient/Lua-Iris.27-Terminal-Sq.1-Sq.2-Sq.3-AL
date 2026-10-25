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

local function play(id, volume)
	if not id or id == "" then return end

	local s = Instance.new("Sound")
	s.SoundId = Id
	s.Volume = volume or 1.7
	s.Parent = SoundService

	s:Play()
	Debris:AddItem(s, 8)
	return s
end

----------------------------------------------------
-- Ui Helpers
----------------------------------------------------

local function set(obj, v)
	if obj and obj:IsA("GuiObject") then
		obj.Visible = v
	end
end

local function tween(obj, t, props)
	if not obj then return end

	local tw = TweenService:Create(
		obj,
		TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		props
	)

	tw:Play()
	return tw
end


local ContentProvider = game:GetService("ContentProvider")

local LoadedSounds = {}

local function preloadSounds(soundTable)

	local assets = {}

	for name,id in pairs(soundTable) do

		if typeof(id) == "string" and id ~= "" then

			local s = Instance.new("Sound")

			s.Name = name
			s.SoundId = id
			s.Volume = 1
			s.Parent = SoundService

			LoadedSounds[name] = s
			table.insert(assets,s)
		end
	end

	ContentProvider:PreloadAsync(assets)
end

local function playCached(name, volume)

	local source = LoadedSounds[name]

	if not source then
		return
	end

	local clone = source:Clone()

	clone.Volume = volume or 1
	clone.Parent = SoundService

	clone:Play()

	Debris:AddItem(clone,8)

	return clone
end
----------------------------------------------------
-- HexBar System
----------------------------------------------------

local HEX_MAP = {
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

local HEX_COLOR = {
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

local function resetHex(hexFrame)
	if not hexFrame then return end
	for i = 1,10 do
		local b = hexFrame:FindFirstChild("HexBar"..i)
		if b then
			b.Visible = false
		end
	end
end

local function applyHex(hexFrame, chronalName, fadeInTime)

	if not hexFrame then
		return
	end

	resetHex(hexFrame)

	local map = HEX_MAP[chronalName]
	local col = HEX_COLOR[chronalName]

	if not map then
		return
	end

	for _,i in ipairs(map) do

		local b = hexFrame:FindFirstChild("HexBar"..i)

		if b then

			b.Visible = true
			b.ZIndex = 20
			
			if b:IsA("ImageLabel") then

				b.ImageTransparency = 1
				b.ImageColor3 = col

				tween(b, fadeInTime,{
					ImageTransparency = 0
				})

			else

				b.BackgroundTransparency = 1
				b.BackgroundColor3 = col

				tween(b, fadeInTime,{
					BackgroundTransparency = 0
				})

			end
		end
	end
end

----------------------------------------------------
--  Sync Flicker (for Brackets, Stereotype, Lens)
----------------------------------------------------

local function flick(objects, count, soundId)
	for i = 1, count do

		for _,o in ipairs(objects) do
			set(o,true)
		end

		play(soundId,1)
		task.wait(0.033)

		for _,o in ipairs(objects) do
			set(o,false)
		end

		task.wait(0.033)
	end

	for _,o in ipairs(objects) do
		set(o,true)
	end

	play(soundId,1)
end

----------------------------------------------------
-- Chronals (UPDATED. Fixed Visibility and Timing)
----------------------------------------------------

local function runChronals(A)
	local order = {
		"Undo","Gate","Cast","Hint","Cell",
		"Dirt","Sand","Tear","Zero","Rush",
		"Zion","Swap","Word","Jump","Page"
	}

	local timings = {
		{0.15,0.6},{0.15,0.45},{0.15,0.3},{0.15,0.1},{0.15,0.09},
		{0.15,0.08},{0.15,0.07},{0.15,0.06},{0.15,0.05},{0.1,0.04},
		{0.1,0.04},{0.1,0.04},{0.08,0.03},{0.08,0.03},{0.08,0.03}
	}

	local hexFrame = A.HexaColors

	for i,name in ipairs(order) do
		local obj = A.Chronals:FindFirstChild(name)
		if obj then

			obj.Visible = true
			obj.ImageTransparency = 1
			
			applyHex(
				hexFrame,
				name,
				timings[i][1]
			)

			play(A.SOUND.CHRONAL,0.2)
			play(A.SOUNDS.CHRONAL,0.7)
			play(A.SOUND.CHRONAL,0.3)

			tween(obj,timings[i][1],{ImageTransparency = 0}).Completed:Wait()

			if name == "Page" then

				for _,img in ipairs(A.Chronals:GetChildren()) do
					if img:IsA("ImageLabel") then
						img.ImageColor3 = Color3.fromRGB(0,255,183)
						img.ZIndex = 25
					end
				end

				A.BlackScreen1.BackgroundColor3 =
					Color3.fromRGB(255,255,255)

				task.delay(1,function()

					tween(
						A.BlackScreen1,
						1,{
							BackgroundColor3 =
								Color3.fromRGB(0,0,0)
						}
					)

				end)

				return obj
			end
			
			local map = HEX_MAP[name]

			if map then

				for _,id in ipairs(map) do

					local b = hexFrame:FindFirstChild(
						"HexBar"..id
					)

					if b then

						if b:IsA("ImageLabel") then

							tween(
								b,
								timings[i][2],{
									ImageTransparency = 1
								})

						else

							tween(
								b,
								timings[i][2],{
									BackgroundTransparency = 1
								})

						end
					end
				end
			end
			
			tween(obj,timings[i][2],{ImageTransparency = 1}).Completed:Wait()
			obj.Visible = false
		end
	end
end

----------------------------------------------------
-- Page Glitch
----------------------------------------------------
local function pageGlitch(A,page)

	if not page then
		return
	end
	
	
	local p0 = UDim2.new(0.47,0,0.424,0)
	local p1 = UDim2.new(0.60,0,0.424,0)
	local p2 = UDim2.new(0.34,0,0.424,0)
	local p3 = UDim2.new(0.62,0,0.424,0)
	local p4 = UDim2.new(0.33,0,0.424,0)
	
	page.Position = p0
	
	task.wait(0.8)
	
	play(A.SOUNDS.PAGEGLITCH,1)
	
	tween(page,0.06,{Position=p1}).Completed:Wait()
	tween(page,0.06,{Position=p2}).Completed:Wait()
	tween(page,0.06,{Position=p3}).Completed:Wait()
	tween(page,0.06,{Position=p4}).Completed:Wait()

	task.wait(0.03)
end
----------------------------------------------------
-- Main
----------------------------------------------------

function SequenceManipulator.Start(A)
preloadSounds(A.SOUNDS)
	------------------------------------------------
	-- RESET STATE (Do not Change any of the settings unless you know what you're doing)
	------------------------------------------------

	set(A.BlackScreen1,true)
	set(A.PurpleLED,false)

	set(A.StereotypeText,false)
	set(A.Lens,false)

	set(A.LeftBracket,false)
	set(A.RightBracket,false)

	local hexFrame = A.HexaColors
	if hexFrame then resetHex(hexFrame) end

	------------------------------------------------
	-- Hold Sound
	------------------------------------------------
	task.wait(2)

	play(A.SOUNDS.MUSIC,0.6)
	------------------------------------------------
	-- Chronals
	------------------------------------------------
	local page = runChronals(A)

	task.wait(0.1)

	play(A.SOUNDS.PAGE,1)
	
	task.wait(1)
	
	if page then
		pageGlitch(A,page)
		
		local originalColors = {}

		for _,img in ipairs(A.Chronals:GetChildren()) do
			if img:IsA("ImageLabel") then

				originalColors[img] = img.ImageColor3

				img.ZIndex = 25
				img.ImageColor3 = Color3.fromRGB(0,255,183)
			end
		end

		A.BlackScreen1.BackgroundColor3 = Color3.fromRGB(255,255,255)
		
		task.delay(1,function()

			for img,color in pairs(originalColors) do

				if img ~= page and img.Parent then
					img.ImageColor3 = color
				end

			end

			tween(
				A.BlackScreen1,
				1,
				{
					BackgroundColor3 = Color3.fromRGB(0,0,0)
				}
			)

		end)
		
		for i = 1,10 do

			local b = hexFrame:FindFirstChild(
				"HexBar"..i
			)

			if b then

				if b:IsA("ImageLabel") then

					tween(b,0.1,{
						ImageTransparency = 1
					})

				else

					tween(b,0.1,{
						BackgroundTransparency = 1
					})

				end
			end
		end
		
		task.wait(0.1)
		
		page.Visible = false
		
		if A.Inversion then
			A.Inversion.BackgroundColor3 = Color3.fromRGB(0,0,0)
			A.Inversion.Visible = false
		end

		for _,img in ipairs(A.Chronals:GetChildren()) do
			if img:IsA("ImageLabel") then
				img.ImageColor3 = Color3.fromRGB(255,255,255)
			end
		end
		
	end

	------------------------------------------------
	-- Indicator
	------------------------------------------------
	
	task.wait(3)
	play(A.SOUNDS.INDICATOR)
	
	task.wait(0.7)
	
	local surface = A.SurfaceClient

	if surface then

		surface.Visible = true
		surface.ImageTransparency = 1

		local grad = surface:FindFirstChildOfClass("UIGradient")

		if grad then

			grad.Offset = Vector2.new(-1,0)

			tween(surface,0.7,{
				ImageTransparency = 0
			})

			TweenService:Create(
				grad,
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

		tween(
			A.BlackScreen1,
			0.7,
			{
				BackgroundColor3 =
					Color3.fromRGB(9,9,9)
			}
		)

	end
	------------------------------------------------
	-- Bracket Sequence
	------------------------------------------------
	local closedL = UDim2.new(0.459,0,0.378,0)
	local closedR = UDim2.new(0.474,0,0.378,0)

	local openL = UDim2.new(0.242,0,0.378,0)
	local openR = UDim2.new(0.682,0,0.378,0)
	
	task.wait(0.7)
	
	A.LeftBracket.Position = closedL
	A.RightBracket.Position = closedR

	flick({A.LeftBracket,A.RightBracket},2,A.SOUNDS.FLICK)

	task.wait(1)
	
	local ghosts = {

		A.LeftBracketAfterImage,
		A.LeftBracketAfterImageCopy,

		A.RightBracketAfterImage,
		A.RightBracketAfterImageCopy
	}

	for _,g in ipairs(ghosts) do

		g.Visible = true
		g.ImageTransparency = 1
	end
	
	play(A.SOUNDS.SLIDE)
	
	for _,g in ipairs(ghosts) do

		tween(
			g,
			0.01,
			{
				ImageTransparency = 0
			}
		)
	end

	task.delay(0.005,function()

		for _,g in ipairs(ghosts) do

			tween(
				g,
				0.05,
				{
					ImageTransparency = 1
				}
			)
		end
	end)
	
	tween(A.LeftBracket,0.1,{Position=openL})
	tween(A.RightBracket,0.1,{Position=openR}).Completed:Wait()

	------------------------------------------------
	-- STEREOTYPE + Lens
	------------------------------------------------

	task.wait(.5)

	flick({A.StereotypeText},2,A.SOUNDS.FLICK)

	set(A.Lens,true)

	task.wait(.7)

	play(A.SOUNDS.ROTATE)
	tween(A.Lens,0.9,{Rotation=-70}).Completed:Wait()
	tween(A.Lens,0.8,{Rotation=120}).Completed:Wait()
	
	task.wait(3)

	flick({A.StereotypeText,A.Lens},2,A.SOUNDS.FLICK)

	task.wait(.5)

	set(A.StereotypeText,false)
	set(A.Lens,false)
	
	
	------------------------------------------------
	-- Close Brackets + Fade Out
	------------------------------------------------

	task.wait(.1)
	
	tween(
		A.BlackScreen1,
		.7,
		{
			BackgroundColor3 =
				Color3.fromRGB(0,0,0)
		}
	)

	tween(
		A.SurfaceClient,
		.4,
		{
			ImageTransparency = 1
		}
	)
	
	play(A.SOUNDS.SLIDE)
	
	if A.SurfaceClient then
		tween(
			A.SurfaceClient,
			.4,
			{
				ImageTransparency = 1
			}
		)
	end
	
	tween(A.LeftBracket,.2,{Position=closedL})
	tween(A.RightBracket,.2,{Position=closedR}).Completed:Wait()

	set(A.LeftBracket,false)
	set(A.RightBracket,false)
	if A.SurfaceClient then
		A.SurfaceClient.Visible = false
	end
	
	task.wait(.5)

	print("Sequence 2 Finished")
	print("Starting Sequence 3")

	SequenceManipulator.StartTerminal(A)
	
end


floor.math  
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
