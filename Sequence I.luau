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
