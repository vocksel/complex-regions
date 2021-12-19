local Mock = require(script.Parent.Parent.Dev.Mock)
local Region = require(script.Parent.Region)

local function createRegionModel(): Model & { Segment1: Part, Segment2: Part }
	local regionInstance = Instance.new("Model")

	local segment1 = Instance.new("Part")
	segment1.Name = "Segment1"
	segment1.Parent = regionInstance

	local segment2 = Instance.new("Part")
	segment2.Name = "Segment2"
	segment2.Parent = regionInstance

	return regionInstance
end

return function()
	it("should support tostring", function()
		local regionInstance = Instance.new("Part")
		local region = Region.new(regionInstance)

		expect(tostring(region)).to.equal(region.ClassName)
	end)

	describe("new", function()
		it("creates a new Region instance", function()
			local regionInstance = Instance.new("Part")
			local region = Region.new(regionInstance)

			expect(region).to.be.a("table")
		end)
	end)

	describe("is", function()
		it("returns true when given a Region instance", function()
			local regionInstance = Instance.new("Part")
			local region = Region.new(regionInstance)

			expect(Region.is(region)).to.equal(true)
		end)

		it("returns false for primitive types", function()
			local primitives = {
				true,
				12345,
				"string",
				{ foo = true },
			}

			for _, primitive in ipairs(primitives) do
				expect(Region.is(primitive)).to.equal(false)
			end
		end)
	end)

	describe("setWhitelist", function()
		it("should set the _whitelist instance variable", function()
			local regionInstance = Instance.new("Part")
			local whitelist = {
				Instance.new("Part"),
			}

			local region = Region.new(regionInstance)
			region:setWhitelist(whitelist)

			expect(region._whitelist).to.equal(whitelist)
		end)
	end)

	describe("getRegionSegments", function()
		it("should return an array of one BasePart if regionInstance is a BasePart", function()
			local regionInstance = Instance.new("Part")
			local region = Region.new(regionInstance)

			local segments = region:getRegionSegments()
			expect(#segments).to.equal(1)
			expect(segments[1]).to.equal(regionInstance)
		end)

		it("should return an array of all descendant parts if regionInstance is a model", function()
			local regionInstance = createRegionModel()
			local region = Region.new(regionInstance)
			local segments = region:getRegionSegments()

			expect(table.find(segments, regionInstance.Segment1)).to.be.ok()
			expect(table.find(segments, regionInstance.Segment2)).to.be.ok()
		end)
	end)

	describe("getInstancesInRegion", function()
		it("should return an array of all whitelisted parts within the region", function()
			local whitelist = {
				Instance.new("Part"),
			}

			local mockWorldModel = Mock.MagicMock.new()
			Mock.setReturnValue(mockWorldModel.GetPartsInPart, whitelist)

			local regionInstance = createRegionModel()

			local region = Region.new(regionInstance)
			region:setWhitelist(whitelist)
			region._worldModel = mockWorldModel

			local instances = region:getInstancesInRegion()
			expect(instances[1]).to.equal(whitelist[1])
		end)

		it("should never find an instance in the whitelist if it is not in the region", function() end)
	end)

	describe("isInstanceInRegion", function()
		local part: Part
		local regionInstance: Part

		beforeEach(function()
			part = Instance.new("Part")
			part.Parent = workspace

			regionInstance = Instance.new("Part")
			regionInstance.Size = Vector3.new(20, 20, 20)
			regionInstance.Parent = workspace
		end)

		afterEach(function()
			part:Destroy()
			regionInstance:Destroy()
		end)

		it("returns true if the instance is in the whitelist and inside the region", function()
			local region = Region.new(regionInstance)
			region:setWhitelist({ part })

			expect(region:isInstanceInRegion(part)).to.equal(true)
		end)

		it("returns true if the parts in a model are inside the region", function()
			local model = Instance.new("Model")
			model.Parent = workspace
			part.Parent = model

			local region = Region.new(regionInstance)

			region:setWhitelist({
				model,
			})

			expect(region:isInstanceInRegion(model)).to.equal(true)
		end)

		it("returns false if the instance is in the whitelist and NOT inside the region", function()
			local region = Region.new(regionInstance)
			region:setWhitelist({ part })

			-- Position the part far away from the region
			part.Position = Vector3.new(0, 200, 0)

			expect(region:isInstanceInRegion(part)).to.equal(false)
		end)

		it("returns false if the instance is not in the whitelist", function()
			local region = Region.new(regionInstance)
			region:setWhitelist({})

			expect(region:isInstanceInRegion(part)).to.equal(false)
		end)
	end)

	describe("listen", function()
		local region

		beforeEach(function()
			local regionInstance = Instance.new("Part")
			region = Region.new(regionInstance)
		end)

		afterEach(function()
			region:destroy()
		end)

		it("should connect to Heartbeat", function()
			expect(region._heartbeat).to.never.be.ok()

			region:listen()

			expect(typeof(region._heartbeat)).to.equal("RBXScriptConnection")
		end)
	end)

	describe("destroy", function()
		local region: Region.Region

		beforeEach(function()
			local regionInstance = Instance.new("Part")
			regionInstance.Parent = workspace

			region = Region.new(regionInstance)
		end)

		it("should destroy all instances", function()
			expect(region.instance.Parent).to.be.ok()
			region:destroy()
			expect(region.instance.Parent).to.equal(nil)
		end)
	end)
end
