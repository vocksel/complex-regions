local RunService = game:GetService("RunService")

local Region = {}
Region.ClassName = "Region"
Region.__index = Region

function Region.new(regionInstance: Model | BasePart)
	local self = {}

	local entered = Instance.new("BindableEvent")
	local left = Instance.new("BindableEvent")

	self.name = "Region"
	self.instance = regionInstance
	self.entered = entered.Event
	self.left = left.Event

	self._enteredBindable = entered
	self._leftBindable = left
	self._heartbeat = nil
	self._worldModel = workspace
	self._whitelist = {}
	self._instancesInRegion = {}

	return setmetatable(self, Region)
end

function Region.is(other: any)
	return tostring(other) == Region.ClassName
end

function Region:__tostring()
	return self.name
end

function Region:setWhitelist(whitelist: { Instance }): nil
	self._whitelist = whitelist

	return nil
end

function Region:getRegionSegments(): { BasePart }
	local segments: { BasePart } = {}

	if self.instance:IsA("Model") then
		for _, descendant in ipairs(self.instance:GetDescendants()) do
			if descendant:IsA("BasePart") then
				table.insert(segments, descendant)
			end
		end
	else
		table.insert(segments, self.instance)
	end

	return segments
end

function Region:getInstancesInRegion(): { Instance }
	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Whitelist
	overlapParams.FilterDescendantsInstances = self._whitelist

	local result = {}

	for _, segment in ipairs(self:getRegionSegments()) do
		for _, collision in ipairs(self._worldModel:GetPartsInPart(segment, overlapParams)) do
			table.insert(result, collision)
		end
	end

	return result
end

function Region:isInstanceInRegion(instance: Instance): boolean
	for _, other in ipairs(self:getInstancesInRegion()) do
		if instance == other or other:IsDescendantOf(instance) then
			return true
		end
	end

	return false
end

function Region:listen()
	self._heartbeat = RunService.Heartbeat:Connect(function()
		for _, instance in ipairs(self._whitelist) do
			local name = instance:GetFullName()
			local isInRegion = self:isInstanceInRegion(instance)
			local wasInRegion = self._instancesInRegion[name]

			if isInRegion and not wasInRegion then
				self._enteredBindable:Fire(instance)
				self._instancesInRegion[name] = true
			elseif wasInRegion and not isInRegion then
				self._leftBindable:Fire(instance)
				self._instancesInRegion[name] = nil
			end
		end
	end)
end

function Region:destroy()
	self.instance:Destroy()
	self._enteredBindable:Destroy()
	self._leftBindable:Destroy()

	-- Need to guard this incase a user creates a Region and destroys it without
	-- listening for triggers.
	if self._heartbeat then
		self._heartbeat:Disconnect()
	end
end

export type Region = typeof(Region.new())

return Region
