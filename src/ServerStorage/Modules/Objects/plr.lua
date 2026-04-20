local plr = {}
plr.__index = plr
local SS = game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")
local SSModules = SS.Modules


local DataManger = require(ServerScriptService.Data.Modules.DataManager)
local AcessoryManager = require(SSModules.Other.AccessoriesManager)



export type PLR = typeof(setmetatable(
    {} :: {
        Player: Player,
        Data: DataManger.SlotData,
        Character: Model,
        CurrentSlot: string,
        FirstName: string,
        LastName: string,
        HairColor: Color3,
        Element: string,
        Stats: {
            VIT: number,
            END: number,
            STR: number,
            SPT: number,
            DEX: number,
            AGL: number,
            WPN: number,
        },
        Talents: {},
        Skills: {},
    },
    plr
))


local function LoadCharacterAppearance(plr: PLR)
    local hum = plr.Character:FindFirstChildOfClass("Humanoid")
    hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

    
    local AccessoriesFolder = Instance.new("Folder")
	local WeldsFolder = Instance.new("Folder")

	WeldsFolder.Name = "Welds"
	WeldsFolder.Parent = AccessoriesFolder
	AccessoriesFolder.Name = "Accessories"
	AccessoriesFolder.Parent = plr.Character
 

    for accessoryType, accessoryName in pairs(plr.Data.Accessories) do
        if accessoryName ~= "" then
            AcessoryManager.EquipAccessory(plr.Character, accessoryType)
        end
    end

    local bodyColors = plr.Character:FindFirstChildOfClass("BodyColors")
   

    if plr.Data.Appearance.Skin_Tone ~= "" then
        for i, colour in pairs(bodyColors) do
            if i.Name == "HeadColor" or i.Name == "LeftArmColor" or i.Name == "RightArmColor" or i.Name == "LeftLegColor" or i.Name == "RightLegColor" or i.Name == "TorsoColor" then
                i.Color = Color3.fromHex(plr.Data.Appearance.Skin_Tone)
            end

        end
    end


   
end

local function SetupStats(plr: PLR)
    for statName, statValue in pairs(plr.Data.STAT_POINTS) do
        plr.Stats[statName] = statValue
    end

end





local playertoPLR = {}

function plr.new(Player: Player, Slot: string):PLR?
    local self = setmetatable({
        Player = Player,
        Data = DataManger.Profiles[Player].Data[Slot],
		FirstName = "",
		LastName = "",
		Character = Player.Character :: any,
        CurrentSlot = Slot,
		Element = "",
		Talents = {},
		Skills = {},
	}, plr) :: PLR

    if self.Character.Parent ~= Workspace.Characters then
        self.Character.Parent = workspace.Characters
    end

    self.CurrentSlot = Slot
    self.HairColor = Color3.new(self.Data.Appearance.Hair_Colour.Red, self.Data.Appearance.Hair_Colour.Green, self.Data.Appearance.Hair_Colour.Blue)

    LoadCharacterAppearance(self)
    SetupStats(self)

    
    playertoPLR[Player] = self

    return self

  
end



function plr:IncreaseStat(statName: string, amount: number)
    
end

function plr:EquipAccessory(accessoryType: string, accessoryName: string)
    AcessoryManager.EquipAccessory(self.Character, accessoryType)
    DataManger.UpdateAccessories(self.Player, accessoryType, accessoryName)
end


function plr:UnequipAccessory(accessoryType: string)
    AcessoryManager.UnequipAccessory(self.Character, accessoryType)
    DataManger.UpdateAccessories(self.Player, accessoryType, "")
end



























return plr