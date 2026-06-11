local Ultils = {}
local TS = game:GetService("TweenService")
local cam:Camera = workspace.CurrentCamera

-- Config
local TOP_TILT_NORMAL_LEFT = UDim2.new(-0.672, 0, -0.157, 0)
local BOTTOM_TILT_NORMAL_LEFT = UDim2.new(-1.325, 0, 0.646, 0)

local Left_TILT_ANGLE = 35
local Right_TILT_ANGLE = -35


local Tilt_TOP_HIDDEN_RIGHT = UDim2.new(-1.325, 0, -2, 0)
local Tilt_BOTTOM_HIDDEN_RIGHT = UDim2.new(-1.325, 0, 2, 0)

local TOP_TILT_NORMAL_RIGHT = UDim2.new(-0.954, 0, -0.671, 0)
local BOTTOM_TILT_NORMAL_RIGHT = UDim2.new(-0.992, 0, 1.058, 0)

local TOP_HIDDEN = UDim2.new(-0.001, 0, -0.4, 0)
local BOTTOM_HIDDEN = UDim2.new(-0.034, 0, 1.1, 0)

local Tilt_TOP_HIDDEN_LEFT = UDim2.new(-1.325, 0, -2, 0)
local Tilt_BOTTOM_HIDDEN_LEFT = UDim2.new(-1.325, 0, 2, 0)


local tweenSlide = TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)


local Type = require(script.Parent.Types)

local function WallJumpBars(side,MovementObj:Type.MovementObj)
    local hum = MovementObj.char.Humanoid
    if not MovementObj or not MovementObj.UI or not hum then return end
    local UItable  = MovementObj.UI
    local Top_tilt = UItable.top_tilt
    local Bottom_tilt = UItable.bottom_tilt
    local TOP = UDim2.new(-0.001, 0, -0.987, 0)
    local BOTTOM = UDim2.new(-0.034, 0, 0.95, 0)

    local FOVChange: Tween = TS:Create(cam, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { FieldOfView = 280 })
	FOVChange:Play()
	local camreturn = Vector3.new(0, 0, 0)
	TS:Create(hum, TweenInfo.new(0.40, Enum.EasingStyle.Back, Enum.EasingDirection.Out,0,false,0), { CameraOffset = camreturn })
		:Play()
	local top: Tween = TS:Create(Top_tilt, tweenSlide, { Position = TOP, Rotation = 0 })
	print(FOVChange)
	local bottom: Tween = TS:Create(Bottom_tilt, tweenSlide, { Position = BOTTOM, Rotation = 0 })
	top:Play()
	bottom:Play()
	FOVChange.Completed:Connect(function()
		TS:Create(
			cam,
			TweenInfo.new(0.50, Enum.EasingStyle.Back, Enum.EasingDirection.Out,0,false,0),
			{ FieldOfView = 70 }
		):Play()
	end)

	top.Completed:Connect(function()
		local finalbarTween: Tween = TS:Create(Top_tilt, tweenSlide, { Position = TOP_HIDDEN, Rotation = 0 })
		finalbarTween:Play()
		TS:Create(Bottom_tilt, tweenSlide, { Position = BOTTOM_HIDDEN, Rotation = 0 }):Play()
		finalbarTween.Completed:Connect(function()
			Top_tilt.Position = Tilt_TOP_HIDDEN_LEFT
			Bottom_tilt.Position = Tilt_BOTTOM_HIDDEN_LEFT
		end)
	end)    
end













function Ultils.StartWallrunBars(side: number, MovementObj:Type.MovementObj)
    local hum = MovementObj.char.Humanoid
    if not MovementObj or not MovementObj.UI or not hum then return end
    local UItable  = MovementObj.UI
    local Top_tilt = UItable.top_tilt
    local Bottom_tilt = UItable.bottom_tilt
    TS:Create(cam, TweenInfo.new(5,Enum.EasingStyle.Back,Enum.EasingDirection.Out), {FieldOfView = 250 }):Play()
    if side == 1 then
        TS:Create(Top_tilt, tweenSlide, { Position = TOP_TILT_NORMAL_RIGHT, Rotation = Right_TILT_ANGLE }):Play()
		TS:Create(Bottom_tilt, tweenSlide, { Position = BOTTOM_TILT_NORMAL_RIGHT, Rotation = Right_TILT_ANGLE }):Play()
        elseif side == -1 then
            TS:Create(Top_tilt, tweenSlide, { Position = TOP_TILT_NORMAL_LEFT, Rotation = Left_TILT_ANGLE }):Play()
		TS:Create(Bottom_tilt, tweenSlide, { Position = BOTTOM_TILT_NORMAL_LEFT, Rotation = Left_TILT_ANGLE }):Play()
    end    
end

function Ultils.StopWallrunBars(side:number, MovementObj:Type.MovementObj, action)

    local hum = MovementObj.char.Humanoid
    if not MovementObj or not MovementObj.UI or not hum then return end
    local UItable  = MovementObj.UI
    local Top_tilt = UItable.top_tilt
    local Bottom_tilt = UItable.bottom_tilt


    if not action then 
        action = "Stop"
    end

    if action == "Stop" then
        local camreturn = Vector3.new(0,0,0)
        TS:Create(hum, TweenInfo.new(0.35,Enum.EasingStyle.Back,Enum.EasingDirection.Out), {CameraOffset = camreturn}):Play()
        TS:Create(cam, TweenInfo.new(0.6,Enum.EasingStyle.Back,Enum.EasingDirection.Out), {FieldOfView = 70 }):Play()

        if side == 1 then
            TS:Create(Top_tilt, tweenSlide, { Position = Tilt_TOP_HIDDEN_RIGHT, Rotation = 15 }):Play()
			TS:Create(Bottom_tilt, tweenSlide, { Position = Tilt_BOTTOM_HIDDEN_RIGHT, Rotation = 15 }):Play()
		elseif side == -1 then
            TS:Create(Top_tilt, tweenSlide, { Position = Tilt_TOP_HIDDEN_LEFT, Rotation = -15 }):Play()
			TS:Create(Bottom_tilt, tweenSlide, { Position = Tilt_BOTTOM_HIDDEN_LEFT, Rotation = -15 }):Play()
		end


    elseif action == "Jump" then
        WallJumpBars(side, MovementObj)
    end
end












return Ultils