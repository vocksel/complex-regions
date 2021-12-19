local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComplexRegions = require(ReplicatedStorage.Packages.ComplexRegions)

type Region = typeof(ComplexRegions.Region.new())

local regions = {}

local BASE_COLOR = Color3.fromRGB(244, 251, 251)
local ACTIVE_COLOR = Color3.fromRGB(36, 252, 20)

local function setRegionColors(region: Region, color: Color3): nil
	if region.instance:IsA("Model") then
		for _, child in ipairs(region.instance:GetChildren()) do
			if child:IsA("BasePart") then
				child.Color = color
			end
		end
	else
		region.instance.Color = color
	end

	return nil
end

Players.LocalPlayer.CharacterAdded:Connect(function(character)
	-- Clean up old regions when the character respawns
	for _, region in ipairs(regions) do
		region:destroy()
	end

	for _, regionInstance in ipairs(CollectionService:GetTagged("Region")) do
		local region = ComplexRegions.Region.new(regionInstance)
		region.name = regionInstance.Name
		region.useDebugColors = true

		region:setWhitelist({ character })
		region:listen()

		region.entered:Connect(function()
			print(character, "entered", region)
			setRegionColors(region, ACTIVE_COLOR)
		end)

		region.left:Connect(function()
			print(character, "left", region)
			setRegionColors(region, BASE_COLOR)
		end)

		print("setup region", region)

		table.insert(regions, region)
	end
end)
