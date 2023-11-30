require('shoot_init')
require('skill_operation')
require('player_power')
function createShoot(keys)
    local caster = keys.caster
    local ability = keys.ability
    local skillPoint = ability:GetCursorPosition()
    local max_distance = ability:GetSpecialValueFor("max_distance")
	local catch_radius = ability:GetSpecialValueFor("catch_radius")
    local casterPoint = caster:GetAbsOrigin()
    local direction = (skillPoint - casterPoint):Normalized()

    local shoot = CreateUnitByName(keys.unitModel, casterPoint, true, nil, nil, caster:GetTeam())
    creatSkillShootInit(keys,shoot,caster,max_distance,direction)
    shoot.catch_radius = catch_radius
    local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
    ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
    shoot.particleID = particleID
    EmitSoundOn(keys.soundCast, shoot)
    moveShoot(keys, shoot, windNetBoomCallBack, nil)

end

--技能爆炸,单次伤害
function windNetBoomCallBack(shoot)
    boomAOEOperation(shoot, windNetAOEOperationCallback)
end

function windNetAOEOperationCallback(shoot,unit)
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
    windNetAOERenderParticles(shoot, unit, debuffDuration)
    catchAOEOperationCallback(shoot, unit, debuffDuration,hitTargetDebuff)
end

function windNetAOERenderParticles(shoot, unit, debuffDuration)
    local catch_radius = shoot.catch_radius
	local particlesName = shoot.particles_boom
	local newParticlesID = ParticleManager:CreateParticle(particlesName, PATTACH_ABSORIGIN_FOLLOW , unit)
	ParticleManager:SetParticleControlEnt(newParticlesID, 0 , unit, PATTACH_POINT_FOLLOW, nil, unit:GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(newParticlesID, 14, Vector(catch_radius, 0, 0))
    ParticleManager:SetParticleControl(newParticlesID, 15, Vector(debuffDuration, 0, 0))
	if unit.tieParticleId == nil then
		unit.tieParticleId = {}
	end
	table.insert(unit.tieParticleId, newParticlesID)

end