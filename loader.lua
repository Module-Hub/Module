local UI = game:GetObjects("rbxassetid://11399990461")[1]

if gethui then
	UI.Parent = gethui()
elseif syn.protect_gui then
	syn.protect_gui(UI)
	UI.Parent = game.CoreGui
else
	UI.Parent = game.CoreGui
end
wait(10)
UI:Destroy()

local plr = game:GetService("Players").LocalPlayer
local whitelist = { "z_t0ht" }

if table.find(whitelist, plr.Name) then
	getgenv().SecureMode = true
	local espLibrary =
		loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Sirius/main/library/esp/esp.lua"))()
	local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/Module-Hub/Source/main/raysource"))()
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

	getgenv().mode = "Summer"
	getgenv().DefaultCam = 1
	getgenv().restock = true
	getgenv().autofarm = true

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
		USE_FALLBACK = false, -- Enables an emergency "fallback mode" for StreamingEnabled games
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

	-- services
	local players = game:GetService("Players")
	local workspace = game:GetService("Workspace")
	local runService = game:GetService("RunService")
	local inputService = game:GetService("UserInputService")
	local networkClient = game:GetService("NetworkClient")
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

	local localplayer = Window:CreateTab("Localplayer", 7743876054) -- Title, Image

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

	local Section = localplayer:CreateSection("RTX Graphics")
	local Button = localplayer:CreateButton({
		Name = "RTX Graphics",
		Callback = function() end,
	})

	local Section = localplayer:CreateSection("UI Settings")
	local Button = localplayer:CreateButton({
		Name = "Destroy Module UI",
		Callback = function()
			Rayfield:Destroy()
		end,
	})

	local Section = localplayer:CreateSection("GPUSAVER")
	local Button = localplayer:CreateButton({
		Name = "GPUSaver",
		Callback = function()
			loadstring(game:HttpGet("https://personal.zt0ht.repl.co/Storage/gpu.lua"))()
		end,
	})

	local Section = localplayer:CreateSection("Advanced ESP")
	local Button = localplayer:CreateButton({
		Name = "Load ESP",
		Callback = function()
			espLibrary:Load()
		end,
	})

	local DR = Window:CreateTab("Games", 7733799901) -- Title, Image

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

	local Section = DR:CreateSection("Car Racing Games")
	local Button = DR:CreateButton({
		Name = "Ryzen V2",
		Callback = function()
			loadstring(game:HttpGet("https://zinedin.zt0ht.repl.co/Storage/HarkedV2.lua"))()
		end,
	})

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

	local Section = DR:CreateSection("Phantom Forces")
	local Button = DR:CreateButton({
		Name = "Module Phantom Forces",
		Callback = function()
			loadstring(game:HttpGet("https://personal.zt0ht.repl.co/Storage/universal.lua"))()
		end,
	})

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

	local Utilities = Window:CreateTab("Utilities", 7734021047)

	local Section = Utilities:CreateSection("Player Rader")
	local Button = Utilities:CreateButton({
		Name = "Player Rader",
		Callback = function()
			loadstring(game:HttpGet("https://zinedin.zt0ht.repl.co/Storage/Rader.lua"))()
		end,
	})

	local Section = Utilities:CreateSection("Backdoor Executor")
	local Button = Utilities:CreateButton({
		Name = "Backdoor Executor",
		Content = "ServerSided Executor",
		Callback = function()
			loadstring(game:HttpGet("https://zinedin.zt0ht.repl.co/Storage/Backdoor.lua", true))()
		end,
	})

	local Section = Utilities:CreateSection("Backdoor Scanner")
	local Button = Utilities:CreateButton({
		Name = "Backdoor Scanner",
		Callback = function()
			loadstring(game:HttpGet("https://zinedin.zt0ht.repl.co/Storage/scanner.lua", true))()
		end,
	})

	local Section = Utilities:CreateSection("Function Spy")
	local Button = Utilities:CreateButton({
		Name = "Function Spy",
		Callback = function()
			loadstring(game:HttpGet("https://zinedin.zt0ht.repl.co/Storage/Functionspy.lua", true))()
		end,
	})

	local Section = Utilities:CreateSection("Infinite Yield")
	local Button = Utilities:CreateButton({
		Name = "Infinite Yield",
		Callback = function()
			loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source", true))()
		end,
	})

	local Section = Utilities:CreateSection("SimpleSpy")
	local Button = Utilities:CreateButton({
		Name = "SimpleSpy",
		Callback = function()
			loadstring(game:HttpGet("https://zinedin.zt0ht.repl.co/Storage/simplespy.lua", true))()
		end,
	})

	local Section = Utilities:CreateSection("RemoteSpy")
	local Button = Utilities:CreateButton({
		Name = "RemoteSpy",
		Callback = function()
			loadstring(game:HttpGet("https://cdn.synapse.to/synapsedistro/hub/RemoteSpy.lua", true))()
		end,
	})

	local Section = Utilities:CreateSection("DarkDex")
	local Button = Utilities:CreateButton({
		Name = "DarkDex",
		Callback = function()
			loadstring(game:HttpGet("https://zinedin.zt0ht.repl.co/Storage/darkdex.lua", true))()
		end,
	})

	local Section = Utilities:CreateSection("ScriptDumper")
	local Button = Utilities:CreateButton({
		Name = "ScriptDumper",
		Callback = function()
			loadstring(game:HttpGet("https://zinedin.zt0ht.repl.co/Storage/scriptdumper.lua", true))()
		end,
	})

	local Credits = Window:CreateTab("Notes", 7733914390)

	local Paragraph = Credits:CreateParagraph({ Title = "Warning", Content = "Utilities is still in beta" })
	local Paragraph = Credits:CreateParagraph({ Title = "Warning", Content = "Dangerous Speeds is still in beta" })
	local Paragraph = Credits:CreateParagraph({ Title = "Warning", Content = "Localplayer is still in beta" })
	Rayfield:LoadConfiguration()
end
