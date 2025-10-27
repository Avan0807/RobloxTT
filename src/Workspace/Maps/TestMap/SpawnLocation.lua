-- SpawnLocation for TestMap

return function(parent)
	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "SpawnLocation"
	spawn.Size = Vector3.new(10, 1, 10)
	spawn.Position = Vector3.new(0, 5, 0)
	spawn.Anchored = true
	spawn.Color = Color3.fromRGB(0, 255, 0)
	spawn.Transparency = 0.5
	spawn.CanCollide = false
	spawn.Parent = parent

	return spawn
end
