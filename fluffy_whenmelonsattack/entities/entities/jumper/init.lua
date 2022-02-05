AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
 
include("shared.lua")
function ENT:Initialize()
	self:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
	self:SetSolid( SOLID_VPHYSICS )         -- Toolbox
	self:SetModel( "models/props_junk/watermelon01.mdl" )
	self:SetName("Angry Melon")
		
end

function ENT:Think()


local phys = self:GetPhysicsObject()
		jump(phys, self) 
	    self:NextThink( CurTime() + math.random(0,10)) -- Make sure that Think() is called.
 return true
        
end

function jump(phys, self)
	local Players = player.GetAll()
	local v = table.Random(Players) -- get a list of all player locations
	if  IsValid(v) == false then 
		print("Melon was unable to find a valid target")
		return 
	end
	local selfEntPos = phys:GetPos()
	local playerPos = v:GetPos()
	local entVector =  (phys:GetPos()- Vector(0,100,100)) - v:GetPos()
	
	propSpeed = math.random(1,100)
	if GAMEMODE:InRound() then
		if selfEntPos:Distance( playerPos ) < 10000	then
			phys:ApplyForceCenter(  playerPos - entVector * propSpeed )
			--Get the props health
			current_hp = self:Health()
			if current_hp < 15 then
				current_hp = 15
			end
			--Give them enough health to ignite and survive it
			self:SetHealth(current_hp)
			--Ignite it for 1 second
			self:Ignite(1)
		
		
		end
	else
		--phys:ApplyForceCenter(  Vector(0,0,25) * math.random(10,propSpeed) )
	end
end


function ENT:Touch( hitEnt )
	local damage_to_inflict = math.Round(math.abs(self:GetVelocity()[1]) / 8);
 	if ( hitEnt:IsPlayer() ) then
		if GAMEMODE:InRound() then
			local dmginfo = DamageInfo()
			dmginfo:SetDamage(damage_to_inflict)
			dmginfo:SetDamageForce(self:GetVelocity())
			dmginfo:SetDamageType(DMG_BURN)
			dmginfo:SetAttacker(self)
			--dmginfo:SetInflictor(game.GetWorld())
			hitEnt:TakeDamageInfo(dmginfo)
		end
	end
 end

function ENT:OnTakeDamage(dmg)

	--print(self:Health())
     -- React physically when getting shot/blown
	local laughs = {"vo/ravenholm/madlaugh02.wav","vo/ravenholm/madlaugh01.wav","vo/ravenholm/madlaugh03.wav","vo/ravenholm/madlaugh04.wav"}
    
	local attacker = dmg:GetAttacker()
    if not GAMEMODE:InRound() then 
    	--Just make them laugh at the player for being foolish and shooting them during the round break
		local phys = self:GetPhysicsObject()
			self:EmitSound(table.Random(laughs), 500, math.random(120,250))
			phys:ApplyForceCenter(  Vector(0,0,100) * math.random(10,100) )
	else
		self:TakePhysicsDamage(dmg);
		self:SetHealth( self:Health() - dmg:GetDamage() )
		if(self:Health() <= 0) then -- If our health-variable is zero or below it
			local phys = self:GetPhysicsObject()
			local selfEntPos = phys:GetPos()
			self:PrecacheGibs( )
			self:GibBreakClient(selfEntPos*100)
			self:Remove(); -- Remove our entity
			if IsValid(attacker) and attacker:IsPlayer() then
				attacker:AddFrags(1)
				GAMEMODE:AddStatPoints(attacker, "Melons Killed", 1)
			end
		end
	end
end



