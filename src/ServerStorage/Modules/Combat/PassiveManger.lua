local PassiveManger = {}
local RS = game:GetService("ReplicatedStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local SSModules = SS.Modules
local Events = RS.Events
local UI_Update = Events.UI_Update
local Function = require(ReplicatedStorage.Dialogues.Dialogue_Configs.TestDialogue.TurnHeadInvisible.Function)
local HelpfulModule = require(SSModules.Other.Helpful)




-- Maths Contants
local p = 2.0 -- Soft Cap Exponent for Crit Dmg
local BaseCritDmg = 1.5 -- Base Crit Dmg Multiplier
local MaxBonus = 1.7 -- Max Crit Dmg Multiplier





function PassiveManger.M1LandedPassive(Attacker,Defender,damage,STAT_POINTS) -- This refers to when a light attack lands on char 
    --[[
    Attacker - the enemy character that landed the attack
    Defender - the character that got hit
    damage - the damage that was dealt from base sclaing
    Stats - the stats of the character that landed the attack
    --]]

    local DEX_Points = STAT_POINTS.DEX
    local AttackerElement = Attacker:GetAttribute("Element")
    local DefenderElement = Defender:GetAttribute("Element")
    local Attacker_Second_ModeCheck = Attacker:GetAttribute("Mode2")
    local Defender_Second_ModeCheck = Defender:GetAttribute("Mode2")
    local Attacker_plr = game.Players:GetPlayerFromCharacter(Attacker)
    local Defender_plr = game.Players:GetPlayerFromCharacter(Defender)
    local DamageModifiers =  10
    local TotalRes = 0.25 
    local isCrit
    local CritDmgMult = BaseCritDmg + (MaxBonus - BaseCritDmg) * (DEX_Points / 99)^p
    local Attack_Dodged  = {}
    local damageAlreadydealt  = false

    local MultipliedDamage = damage * (1 + DamageModifiers/100)
    MultipliedDamage = MultipliedDamage * (1 - TotalRes)


    
    if Attacker:GetAttribute("CritTest") then  
     isCrit = true
    else 
     isCrit = HelpfulModule.CalculateCrit(DEX_Points)
     print(isCrit)
    end
	
	if isCrit then 
		MultipliedDamage = MultipliedDamage * CritDmgMult
	end

    if DefenderElement == "Bone" then 
        print("If there was a passive for mode 1 it would be here")
        if Defender_Second_ModeCheck then
            local TargetHum = Defender.Humanoid
            local plr = game.Players:GetPlayerFromCharacter(Defender)
            local DodgeCounter = Defender:GetAttribute("Dodges")
            

            MultipliedDamage = 0
            Defender:SetAttribute("Dodges", DodgeCounter - 1)
            Defender:SetAttribute("InCombat",true)   
            TargetHum:TakeDamage(MultipliedDamage)
            Attack_Dodged[Defender] = true
            damageAlreadydealt = true
        end
    end

    if AttackerElement == "Bone" then
        print("If there was a passive for mode 1 it would be here")
        if Attacker_Second_ModeCheck and not Attack_Dodged[Defender] then
            local TargetHum = Defender.Humanoid
            local Karma = Defender:GetAttribute("Karma")
            Defender:SetAttribute("Karma",math.min(Karma + 5, 50))
            local totalDamage = 0
	        local tickRate = 3  -- Stage 1

            if Karma > 33 then
		        tickRate = 1  -- Stage 3
	        elseif Karma > 16 then
		       tickRate = 2  -- Stage 2
	        end

            local dotDamage = 3  -- Damage per tick
	        local karmaDecayRate = 2  -- Karma decreases over time

            task.spawn(function()
                while totalDamage < MultipliedDamage and Karma > 0 and TargetHum and TargetHum.Health > 0 do 
                    TargetHum:TakeDamage(dotDamage)
			        totalDamage += dotDamage

                    Karma = math.max(0, Karma - (karmaDecayRate * tickRate))

                    task.wait(tickRate)

                    if totalDamage >= MultipliedDamage or TargetHum.Health <= 0 then break end
                end
                damageAlreadydealt = true
                UI_Update:FireClient(Defender_plr, totalDamage, TargetHum.Health, TargetHum.MaxHealth, MultipliedDamage)
            end)
            

            

        end

       
    end
    
   if AttackerElement == "Astral"  then
        print("If there was a passive for mode 1 it would be here")
        if Attacker_Second_ModeCheck then
           local SPT = STAT_POINTS.SPT
           local SPT_Bonus = 1
           local SPTScalingFactor = 0.001 
           SPT_Bonus = 1 + (SPT * SPTScalingFactor)

           damage = damage * SPT_Bonus

           MultipliedDamage = damage * (1 + DamageModifiers/100)
           MultipliedDamage = MultipliedDamage * (1 - TotalRes)
           
           if Attacker:GetAttribute("CritTest") then  
                isCrit = true
               else 
                isCrit = HelpfulModule.CalculateCrit(DEX_Points)
                print(isCrit)
               end
            
            if isCrit then 
                MultipliedDamage = MultipliedDamage * CritDmgMult
            end 

        end

        
    end

  return MultipliedDamage, isCrit, damageAlreadydealt

end



function PassiveManger.DefensivePassive(char, damage) -- This refers to when char blocks an attack
    
end

function PassiveManger.DodgePassive(char, damage) -- This refers to when char dodges an attack or just dodges in general
    local Element = char:GetAttribute("Element")
    local Second_ModeCheck = char:GetAttribute("Mode2")

    if Element == "Astral" then
        print("If there was a passive for mode 1 it would be here")
        if Second_ModeCheck then
           print("This is where the dodge logic would go for the flashstep")
        end
    end

    
end


function PassiveManger.BackStabPassive(char, damage) -- This refers to when char lands a backstab attack
  

end


function PassiveManger.OnSkillLanded(attacker, defender, damage,skill) -- 

end




return PassiveManger