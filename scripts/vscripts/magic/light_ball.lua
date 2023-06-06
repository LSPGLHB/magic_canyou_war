require('shoot_init')
require('skill_operation')
function createLightBall(keys)
    local caster = keys.caster
    local ability = keys.ability
    local skillPoint = ability:GetCursorPosition()
    local speed = ability:GetSpecialValueFor("speed")
    local max_distance = ability:GetSpecialValueFor("max_distance")
    local angleRate = ability:GetSpecialValueFor("angle_rate") * math.pi
    local aoe_radius = ability:GetSpecialValueFor("aoe_radius")
    local casterPoint = caster:GetAbsOrigin()
    local direction = (skillPoint - casterPoint):Normalized()
    local directionTable ={}
    local angle23 = 0.05 * math.pi
    local newX2 = math.cos(math.atan2(direction.y, direction.x) - angle23)
    local newY2 = math.sin(math.atan2(direction.y, direction.x) - angle23)
    local newX3 = math.cos(math.atan2(direction.y, direction.x) + angle23)
    local newY3 = math.sin(math.atan2(direction.y, direction.x) + angle23)
    local direction2 = Vector(newX2, newY2, direction.z)
    table.insert(directionTable,direction2)
    local direction3 = Vector(newX3, newY3, direction.z)
    table.insert(directionTable,direction3)
    initDurationBuff(keys)
    for i = 1, 2, 1 do
        local shoot = CreateUnitByName(keys.unitModel, casterPoint, true, nil, nil, caster:GetTeam())
        creatSkillShootInit(keys,shoot,caster,max_distance,directionTable[i])
        shoot.aoe_radius = aoe_radius
        local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
        ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
        shoot.particleID = particleID
        moveShoot(keys, shoot, lightBallBoomCallBack, nil)
    end
end

--技能爆炸,单次伤害
function lightBallBoomCallBack(keys,shoot)
    ParticleManager:DestroyParticle(shoot.particleID, true) --子弹特效消失
    lightBallRenderParticles(keys,shoot) --爆炸粒子效果生成		  
    --dealSkilllightBallBoom(keys,shoot) --实现aoe爆炸效果
    boomAOEOperation(keys, shoot, AOEOperationCallback)
    EmitSoundOn("magic_light_ball_boom", shoot)
    Timers:CreateTimer(keys.particles_hit_dur,function ()
        --ParticleManager:DestroyParticle(particleBoom, true)
        shoot:ForceKill(true)
        shoot:AddNoDraw()
        return nil
    end)
end

function lightBallRenderParticles(keys,shoot)
    local caster = keys.caster
	local ability = keys.ability
	local radius = shoot.aoe_radius--ability:GetSpecialValueFor("aoe_radius")
	local particleBoom = ParticleManager:CreateParticle(keys.particlesBoom, PATTACH_WORLDORIGIN, caster)
	local groundPos = GetGroundPosition(shoot:GetAbsOrigin(), shoot)
	ParticleManager:SetParticleControl(particleBoom, 3, groundPos)
	ParticleManager:SetParticleControl(particleBoom, 10, Vector(radius, 1, 1))
end

function AOEOperationCallback(keys,shoot,unit)
    local caster = keys.caster
	local playerID = caster:GetPlayerID()
	local ability = keys.ability
    local AbilityLevel = shoot.abilityLevel
    local debuffName = keys.modifierDebuffName
    local damage = getApplyDamageValue(shoot)
    ApplyDamage({victim = unit, attacker = shoot, damage = damage, damage_type = ability:GetAbilityDamageType()})

    local debuffDuration = ability:GetSpecialValueFor("debuff_duration") --debuff持续时间
    debuffDuration = getFinalValueOperation(playerID,debuffDuration,'control',AbilityLevel,owner)
    debuffDuration = getApplyControlValue(shoot, debuffDuration)
    local faceAngle = ability:GetSpecialValueFor("face_angle")
    local flag = setDebuffByFaceAngle(shoot, unit, faceAngle)
    if flag then
        ability:ApplyDataDrivenModifier(caster, unit, debuffName, {Duration = debuffDuration})
    end

end 


