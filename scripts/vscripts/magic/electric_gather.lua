require('shoot_init')
require('skill_operation')
require('player_power')
function createShoot(keys)
    local caster = keys.caster
    local ability = keys.ability
    local skillPoint = ability:GetCursorPosition()
    local speed = ability:GetSpecialValueFor("speed")
    local max_distance = ability:GetSpecialValueFor("max_distance")

    local casterPoint = caster:GetAbsOrigin()
    local direction = (skillPoint - casterPoint):Normalized()


    local shootPosTable ={}
    local angle23 = 0.45 * math.pi

    local newX2 = math.cos(math.atan2(direction.y, direction.x) - angle23)
    local newY2 = math.sin(math.atan2(direction.y, direction.x) - angle23)
    local newX3 = math.cos(math.atan2(direction.y, direction.x) + angle23)
    local newY3 = math.sin(math.atan2(direction.y, direction.x) + angle23)
    local direction2 = Vector(newX2, newY2, direction.z)
    local direction3 = Vector(newX3, newY3, direction.z)

    local shootPos2 = casterPoint + direction2 * 60
    table.insert(shootPosTable,shootPos2)
    local shootPos3 = casterPoint + direction3 * 60
    table.insert(shootPosTable,shootPos3)


    initDurationBuff(keys)

    for i = 1, 2, 1 do
        local shootPos = shootPosTable[i]
        local shoot = CreateUnitByName(keys.unitModel, shootPos, true, nil, nil, caster:GetTeam())
        shootPos = Vector(shootPos.x,shootPos.y,shootPos.z+100)
        shoot:SetAbsOrigin(shootPos)
        local shootDirection = (skillPoint - shoot:GetAbsOrigin()):Normalized()
        creatSkillShootInit(keys,shoot,caster,max_distance,shootDirection)
        --shoot.aoe_radius = aoe_radius
        local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
        ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
        shoot.particleID = particleID
        EmitSoundOn(keys.soundCastSp1, shoot)

		moveElectricGatherSp1(keys,shoot)
   
    end

end

function moveElectricGatherSp1(keys,shoot)
	local caster = keys.caster
	local ability = keys.ability
	local pull_back_distance = ability:GetSpecialValueFor("pull_back_distance") 
	local charge_time = ability:GetSpecialValueFor("charge_time") 
	local charge_interval =  ability:GetSpecialValueFor("charge_interval")
    local max_distance = ability:GetSpecialValueFor("max_distance")

	local playerID = caster:GetPlayerID()
	local speedBase = ability:GetSpecialValueFor("speed")

	local timeCount = 0
	caster.electric_gather_send = 0
	shoot.traveled_back_distance = 0
	Timers:CreateTimer(function()

		if caster.electric_gather_send == 1 then
			shoot.speed = 0
			max_distance = max_distance + shoot.traveled_back_distance
			local shootDirection = shoot.direction * -1
			
			Timers:CreateTimer(charge_time/2,function()
				EmitSoundOn(keys.soundCastSp2, shoot)
				creatSkillShootInit(keys,shoot,caster,max_distance,shootDirection)
				return nil
			end)
			return nil
		end
		--local maxSpeed = getFinalValueOperation(playerID,speedBase,'ability_speed',shoot.abilityLevel,nil) * GameRules.speedConstant * 0.02
		timeCount = timeCount + charge_interval

		shoot.speed = pull_back_distance * 2 / (charge_time * charge_time) *  (charge_time - timeCount) * 0.02

		--print(timeCount)
		shoot.traveled_back_distance = shoot.traveled_back_distance + shoot.speed
		
		return charge_interval
	end)
	
	shoot.direction = shoot.direction * -1

	moveShoot(keys, shoot, electricGatherBoomCallBack, nil)
end

function electricGatherSend(keys)
	local caster = keys.caster
	caster.electric_gather_send = 1
end

function electricGatherChargeInit(keys)
	local caster = keys.caster
	local ability = keys.ability
	local charge_damage_per_interval = ability:GetSpecialValueFor("charge_damage_per_interval")
	ability.electric_gather_damage_bouns = 0.0
	ability.electric_gather_damage_bouns = ability.electric_gather_damage_bouns + charge_damage_per_interval

end

function electricGatherCharge(keys)
	local caster = keys.caster
	local ability = keys.ability
	local charge_damage_per_interval = ability:GetSpecialValueFor("charge_damage_per_interval")
	ability.electric_gather_damage_bouns = ability.electric_gather_damage_bouns + charge_damage_per_interval
end



function electricGatherBoomCallBack(shoot)
	electricGatherBoomAOERenderParticles(shoot)
    boomAOEOperation(shoot, electricGatherAOEOperationCallback)
end
function electricGatherBoomAOERenderParticles(shoot)
	local particlesName = shoot.particles_boom
	local newParticlesID = ParticleManager:CreateParticle(particlesName, PATTACH_ABSORIGIN_FOLLOW , shoot)
	ParticleManager:SetParticleControlEnt(newParticlesID, shoot.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
end

function electricGatherAOEOperationCallback(shoot,unit)
	local keys = shoot.keysTable
    local caster = keys.caster
	local ability = keys.ability
	--print("electricGatherAOEOperationCallback:",ability.electric_gather_damage_bouns)
    local damage = (getApplyDamageValue(shoot)  + ability.electric_gather_damage_bouns) / 2

    ApplyDamage({victim = unit, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})
end


