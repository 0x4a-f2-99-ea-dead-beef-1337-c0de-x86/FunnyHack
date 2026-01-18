---@diagnostic disable: undefined-global

local cloneref = cloneref or function(...)
	return ...
end

local GetService = function(Service)
	return cloneref(game.GetService(game, Service))
end

--// Services

local Services = {
	RunService = GetService("RunService"),
	UserInputService = GetService("UserInputService"),
	HttpService = GetService("HttpService"),
	TweenService = GetService("TweenService"),
	StarterGui = GetService("StarterGui"),
	Players = GetService("Players"),
	StarterPlayer = GetService("StarterPlayer"),
	Lighting = GetService("Lighting"),
	ReplicatedStorage = GetService("ReplicatedStorage"),
	ReplicatedFirst = GetService("ReplicatedFirst"),
	TeleportService = GetService("TeleportService"),
	CoreGui = GetService("CoreGui"),
	--VirtualUser = GetService("VirtualUser"), -- Gets detected by some anti-cheats.
	Camera = workspace.CurrentCamera
}

--// Variables

local Variables = {
	LocalPlayer = Services.Players.LocalPlayer,
	Typing = false,
	Mouse = Services.Players.LocalPlayer:GetMouse()
}

--// Functions

local Functions = {
	GetService = clonefunction and clonefunction(GetService) or GetService,
	
	Encode = function(Table)
		return Table and type(Table) == "table" and Services.HttpService:JSONEncode(Table)
	end,

	Decode = function(String)
		return String and type(String) == "string" and Services.HttpService:JSONDecode(String)
	end,

	GetClosestPlayer = function(RequiredDistance, Part, Settings)
		RequiredDistance = RequiredDistance or 1 / 0
		Part = Part or "HumanoidRootPart"
		Settings = Settings or {false, false, false}

		local Target = nil

		for _, Value in next, Services.Players:GetPlayers() do
			if Value ~= Variables.LocalPlayer and Value.Character[Part] then
				if type(Settings) == "table" then
					if Settings[1] and Value.TeamColor == Variables.LocalPlayer.TeamColor then continue end
					if Settings[2] and Value.Character.Humanoid.Health <= 0 then continue end
					if Settings[3] and #(Services.Camera:GetPartsObscuringTarget({Value.Character[Part].Position}, Value.Character:GetDescendants())) > 0 then continue end
				end

				local Vector, OnScreen = Services.Camera:WorldToViewportPoint(Value.Character[Part].Position)
				local Distance = (Services.UserInputService:GetMouseLocation() - Vector2.new(Vector.X, Vector.Y)).Magnitude

				if Distance < RequiredDistance and OnScreen then
					RequiredDistance, Target = Distance, Value
				end
			end
		end

		return Target
	end,

	Recursive = function(Table, Callback)
		for Index, Value in next, Table do
			Callback(Index, Value)

			if type(Value) == "table" then
				Recursive(Value, Callback)
			end
		end
	end,

	GetPlayer = function(String)
		for _, Value in next, Services.Players:GetPlayers() do
			if string.sub(string.lower(Value.Name), 1, -1) == string.lower(String) then
				return Value
			end
		end
	end,

	WallCheck = function(Object, Blacklist)
		return #(Services.Camera:GetPartsObscuringTarget({Object}, type(Blacklist) == "table" and Blacklist or Object:GetDescendants())) > 0
	end,

	TeamCheck = function(Player)
		return Player.TeamColor == Variables.LocalPlayer.TeamColor
	end,

	AliveCheck = function(Player)
		return Player.Character:FindFirstChildOfClass("Humanoid").Health > 0
	end,
}

--// Main

for Index, Value in next, Services do
	getfenv(1)[Index] = Value
end

for Index, Value in next, Variables do
	getfenv(1)[Index] = Value
end

for Index, Value in next, Functions do
	getfenv(1)[Index] = Value
end

--// Managing

Services.UserInputService.TextBoxFocused:Connect(function()
	getfenv(1).Typing = true
end)

Services.UserInputService.TextBoxFocusReleased:Connect(function()
	getfenv(1).Typing = false
end)

--// Unload Function

getfenv(1).ED_UnloadFunctions = function()
	for Index, _ in next, Services do
		getfenv(1)[Index] = nil
	end

	for Index, _ in next, Variables do
		getfenv(1)[Index] = nil
	end

	for Index, _ in next, Functions do
		getfenv(1)[Index] = nil
	end
end