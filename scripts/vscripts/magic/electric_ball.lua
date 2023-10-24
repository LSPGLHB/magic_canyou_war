require('shoot_init')
require('skill_operation')
function createShoot(keys)
    local caster = keys.caster
    local ability = keys.ability
    local skillPoint = ability:GetCursorPosition()

    local casterPoint = caster:GetAbsOrigin()
    local max_distance = ability:GetSpecialValueFor("max_distance")
    local direction = (skillPoint - casterPoint):Normalized()
    local shoot = CreateUnitByName(keys.unitModel, casterPoint, true, nil, nil, caster:GetTeam())
    creatSkillShootInit(keys,shoot,caster,max_distance,direction)
    --过滤掉增加施法距离的操作
	shoot.max_distance_operation = max_distance
    initDurationBuff(keys)

    local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
    ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
	shoot.particleID = particleID
	EmitSoundOn(keys.soundCast, shoot)
    moveShoot(keys, shoot, electricBallBoomCallBack, nil)
end

--技能爆炸,单次伤害
function electricBallBoomCallBack(shoot)
    electricBallRenderParticles(shoot) --爆炸粒子效果生成		  
	boomAOEOperation(shoot, electricBallAOEOperationCallback)
end

function electricBallRenderParticles(shoot)
	local newParticlesID = ParticleManager:CreateParticle(shoot.particles_boom, PATTACH_ABSORIGIN_FOLLOW , shoot)
	ParticleManager:SetParticleControlEnt(newParticlesID, shoot.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
end

function electricBallAOEOperationCallback(shoot,unit)
	local keys = shoot.keysTable
	local caster = keys.caster
	local ability = keys.ability
    local AbilityLevel = shoot.abilityLevel
    local playerID = caster:GetPlayerID()
    local hitTargetDebuff = keys.hitTargetDebuff
    local stunDebuff = keys.stunDebuff

	local damage = getApplyDamageValue(shoot) / 3
	

    local debuffDuration = ability:GetSpecialValueFor("debuff_duration") --debuff持续时间
    debuffDuration = getFinalValueOperation(playerID,debuffDuration,'control',AbilityLevel,nil)
    debuffDuration = getApplyControlValue(shoot, debuffDuration)
    ability:ApplyDataDrivenModifier(caster, unit, hitTargetDebuff, {Duration = debuffDuration})
    local interval = 2
    local timeCount = 0
    Timers:CreateTimer(function()
        ApplyDamage({victim = unit, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})
        ability:ApplyDataDrivenModifier(caster, unit, stunDebuff, {Duration = 1})
        EmitSoundOn(keys.soundBoom, shoot)
        timeCount = timeCount + interval
        if timeCount < debuffDuration then
            return interval
        end
        return nil
    end)
end

