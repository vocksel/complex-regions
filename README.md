# ComplexRegions

This is a package that allows you to define regions in an experience out of BaseParts of any shape or size.

![A character within a region composed of rectangles and a sphere](example/example.png)

## Installation

### Wally

If you are using [Wally](https://github.com/UpliftGames/wally), add the following to your `wally.toml` and run `wally install` to get a copy of the package.

```
[dependencies]
ComplexRegions = "vocksel/complex-regions@0.1.0
```

### Roblox Studio

* Download a copy of the rbxm from the [releases page](https://github.com/vocksel/complex-regions/releases/latest) under the Assets section. 
* Drag and drop the file into Roblox Studio to add it to your experience.

## Creating a Region

A region can be a singular BasePart instance, or a Model/Folder containing several BaseParts that make up the region. The latter is where this package shines.

To create a region add a new Model into the Workspace, rename it to Region, and add some Parts inside of it. Make sure to set `CanCollide = false` for each Part so that other instances can enter the region.

Next, create a new LocalScript in StarterPlayerScripts with the following contents:

```lua
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComplexRegions = require(ReplicatedStorage.Packages.ComplexRegions)

local region = ComplexRegions.Region.new(workspace.Region)

-- The whitelist determines which instances can interact with the region. In
-- this case, we will respond when our Character enters.
region:setWhitelist({
    Players.LocalPlayer.Character
})

-- This starts up a Heartbeat connection and is required for the region to
-- respond to instances in the whitelist entering and leaving.
region:listen()

region.entered:Connect(function(character: Model)
    print(character, "entered", region)
end)

region.left:Connect(function(character: Model)
    print(character, "left", region)
end)
```

Now when you start the experience and walk in and out of the region messages will print in the output.

## API

`createRegion(regionInstance: Model | BasePart, whitelist: { Instance }): Region`

This is a helper function that will create a Region, set its whitelist, and also listen for instances entering and leaving.

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

### Region

**`Region.new(regionInstance: Model | BasePart): Region`**

Creates a new Region where `regionInstance` represents the boundaries of the Region.

Usage:

```lua
local regionInstance = Instance.new("Part")
local region = Region.new(regionInstance)
```

**`Region.is(other: any): boolean`**

Checks if the given argument is a Region instance or not.

Usage:

```lua
local regionInstance = Instance.new("Part")
local region = Region.new(regionInstance)

print(Region.is(region)) -- true
print(Region.is("string") -- false)
```

**`Region.name: string = "Region"`**

The name of the Region. This is used when calling `tostring()` on the Region instance.

**`Region.instance: Model | BasePart`**

Reference to the `regionInstance` that was passed in when constructing.

**`Region:setWhitelist(whitelist: { Instance }): nil`**

Sets the list of instances that can trigger the Region's `entered` and `left` events.

The whitelist must be defined, or else the Region will not respond to any instances.

Usage:

```lua
local regionInstance = Instance.new("Part")
local region = Region.new(regionInstance)

region:setWhitelist({
    Players.LocalPlayer.Character
})
```

**`Region:listen(): nil`**

Starts a Heartbeat connection to listen for instances in the whitelist entering and leaving the Region.

This method must be called before instances in the whitelist will be detected within the Region's boundaries.

Usage:

```lua
local regionInstance = Instance.new("Part")
local region = Region.new(regionInstance)

region:setWhitelist({
    Players.LocalPlayer.Character
})

region:listen()
```

**`Region:getRegionSegments(): { BasePart }`**

Returns an array of all BaseParts that compose the Region.

Usage:

```lua
local regionInstance = Instance.new("Part")
local region = Region.new(regionInstance)

print(region:getRegionSegments())
```

**`Region:getInstancesInRegion(): { Instance }`**

Returns an array of all Instances that are currently within the Region. This only applies to instances in the whitelist.

Usage:

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

**`Region:isInstanceInRegion(instance: Instance): boolean`**

Checks if the given Instance is within the Region's boundaries. This only applies to instances in the whitelist.

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

**`Region:destroy(): nil`**

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

**`Region.entered(instance: Instance): RBXScriptConnection`**

Fired when an instance in the whitelist enters the Region.

Usage:

```lua
local region = Region.new(workspace.Region)

region.entered:Connect(function(instance: Instance)
    print(instance, "entered the region")
end)
```

**`Region.left(instance: Instance): RBXScriptConnection`**

Fired when an instance in the whitelist leaves the Region.

Usage:

```lua
local region = Region.new(workspace.Region)

region.left:Connect(function(instance: Instance)
    print(instance, "left the region")
end)
```

## Contributing

See the [contributing guide](CONTRIBUTING.md).

## License

[MIT License](LICENSE)