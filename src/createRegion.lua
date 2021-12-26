local Region = require(script.Parent.Region)

--[=[
	@within ComplexRegions
	@function createRegion

	Helper function that will create a Region, set its whitelist, and also
	listen for instances entering and leaving.

	Usage:

	```lua
	local region = ComplexRegions.createRegion(workspace.Region, {
		Players.LocalPlayer.Character
	})

	region.entered:Connect(function(instance: Instance)
		print(instance, "entered the region")
	end)

	region.left:Connect(function(instance: Instance)
		print(instance, "left the region")
	end)
	```

	@param regionInstance Model | BasePart -- The instance that represents the region
	@param whitelist { Instance } -- Array of Instances that will trigger the region's events
	@return Region
]=]
local function createRegion(regionInstance: Model | BasePart, whitelist: { Instance })
	local region = Region.new(regionInstance)
	region:setWhitelist(whitelist)
	region:listen()

	return region
end

return createRegion
