require('shoot_init')
require('skill_operation')
require('player_power')
--禁视光球
function createVisionDownLightBall(keys)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local skillPoint = ability:GetCursorPosition()
    local speed = ability:GetSpecialValueFor("speed")
    local angleRate = ability:GetSpecialValueFor("angle_rate") * math.pi
    local aoe_radius = ability:GetSpecialValueFor("aoe_radius")
    local aoe_duration = ability:GetSpecialValueFor("aoe_duration")    
    local casterPoint = caster:GetAbsOrigin()
    local direction = (skillPoint - casterPoint):Normalized()
    local max_distance = (skillPoint - casterPoint ):Length2D()
    local shoot = CreateUnitByName(keys.unitModel, casterPoint, true, nil, nil, caster:GetTeam())
    creatSkillShootInit(keys,shoot,caster,max_distance,direction)
    shoot.max_distance_operation = max_distance
    initDurationBuff(keys)
    local AbilityLevel = shoot.abilityLevel
    aoe_duration = getFinalValueOperation(playerID,aoe_duration,'control',AbilityLevel,nil)--数值加强
    aoe_duration = getApplyControlValue(shoot, aoe_duration)--克制加强
    shoot.aoe_duration = aoe_duration	
    shoot.aoe_radius = aoe_radius
    local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
    ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
    shoot.particleID = particleID
    EmitSoundOn(keys.soundCast, shoot)
    moveShoot(keys, shoot, visionDownLightBallBoomCallBack, nil)
end

function visionDownLightBallBoomCallBack(shoot)
    visionDownLightBallDuration(shoot) 
end

function visionDownLightBallDuration(shoot)
    local keys = shoot.keysTable
    local interval = 0.5--伤害间隔
    visionDownLightBallRenderParticles(shoot)
    EmitSoundOn(keys.soundBoom, shoot)
    durationAOEDamage(shoot, interval, visionDownLightBallDamageCallback)
    local ability = keys.ability
    local faceAngle = ability:GetSpecialValueFor("face_angle")
    local judgeTime = ability:GetSpecialValueFor("vision_time")
    durationAOEJudgeByAngleAndTime(shoot, faceAngle, judgeTime,visionDebuffCallback)     

end

function visionDownLightBallDamageCallback(shoot, unit, interval)
	local keys = shoot.keysTable
	local caster = keys.caster
    local ability = keys.ability
    local duration = shoot.aoe_duration
    local faceAngle = ability:GetSpecialValueFor("face_angle")
    local damageTotal = getApplyDamageValue(shoot)
    local damage = damageTotal / (duration / interval)   
    local isface = isFaceByFaceAngle(shoot, unit, faceAngle)
    local modifierDefenseName = keys.modifierDefenseName
    if isface then   
        ApplyDamage({victim = unit, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})
        if unit:HasModifier(modifierDefenseName) then
            unit:RemoveModifierByName(modifierDefenseName)
        end
    else
        ability:ApplyDataDrivenModifier(caster, unit, modifierDefenseName, {Duration = -1})
    end
    if shoot.isKillAOE == 1 then
        if unit:HasModifier(modifierDefenseName) then
            unit:RemoveModifierByName(modifierDefenseName)
        end 
    end
end

function visionDownLightBallRenderParticles(shoot)
    local keys = shoot.keysTable
    local caster = keys.caster
	--local ability = keys.ability
	local particleBoom = ParticleManager:CreateParticle(keys.particles_duration, PATTACH_WORLDORIGIN, caster)
    local groundPos = shoot:GetAbsOrigin()--GetGroundPosition(shoot:GetAbsOrigin(), shoot)
	ParticleManager:SetParticleControl(particleBoom, 3, groundPos)
    ParticleManager:SetParticleControl(particleBoom, 11, Vector(shoot.aoe_duration, 0, 0))
	ParticleManager:SetParticleControl(particleBoom, 10, Vector(shoot.aoe_radius, 1, 0))
end

--视野debuff触发
function visionDebuffCallback(shoot,unit)
    local keys = shoot.keysTable
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local AbilityLevel = shoot.abilityLevel
    local debuffName = keys.modifierDebuffName
    if not unit:HasModifier(debuffName) then
        EmitSoundOn(keys.soundDebuff, shoot)
    end
    local debuffDuration = ability:GetSpecialValueFor("debuff_duration") --debuff持续时间
    debuffDuration = getFinalValueOperation(playerID,debuffDuration,'control',AbilityLevel,nil)--数值加强
    debuffDuration = getApplyControlValue(shoot, debuffDuration)--相生加强
    ability:ApplyDataDrivenModifier(caster, unit, debuffName, {Duration = debuffDuration})
    
end

