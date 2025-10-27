-- AdvancedEffects.lua - Sử dụng TẤT CẢ built-in effects của Roblox
-- Bổ sung thêm cho EffectLibrary.lua

local AdvancedEffects = {}

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

-- ========================================
-- BUILT-IN ROBLOX EFFECTS
-- ========================================

-- Fire Effect (Built-in Fire instance - dễ dùng hơn particles!)
function AdvancedEffects.QuickFire(part, duration)
	duration = duration or 5

	local fire = Instance.new("Fire")
	fire.Size = 15
	fire.Heat = 15
	fire.Color = Color3.fromRGB(255, 100, 0)
	fire.SecondaryColor = Color3.fromRGB(255, 50, 0)
	fire.Parent = part

	Debris:AddItem(fire, duration)

	return fire
end

-- Smoke Effect (Built-in Smoke instance)
function AdvancedEffects.Smoke(part, duration, color)
	duration = duration or 5
	color = color or Color3.fromRGB(100, 100, 100)

	local smoke = Instance.new("Smoke")
	smoke.Size = 10
	smoke.RiseVelocity = 5
	smoke.Color = color
	smoke.Opacity = 0.5
	smoke.Parent = part

	Debris:AddItem(smoke, duration)

	return smoke
end

-- Sparkles Effect (Built-in Sparkles instance - hay cho magic!)
function AdvancedEffects.Sparkles(part, duration, color)
	duration = duration or 5
	color = color or Color3.fromRGB(255, 255, 100)

	local sparkles = Instance.new("Sparkles")
	sparkles.SparkleColor = color
	sparkles.Parent = part

	Debris:AddItem(sparkles, duration)

	return sparkles
end

-- ========================================
-- HIGHLIGHT EFFECT (NEW - outline objects)
-- ========================================

function AdvancedEffects.Highlight(target, duration, color)
	duration = duration or 3
	color = color or Color3.fromRGB(255, 255, 0)

	local highlight = Instance.new("Highlight")
	highlight.Adornee = target
	highlight.FillColor = color
	highlight.FillTransparency = 0.5
	highlight.OutlineColor = color
	highlight.OutlineTransparency = 0
	highlight.Parent = target

	-- Pulse effect
	local pulseIn = TweenService:Create(
		highlight,
		TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, -1, true),
		{FillTransparency = 0.8}
	)
	pulseIn:Play()

	Debris:AddItem(highlight, duration)

	return highlight
end

-- ========================================
-- CAMERA EFFECTS (Screen effects)
-- ========================================

function AdvancedEffects.CameraBlur(player, intensity, duration)
	intensity = intensity or 10
	duration = duration or 1

	local camera = workspace.CurrentCamera
	local blur = camera:FindFirstChild("EffectBlur")

	if not blur then
		blur = Instance.new("BlurEffect")
		blur.Name = "EffectBlur"
		blur.Size = 0
		blur.Parent = camera
	end

	-- Blur in
	local blurIn = TweenService:Create(
		blur,
		TweenInfo.new(0.2),
		{Size = intensity}
	)
	blurIn:Play()

	-- Blur out
	task.delay(duration, function()
		local blurOut = TweenService:Create(
			blur,
			TweenInfo.new(0.5),
			{Size = 0}
		)
		blurOut:Play()
	end)
end

function AdvancedEffects.CameraShake(player, intensity, duration)
	intensity = intensity or 0.5
	duration = duration or 0.5

	local camera = workspace.CurrentCamera
	local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")

	if humanoid then
		-- Use Humanoid.CameraOffset for shake
		local originalOffset = humanoid.CameraOffset

		local elapsed = 0
		local connection
		connection = game:GetService("RunService").RenderStepped:Connect(function(dt)
			elapsed = elapsed + dt

			if elapsed >= duration then
				humanoid.CameraOffset = originalOffset
				connection:Disconnect()
			else
				-- Random shake
				humanoid.CameraOffset = Vector3.new(
					math.random(-intensity, intensity),
					math.random(-intensity, intensity),
					math.random(-intensity, intensity)
				)
			end
		end)
	end
end

function AdvancedEffects.CameraBloom(player, intensity, duration)
	intensity = intensity or 1
	duration = duration or 2

	local camera = workspace.CurrentCamera
	local bloom = camera:FindFirstChild("EffectBloom")

	if not bloom then
		bloom = Instance.new("BloomEffect")
		bloom.Name = "EffectBloom"
		bloom.Intensity = 0
		bloom.Size = 24
		bloom.Threshold = 0.8
		bloom.Parent = camera
	end

	-- Bloom in
	local bloomIn = TweenService:Create(
		bloom,
		TweenInfo.new(0.2),
		{Intensity = intensity}
	)
	bloomIn:Play()

	-- Bloom out
	task.delay(duration, function()
		local bloomOut = TweenService:Create(
			bloom,
			TweenInfo.new(0.5),
			{Intensity = 0}
		)
		bloomOut:Play()
	end)
end

function AdvancedEffects.ColorCorrection(player, saturation, contrast, duration)
	saturation = saturation or 0
	contrast = contrast or 0
	duration = duration or 2

	local camera = workspace.CurrentCamera
	local colorCorrection = camera:FindFirstChild("EffectColorCorrection")

	if not colorCorrection then
		colorCorrection = Instance.new("ColorCorrectionEffect")
		colorCorrection.Name = "EffectColorCorrection"
		colorCorrection.Saturation = 0
		colorCorrection.Contrast = 0
		colorCorrection.Parent = camera
	end

	-- Apply effect
	local applyEffect = TweenService:Create(
		colorCorrection,
		TweenInfo.new(0.2),
		{Saturation = saturation, Contrast = contrast}
	)
	applyEffect:Play()

	-- Remove effect
	task.delay(duration, function()
		local removeEffect = TweenService:Create(
			colorCorrection,
			TweenInfo.new(0.5),
			{Saturation = 0, Contrast = 0}
		)
		removeEffect:Play()
	end)
end

-- ========================================
-- DAMAGE NUMBERS (BillboardGui)
-- ========================================

function AdvancedEffects.DamageNumber(position, damage, isCrit, damageType)
	isCrit = isCrit or false
	damageType = damageType or "Normal" -- Normal, Heal, Soul, Fire, Ice

	-- Create part for billboard
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 1
	part.Size = Vector3.new(1, 1, 1)
	part.Position = position
	part.Parent = workspace

	-- Create billboard
	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(4, 0, 2, 0)
	billboard.Adornee = part
	billboard.AlwaysOnTop = true
	billboard.Parent = part

	-- Create text
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = tostring(math.floor(damage))
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextStrokeTransparency = 0.5
	textLabel.Parent = billboard

	-- Color based on type
	if isCrit then
		textLabel.TextColor3 = Color3.fromRGB(255, 255, 0) -- Yellow crit
		textLabel.Text = "💥 " .. textLabel.Text
	elseif damageType == "Heal" then
		textLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
		textLabel.Text = "+" .. textLabel.Text
	elseif damageType == "Soul" then
		textLabel.TextColor3 = Color3.fromRGB(150, 0, 200)
	elseif damageType == "Fire" then
		textLabel.TextColor3 = Color3.fromRGB(255, 100, 0)
	elseif damageType == "Ice" then
		textLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
	else
		textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	end

	-- Animate up and fade
	local tweenUp = TweenService:Create(
		part,
		TweenInfo.new(1, Enum.EasingStyle.Linear),
		{Position = position + Vector3.new(0, 3, 0)}
	)

	local tweenFade = TweenService:Create(
		textLabel,
		TweenInfo.new(1),
		{TextTransparency = 1, TextStrokeTransparency = 1}
	)

	tweenUp:Play()
	tweenFade:Play()

	Debris:AddItem(part, 1)
end

-- ========================================
-- FLOATING TEXT (Status messages)
-- ========================================

function AdvancedEffects.FloatingText(position, text, color, duration)
	color = color or Color3.fromRGB(255, 255, 255)
	duration = duration or 2

	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 1
	part.Size = Vector3.new(1, 1, 1)
	part.Position = position
	part.Parent = workspace

	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(6, 0, 2, 0)
	billboard.Adornee = part
	billboard.AlwaysOnTop = true
	billboard.Parent = part

	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = text
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextColor3 = color
	textLabel.TextStrokeTransparency = 0.5
	textLabel.Parent = billboard

	-- Float up
	local tweenUp = TweenService:Create(
		part,
		TweenInfo.new(duration),
		{Position = position + Vector3.new(0, 5, 0)}
	)

	local tweenFade = TweenService:Create(
		textLabel,
		TweenInfo.new(duration),
		{TextTransparency = 1, TextStrokeTransparency = 1}
	)

	tweenUp:Play()
	tweenFade:Play()

	Debris:AddItem(part, duration)
end

-- ========================================
-- SCREEN FLASH
-- ========================================

function AdvancedEffects.ScreenFlash(player, color, duration)
	color = color or Color3.fromRGB(255, 255, 255)
	duration = duration or 0.5

	local playerGui = player:WaitForChild("PlayerGui")

	-- Create flash screen
	local flash = Instance.new("Frame")
	flash.Size = UDim2.new(1, 0, 1, 0)
	flash.BackgroundColor3 = color
	flash.BackgroundTransparency = 1
	flash.BorderSizePixel = 0
	flash.ZIndex = 10
	flash.Parent = playerGui

	-- Flash in and out
	local flashIn = TweenService:Create(
		flash,
		TweenInfo.new(duration / 2),
		{BackgroundTransparency = 0}
	)

	local flashOut = TweenService:Create(
		flash,
		TweenInfo.new(duration / 2),
		{BackgroundTransparency = 1}
	)

	flashIn:Play()
	flashIn.Completed:Connect(function()
		flashOut:Play()
		flashOut.Completed:Connect(function()
			flash:Destroy()
		end)
	end)
end

-- ========================================
-- VIGNETTE EFFECT
-- ========================================

function AdvancedEffects.Vignette(player, intensity, duration)
	intensity = intensity or 0.5
	duration = duration or 2

	local playerGui = player:WaitForChild("PlayerGui")

	-- Create vignette
	local vignette = playerGui:FindFirstChild("EffectVignette")
	if not vignette then
		vignette = Instance.new("ImageLabel")
		vignette.Name = "EffectVignette"
		vignette.Size = UDim2.new(1, 0, 1, 0)
		vignette.BackgroundTransparency = 1
		vignette.Image = "rbxasset://textures/ui/VignetteOverlay.png"
		vignette.ImageColor3 = Color3.fromRGB(0, 0, 0)
		vignette.ImageTransparency = 1
		vignette.ZIndex = 5
		vignette.Parent = playerGui
	end

	-- Fade in
	local fadeIn = TweenService:Create(
		vignette,
		TweenInfo.new(0.3),
		{ImageTransparency = 1 - intensity}
	)
	fadeIn:Play()

	-- Fade out
	task.delay(duration, function()
		local fadeOut = TweenService:Create(
			vignette,
			TweenInfo.new(0.5),
			{ImageTransparency = 1}
		)
		fadeOut:Play()
	end)
end

-- ========================================
-- SHOCKWAVE (Expanding ring)
-- ========================================

function AdvancedEffects.Shockwave(position, size, color, duration)
	size = size or 20
	color = color or Color3.fromRGB(255, 255, 255)
	duration = duration or 1

	-- Create ring
	local ring = Instance.new("Part")
	ring.Anchored = true
	ring.CanCollide = false
	ring.Shape = Enum.PartType.Cylinder
	ring.Size = Vector3.new(0.5, 1, 1)
	ring.Position = position
	ring.CFrame = CFrame.new(position) * CFrame.Angles(0, 0, math.rad(90))
	ring.Material = Enum.Material.Neon
	ring.Color = color
	ring.Transparency = 0.5
	ring.Parent = workspace

	-- Expand
	local expand = TweenService:Create(
		ring,
		TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{
			Size = Vector3.new(0.5, size, size),
			Transparency = 1
		}
	)
	expand:Play()

	Debris:AddItem(ring, duration)
end

-- ========================================
-- ENERGY SPHERE (Charging effect)
-- ========================================

function AdvancedEffects.EnergySphere(parent, duration, color)
	duration = duration or 2
	color = color or Color3.fromRGB(100, 200, 255)

	local sphere = Instance.new("Part")
	sphere.Shape = Enum.PartType.Ball
	sphere.Size = Vector3.new(0.5, 0.5, 0.5)
	sphere.Material = Enum.Material.Neon
	sphere.Color = color
	sphere.Transparency = 0.3
	sphere.CanCollide = false
	sphere.Anchored = true
	sphere.Parent = parent

	-- Keep position synced
	local connection
	connection = game:GetService("RunService").Heartbeat:Connect(function()
		if parent and parent.Parent then
			sphere.Position = parent.Position
		else
			connection:Disconnect()
			sphere:Destroy()
		end
	end)

	-- Pulse
	local pulse = TweenService:Create(
		sphere,
		TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, -1, true),
		{
			Size = Vector3.new(3, 3, 3),
			Transparency = 0.8
		}
	)
	pulse:Play()

	-- Sparkles
	local sparkles = Instance.new("Sparkles")
	sparkles.SparkleColor = color
	sparkles.Parent = sphere

	-- Remove after duration
	task.delay(duration, function()
		connection:Disconnect()
		pulse:Cancel()

		local shrink = TweenService:Create(
			sphere,
			TweenInfo.new(0.3),
			{Size = Vector3.new(0, 0, 0)}
		)
		shrink:Play()

		Debris:AddItem(sphere, 0.3)
	end)

	return sphere
end

-- ========================================
-- FORCE FIELD (Protective barrier)
-- ========================================

function AdvancedEffects.ForceField(character, duration, color)
	duration = duration or 10
	color = color or Color3.fromRGB(100, 200, 255)

	-- Create sphere around character
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end

	local barrier = Instance.new("Part")
	barrier.Shape = Enum.PartType.Ball
	barrier.Size = Vector3.new(8, 8, 8)
	barrier.Material = Enum.Material.ForceField
	barrier.Color = color
	barrier.Transparency = 0.7
	barrier.CanCollide = false
	barrier.Anchored = true
	barrier.Parent = workspace

	-- Keep position synced
	local connection
	connection = game:GetService("RunService").Heartbeat:Connect(function()
		if rootPart and rootPart.Parent then
			barrier.Position = rootPart.Position
		else
			connection:Disconnect()
			barrier:Destroy()
		end
	end)

	-- Sparkles on barrier
	local sparkles = Instance.new("Sparkles")
	sparkles.SparkleColor = color
	sparkles.Parent = barrier

	-- Remove after duration
	task.delay(duration, function()
		connection:Disconnect()

		local fade = TweenService:Create(
			barrier,
			TweenInfo.new(0.5),
			{Transparency = 1}
		)
		fade:Play()

		Debris:AddItem(barrier, 0.5)
	end)

	return barrier
end

-- ========================================
-- LIGHTNING ARC (Between two points)
-- ========================================

function AdvancedEffects.LightningArc(startPos, endPos, color, segments)
	color = color or Color3.fromRGB(200, 200, 255)
	segments = segments or 8

	local attachments = {}
	local beams = {}

	-- Create segments
	for i = 0, segments do
		local t = i / segments
		local basePos = startPos:Lerp(endPos, t)

		-- Add random offset (except endpoints)
		local offset = Vector3.new(0, 0, 0)
		if i > 0 and i < segments then
			offset = Vector3.new(
				math.random(-3, 3),
				math.random(-3, 3),
				math.random(-3, 3)
			)
		end

		local part = Instance.new("Part")
		part.Anchored = true
		part.CanCollide = false
		part.Transparency = 1
		part.Size = Vector3.new(0.1, 0.1, 0.1)
		part.Position = basePos + offset
		part.Parent = workspace

		local attachment = Instance.new("Attachment", part)
		table.insert(attachments, {part = part, attachment = attachment})
	end

	-- Create beams between segments
	for i = 1, #attachments - 1 do
		local beam = Instance.new("Beam")
		beam.Attachment0 = attachments[i].attachment
		beam.Attachment1 = attachments[i + 1].attachment
		beam.Color = ColorSequence.new(color)
		beam.Width0 = 0.5
		beam.Width1 = 0.5
		beam.Texture = "rbxassetid://1084983440"
		beam.TextureSpeed = 3
		beam.LightEmission = 1
		beam.FaceCamera = true
		beam.Parent = attachments[i].part

		table.insert(beams, beam)
	end

	-- Animate and cleanup
	task.delay(0.3, function()
		for _, data in ipairs(attachments) do
			data.part:Destroy()
		end
	end)
end

print("✅ AdvancedEffects loaded")
return AdvancedEffects
