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
