require('shoot_init')
require('skill_operation')
v_ice_ball_datadriven = ({})
LinkLuaModifier( "modifier_v_ice_ball_debuff_sp1_datadriven", "magic/modifiers/v_ice_ball_modifier_debuff.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL )
LinkLuaModifier( "modifier_v_ice_ball_debuff_sp2_datadriven", "magic/modifiers/v_ice_ball_modifier_debuff.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL )

function v_ice_ball_datadriven:GetCastRange(v,t)
    local range = getRangeByName(self,'a')
    return range
end

function v_ice_ball_datadriven:OnSpellStart()
    createShoot(self)
end

function createShoot(ability)
    local caster = ability:GetCaster()
    local magicName = ability:GetAbilityName()
    local keys = getMagicKeys(ability,magicName)

    keys.particles_nm =      "particles/14vzibingqiu_shengcheng.vpcf"
    keys.soundCast = 		"magic_v_ice_ball_cast"
    keys.particles_power = 	"particles/14vzibingqiu_jiaqiang.vpcf"
    keys.soundPower =		"magic_ice_power_up"
    keys.particles_weak = 	"particles/14vzibingqiu_xueruo.vpcf"
    keys.soundWeak =			"magic_ice_power_down"  
    keys.particles_duration = 	"particles/14vzibingqiu_baozha.vpcf"
    keys.soundDuration =			"magic_v_ice_ball_boom"
    keys.aoeTargetDebuffSp1 =  "modifier_v_ice_ball_debuff_sp1_datadriven"
    keys.aoeTargetDebuffSp2 =  "modifier_v_ice_ball_debuff_sp2_datadriven"

    local skillPoint = ability:GetCursorPosition()
    --local speed = ability:GetSpecialValueFor("speed")
    local max_distance = ability:GetSpecialValueFor("max_distance")
    local angleRate = ability:GetSpecialValueFor("angle_rate")
    
    local casterPoint = caster:GetAbsOrigin()
    local direction = (skillPoint - casterPoint):Normalized()
    local directionTable ={}
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
    for i = 1, 2, 1 do
        local shoot = CreateUnitByName(keys.unitModel, casterPoint, true, nil, nil, caster:GetTeam())
        shoot.shootCount = i
        creatSkillShootInit(keys,shoot,caster,max_distance,directionTable[i])

        local aoe_duration = ability:GetSpecialValueFor("aoe_duration")
        aoe_duration = getFinalValueOperation(caster:GetPlayerID(),aoe_duration,'control',keys.AbilityLevel,nil)
        aoe_duration = getApplyControlValue(shoot, aoe_duration)
        shoot.aoe_duration = aoe_duration
        if i == 1 then
            shoot.aoeTargetDebuff = keys.aoeTargetDebuffSp1
        end
        if i == 2 then
            shoot.aoeTargetDebuff = keys.aoeTargetDebuffSp2
        end
        local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
        ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
        shoot.particleID = particleID
        EmitSoundOn(keys.soundCast, shoot)
        moveShoot(keys, shoot, vIceBallBoomCallBack, nil)
    end
    caster.shootOver = 1
end


function vIceBallBoomCallBack(shoot)
    --local keys = shoot.keysTable
    vIceBallDuration(shoot) --实现持续光环效果以及粒子效果
   -- EmitSoundOn(keys.soundBoom, shoot)
end

function vIceBallDuration(shoot)
    local interval = 0.5
    vIceBallRenderParticles(shoot)
    durationAOEDamage(shoot, interval, vIceBallDamageCallback)
    modifierHole(shoot)
end

function vIceBallRenderParticles(shoot)
    local keys = shoot.keysTable
    local caster = keys.caster
	local particleBoom = ParticleManager:CreateParticle(keys.particles_duration, PATTACH_WORLDORIGIN, caster)
    local groundPos = GetGroundPosition(shoot:GetAbsOrigin(), shoot)
	ParticleManager:SetParticleControl(particleBoom, 3, groundPos)
    ParticleManager:SetParticleControl(particleBoom, 5, Vector(shoot.aoe_radius, 0, 0))
    ParticleManager:SetParticleControl(particleBoom, 11, Vector(shoot.aoe_duration, 0, 0))
end

function vIceBallDamageCallback(shoot, unit, interval)
    local keys = shoot.keysTable
    local caster = keys.caster
    local ability = keys.ability
    local duration = shoot.aoe_duration
    local damageTotal = getApplyDamageValue(shoot)
    local damage = damageTotal / (duration / interval) / 2
    ApplyDamage({victim = unit, attacker = shoot, damage = damage, damage_type = ability:GetAbilityDamageType()})
end


