require('shoot_init')
require('skill_operation')
function createFrostBlast(keys)
    local caster = keys.caster
    local ability = keys.ability
    local skillPoint = ability:GetCursorPosition()
    local speed = ability:GetSpecialValueFor("speed")
	local aoe_radius = ability:GetSpecialValueFor("aoe_radius")
    local casterPoint = caster:GetAbsOrigin()
    local max_distance = (skillPoint - casterPoint ):Length2D()
    local direction = (skillPoint - casterPoint):Normalized()
    local shoot = CreateUnitByName(keys.unitModel, casterPoint, true, nil, nil, caster:GetTeam())
    creatSkillShootInit(keys,shoot,caster,max_distance,direction)
    --过滤掉增加施法距离的操作
	shoot.max_distance_operation = max_distance
    initDurationBuff(keys)
	shoot.aoe_radius = aoe_radius
    local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
    ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
	shoot.particleID = particleID
    EmitSoundOn(keys.soundCast, shoot)
    moveShoot(keys, shoot, frostBlastBoomCallBack, nil)
end

--技能爆炸,单次伤害
function frostBlastBoomCallBack(keys,shoot)
    ParticleManager:DestroyParticle(shoot.particleID, true) --子弹特效消失
    frostBlastRenderParticles(keys,shoot) --爆炸粒子效果生成		  
	diffuseBoomAOEOperation(keys, shoot, AOEOperationCallback)

end

function frostBlastRenderParticles(keys,shoot)
	local caster = keys.caster
	local ability = keys.ability
    local aoe_radius = shoot.aoe_radius
    local diffuseSpeed = ability:GetSpecialValueFor("diffuse_speed") * 1.66
    local cp1Y = aoe_radius / diffuseSpeed
	local particleBoom = ParticleManager:CreateParticle(keys.particlesBoom, PATTACH_WORLDORIGIN, caster)
	local groundPos = GetGroundPosition(shoot:GetAbsOrigin(), shoot)
	ParticleManager:SetParticleControl(particleBoom, 3, groundPos)
	ParticleManager:SetParticleControl(particleBoom, 1, Vector(diffuseSpeed, cp1Y, 0))--未实现传参
end

function AOEOperationCallback(keys,shoot,unit)
	local caster = keys.caster
	local playerID = caster:GetPlayerID()
	local ability = keys.ability
	local AbilityLevel = shoot.abilityLevel
    local aoeTargetDebuff = keys.aoeTargetDebuff
    local isHitUnit = checkHitUnitToMark(shoot, true, unit)
    if isHitUnit then 
        local damage = getApplyDamageValue(shoot)
        ApplyDamage({victim = unit, attacker = shoot, damage = damage, damage_type = ability:GetAbilityDamageType()})
        local debuffDuration = ability:GetSpecialValueFor("debuff_duration") --debuff持续时间
        debuffDuration = getFinalValueOperation(playerID,debuffDuration,'control',AbilityLevel,nil)--数值加强
        debuffDuration = getApplyControlValue(shoot, debuffDuration)--相生加强
        ability:ApplyDataDrivenModifier(caster, unit, aoeTargetDebuff, {Duration = debuffDuration})
    end

end




