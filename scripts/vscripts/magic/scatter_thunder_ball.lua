require('shoot_init')
require('skill_operation')
scatter_thunder_ball_pre_datadriven = class({})
scatter_thunder_ball_datadriven = class({})

LinkLuaModifier( "modifier_sleep_debuff_datadriven", "magic/modifiers/modifier_sleep_debuff.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL )


function scatter_thunder_ball_pre_datadriven:GetCastRange(v,t)
    local range = getRangeByName(self,'c')
    return range
end

function scatter_thunder_ball_datadriven:GetCastRange(v,t)
    local range = getRangeByName(self,'c')
    return range
end

function scatter_thunder_ball_pre_datadriven:OnSpellStart()
    creatShoot(self)
end

function scatter_thunder_ball_datadriven:OnSpellStart()
    creatShoot(self)
end



function creatShoot(ability)
    local caster = ability:GetCaster()
    local magicName = ability:GetAbilityName()
    local keys = getMagicKeys(ability,magicName)

    keys.particles_nm = "particles/03dianqiu_shengcheng.vpcf"
    keys.soundCast = "magic_scatter_thunder_ball_cast"
	keys.particles_power = "particles/03dianqiu_jiaqiang.vpcf"
	keys.soundPower = "magic_thunder_power_up"
	keys.particles_weak ="particles/03dianqiu_xueruo.vpcf"
	keys.soundWeak = "magic_thunder_power_down"	

    keys.particles_boom = "particles/03dianqiu_mingzhong.vpcf"
    keys.soundBoom = "magic_scatter_thunder_ball_hit"

	keys.particles_misfire = "particles/03dianqiu_jiluo.vpcf"
	keys.soundMisfire =	"magic_thunder_mis_fire"
	keys.particles_miss = "particles/03dianqiu_xiaoshi.vpcf"
	keys.soundMiss = "magic_thunder_miss"	


	keys.hitTargetDebuff = "modifier_sleep_debuff_datadriven"



    local skillPoint = ability:GetCursorPosition()
    local max_distance = ability:GetSpecialValueFor("max_distance")
    local angleRate = ability:GetSpecialValueFor("angle_rate")
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
        --shoot.aoe_radius = ability:GetSpecialValueFor("max_distance")
        local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
        ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
        shoot.particleID = particleID
        EmitSoundOn(keys.soundCast, shoot)
        moveShoot(keys, shoot, scatterThunderBallBoomCallBack, nil)
    end
end

--技能爆炸,单次伤害
function scatterThunderBallBoomCallBack(shoot)
    boomAOERenderParticles(shoot)
    boomAOEOperation(shoot, AOEOperationCallback)
end

function boomAOERenderParticles(shoot)
	local particlesName = shoot.particles_boom
	local newParticlesID = ParticleManager:CreateParticle(particlesName, PATTACH_ABSORIGIN_FOLLOW , shoot)
	ParticleManager:SetParticleControlEnt(newParticlesID, shoot.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
end

function AOEOperationCallback(shoot,unit)
    local keys = shoot.keysTable
    local caster = keys.caster
	local playerID = caster:GetPlayerID()
	local ability = keys.ability
    local AbilityLevel = shoot.abilityLevel
    local hitTargetDebuff = keys.hitTargetDebuff
    local damage = getApplyDamageValue(shoot) / 3
    ApplyDamage({victim = unit, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})

    local debuffDuration = ability:GetSpecialValueFor("debuff_duration") --debuff持续时间
    debuffDuration = getFinalValueOperation(playerID,debuffDuration,'control',AbilityLevel, nil)
    debuffDuration = getApplyControlValue(shoot, debuffDuration)

    --ability:ApplyDataDrivenModifier(caster, unit, hitTargetDebuff, {Duration = debuffDuration})
    unit:AddNewModifier( unit, ability, hitTargetDebuff, {Duration = debuffDuration} )
end 


