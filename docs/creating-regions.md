---
sidebar_position: 2
---

# Creating Regions

A region can be a singular `BasePart` instance, or a `Model` containing several `BasePart`s that make up the region. The latter is where this package shines.

![Example of regions composed of multiple parts](/example.png)

To create a region add a new `Model` into the Workspace, rename it to Region, and add some Parts inside of it. Make sure to set `CanCollide = false` for each Part so that other instances can enter the region.

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