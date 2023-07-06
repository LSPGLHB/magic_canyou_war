require('shoot_init')
require('skill_operation')
function createShoot(keys)
    local caster = keys.caster
    local ability = keys.ability
    local skillPoint = ability:GetCursorPosition()
    local speed = ability:GetSpecialValueFor("speed")
    local max_distance = ability:GetSpecialValueFor("max_distance")
    local angleRate = ability:GetSpecialValueFor("angle_rate")
    --local aoe_radius = ability:GetSpecialValueFor("aoe_radius")
    local casterPoint = caster:GetAbsOrigin()
    local direction = (skillPoint - casterPoint):Normalized()
    local directionTable ={}
    table.insert(directionTable,direction)
    local angle23 = angleRate * math.pi
    local newX2 = math.cos(math.atan2(direction.y, direction.x) - angle23)
    local newY2 = math.sin(math.atan2(direction.y, direction.x) - angle23)
    local newX3 = math.cos(math.atan2(direction.y, direction.x) + angle23)
    local newY3 = math.sin(math.atan2(direction.y, direction.x) + angle23)
    local direction2 = Vector(newX2, newY2, direction.z)
    table.insert(directionTable,direction2)
    local direction3 = Vector(newX3, newY3, direction.z)
    table.insert(directionTable,direction3)
    initDurationBuff(keys)
    for i = 1, 3, 1 do
        local shoot = CreateUnitByName(keys.unitModel, casterPoint, true, nil, nil, caster:GetTeam())
        creatSkillShootInit(keys,shoot,caster,max_distance,directionTable[i])
        --shoot.aoe_radius = aoe_radius
        local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
        ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
        shoot.particleID = particleID
        EmitSoundOn(keys.soundCast, shoot)
        moveShoot(keys, shoot, scatterSoilBallBoomCallBack, nil)
    end
end

--技能爆炸,单次伤害
function scatterSoilBallBoomCallBack(shoot)
    boomAOEOperation(shoot, scatterSoilBallAOEOperationCallback)
end


function scatterSoilBallAOEOperationCallback(shoot,unit)
    local keys = shoot.keysTable
    local caster = keys.caster
	local playerID = caster:GetPlayerID()
	local ability = keys.ability
    local AbilityLevel = shoot.abilityLevel
    local debuffName = keys.hitTargetDebuff
    local damage = getApplyDamageValue(shoot) / 3
    ApplyDamage({victim = unit, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})

    local debuffDuration = ability:GetSpecialValueFor("debuff_duration") --debuff持续时间
    debuffDuration = getFinalValueOperation(playerID,debuffDuration,'control',AbilityLevel, nil)
    debuffDuration = getApplyControlValue(shoot, debuffDuration)

    ability:ApplyDataDrivenModifier(caster, unit, debuffName, {Duration = debuffDuration})
end 


