require('shoot_init')
require('skill_operation')
require('player_power')
function createShoot(keys)
    local caster = keys.caster
    local ability = keys.ability
    local skillPoint = ability:GetCursorPosition()
    --local speed = ability:GetSpecialValueFor("speed")
    local max_distance = ability:GetSpecialValueFor("max_distance")

    local casterPoint = caster:GetAbsOrigin()
    local direction = (skillPoint - casterPoint):Normalized()

    local shoot = CreateUnitByName(keys.unitModel, casterPoint, true, nil, nil, caster:GetTeam())
    creatSkillShootInit(keys,shoot,caster,max_distance,direction)
    --shoot.aoe_radius = aoe_radius
    local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
    ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
    shoot.particleID = particleID
    EmitSoundOn(keys.soundCast, shoot)
    moveShoot(keys, shoot, iceBallBoomCallBack, nil)

end

--技能爆炸,单次伤害
--技能爆炸,单次伤害
function iceBallBoomCallBack(shoot)
	boomAOERenderParticles(shoot)
    boomAOEOperation(shoot, iceBallAOEOperationCallback)
end
function boomAOERenderParticles(shoot)
	local particlesName = shoot.particles_boom
	local newParticlesID = ParticleManager:CreateParticle(particlesName, PATTACH_ABSORIGIN_FOLLOW , shoot)
	ParticleManager:SetParticleControlEnt(newParticlesID, shoot.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
end

function iceBallAOEOperationCallback(shoot,unit)
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
end