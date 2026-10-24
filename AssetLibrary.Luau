-- You Have to use your own sound IDs. for ALL THE IMAGES, same thing applies with imagelabels.


local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SequenceManipulator =
	require(
		ReplicatedStorage.Modules.SequenceManipulator
	)

local gui = script.Parent
local canvas = gui:WaitForChild("PrimaryCanvas")
local loading = canvas:WaitForChild("LoadingSequence")


local assets = {

	loadingSequence = loading,

	BlackScreen1 = loading:WaitForChild("BlackScreen1"),
	PurpleLED = loading:WaitForChild("PurpleLED"),

	Terminal = loading:WaitForChild("Terminal"),

	TEXTS = loading:WaitForChild("TEXTS"),

	LoadingSequence = loading,

	LED = loading:WaitForChild("LED"),

	FadeOut = loading:WaitForChild("FadeOut"),
	ScanLinesA = loading:WaitForChild("ScanLinesA"),
	ScanLinesB = loading:WaitForChild("ScanLinesB"),
	ScanLineGradient = loading:WaitForChild("ScanLineGradient"),

	TerminalTheme = loading:WaitForChild("Terminal"):WaitForChild("TerminalTheme"),

	Chronals = loading:WaitForChild("Chronals"),

	Undo = loading.Chronals:WaitForChild("Undo"),
	Gate = loading.Chronals:WaitForChild("Gate"),
	Cast = loading.Chronals:WaitForChild("Cast"),
	Hint = loading.Chronals:WaitForChild("Hint"),
	Cell = loading.Chronals:WaitForChild("Cell"),
	Dirt = loading.Chronals:WaitForChild("Dirt"),
	Sand = loading.Chronals:WaitForChild("Sand"),
	Tear = loading.Chronals:WaitForChild("Tear"),
	Zero = loading.Chronals:WaitForChild("Zero"),
	Rush = loading.Chronals:WaitForChild("Rush"),
	Zion = loading.Chronals:WaitForChild("Zion"),
	Swap = loading.Chronals:WaitForChild("Swap"),
	Word = loading.Chronals:WaitForChild("Word"),
	Jump = loading.Chronals:WaitForChild("Jump"),
	Page = loading.Chronals:WaitForChild("Page"),


	LeftBracket = loading:WaitForChild("LeftBracket"),
	RightBracket = loading:WaitForChild("RightBracket"),

	LeftBracketAfterImage =
		loading:WaitForChild("LeftBracketAfterImage"),

	LeftBracketAfterImageCopy =
		loading:WaitForChild("LeftBracketAfterImageCopy"),

	RightBracketAfterImage =
		loading:WaitForChild("RightBracketAfterImage"),

	RightBracketAfterImageCopy =
		loading:WaitForChild("RightBracketAfterImageCopy"),

	StereotypeText =
		loading:WaitForChild("StereotypeText"),

	HexaColors = loading:WaitForChild("HexaColors"),

	SurfaceClient = loading:WaitForChild("SurfaceClient"),

	HexBars = {
		loading.HexaColors:WaitForChild("HexBar1"),
		loading.HexaColors:WaitForChild("HexBar2"),
		loading.HexaColors:WaitForChild("HexBar3"),
		loading.HexaColors:WaitForChild("HexBar4"),
		loading.HexaColors:WaitForChild("HexBar5"),
		loading.HexaColors:WaitForChild("HexBar6"),
		loading.HexaColors:WaitForChild("HexBar7"),
		loading.HexaColors:WaitForChild("HexBar8"),
		loading.HexaColors:WaitForChild("HexBar9"),
		loading.HexaColors:WaitForChild("HexBar10"),
	},

	Lens =
		loading:WaitForChild("Lens"),

	SOUNDS = {

		FLICK = "rbxassetid://x",
		
		SLIDE = "rbxassetid://x",
		
		ROTATE = "rbxassetid://x",

		INDICATOR = "rbxassetid://x",

		CHRONAL = "rbxassetid://x",

		PAGE = "rbxassetid://x",

		PAGEGLITCH = "rbxassetid://x",

		MUSIC = "rbxassetid://x",

		INFO_CORRECT = "rbxassetid://x",

		INFO_INVALID = "rbxassetid://x",

		INFO_TICK = "rbxassetid://x",

		JITTER = "rbxassetid://x" 

	}
}


SequenceManipulator.Start(assets)
