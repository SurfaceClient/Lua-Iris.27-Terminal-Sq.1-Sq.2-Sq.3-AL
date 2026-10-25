-- This takes place right after Seq 1

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
