--[=[
	@class ComplexRegions
]=]

--[=[
	@prop Region Region
	@within ComplexRegions

	The Region class is exposed on the API but should typically be instantiated
	with the `createRegion` function.

	```lua
	local regionInstance = Instance.new("Part")
	local region = ComplexRegions.Region.new(regionInstance)
	```
]=]

return {
	createRegion = require(script.createRegion),
	Region = require(script.Region),
}
