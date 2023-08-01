require('shoot_init')
require('skill_operation')
function createShoot(keys)
    local caster = keys.caster
    local ability = keys.ability
    local skillPoint = ability:GetCursorPosition()
    local casterPoint = caster:GetAbsOrigin()
    local speed = ability:GetSpecialValueFor("speed")
    local catch_radius = ability:GetSpecialValueFor("catch_radius")
    local max_distance = ability:GetSpecialValueFor("max_distance")
    
    local cast_distance = (skillPoint - casterPoint):Length2D()
    --(1 + 0.57 )--* (cast_distance / (max_distance - 200)))
    local real_distance = cast_distance * math.pi 
    local xPoint_distance = real_distance / 2

    local direction = (skillPoint - casterPoint):Normalized()

    local angle = 0.5 * math.pi
    local newX1 = math.cos(math.atan2(direction.y, direction.x) - angle)
    local newY1 = math.sin(math.atan2(direction.y, direction.x) - angle)
    local direction_sp1 = Vector(newX1, newY1, direction.z)

    
    local shoot = CreateUnitByName(keys.unitModel, casterPoint, true, nil, nil, caster:GetTeam())
    creatSkillShootInit(keys,shoot,caster,real_distance,direction_sp1)
    initDurationBuff(keys)
    shoot.catch_radius = catch_radius
    shoot.angle = angle
    shoot.xPoint_distance = xPoint_distance
    local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
    ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
    shoot.particleID = particleID
    EmitSoundOn(keys.soundCast, shoot)
    shoot.intervalCallBack = oBoomerangIntervalCallBack
    moveShoot(keys, shoot, oBoomerangBoomCallBack, nil)

end

--技能爆炸,单次伤害
function oBoomerangBoomCallBack(shoot)
    oBoomerangRenderParticles(shoot)
    boomAOEOperation(shoot, oBoomerangAOEOperationCallback)
end



function oBoomerangAOEOperationCallback(shoot,unit)
	local keys = shoot.keysTable
    local caster = keys.caster
	
	local ability = keys.ability
    
    local damage = getApplyDamageValue(shoot) 
    ApplyDamage({victim = unit, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})


	local AbilityLevel = shoot.abilityLevel
    local hitTargetDebuff = keys.hitTargetDebuff
	local playerID = caster:GetPlayerID()
    local debuffDuration = ability:GetSpecialValueFor("debuff_duration") --debuff持续时间
    debuffDuration = getFinalValueOperation(playerID,debuffDuration,'control',AbilityLevel,nil)
    debuffDuration = getApplyControlValue(shoot, debuffDuration)
    ability:ApplyDataDrivenModifier(caster, unit, hitTargetDebuff, {Duration = debuffDuration})  
    oBoomerangCatchRenderParticles(shoot, unit, debuffDuration)
    catchAOEOperationCallback(shoot, unit, debuffDuration)
end

function  oBoomerangRenderParticles(shoot)
    local particlesName = shoot.particles_boom
	local newParticlesID = ParticleManager:CreateParticle(particlesName, PATTACH_ABSORIGIN_FOLLOW , shoot)
	ParticleManager:SetParticleControlEnt(newParticlesID, shoot.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
end

function oBoomerangCatchRenderParticles(shoot, unit, debuffDuration)
    local keys = shoot.keysTable
	local particlesName = keys.particles_catch

	local catch_radius = shoot.catch_radius
    local unitPos = unit:GetAbsOrigin()

	local particleBoom = ParticleManager:CreateParticle(particlesName, PATTACH_ABSORIGIN_FOLLOW , unit)
	ParticleManager:SetParticleControlEnt(particleBoom, 0 , unit, PATTACH_POINT_FOLLOW, nil, unit:GetAbsOrigin(), true)
    ParticleManager:SetParticleControl(particleBoom, 14, Vector(catch_radius, 0, 0))
    ParticleManager:SetParticleControl(particleBoom, 15, Vector(debuffDuration, 0, 0))

    --用于更高优先级救出控制范围消除特效
    if unit.tieParticleId == nil then
		unit.tieParticleId = {}
	end
	table.insert(unit.tieParticleId, particleBoom)


end

function oBoomerangIntervalCallBack(shoot)
    local keys = shoot.keysTable
    local ability = keys.ability
    local speed = ability:GetSpecialValueFor("speed")
    local angle = shoot.angle
    local xPoint_distance = shoot.xPoint_distance 

    local angleRate =  -1.05 * angle / (xPoint_distance  / speed / 0.02)
    local direction = shoot.direction
    local direction = shoot.direction
    local angle_new = angleRate * math.pi 

    local newX = math.cos(math.atan2(direction.y, direction.x) - angle_new)
    local newY = math.sin(math.atan2(direction.y, direction.x) - angle_new)
    shoot.direction = Vector(newX, newY, direction.z)
end