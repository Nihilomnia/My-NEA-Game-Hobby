local Cast = {}

local Debris = game:GetService("Debris")

export type CastParams = {
	Origin : BasePart | Vector3,
	Direction : Vector3,
	Range : number?,
	Offset : Vector3?,
	FilterType : Enum.RaycastFilterType?,
	FilterList : {Instance}?,
	Visualize:boolean?
}


function Cast.Ray(data:CastParams) : RaycastResult?
	if not data then return end 
	if not data.Origin then return end 
	if not data.Direction then return end 
	
	local range = data.Range or 10
	local offset = data.Offset or Vector3.zero
	
	local originPos
	
	if typeof(data.Origin) == "Instance" then
		local part = data.Origin :: BasePart
		originPos = (part.CFrame + offset).Position -- Vectorize the Origins Position Using the cframe
	else
		originPos = data.Origin + offset
	end
	
	local directionVector = data.Direction.Unit * range -- Unit Vectorize the direction and give it a range 
	
	local params = RaycastParams.new()
	params.FilterType = data.FilterType or Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = data.FilterList or {}
	
	local result = workspace:Raycast(originPos,directionVector,params)
	
	if data.Visualize then
		local RayVisual = Instance.new("Part")
		RayVisual.Anchored = true
		RayVisual.CanCollide = false
		RayVisual.Size = Vector3.new(0.1,0.1,range)
		visual.CFrame = CFrame.new(originPos, originPos + directionVector)
		* CFrame.new(0, 0, -range / 2) -- Midpoint
		
		RayVisual.Material = Enum.Material.Neon
		RayVisual.Color = Color3.fromRGB(255, 0, 0)
		RayVisual.Parent = workspace
		Debris:AddItem(RayVisual,0.1)
	end
	
	if result then
		return {
			Instance = result.Instance,
			Position = result.Position,
			Normal = result.Normal,
			Distance = result.Distance
		}
	end
	
	return nil
end

-- Ex: Direction = Cast.FromPart(HRP, "Right")
-- ^^ Still Vector Based Because we return a vector!

function Cast.FromPart(part: BasePart, axis: "Forward" | "Backward" | "Left" | "Right" | "Up" | "Down")
	if axis == "Forward" then
		return part.CFrame.LookVector
	elseif axis == "Backward" then
		return -part.CFrame.LookVector
	elseif axis == "Left" then
		return -part.CFrame.RightVector
	elseif axis == "Right" then
		return part.CFrame.RightVector
	elseif axis == "Up" then
		return part.CFrame.UpVector
	elseif axis == "Down" then
		return -part.CFrame.UpVector
	else
		error("Invalid axis. Use 'Forward', 'Backward', 'Left', 'Right', 'Up', or 'Down'.")
	end
end

return Cast