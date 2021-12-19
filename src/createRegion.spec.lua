return function()
	local createRegion = require(script.Parent.createRegion)
	local Region = require(script.Parent.Region)

	local region
	local whitelist = {
		Instance.new("Part"),
	}

	beforeEach(function()
		local regionInstance = Instance.new("Part")
		region = createRegion(regionInstance, whitelist)
	end)

	it("returns a Region instance", function()
		expect(Region.is(region)).to.equal(true)
	end)

	it("sets the whitelist", function()
		expect(region._whitelist).to.equal(whitelist)
	end)

	it("automatically listen for triggers", function()
		expect(typeof(region._heartbeat)).to.equal("RBXScriptConnection")
	end)
end
