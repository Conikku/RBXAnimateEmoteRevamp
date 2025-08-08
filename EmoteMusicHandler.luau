-- MusicEmoteServer.lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")

-- Create RemoteEvent if it doesn't exist
local musicRemoteEvent = ReplicatedStorage:FindFirstChild("PlayMusicEmote")
if not musicRemoteEvent then
	musicRemoteEvent = Instance.new("RemoteEvent")
	musicRemoteEvent.Name = "PlayMusicEmote"
	musicRemoteEvent.Parent = ReplicatedStorage
end

-- Table to track each player's current music
local playerMusic = {}

-- Function to stop a player's current music
local function stopPlayerMusic(player)
	if playerMusic[player.UserId] then
		local sound = playerMusic[player.UserId]
		if sound then
			pcall(function()
				sound:Stop()
				sound:Destroy()
			end)
		end
		playerMusic[player.UserId] = nil
	end
end

-- Function to play music for a player
local function playMusicForPlayer(player, soundId)
	-- Stop any existing music for this player
	stopPlayerMusic(player)

	-- Create new sound
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://" .. soundId
	sound.Volume = 0.5
	sound.Looped = true

	-- Parent to the player's character or workspace
	if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		sound.Parent = player.Character.HumanoidRootPart
	else
		sound.Parent = workspace
	end

	-- Play the sound
	sound:Play()

	-- Store reference
	playerMusic[player.UserId] = sound

	-- Clean up when sound ends
	sound.Ended:Connect(function()
		if playerMusic[player.UserId] == sound then
			playerMusic[player.UserId] = nil
		end
	end)
end

-- Handle remote event
musicRemoteEvent.OnServerEvent:Connect(function(player, action, soundId, userId)
	if action == "play" and soundId and userId == player.UserId then
		-- Stop any existing music first
		if playerMusic[player.UserId] then
			playerMusic[player.UserId]:Stop()
			playerMusic[player.UserId]:Destroy()
		end
		playMusicForPlayer(player, soundId)
	elseif action == "stop" then
		stopPlayerMusic(player)
	end
end)

-- Clean up when player leaves
Players.PlayerRemoving:Connect(function(player)
	stopPlayerMusic(player)
end)
