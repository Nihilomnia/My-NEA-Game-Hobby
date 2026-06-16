local module = {}
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local FontsModule = require(script.Fonts)
-- Configuration
local CONFIG = {
	MAX_LINE_WIDTH = 800, -- Auto-wrap threshold
	LETTER_DELAY = 0.1, -- Time between letters
	LINE_GAP = 2, -- Time between dialogue lines
	FADE_IN_TIME = 0.1, -- Letter fade-in duration
	FADE_OUT_TIME = 0.03, -- Letter fade-out step time
	READ_TIME = 1.5, -- Time to read before fade-out
	SIZE = 36,

	-- Outline/Shadow settings
	USE_OUTLINE = true, -- true = 8-way outline, false = shadow only
	OUTLINE_COLOR = Color3.new(0, 0, 0),
	OUTLINE_TRANSPARENCY = 0.3, -- 0 = opaque, 1 = invisible
	SHADOW_OFFSET = Vector2.new(2, 2), -- Only used if USE_OUTLINE = false

	-- Shake settings
	SHAKE_MAGNITUDE = 5,
	SHAKE_SPEED = 0.05,
}

--- S is the raw font info taken from the font module

local s = FontsModule.FontTable.MinecraftFont.FontData
	

local fontMap = FontsModule.FontTable.MinecraftFont.FontMap

-----

local info = {}

info.fontInfo = {}
info.characterTable = {}
info.kernings = {}

local init, _ = s:find("kernings")
if init then
	local kernings = s:sub(init, s:len()):split("\n")

	local kerningsTable = info.kernings

	for i, v in ipairs(kernings) do
		local first, second, amount =
			v:match("kerning first=([%-?%.?%d?]+) second=([%-?%.?%d?]+) amount=([%-?%.?%d?]+)")
		if first then
			kerningsTable[utf8.char(first)] = kerningsTable[utf8.char(first)] or {}
			kerningsTable[utf8.char(first)][utf8.char(second)] = amount
		end
	end
	s = s:sub(1, init - 1)
end
local split = s:split("\n")

local characterTable = info.characterTable

for i = 3, 1, -1 do
	local infoThisIteration = split[i]:split(" ")
	for i, v in ipairs(infoThisIteration) do
		local field, value = unpack(v:split("="))
		if field and value then
			field, value = field:gsub('"', ""), value:gsub('"', "")
			info.fontInfo[field] = tonumber(value) or value
		end
	end
	table.remove(split, i)
end
table.remove(split, 1)

for i = #split, 1, -1 do
	local v = split[i]
	local charId, x, y, width, height, xOffset, yOffset, xAdvance, page, chnl = v:match(
		"char id=([%-?%.?%d?]+) x=([%-?%.?%d?]+) y=([%-?%.?%d?]+) width=([%-?%.?%d?]+) height=([%-?%.?%d?]+) xoffset=([%-?%.?%d?]+) yoffset=([%-?%.?%d?]+) xadvance=([%-?%.?%d?]+) page=([%-?%.?%d?]+) chnl=([%-?%.?%d?]+)"
	)
	if charId then
		table.remove(split, i)
		table.insert(characterTable, {
			charId = charId,
			x = x,
			y = y,
			width = width,
			height = height,
			xOffset = xOffset,
			yOffset = yOffset,
			xAdvance = xAdvance,
			page = page,
			chnl = chnl,
		})
	end
end



local stringFolder = Instance.new("Folder")
stringFolder.Name = info.fontInfo.face
stringFolder.Parent = script

for i, v in ipairs(characterTable) do
	local mainFrame = Instance.new("Frame")
	mainFrame.Size = UDim2.fromOffset(v.xAdvance or v.width, CONFIG.SIZE)
	mainFrame.BackgroundTransparency = 1
	mainFrame.Name = utf8.char(v.charId)
	mainFrame.BackgroundTransparency = 1
	local newLabel = Instance.new("ImageLabel")
	newLabel.Image = fontMap
	newLabel.Size = UDim2.fromOffset(v.width, v.height)
	newLabel.Parent = mainFrame
	newLabel.Name = utf8.char(v.charId)
	newLabel.Position = UDim2.fromOffset(v.xOffset, v.yOffset)
	newLabel.ImageRectSize = Vector2.new(v.width, v.height)
	newLabel.ImageRectOffset = Vector2.new(v.x, v.y)
	newLabel.Parent = mainFrame
	newLabel.BackgroundTransparency = 1
	newLabel.ScaleType = Enum.ScaleType.Fit
	newLabel.BackgroundTransparency = 1
	mainFrame.Parent = stringFolder
end

-----

local messageQueue = {}
local isFeeding = false
local currentHeaderFrame

-- Function to parse tags inside the message
local function parseTags(str)
	local segments = {}
	local tagStack = {}
	local i = 1

	while i <= #str do
		local startTag, endTag = str:find("<[^>]*>", i)

		if startTag then
			local preText = str:sub(i, startTag - 1)
			if preText ~= "" then
				table.insert(segments, { text = preText, tags = table.clone(tagStack) })
			end

			local tagText = str:sub(startTag + 1, endTag - 1)

			-- Handle pause tag specially (it's self-closing)
			if tagText:match("^pause:%d+%.?%d*$") then
				table.insert(segments, { text = "", tags = { tagText }, isPause = true })
			elseif tagText:sub(1, 1) == "/" then
				local closing = tagText:sub(2)
				for idx = #tagStack, 1, -1 do
					if tagStack[idx]:match("^colour:") and closing:match("^colour:") then
						table.remove(tagStack, idx)
						break
					elseif tagStack[idx] == closing then
						table.remove(tagStack, idx)
						break
					end
				end
			else
				table.insert(tagStack, tagText)
			end

			i = endTag + 1
		else
			local remaining = str:sub(i)
			table.insert(segments, { text = remaining, tags = table.clone(tagStack) })
			break
		end
	end

	return segments
end

-- Function to apply shake effect to letter and image
local function applyShakeEffect(letterFrame, imageLabel)
	local originalPosition = letterFrame.Position
	local originalImagePosition = imageLabel.Position
	local shakeMagnitude = 5
	local cycleTime = 0.05
	local isShaking = true

	task.spawn(function()
		while isShaking do
			letterFrame.Position = originalPosition
				+ UDim2.new(
					0,
					math.random(-shakeMagnitude, shakeMagnitude),
					0,
					math.random(-shakeMagnitude, shakeMagnitude)
				)
			imageLabel.Position = originalImagePosition
				+ UDim2.new(
					0,
					math.random(-shakeMagnitude, shakeMagnitude),
					0,
					math.random(-shakeMagnitude, shakeMagnitude)
				)
			task.wait(cycleTime)
		end
	end)

	return function()
		isShaking = false
	end
end

-- Function to create frame for letters
local function createLetteredFrame(text, fadeDuration)
	local frame = Instance.new("Frame")
	frame.BackgroundTransparency = 1
	frame.Size = UDim2.new(1, 0, 0, 40)
	frame.AutomaticSize = Enum.AutomaticSize.X
	frame.ClipsDescendants = false

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Parent = frame

	for i, unit in utf8.graphemes(text) do
		local char = text:sub(i, unit)
		local template = stringFolder:FindFirstChild(char)
		if template then
			local letter = template:Clone()
			letter.Visible = true
			letter.LayoutOrder = i
			local image = letter:FindFirstChildWhichIsA("ImageLabel")
			if image then
				image.ImageTransparency = 1
				local tween = TweenService:Create(image, TweenInfo.new(fadeDuration), { ImageTransparency = 0 })
				tween:Play()
			end
			letter.Parent = frame
		end
	end

	return frame
end

-- Function to feed message and show it letter by letter with effects
local function feedSingle(str, plr, isLast)
	local headerText
	str = str:gsub("<h>(.-)<h>", function(h)
		headerText = h
		return ""
	end)

	local parsed = parseTags(str)

	local subtitleContainer = plr.PlayerGui.CutsceneUI:FindFirstChild("SubtitleContainer")
	if not subtitleContainer then
		subtitleContainer = Instance.new("Frame")
		subtitleContainer.Name = "SubtitleContainer"
		subtitleContainer.BackgroundTransparency = 1
		subtitleContainer.AnchorPoint = Vector2.new(0.5, 1)
		subtitleContainer.Position = UDim2.new(0.5, 0, 1, -100)
		subtitleContainer.Size = UDim2.new(1, -100, 0, 100)
		subtitleContainer.AutomaticSize = Enum.AutomaticSize.Y
		subtitleContainer.ClipsDescendants = false
		subtitleContainer.Parent = plr.PlayerGui.CutsceneUI

		local layout = Instance.new("UIListLayout")
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.FillDirection = Enum.FillDirection.Vertical
		layout.Padding = UDim.new(0, 6)
		layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		layout.Parent = subtitleContainer
	end

	if headerText then
		if currentHeaderFrame then
			for _, letter in ipairs(currentHeaderFrame:GetChildren()) do
				local img = letter:FindFirstChildWhichIsA("ImageLabel")
				if img then
					TweenService:Create(img, TweenInfo.new(0.25), { ImageTransparency = 1 }):Play()
				end
			end
			task.wait(0.25)
			currentHeaderFrame:Destroy()
			currentHeaderFrame = nil
		end
		currentHeaderFrame = createLetteredFrame(headerText, 0.5)
		currentHeaderFrame.Parent = subtitleContainer
	end

	local newFrame = Instance.new("Frame")
	newFrame.BackgroundTransparency = 1
	newFrame.Size = UDim2.new(1, 0, 0, 40)
	newFrame.ClipsDescendants = false
	newFrame.AutomaticSize = Enum.AutomaticSize.X
	newFrame.Name = "DialogueLine"

	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.Padding = UDim.new(0, 0)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Parent = newFrame

	newFrame.Parent = subtitleContainer

	local letterCount = 0
	local stopShaking

	-- Loop through the parsed message segments and apply effects
	for _, segment in ipairs(parsed) do
		-- Handle pause tag
		if segment.isPause then
			for _, tag in ipairs(segment.tags) do
				if tag:match("^pause:%d+%.?%d*$") then
					local duration = tonumber(tag:match("pause:(%d+%.?%d*)"))
					task.wait(duration)
				end
			end
			continue 
		end

	
		local graphemes = {}
		for i, v in utf8.graphemes(segment.text) do
			table.insert(graphemes, segment.text:sub(i, v))
		end

		for _, char in ipairs(graphemes) do
			local template = stringFolder:FindFirstChild(char)
			-- Around line ~240, replace the image creation section with this:
			if template then
				local newLetter = template:Clone()
				newLetter.LayoutOrder = letterCount
				newLetter.Visible = true
				newLetter.Parent = newFrame
				letterCount += 1

				local image = newLetter:FindFirstChildWhichIsA("ImageLabel")
				if image then
					-- CREATE OUTLINE/SHADOW
					local outline = image:Clone()
					outline.Name = "Outline"
					outline.ImageColor3 = Color3.new(0, 0, 0) -- Black outline
					outline.ZIndex = image.ZIndex - 1
					outline.ImageTransparency = 1
					outline.Parent = newLetter

					-- Create 8-directional outline (or 4 for performance)
					local outlineOffsets = {
						{ -1, -1 },
						{ 0, -1 },
						{ 1, -1 }, -- Top row
						{ -1, 0 },
						{ 1, 0 }, -- Middle (skip center)
						{ -1, 1 },
						{ 0, 1 },
						{ 1, 1 }, -- Bottom row
					}

					-- For simpler shadow (instead of outline), use just this:
					-- local outlineOffsets = {{2, 2}} -- Shadow offset

					for i, offset in ipairs(outlineOffsets) do
						local outlineClone = outline:Clone()
						outlineClone.Position = image.Position + UDim2.fromOffset(offset[1], offset[2])
						outlineClone.Name = "Outline" .. i
						outlineClone.Parent = newLetter
					end

					outline:Destroy() -- Remove the template clone

					-- Set main image transparency
					image.ImageTransparency = 1

					-- Apply color if specified
					for _, tag in ipairs(segment.tags) do
						if tag:match("^colour:#%x%x%x%x%x%x$") then
							local hex = tag:match("#%x%x%x%x%x%x")
							local r = tonumber(hex:sub(2, 3), 16) / 255
							local g = tonumber(hex:sub(4, 5), 16) / 255
							local b = tonumber(hex:sub(6, 7), 16) / 255
							image.ImageColor3 = Color3.new(r, g, b)
						end
					end

					-- Apply fade effect to BOTH main image AND outlines
					local fade = TweenService:Create(image, TweenInfo.new(0.1), { ImageTransparency = 0 })
					fade:Play()

					for _, child in ipairs(newLetter:GetChildren()) do
						if child.Name:match("^Outline") and child:IsA("ImageLabel") then
							local outlineFade =
								TweenService:Create(child, TweenInfo.new(0.1), { ImageTransparency = 0.3 })
							outlineFade:Play()
						end
					end

					-- Rest of the existing code (shake, sound, etc.)
					for _, tag in ipairs(segment.tags) do
						if tag == "shake" then
							stopShaking = applyShakeEffect(newLetter, image)
						elseif tag:match("^sound:rbxassetid://%d+$") then
							local soundId = tag:match("sound:rbxassetid://(%d+)")
							local sound = Instance.new("Sound")
							sound.SoundId = "rbxassetid://" .. soundId
							sound.Volume = 1
							sound.Parent = plr.PlayerGui or workspace.CurrentCamera
							sound:Play()
							Debris:AddItem(sound, 2)
						end
					end
				end

				task.wait(0.1)
			end
		end
	end

	-- Fade out letters
	task.wait(1.5)

	for t = 0, 1, 0.1 do
		for _, letter in ipairs(newFrame:GetChildren()) do
			if letter:IsA("Frame") then
				-- Fade main image
				local img = letter:FindFirstChildWhichIsA("ImageLabel")
				if img then
					img.ImageTransparency = t
				end

				-- Fade outlines
				for _, child in ipairs(letter:GetChildren()) do
					if child.Name:match("^Outline") and child:IsA("ImageLabel") then
						child.ImageTransparency = math.clamp(0.3 + (t * 0.7), 0.3, 1)
					end
				end
			end
		end
		task.wait(0.03)
	end

	if stopShaking then
		stopShaking()
	end
	newFrame:Destroy()

	-- Fade out header if last message
	if isLast and currentHeaderFrame then
		for _, letter in ipairs(currentHeaderFrame:GetChildren()) do
			local img = letter:FindFirstChildWhichIsA("ImageLabel")
			if img then
				TweenService:Create(img, TweenInfo.new(0.25), { ImageTransparency = 1 }):Play()
			end
		end
		task.wait(0.25)
		currentHeaderFrame:Destroy()
		currentHeaderFrame = nil
	end
end

local MAX_LINE_WIDTH = 800 -- Maximum width in pixels before wrapping

local function calculateTextWidth(text)
	local width = 0
	for i, unit in utf8.graphemes(text) do
		local char = text:sub(i, unit)
		local template = stringFolder:FindFirstChild(char)
		if template then
			width = width + template.Size.X.Offset
		end
	end
	return width
end

local function wrapText(str, maxWidth)
	local lines = {}
	local currentLine = ""
	local currentWidth = 0

	-- Split by existing newlines first
	for line in str:gmatch("[^\n]+") do
		-- Split line into words
		local words = {}
		for word in line:gmatch("%S+") do
			table.insert(words, word)
		end

		for i, word in ipairs(words) do
			local wordWidth = calculateTextWidth(word)
			local spaceWidth = calculateTextWidth(" ")

			-- Check if adding this word would exceed max width
			if currentWidth + wordWidth + (currentWidth > 0 and spaceWidth or 0) > maxWidth then
				-- Start new line
				if currentLine ~= "" then
					table.insert(lines, currentLine)
					currentLine = word
					currentWidth = wordWidth
				else
					-- Word itself is too long, force it on its own line
					table.insert(lines, word)
					currentLine = ""
					currentWidth = 0
				end
			else
				-- Add word to current line
				if currentLine ~= "" then
					currentLine = currentLine .. " " .. word
					currentWidth = currentWidth + spaceWidth + wordWidth
				else
					currentLine = word
					currentWidth = wordWidth
				end
			end
		end

		-- Add remaining line
		if currentLine ~= "" then
			table.insert(lines, currentLine)
			currentLine = ""
			currentWidth = 0
		end
	end

	return lines
end

function module.feed(input, plr)
	local lines = typeof(input) == "table" and input or { input }

	-- Wrap each line
	local wrappedLines = {}
	for _, line in ipairs(lines) do
		-- Extract header before wrapping
		local headerText = line:match("<h>(.-)<h>")
		local mainText = line:gsub("<h>.-<h>", "")

		-- Wrap the main text
		local wrapped = wrapText(mainText, MAX_LINE_WIDTH)

		-- Add header back to first wrapped line
		if headerText then
			wrapped[1] = "<h>" .. headerText .. "<h>" .. wrapped[1]
		end

		-- Add all wrapped lines to queue
		for _, wrappedLine in ipairs(wrapped) do
			table.insert(wrappedLines, wrappedLine)
		end
	end

	-- Feed wrapped lines
	for _, line in ipairs(wrappedLines) do
		table.insert(messageQueue, line)
	end

	if not isFeeding then
		isFeeding = true
		while #messageQueue > 0 do
			local msg = table.remove(messageQueue, 1)
			local isLast = #messageQueue == 0
			feedSingle(msg, plr, isLast)
			task.wait(2)
		end
		isFeeding = false
	end
end

return module
