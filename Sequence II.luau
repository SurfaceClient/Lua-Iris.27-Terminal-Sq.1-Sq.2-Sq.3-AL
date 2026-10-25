-- This takes place right after Seq 1

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


