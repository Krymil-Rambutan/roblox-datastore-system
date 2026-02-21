--// Persistent Player Data System
--// Portfolio Version
--// Saves: Money + Level
--// Auto Save + Safe Loading

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local dataStore = DataStoreService:GetDataStore("PlayerData_v1")

local AUTO_SAVE_INTERVAL = 60 -- seconds

-- Default Data Template
local defaultData = {
	Money = 0,
	Level = 1
}

-- Create leaderstats
local function createLeaderstats(player, data)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player
	
	local money = Instance.new("IntValue")
	money.Name = "Money"
	money.Value = data.Money
	money.Parent = leaderstats
	
	local level = Instance.new("IntValue")
	level.Name = "Level"
	level.Value = data.Level
	level.Parent = leaderstats
end

-- Load Data
local function loadData(player)
	local success, data = pcall(function()
		return dataStore:GetAsync(player.UserId)
	end)

	if success and data then
		return data
	else
		return table.clone(defaultData)
	end
end

-- Save Data
local function saveData(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return end
	
	local dataToSave = {
		Money = leaderstats.Money.Value,
		Level = leaderstats.Level.Value
	}
	
	pcall(function()
		dataStore:SetAsync(player.UserId, dataToSave)
	end)
end

-- Player Join
Players.PlayerAdded:Connect(function(player)
	local data = loadData(player)
	createLeaderstats(player, data)
end)

-- Auto Save Loop
task.spawn(function()
	while true do
		task.wait(AUTO_SAVE_INTERVAL)
		for _, player in pairs(Players:GetPlayers()) do
			saveData(player)
		end
	end
end)

-- Save On Leave
Players.PlayerRemoving:Connect(function(player)
	saveData(player)
end)

-- Save On Shutdown
game:BindToClose(function()
	for _, player in pairs(Players:GetPlayers()) do
		saveData(player)
	end
end)
