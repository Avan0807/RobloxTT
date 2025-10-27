-- Ground for TestMap
-- This file will create a simple ground part when synced via Rojo

return function(parent)
	local ground = Instance.new("Part")
	ground.Name = "Ground"
	ground.Size = Vector3.new(200, 1, 200)
	ground.Position = Vector3.new(0, 0, 0)
	ground.Anchored = true
	ground.Color = Color3.fromRGB(100, 150, 100)
	ground.Material = Enum.Material.Grass
	ground.Parent = parent

	return ground
end
