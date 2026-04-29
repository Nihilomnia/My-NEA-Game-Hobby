local Data = {}

--



export type DataSet = {
	--// General
	WalkSpeed: number,
	JumpPower: number,
	MaxTilt: number,
	DoubleJumps: number,

	--// Stamina


	--// FOV
	BaseFov: number,
	SprintFov: number,

	--// Sprint
	SprintSpeed: number,
	SprintJumpPower: number,

	--// Dash
	DashDuration: number,
	DashSpeed: number,
	SideDashCooldown: number,
	BackDashCooldown: number,
	FrontDashCooldown: number,
	SideDashDuration: number,
	FrontDashDuration: number,
	BackDashDuration: number,
	SideDashSpeed: number,
	FrontDashSpeed: number,
	BackDashSpeed: number,

	--// Vault
	VaultBoost: number,
	VaultDuration: number,

	--// Slide
	SlideDuration: number,
	SlideSpeed: number,
	SlideCooldown: number,
	SlideCancelSpeed: number,
	SlideCancelDuration: number,

	--// Crouch
	CrouchSpeed: number,
	CrouchCooldown: number,
	CrouchHipHeight: number,

	--// Crawl
	CrawlSpeed: number,
	CrawlCooldown: number,
	CrawlHipHeight: number,

	--// Climb
	ClimbSpeed: number,
	ClimbStaminaDrain: number,
	ClimbStaminaRegen: number,
	ClimbDetectionRange: number,

	--// Wall Run
	WallRunSpeed: number,
	WallRunDuration: number,

	--// Wall Hold
	WallHoldDuration: number,
	UpBoost: number,
	BackBoost: number,

	--// Swing
	DetectSwingRange: number,
	SwingDuration: number,
	SwingCooldown: number,
	SwingForwardBoost: number,
	SwingUpBoost: number,
}

  
 local DataTable : DataSet = {
		--// General
		WalkSpeed = 22,
		JumpPower = 50,
		MaxTilt = 15,
		DoubleJumps = 1,

		--// Fov
		BaseFov = 80,
		SprintFov = 90,

		--// Sprint
		SprintSpeed = 40,
		SprintJumpPower = 45,

		--// Dash
		DashDuration = 1.25,
		DashSpeed = 80,
		SideDashCooldown = 1,
		BackDashCooldown = 1.25,
		FrontDashCooldown = 1.25,
		SideDashDuration = 0.245,
		FrontDashDuration = 0.45,
		BackDashDuration = 0.425,
		SideDashSpeed = 80,
		FrontDashSpeed = 80,
		BackDashSpeed = 60,

		--// Vault
		VaultBoost = 1.5, -- This is strong. Higher the number the more forward force
		VaultDuration = 0.2,

		--// Slide
		SlideDuration = 0.8,
		SlideSpeed = 80,
		SlideCooldown = 0.5,
		SlideCancelSpeed = 45,
		SlideCancelDuration = 0.3,
		
		--// Crouch
		CrouchSpeed = 10,
		CrouchCooldown = 0.5,
		CrouchHipHeight = 0.5, -- We are subtracting from this
		
		--// Crawl
		CrawlSpeed = 5,
		CrawlCooldown = 0.5,
		CrawlHipHeight = 0.25,

		--// Climb
		ClimbSpeed = 20,
		ClimbStaminaDrain = 1,
		ClimbStaminaRegen = 1,
		ClimbDetectionRange = 2,

		--// Wall Run
		WallRunSpeed = 50,
		WallRunDuration = 20,
		
		--// Wall Hold
		WallHoldDuration = 2.5,
		UpBoost = 60,
		BackBoost = 20,


		--// Swing
		DetectSwingRange = 5,
		SwingDuration = 0.25,
		SwingCooldown = 0.4,
		SwingForwardBoost = 80,
		SwingUpBoost = 65,
	}

Data.Data = DataTable

--




--

return Data