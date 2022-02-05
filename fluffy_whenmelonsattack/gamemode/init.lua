AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
local LastMelonSpawnCount = 0;
local NextRoundLength = 60;

-- Used to override default functionality on FFA round end
function GM:GetWinningPlayer()
    return nil
end


-- No weapons
function GM:PlayerLoadout(ply)
    ply:SetupHands()
    ply:SetJumpPower(250)
    ply:SetWalkSpeed(250)
    ply:SetRunSpeed(350)
   --loadout thing here 
    ply:Give( "weapon_pistol" )
    ply:GiveAmmo(10000,"Pistol");
    HandlePlayerUpgrades(ply, false)
end

function HandlePlayerUpgrades(ply, notify)
    local msg = nil
    if ply:Frags() >= 10 then
        if not ply:HasWeapon("weapon_smg1") then
        
            ply:Give("weapon_smg1")
            ply:GiveAmmo(500,"SMG1")
            ply:SelectWeapon("weapon_smg1")
            msg = 'SMG Unlocked'
        end
    end
    if ply:Frags() >= 25 then
        if not ply:HasWeapon("weapon_shotgun") then
        
            ply:Give("weapon_shotgun")
            ply:GiveAmmo(250,"Buckshot")
            ply:SelectWeapon("weapon_shotgun")
            msg = 'Shotgun Unlocked'
        end
    end
    if ply:Frags() >= 50 then
        if not ply:HasWeapon("weapon_rpg") then
        
            ply:Give("weapon_rpg")
            ply:GiveAmmo(10,"RPG_Round")
            ply:SelectWeapon("weapon_rpg")
            msg = 'RPG Grenades Unlocked'
        end
    end
    if not notify then return end
    GAMEMODE:PlayerOnlyAnnouncement(ply, 3, msg, 1, "top")
end



hook.Add("PreRoundStart", "SpawnMelons", function()
    -- Ensure our melon spawner exists and spawn melons based on round length and player count
    CreateMelonSpawner()

    --We need to spawn melons too
    SpawnMoreMelons()
end)


function CreateMelonSpawner()
    print("Melon Spawner Called")
    local melonSpawner = ents.FindByClass( "spawner" )
    if IsValid(melons) == false then
        MelonSpawnerEntity = ents.Create( "spawner" )
        --Check its valid
        if (  !IsValid( MelonSpawnerEntity ) ) then return end
        --Spawn it in - Its location is hard coded against the spawner entity because I am lazy
        print("Melon Spawner Created")
        MelonSpawnerEntity:Spawn()
    end
 end

function SpawnMoreMelons()
    local roundNum = GAMEMODE:GetRoundNumber() + 1
    --Now we need the melon spawner to create us some lovely melons
    local playerCount = player.GetCount()
    if playerCount > 6 then
        playerCount = math.Round(playerCount / 2) 
    end
    local melonsToSpawn = (playerCount * GAMEMODE.MaxMelonPerPerson) * math.Round(roundNum / 2)
    melonsToSpawn = math.Round(melonsToSpawn,0)
    print("Attempting to spawn "..melonsToSpawn.." melons")
    local melons = ents.FindByClass( "jumper" )
    melonCount = table.Count(melons)
    
    if (  !IsValid( MelonSpawnerEntity ) ) then 
        print("Unable To Find Melon Spawner")
        return 
    end
    --Check we are not trying to spawn more than we should
    if (melonsToSpawn + melonCount) > GAMEMODE.MaxMelonCount then
        melonsToSpawn = GAMEMODE.MaxMelonCount - melonCount
        print("Reducing spawm amount to "..melonsToSpawn.." melons")
    end
    if((melonsToSpawn + melonCount) <= GAMEMODE.MaxMelonCount) then
        if melonsToSpawn > 0 then
            --Alert the player somehow here
            MelonSpawnerEntity:spawnJumpers( melonsToSpawn, GAMEMODE.RoundCooldown)
        end
        LastMelonSpawnCount = melonsToSpawn
    else 
        print("Unable to spawn "..melonsToSpawn.." more melons as we have exceeded the limit of "..GAMEMODE.MaxMelonCount)
    end

end



-- Called just before the round starts
-- Cleans up the map and resets round data
function GM:PreStartRound()
    local round = GAMEMODE:GetRoundNumber()

    -- Make sure we have enough players to start the next round
    if not GAMEMODE:CanRoundStart() then
        SetGlobalString("RoundState", "GameNotStarted")

        return
    end
    -- Reset stuff
    --game.CleanUpMap()
    --hook.Call("PostCleanup")

    -- End the game if needed
    -- Different gamemode round types have different logic
    if GAMEMODE.RoundType == "default" then
        -- End the game once all the rounds have been played
        if round >= GAMEMODE.RoundNumber then
            GAMEMODE:EndGame()

            return
        end
    elseif GAMEMODE.RoundType == "timed" then
        -- End the game if the game has exceeded the time limit
        local gametime = GetGlobalFloat("GameStartTime", -1)

        if gametime > -1 and gametime + GAMEMODE.GameTime < CurTime() then
            GAMEMODE:EndGame()

            return
        end
    elseif GAMEMODE.RoundType == "timed_endless" then
        -- This gamemode should only have one round
        -- Timing is handled in the Think hook - see below
        if round >= 1 then
            GAMEMODE:EndGame()

            return
        end
    end

    -- Set global round data
    SetGlobalInt("RoundNumber", round + 1)
    SetGlobalString("RoundState", "PreRound")
    SetGlobalFloat("RoundStart", CurTime())
    hook.Call("PreRoundStart")

    -- Respawn everybody & freeze them until the round actually starts
    -- This has a timer to allow for any map entity editing to take place
    timer.Simple(FrameTime(), function()
        for k, v in pairs(player.GetAll()) do
            -- Add round points to anyone that isn't spectating
            if (not GAMEMODE.TeamBased and v:Team() ~= TEAM_SPECTATOR) or (GAMEMODE.TeamBased and v:Team() ~= TEAM_UNASSIGNED and v:Team() ~= TEAM_SPECTATOR) then
                v:AddStatPoints("Rounds Played", 1)
            end

            if not v:Alive() then
                v:Spawn()
            end
        end
    end)
    -- Start the round after a short cooldown
    timer.Simple(GAMEMODE.RoundCooldown, function()
        GAMEMODE:StartRound()
    end)
end

--To make the round longer each time
GM.RoundTime = function()
    return 60 * GAMEMODE:GetRoundNumber()
end



-- Handles the victory which is just a tally of melons killed
function GM:HandleFFAWin(reason)
    local winner = nil -- Default: everyone sucks
    local msg = "The round has ended!"

    local melons = ents.FindByClass( "jumper" )
    melonCount = table.Count(melons)
    local round = GAMEMODE:GetRoundNumber()
	if round >= GAMEMODE.RoundNumber then
		msg = "The battle is over! Rest easy soldier"
	else
		msg = melonCount.." melons are left alive, and more are incoming!"
	end
  

    return winner, msg
end



--Over writing this so we know that a MELON killed a player rather than a "Jumper"
function GM:PlayerDeath( ply, inflictor, attacker )

    -- Don't spawn for at least 2 seconds
    ply.NextSpawnTime = CurTime() + 2
    ply.DeathTime = CurTime()

    if ( IsValid( attacker ) && attacker:GetClass() == "trigger_hurt" ) then attacker = ply end

    if ( IsValid( attacker ) && attacker:IsVehicle() && IsValid( attacker:GetDriver() ) ) then
        attacker = attacker:GetDriver()
    end

    if ( !IsValid( inflictor ) && IsValid( attacker ) ) then
        inflictor = attacker
    end

    -- Convert the inflictor to the weapon that they're holding if we can.
    -- This can be right or wrong with NPCs since combine can be holding a
    -- pistol but kill you by hitting you with their arm.
    if ( IsValid( inflictor ) && inflictor == attacker && ( inflictor:IsPlayer() || inflictor:IsNPC() ) ) then

        inflictor = inflictor:GetActiveWeapon()
        if ( !IsValid( inflictor ) ) then inflictor = attacker end

    end

    player_manager.RunClass( ply, "Death", inflictor, attacker )

    if ( attacker == ply ) then

        net.Start( "PlayerKilledSelf" )
            net.WriteEntity( ply )
        net.Broadcast()

        MsgAll( attacker:Nick() .. " suicided!\n" )

    return end

    net.Start( "PlayerKilled" )

        net.WriteEntity( ply )
        net.WriteString( inflictor:GetClass() )
        net.WriteString( attacker:GetName() )

    net.Broadcast()

    MsgAll( ply:Nick() .. " was killed by " .. attacker:GetName() .. "\n" )

    timer.Simple(GAMEMODE.RespawnTime, function() ply:Spawn() end)

end


hook.Add("RoundStart", "AnnounceMelonsAlive", function()
    local melons = ents.FindByClass( "jumper" )
    melonCount = table.Count(melons)
    local title = "The melons are attacking!"
    local subtext =  (melonCount.." angry melons left to destroy")
    GAMEMODE:PulseAnnouncementTwoLine(10, title, subtext, 1.5, "bottom")
end)



-- Register XP for Duck Hunt
hook.Add("RegisterStatsConversions", "AddWhenMelonsAttackConversions", function()
    GAMEMODE:AddStatConversion("Melons Killed", "Melons Killed", 1)
end)

function CheckPlayerUpgrades()
    for k, v in pairs(player.GetAll()) do
        if v:Alive() then
           HandlePlayerUpgrades(v, true)
        end
     end
end

timer.Create( "CheckPlayerUpgrades", 1,0, CheckPlayerUpgrades )

