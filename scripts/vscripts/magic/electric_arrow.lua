require('shoot_init')
require('skill_operation')
function createShoot(keys)
    local caster = keys.caster
    local ability = keys.ability
    local skillPoint = ability:GetCursorPosition()
    --local speed = ability:GetSpecialValueFor("speed")
	--local aoe_radius = ability:GetSpecialValueFor("aoe_radius") 
    local casterPoint = caster:GetAbsOrigin()
    local max_distance = ability:GetSpecialValueFor("max_distance") -- (skillPoint - casterPoint ):Length2D()

    local direction = (skillPoint - casterPoint):Normalized()
    --casterPoint = casterPoint + direction * 50
    initDurationBuff(keys)

    local shoot = CreateUnitByName(keys.unitModel, casterPoint, true, nil, nil, caster:GetTeam())
    creatSkillShootInit(keys,shoot,caster,max_distance,direction)
    --过滤掉增加施法距离的操作
    --shoot.max_distance_operation = max_distance
    --shoot.aoe_radius = aoe_radius
    local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
    ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
    shoot.particleID = particleID
    EmitSoundOn(keys.soundCastSp1, shoot)

    local send_delay = ability:GetSpecialValueFor("send_delay")
    shoot.speed = 0
    moveShoot(keys, shoot, electricArrowBoomCallBack, nil)
    Timers:CreateTimer(send_delay, function()
        EmitSoundOn(keys.soundCastSp2, shoot)
        local AbilityLevel = shoot.abilityLevel
        local playerID = caster:GetPlayerID()
        local speedBase = ability:GetSpecialValueFor("speed")
        local speedBuffName = 'ability_speed'
        shoot.speed = getFinalValueOperation(playerID,speedBase,speedBuffName,AbilityLevel,nil) * GameRules.speedConstant * 0.02
    end) 
end

--技能爆炸,单次伤害
function electricArrowBoomCallBack(shoot)
    electricArrowRenderParticles(shoot)
	boomAOEOperation(shoot, electricArrowAOEOperationCallback)
end

function electricArrowRenderParticles(shoot)
	local particlesName = shoot.particles_boom
	local newParticlesID = ParticleManager:CreateParticle(particlesName, PATTACH_ABSORIGIN_FOLLOW , shoot)
	ParticleManager:SetParticleControlEnt(newParticlesID, shoot.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
end


function electricArrowAOEOperationCallback(shoot,unit)
	local keys = shoot.keysTable
	local caster = keys.caster
	local ability = keys.ability
    local bouns_damage_percentage = ability:GetSpecialValueFor("bouns_damage_percentage")
    local damage_bouns = (unit:GetMaxHealth() - unit:GetHealth()) * (bouns_damage_percentage / 100)
	local damage = getApplyDamageValue(shoot) + damage_bouns
	ApplyDamage({victim = unit, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})
end

