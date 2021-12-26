local RunService = game:GetService("RunService")

--[=[
	@class Region
]=]
local Region = {}
Region.ClassName = "Region"
Region.__index = Region

--[=[
	@type RegionInstance BasePart | Model
	@within Region

	The 3D representation of the Region's boundaries. It can either be a single
	BasePart or a Model composed of several BaseParts that all represent one
	Region.
]=]

--[=[
	@prop name string
	@within Region

	The name of the Region. This is used when calling `tostring()` on the Region instance.

	(Default: "Region")
]=]

--[=[
	@prop instance RegionInstance
	@within Region

	A reference to the `regionInstance` argument pass when constructing
]=]

--[=[
	@prop entered RBXScriptSignal
	@within Region

	Fired when an instance in the whitelist enters the Region.

	```lua
	local regionInstance = Instance.new("Part")
	local region = Region.new(regionInstance)

	region.entered:Connect(function(instance: Instance)
		print(instance, "entered the region")
	end)
	```
]=]

--[=[
	@prop left RBXScriptSignal
	@within Region

	Fired when an instance in the whitelist leaves the Region.

	Usage:

	```lua
	local regionInstance = Instance.new("Part")
	local region = Region.new(regionInstance)

	region.left:Connect(function(instance: Instance)
		print(instance, "left the region")
	end)
	```
]=]

--[=[
	Constructs a new Region instance.

	You can either pass in a Model or a BasePart which will represent the
	Region's boundaries in the Workspace.

	When using a Model, it must contain BaseParts as children.

	A Region's BaseParts are known as "segments." Every Region must have at
	least one segment, and when a segment is collided with by instances in the
	whitelist certain events will be triggered.

	```lua
	local regionInstance = Instance.new("Part")
	local region = Region.new(regionInstance)
	```

	@param regionInstance RegionInstance
	@return Region
]=]
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

--[=[
	Static function for checking if the given argument is a Region instance or not.

	```lua
	local regionInstance = Instance.new("Part")
	local region = Region.new(regionInstance)

	print(Region.is(region)) -- true
	print(Region.is("string") -- false
	```

	@param other any
	@return boolean -- Returns `true` if `other` is a Region, `false` otherwise
]=]
function Region.is(other: any)
	return tostring(other) == Region.ClassName
end

function Region:__tostring()
	return self.name
end

--[=[
	Sets the instances that can collide with the Region and trigger events.

	The whitelist must be defined or the Region will not respond to any instances.

	:::tip
	A common use case is to set the whitelist to all the Character models in the
	Workspace. This allows you to setup a region system where your players can
	enter and leave specific zones.
	:::

	```lua
	local regionInstance = Instance.new("Part")
	local region = Region.new(regionInstance)

	region:setWhitelist({
		Players.LocalPlayer.Character
	})
	```

	@param whitelist { Instance }
]=]
function Region:setWhitelist(whitelist: { Instance }): nil
	self._whitelist = whitelist

	return nil
end

--[=[
	Get all of the BaseParts that compose the Region's boundary.

	:::info
	If you passed in a BasePart when constructing, this will return an array
	with that BasePart as the only element. If you passed a Model, this will
	return an array with all BasePart descendants.
	:::

	```lua
	local regionInstance = Instance.new("Part")
	local region = Region.new(regionInstance)

	print(region:getRegionSegments())
	```

	@return { BasePart } -- Returns all BaseParts that compose the Region
]=]
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

--[=[
	Gets all whitelisted Instances that are within the Region.

	:::tip
	The below example uses a while loop to print out all whitelisted instances
	within the Region for illustrative purposes. Usually you will want to
	respond to the `enter` and `left` events.
	:::

	```lua
	local regionInstance = Instance.new("Part")
	local region = Region.new(regionInstance)

	region:setWhitelist({
		Players.LocalPlayer.Character
	})

	region:listen()

	while task.wait(1) do
		print(region:getInstancesInRegion())
	end
	```

	@return { Instance } -- Array of whitelisted Instances that are within the Region
]=]
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

--[=[
	Checks if the given Instance is within the Region.

	This only applies to instances in the whitelist. If you call this function
	on an instance that is not whitelisted, it will always return `false`.

	```lua
	local regionInstance = Instance.new("Part")
	local region = Region.new(regionInstance)

	region:setWhitelist({
		workspace.Part
	})

	region:listen()

	while task.wait(1) do
		print(region:isInstanceInRegion(workspace.Part))
	end
	```

	@param instance Instance
	@return boolean -- Returns `true` if the Instance is within the Region, `false` otherwise
]=]
function Region:isInstanceInRegion(instance: Instance): boolean
	for _, other in ipairs(self:getInstancesInRegion()) do
		if instance == other or other:IsDescendantOf(instance) then
			return true
		end
	end

	return false
end

--[=[
	Starts a Heartbeat connection to listen for instances in the whitelist
	colliding with the Region.

	This method must be called before instances in the whitelist will be
	detected within the Region's boundaries.

	```lua
	local regionInstance = Instance.new("Part")
	local region = Region.new(regionInstance)

	region:setWhitelist({
		Players.LocalPlayer.Character
	})

	region:listen()
	```
]=]
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

--[=[
	Destroys the Region, cleaning up any connections and destroying Instances that the Region relied on.

	Note that this _will_ destroy `regionInstance`.

	```lua
	local regionInstance = Instance.new("Part")
	local region = Region.new(regionInstance)

	region:setWhitelist({
		workspace.Part
	})

	region:listen()

	-- Later...

	region:destroy()

	print(regionInstance.Parent) -- nil
	```
]=]
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
