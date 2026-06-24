local Goodsignal = require(script.Parent.GoodSignal)

local types = {}

export type HitboxProperties = {
	Visualizer: boolean,
	DetectionMode: ("Default" | "ConstantDetection" | "HitOnce" | "HitParts"),
	AutoDestroy: boolean,	
	Key: string,

	OverlapParams: OverlapParams,

	Size: Vector3,
	Shape: Enum.PartType,
	CFrame: CFrame,
	Offset: CFrame,

	VelocityPredictionTime: number?,
	VelocityPrediction: boolean?,

	Touched: Goodsignal.Signal<BasePart, Humanoid?>,
	TouchEnded: Goodsignal.Signal<BasePart, Humanoid?>,
} & any

export type Hitbox = {
	-- properties
	Visualizer: boolean,
	VisualizerColor: Color3?,
	VisualizerTransparency: number,

	DetectionMode: ("Default" | "ConstantDetection" | "HitOnce" | "HitParts"),
	AutoDestroy: boolean,	
	Key: string,

	OverlapParams: OverlapParams,

	Size: Vector3,
	Shape: Enum.PartType,
	CFrame: CFrame,
	Offset: CFrame,

	VelocityPredictionTime: number?,
	VelocityPrediction: boolean?,

	-- events
	Touched: Goodsignal.Signal<BasePart, Humanoid?>,
	TouchEnded: Goodsignal.Signal<BasePart, Humanoid?>,

	-- methods
	Start: (self: Hitbox) -> (),
	Stop: (self: Hitbox) -> (),
	Destroy: (self: Hitbox) -> (boolean),

	-- dev
	HitList: {[Humanoid]: boolean}?,
	TouchingParts: {[BasePart]: boolean}?,
	Connection: RBXScriptConnection?,
	Box: BoxHandleAdornment? | SphereHandleAdornment?,
} & any

return types