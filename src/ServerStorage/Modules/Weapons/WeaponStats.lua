local module = {}
local info ={
	["Fists"]={
		Damage = 5,
		Scaling = 5,
		BlockDmg = 6.6,
		Knockback =4,
		RagdollTime =1.2,
		SwingReset =0.3,
		StunTime = 1,
		BlockingWalkSpeed = 6,
		HitBox_Data = {
			Combo1 = {
			 HitboxSize = Vector3.new(4, 5, 8),
		     HitboxOffset = CFrame.new(0,0,-6.3),
			},

			Combo2 = {
			 HitboxSize = Vector3.new(4, 5, 8),
		     HitboxOffset = CFrame.new(0,0,-6.3),
			},

			Combo3 = {
			 HitboxSize = Vector3.new(4, 5, 8),
		     HitboxOffset = CFrame.new(0,0,-7.3),
			},

			Combo4 = {
			 HitboxSize = Vector3.new(4, 5, 6),
		     HitboxOffset = CFrame.new(0,0,-7.3),
			},
		}

	},
	
	["Fractured_Kunai"]={
		Damage = 15,
		Scaling = 7,
		BlockDmg = 6.6,
		Knockback =5,
		RagdollTime =1.2,
		SwingReset =0.25,
		StunTime = 1.5,
		BlockingWalkSpeed = 6,
		ChipDamage = 5,
		HitBox_Data = {
			Combo1 = {
			 HitboxSize = Vector3.new(4, 5, 8),
		     HitboxOffset = CFrame.new(0,0,-6.3),
			},

			Combo2 = {
			 HitboxSize = Vector3.new(4, 5, 8),
		     HitboxOffset = CFrame.new(0,0,-6.3),
			},

			Combo3 = {
			 HitboxSize = Vector3.new(4, 5, 8),
		     HitboxOffset = CFrame.new(0,0,-7.3),
			},

			Combo4 = {
			 HitboxSize = Vector3.new(4, 5, 6),
		     HitboxOffset = CFrame.new(0,0,-7.3),
			},
		}
		
	},
	 
	["Katana"]={
		Damage = 10,
		Scaling = 7,
		BlockDmg = 10,
		Knockback =5,
		RagdollTime =1.2,
		SwingReset =.2,
		StunTime = 1.1,
		BlockingWalkSpeed = 6,
		HitBox_Data = {
			Combo1 = {
			 HitboxSize = Vector3.new(4, 5, 8),
		     HitboxOffset = CFrame.new(0,0,-6.3),
			},

			Combo2 = {
			 HitboxSize = Vector3.new(4, 5, 8),
		     HitboxOffset = CFrame.new(0,0,-6.3),
			},

			Combo3 = {
			 HitboxSize = Vector3.new(4, 5, 8),
		     HitboxOffset = CFrame.new(0,0,-7.3),
			},

			Combo4 = {
			 HitboxSize = Vector3.new(4, 5, 6),
		     HitboxOffset = CFrame.new(0,0,-7.3),
			},
		}
	},
	
	["DrakeFang"]={
		Damage = 15,
		Scaling = 9,
		BlockDmg = 12,
		Knockback =5,
		RagdollTime =1.2,
		SwingReset =.1,
		StunTime = 1.1,
		BlockingWalkSpeed = 6,
		HitBox_Data = {
			Combo1 = {
			 HitboxSize = Vector3.new(4, 5, 8),
		     HitboxOffset = CFrame.new(0,0,-6.3),
			},

			Combo2 = {
			 HitboxSize = Vector3.new(4, 5, 8),
		     HitboxOffset = CFrame.new(0,0,-6.3),
			},

			Combo3 = {
			 HitboxSize = Vector3.new(4, 5, 8),
		     HitboxOffset = CFrame.new(0,0,-7.3),
			},

			Combo4 = {
			 HitboxSize = Vector3.new(4, 5, 6),
		     HitboxOffset = CFrame.new(0,0,-7.3),
			},
		}
	},

	["TwinSpears"]={
		Damage = 18,
		Scaling = 9,
		BlockDmg = 12,
		Knockback =5,
		RagdollTime =1.2,
		SwingReset =.1,
		StunTime = 1.1,
		BlockingWalkSpeed = 6,
		HitBox_Data = {
			Combo1 = {
			 HitboxSize = Vector3.new(4, 5, 8),
		     HitboxOffset = CFrame.new(0,0,-6.3),
			},

			Combo2 = {
			 HitboxSize = Vector3.new(4, 5, 8),
		     HitboxOffset = CFrame.new(0,0,-6.3),
			},

			Combo3 = {
			 HitboxSize = Vector3.new(4, 5, 8),
		     HitboxOffset = CFrame.new(0,0,-7.3),
			},

			Combo4 = {
			 HitboxSize = Vector3.new(4, 5, 6),
		     HitboxOffset = CFrame.new(0,0,-7.3),
			},
		}
	},

	
	["ShootingStar"]={
		Damage = 20,
		Scaling = 8,
		BlockDmg = 25,
		Knockback = 8,
		RagdollTime =1.5,	
		SwingReset = .1,
		StunTime = 1.2,
		BlockingWalkSpeed = 6,
		HitBox_Data = {
			Combo1 = {
			 HitboxSize = Vector3.new(4, 5, 8),
		     HitboxOffset = CFrame.new(0,0,-6.3),
			},

			Combo2 = {
			 HitboxSize = Vector3.new(4, 5, 8),
		     HitboxOffset = CFrame.new(0,0,-6.3),
			},

			Combo3 = {
			 HitboxSize = Vector3.new(4, 5, 8),
		     HitboxOffset = CFrame.new(0,0,-7.3),
			},

			Combo4 = {
			 HitboxSize = Vector3.new(4, 5, 6),
		     HitboxOffset = CFrame.new(0,0,-7.3),
			},
		}
	},	
	
}
function module.getStats(weapon)
	return info[weapon]
end
return module
