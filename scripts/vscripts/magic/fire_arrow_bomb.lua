require('shoot_init')
require('skill_operation')
require('player_power')
function createShoot(keys)
    local caster = keys.caster
    local ability = keys.ability
    local skillPoint = ability:GetCursorPosition()
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
    moveShoot(keys, shoot, fireArrowBombBoomCallBack, nil)

end

--技能爆炸,单次伤害
function fireArrowBombBoomCallBack(shoot)
    --ParticleManager:DestroyParticle(shoot.particleID, true) --子弹特效消失
	fireArrowBombBoomAOERenderParticles(shoot)
    boomAOEOperation(shoot, fireArrowBombAOEOperationCallback)
end
function fireArrowBombBoomAOERenderParticles(shoot)
	local particlesName = shoot.particles_boom
	local newParticlesID = ParticleManager:CreateParticle(particlesName, PATTACH_ABSORIGIN_FOLLOW , shoot)
	ParticleManager:SetParticleControlEnt(newParticlesID, shoot.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
end

function fireArrowBombAOEOperationCallback(shoot,unit)
	local keys = shoot.keysTable
    local caster = keys.caster
	local playerID = caster:GetPlayerID()
	local ability = keys.ability
    local AbilityLevel = shoot.abilityLevel
    local debuffName = keys.hitTargetDebuff   
    local debuffDuration = ability:GetSpecialValueFor("debuff_duration") --debuff持续时间
    ability:ApplyDataDrivenModifier(caster, unit, debuffName, {Duration = debuffDuration})

    Timers:CreateTimer(debuffDuration, function()
        local casterPoint = caster:GetAbsOrigin()
        local unitPoint = unit:GetAbsOrigin()
        local ucDistance = (unitPoint - casterPoint):Length2D()
        local max_distance = ability:GetSpecialValueFor("max_distance")
        --print("fireArrowBombAOEOperationCallback:",getApplyDamageValue(shoot))
        local damage = getApplyDamageValue(shoot) * (ucDistance / max_distance)
        ApplyDamage({victim = unit, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})
		EmitSoundOn(keys.soundTimeover, shoot)
		local boomParticle = ParticleManager:CreateParticle(keys.particles_timeover, PATTACH_ABSORIGIN_FOLLOW , unit)
		ParticleManager:SetParticleControlEnt(boomParticle, 9 , unit, PATTACH_POINT_FOLLOW, nil, unit:GetAbsOrigin(), true)
    end)

end 


