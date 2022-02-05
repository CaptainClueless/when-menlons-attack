AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
 
include("shared.lua")
 -- This is a hardcoded list of maps we know about
spawnerLocations = {
	 ['gm_construct'] = Vector(-929, 176, -84),
	 ['cs_italy'] = Vector(-93.762573, 1183.321045, -95.968750),
	 ['cs_assault'] = Vector(5725.124512, 4889.707520, -394.920502),
	 ['cs_compound'] = Vector(2935.683594, -50.051316, 65.219406),
	 ['cs_havana'] = Vector( -50.342026, 250, 279),
	 ['cs_militia'] = Vector( 387.796722, 1044.647217, 198.791092),
	 ['cs_office'] = Vector(-1004.329712, -742.296570, -263.917847),
	 ['de_aztec'] = Vector(-1763.717529, -383.823395, -156.532394),
	 ['de_tides'] = Vector(558.745728, -441.980927, 64.031250),
	 ['de_port'] = Vector(1178.941162, 856.959290, 1048.031250),
	 ['ttt_apehouse'] = Vector(-539.948425, 1694.375122, 64.031250),
	 ['ttt_bb_suburbia_b3'] = Vector(8.800400, -1272.516724, 64.031250),
	 ['ttt_bb_teenroom_b2'] = Vector(992.174744, -313.162231, 1264.031250),
	-- ['ttt_fallout'] = Vector(-1041.495605, 459.845642, 192.720032), --Players spawn in a wall
	 ['ttt_island_2013'] = Vector(-524.239868, 1242.552002, 625.465698),
	 

}

spawnerAngle = {
	['gm_construct'] = Angle(0, 180, 0),
	['cs_italy'] = Angle(0, 90, 0),
	['cs_assault'] = Angle(0, 180, 12),
	['cs_compound'] = Angle(0, 20, 0),
	['cs_havana'] = Angle(0, 90, 0),
	['cs_militia'] = Angle(0, 90, 0),
	['cs_office'] = Angle(0, 0, 0),
	['de_aztec'] = Angle(0, 90, 0),
	['de_tides'] = Angle(0, 90, 0),
	['de_port'] = Angle(0, 90, 0),
	['ttt_apehouse'] = Angle(0, 90, 0),
	['ttt_bb_suburbia_b3'] = Angle(0, 90, 0),
	['ttt_bb_teenroom_b2'] = Angle(0, 90, 0),
	--['ttt_fallout'] = Angle(0, 90, 0),
	['ttt_island_2013'] = Angle(0, 120, 0),
}

local laughs = {"vo/ravenholm/madlaugh02.wav","vo/ravenholm/madlaugh01.wav","vo/ravenholm/madlaugh03.wav","vo/ravenholm/madlaugh04.wav"}

model_file = "models/props_junk/TrashDumpster02.mdl";

function ENT:Initialize()
		self:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
		self:SetMoveType( MOVETYPE_NONE )   -- after all, gmod is a physics
		self:SetSolid( SOLID_VPHYSICS )         -- Toolbox
		self:SetPos(spawnerLocations[game.GetMap()])
		self:SetAngles(spawnerAngle[game.GetMap()])
		self:SetModel(model_file)
end


function ENT:spawnJumpers(count, roundBreakTIme)
	
	local speedToSpawn = roundBreakTIme / count
	
	print("I need to spawn "..count.." jumpers using "..speedToSpawn.." delay")
	for i=1,count do 
		timer.Simple( (speedToSpawn * i), function() launchMelon() end )
	end
end

function launchMelon() 

	local ent = ents.Create( "jumper" )
	if (  !IsValid( ent ) ) then
		print("Jumper not valid")
	else
		ent:SetPos( Vector(spawnerLocations[game.GetMap()][1],spawnerLocations[game.GetMap()][2], spawnerLocations[game.GetMap()][3] + 5  ))
		ent:SetModel( "models/props_junk/watermelon01.mdl" )
		ent:SetName('Angry Melon')
		ent:SetHealth(math.random(5,25))
		ent:Spawn()
		ent:Activate()
		
		
		local phys = ent:GetPhysicsObject()
		if (  !IsValid( phys ) ) then 
			ent:Remove() 
			print("Failed to create a valid physics object")
		else 
			local velocity = Vector(math.random(-100,100), math.random(-100,100), math.random(50,100))
			velocity = velocity * 100 
			velocity = velocity + ( VectorRand() * 100 ) -- a random element
			phys:ApplyForceCenter( velocity )
			ent:EmitSound(table.Random(laughs), 500, math.random(120,250))
		end
	end
end

--It can and will spawn random ammo crates for each round too
function launchAmmoCrates()

end


