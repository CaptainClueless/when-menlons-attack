DeriveGamemode("fluffy_mg_base")
GM.Name = "When Melons Attack"
GM.Author = "Captain SemiColon"
GM.HelpText = [[
    Its a war against the melons
    
    Battle your way through hordes of melons and see if you can survive
]]

GM.TeamBased = false -- Is the gamemode FFA or Teams?
GM.Elimination = false
GM.RoundNumber = 3 -- How many rounds?
GM.RoundTime = function()
    return 60 * GAMEMODE:GetRoundNumber()
end
GM.ThirdpersonEnabled = true
GM.DeathSounds = true
GM.MinPlayers = 1               -- 1 person can play this if they wanted to 


--The above should be multiplied by the round length to go 1 min ,2 min, 3 min 

GM.HUDStyle = HUD_STYLE_DEFAULT 
GM.RoundCooldown = 10
GM.SpawnProtection = true;
GM.SpawnProtectionTime = 2 -- Increased spawn protection time for runners
GM.DeathLingerTime = 5

GM.MaxMelonCount = 150 --A sanity check for ensuring we dont spam the server with melons and crash it
GM.MaxMelonPerPerson = 10

function GM:Initialize()
end
