local Region = require(script.Parent.Region)

local function createRegion(regionInstance: Model | BasePart, whitelist: { Instance })
	local region = Region.new(regionInstance)
	region:setWhitelist(whitelist)
	region:listen()

	return region
end

return createRegion
