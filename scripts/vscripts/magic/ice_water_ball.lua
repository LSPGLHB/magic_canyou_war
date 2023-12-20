require('shoot_init')
require('skill_operation')

ice_water_ball_datadriven =({})
LinkLuaModifier("ice_water_ball_datadriven_modifier_debuff_sp1", "magic/modifiers/ice_water_ball_modifier_debuff.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("ice_water_ball_datadriven_modifier_debuff_sp2", "magic/modifiers/ice_water_ball_modifier_debuff.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)

function ice_water_ball_datadriven:GetCastRange(v,t)
    local range = getRangeByName(self,'b')
    return range
end

function ice_water_ball_datadriven:GetAOERadius()
	local aoe_radius = getAOERadiusByName(self,'b')
	return aoe_radius
end

function ice_water_ball_datadriven:OnSpellStart()
    createShoot(self)
end


function createShoot(ability)
    local caster = ability:GetCaster()
    local magicName = ability:GetAbilityName()
    local keys = getMagicKeys(ability,magicName)

    keys.particles_nm_sp1 =      "particles/24_1bingshuishuangdan_shengcheng.vpcf"
    keys.particles_nm_sp2 =      "particles/24_2bingshuishuangdan_shengcheng.vpcf"
    keys.soundCast = 		"magic_ice_water_ball_cast"
    
    keys.particles_power_sp1 = 	"particles/24_1bingshuishuangdan_jiaqiang.vpcf"
    keys.particles_power_sp2 = 	"particles/24_2bingshuishuangdan_jiaqiang.vpcf"
    keys.soundPower =		"magic_ice_power_up"

    keys.particles_weak_sp1 = 	"particles/24_1bingshuishuangdan_xueruo.vpcf"
    keys.particles_weak_sp2 = 	"particles/24_2bingshuishuangdan_xueruo.vpcf"
    keys.soundWeak =			"magic_ice_power_down"
    
    keys.particles_misfire_sp1 = "particles/24_1bingshuishuangdan_jiluo.vpcf"
    keys.particles_misfire_sp2 = "particles/24_2bingshuishuangdan_jiluo.vpcf"
    keys.soundMisfire =		"magic_ice_mis_fire"

    keys.particles_miss_sp1 =    "particles/24_1bingshuishuangdan_xiaoshi.vpcf"
    keys.particles_miss_sp2 =    "particles/24_2bingshuishuangdan_xiaoshi.vpcf"
    keys.soundMiss =			"magic_ice_miss"

    keys.particles_boom_sp1 = 	"particles/24_1bingshuishuangdan_mingzhong.vpcf"
    keys.particles_boom_sp2 = 	"particles/24_2bingshuishuangdan_mingzhong.vpcf"
    keys.soundBoom =			"magic_ice_water_ball_boom"

    keys.hitTargetDebuffSp1 =  "ice_water_ball_datadriven_modifier_debuff_sp1"
    keys.hitTargetDebuffSp2 =  "ice_water_ball_datadriven_modifier_debuff_sp2"


    local skillPoint = ability:GetCursorPosition()
    --local speed = ability:GetSpecialValueFor("speed")
    local max_distance = ability:GetSpecialValueFor("max_distance")

    local casterPoint = caster:GetAbsOrigin()

    local direction = (skillPoint - casterPoint):Normalized()
    local xPoint_distance = (skillPoint - casterPoint):Length2D()

    local angle = 0.3 * math.pi
    local newX1 = math.cos(math.atan2(direction.y, direction.x) - angle)
    local newY1 = math.sin(math.atan2(direction.y, direction.x) - angle)
    local direction_sp1 = Vector(newX1, newY1, direction.z)

    local newX2 = math.cos(math.atan2(direction.y, direction.x) + angle)
    local newY2 = math.sin(math.atan2(direction.y, direction.x) + angle)
    local direction_sp2 = Vector(newX2, newY2, direction.z)

    initDurationBuff(keys)

    
    local shoot_sp1 = CreateUnitByName(keys.unitModel, casterPoint, true, nil, nil, caster:GetTeam())
    creatSkillShootInit(keys,shoot_sp1,caster,max_distance,direction_sp1)

    local particleID = ParticleManager:CreateParticle(keys.particles_nm_sp1, PATTACH_ABSORIGIN_FOLLOW , shoot_sp1)
    ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot_sp1, PATTACH_POINT_FOLLOW, nil, shoot_sp1:GetAbsOrigin(), true)
    shoot_sp1.particleID = particleID
    EmitSoundOn(keys.soundCast, shoot_sp1)
    shoot_sp1.angle = angle
    shoot_sp1.xPoint_distance = xPoint_distance
    shoot_sp1.particles_nm = keys.particles_nm_sp1
    shoot_sp1.particles_power = keys.particles_power_sp1
    shoot_sp1.particles_weak = keys.particles_weak_sp1
    shoot_sp1.particles_miss = keys.particles_miss_sp1
	shoot_sp1.particles_misfire = keys.particles_misfire_sp1
    shoot_sp1.particles_boom = keys.particles_boom_sp1
    shoot_sp1.intervalCallBack = intervalCallBackSp1
    moveShoot(keys, shoot_sp1, iceWaterBallBoomCallBackSp1, nil)

    local shoot_sp2 = CreateUnitByName(keys.unitModel, casterPoint, true, nil, nil, caster:GetTeam())
    creatSkillShootInit(keys,shoot_sp2,caster,max_distance,direction_sp2)

    local particleID = ParticleManager:CreateParticle(keys.particles_nm_sp2, PATTACH_ABSORIGIN_FOLLOW , shoot_sp2)
    ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot_sp2, PATTACH_POINT_FOLLOW, nil, shoot_sp2:GetAbsOrigin(), true)
    shoot_sp2.particleID = particleID
    EmitSoundOn(keys.soundCast, shoot_sp2)
    shoot_sp2.angle = angle
    shoot_sp2.xPoint_distance = xPoint_distance
    shoot_sp2.particles_nm = keys.particles_nm_sp2
    shoot_sp2.particles_power = keys.particles_power_sp2
    shoot_sp2.particles_weak = keys.particles_weak_sp2
    shoot_sp2.particles_miss = keys.particles_miss_sp2
	shoot_sp2.particles_misfire = keys.particles_misfire_sp2
    shoot_sp2.particles_boom = keys.particles_boom_sp2
    shoot_sp2.intervalCallBack = intervalCallBackSp2
    moveShoot(keys, shoot_sp2, iceWaterBallBoomCallBackSp2, nil)
    
end


function iceWaterBallBoomCallBackSp1(shoot)
	boomAOERenderParticlesSp1(shoot)
    boomAOEOperation(shoot, iceWaterBallAOEOperationCallbackSp1)
end
function boomAOERenderParticlesSp1(shoot)
	local particlesName = shoot.particles_boom
	local newParticlesID = ParticleManager:CreateParticle(particlesName, PATTACH_ABSORIGIN_FOLLOW , shoot)
	ParticleManager:SetParticleControlEnt(newParticlesID, shoot.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
end

function iceWaterBallAOEOperationCallbackSp1(shoot,unit)
	local keys = shoot.keysTable
    local caster = keys.caster
	local ability = keys.ability
    local damage = getApplyDamageValue(shoot) / 2
    ApplyDamage({victim = unit, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})

	local playerID = caster:GetPlayerID()	
    local AbilityLevel = shoot.abilityLevel
    local hitTargetDebuff = keys.hitTargetDebuffSp1
    local debuffDuration = ability:GetSpecialValueFor("debuff_duration") --debuff持续时间
    debuffDuration = getFinalValueOperation(playerID,debuffDuration,'control',AbilityLevel,nil)
    debuffDuration = getApplyControlValue(shoot, debuffDuration)
    --ability:ApplyDataDrivenModifier(caster, unit, hitTargetDebuff, {Duration = debuffDuration}) 
    unit:AddNewModifier(caster,ability,hitTargetDebuff, {Duration = debuffDuration})
end

function iceWaterBallBoomCallBackSp2(shoot)
	boomAOERenderParticlesSp2(shoot)
    boomAOEOperation(shoot, iceWaterBallAOEOperationCallbackSp2)
end
function boomAOERenderParticlesSp2(shoot)
	local particlesName = shoot.particles_boom
	local newParticlesID = ParticleManager:CreateParticle(particlesName, PATTACH_ABSORIGIN_FOLLOW , shoot)
	ParticleManager:SetParticleControlEnt(newParticlesID, shoot.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
end

function iceWaterBallAOEOperationCallbackSp2(shoot,unit)
	local keys = shoot.keysTable
    local caster = keys.caster
	local ability = keys.ability
    local damage = getApplyDamageValue(shoot) / 2
    ApplyDamage({victim = unit, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})

	local playerID = caster:GetPlayerID()	
    local AbilityLevel = shoot.abilityLevel
    local hitTargetDebuff = keys.hitTargetDebuffSp2
    local debuffDuration = ability:GetSpecialValueFor("debuff_duration") --debuff持续时间
    debuffDuration = getFinalValueOperation(playerID,debuffDuration,'control',AbilityLevel,nil)
    debuffDuration = getApplyControlValue(shoot, debuffDuration)
    --ability:ApplyDataDrivenModifier(caster, unit, hitTargetDebuff, {Duration = debuffDuration}) 
    unit:AddNewModifier(caster,ability,hitTargetDebuff, {Duration = debuffDuration})
end

function intervalCallBackSp1(shoot)
    intervalCallBackOperation(shoot, -1) 
end

function intervalCallBackSp2(shoot)
    intervalCallBackOperation(shoot, 1) 
end


function intervalCallBackOperation(shoot, flag)
    local angle = shoot.angle
    local xPoint_distance = shoot.xPoint_distance * (1 + 0.1 * (shoot.xPoint_distance / (shoot.max_distance -200)))
    
    local angleRate = flag * angle / (xPoint_distance  / (shoot.speed / 0.02 / GameRules.speedConstant) / 0.02)
    local direction = shoot.direction
    local direction = shoot.direction
    local angle_new = 0
    if xPoint_distance > shoot.traveled_distance then
        angle_new = angleRate * math.pi 
    end
    local newX = math.cos(math.atan2(direction.y, direction.x) - angle_new)
    local newY = math.sin(math.atan2(direction.y, direction.x) - angle_new)
    shoot.direction = Vector(newX, newY, direction.z)
end