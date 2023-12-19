require('shoot_init')
require('skill_operation')

big_fire_ball_pre_datadriven = class({})
big_fire_ball_datadriven = class({})
LinkLuaModifier( "modifier_beat_back", "magic/modifiers/modifier_beat_back.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL )
LinkLuaModifier( "modifier_disable_turning", "magic/modifiers/modifier_disable_turning.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL )
LinkLuaModifier( "big_fire_ball_pre_datadriven_modifier_debuff", "magic/modifiers/big_fire_ball_modifier_debuff.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL )
LinkLuaModifier( "big_fire_ball_datadriven_modifier_debuff", "magic/modifiers/big_fire_ball_modifier_debuff.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL )

function big_fire_ball_pre_datadriven:GetCastRange(v,t)
    local range = getRangeByName(self,'a')
    return range
end

function big_fire_ball_datadriven:GetCastRange(v,t)
    local range = getRangeByName(self,'a')
    return range
end

function big_fire_ball_pre_datadriven:GetAOERadius()
	local aoe_radius = getAOERadiusByName(self,'a')
	return aoe_radius
end
function big_fire_ball_datadriven:GetAOERadius()
	local aoe_radius = getAOERadiusByName(self,'a')
	return aoe_radius
end

function big_fire_ball_pre_datadriven:OnSpellStart()
    createShoot(self)
end

function big_fire_ball_datadriven:OnSpellStart()
    createShoot(self)
end

function createShoot(ability)
    local caster = ability:GetCaster()
	local magicName = ability:GetAbilityName()
    local keys = getMagicKeys(ability,magicName)

    keys.particles_nm = "particles/26dahuoqiushu_shengcheng.vpcf"
    keys.soundCast = "magic_big_fire_ball_cast"
	keys.particles_power = "particles/26dahuoqiushu_jiaqiang.vpcf"
	keys.soundPower = "magic_fire_power_up"
	keys.particles_weak = "particles/26dahuoqiushu_xueruo.vpcf"
	keys.soundWeak = "magic_water_power_down"

    keys.particles_boom = "particles/26dahuoqiushu_baozha.vpcf"
    keys.soundBoom = "magic_big_fire_ball_boom"

	keys.particles_defense = "particles/duobizhimangbuff_1.vpcf"
	keys.soundDefense =      "magic_defence"
				
	keys.soundBeat =	"magic_beat_hit"

	keys.hitTargetDebuff = "modifier_beat_back"

	keys.hitDisableTurning =	"modifier_disable_turning"
	keys.modifierDebuffName =  magicName.."_modifier_debuff"




    local skillPoint = ability:GetCursorPosition()
    --local speed = ability:GetSpecialValueFor("speed")
    --local angleRate = ability:GetSpecialValueFor("angle_rate") * math.pi
	--local aoe_radius = ability:GetSpecialValueFor("aoe_radius")
    local casterPoint = caster:GetAbsOrigin()
    local max_distance = (skillPoint - casterPoint ):Length2D()
    local direction = (skillPoint - casterPoint):Normalized()
    local shoot = CreateUnitByName(keys.unitModel, casterPoint, true, nil, nil, caster:GetTeam())
    creatSkillShootInit(keys,shoot,caster,max_distance,direction)
    --过滤掉增加施法距离的操作
	shoot.max_distance_operation = max_distance
    initDurationBuff(keys)

    local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
    ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
	shoot.particleID = particleID
	EmitSoundOn(keys.soundCast, caster)
    moveShoot(keys, shoot, bigFireBallBoomCallBack, nil)
end

--技能爆炸,单次伤害
function bigFireBallBoomCallBack(shoot)
    bigFireBallRenderParticles(shoot) --爆炸粒子效果生成		  
    --dealSkillbigFireBallBoom(keys,shoot) --实现aoe爆炸效果
	boomAOEOperation(shoot, AOEOperationCallback)
    --bigFireBallDuration(keys,shoot) --实现持续光环效果以及粒子效果
	--EndShootControl(keys)--遥控用
end

function bigFireBallRenderParticles(shoot)
	local keys = shoot.keysTable
	local caster = keys.caster
	--local ability = keys.ability
	local particleBoom = ParticleManager:CreateParticle(keys.particles_boom, PATTACH_WORLDORIGIN, caster)
	local groundPos = GetGroundPosition(shoot:GetAbsOrigin(), shoot)
	ParticleManager:SetParticleControl(particleBoom, 3, groundPos)
	ParticleManager:SetParticleControl(particleBoom, 10, Vector(shoot.aoe_radius, 1, 0))
end

function AOEOperationCallback(shoot,unit)
	local keys = shoot.keysTable
	local caster = keys.caster
	local playerID = caster:GetPlayerID()
	local ability = keys.ability
	local AbilityLevel = shoot.abilityLevel
    local debuffName = keys.modifierDebuffName
	local beatBackDistance = ability:GetSpecialValueFor("beat_back_distance")
	local beatBackSpeed = ability:GetSpecialValueFor("beat_back_speed") 
	beatBackDistance = getFinalValueOperation(playerID,beatBackDistance,'control',AbilityLevel,nil)--装备数值加强
	beatBackDistance = getApplyControlValue(shoot, beatBackDistance)--相生加强

	local shootPos = shoot:GetAbsOrigin()
	local tempShootPos  = Vector(shootPos.x,shootPos.y,0)
	local targetPos= unit:GetAbsOrigin()
	local tempTargetPos = Vector(targetPos.x ,targetPos.y ,0)
	local beatBackDirection =  (tempTargetPos - tempShootPos):Normalized()
	beatBackUnit(keys,shoot,unit,beatBackSpeed,beatBackDistance,beatBackDirection,AbilityLevel,true)
	disableTurning(keys,shoot,unit,AbilityLevel)
	local damage = getApplyDamageValue(shoot)
	ApplyDamage({victim = unit, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})
	local debuffDuration = ability:GetSpecialValueFor("debuff_duration") --debuff持续时间
	debuffDuration = getFinalValueOperation(playerID,debuffDuration,'control',AbilityLevel,nil)--装备数值加强
	debuffDuration = getApplyControlValue(shoot, debuffDuration)--相生加强
	local faceAngle = ability:GetSpecialValueFor("face_angle")
	local flag = isFaceByFaceAngle(shoot, unit, faceAngle)
	if flag then
		--ability:ApplyDataDrivenModifier(caster, unit, debuffName, {Duration = debuffDuration})
		unit:AddNewModifier( unit, ability, debuffName, {Duration = debuffDuration} )
	else
        local defenceParticlesID = ParticleManager:CreateParticle(keys.particles_defense, PATTACH_OVERHEAD_FOLLOW , unit)
        ParticleManager:SetParticleControlEnt(defenceParticlesID, 3 , unit, PATTACH_OVERHEAD_FOLLOW, nil, shoot:GetAbsOrigin(), true)
        EmitSoundOn(keys.soundDefense, unit)
        Timers:CreateTimer(0.5, function()
                ParticleManager:DestroyParticle(defenceParticlesID, true)
                return nil
        end)
	end

end




