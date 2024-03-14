require('shoot_init')
require('skill_operation')
stone_ball_datadriven = class({})
LinkLuaModifier( "modifier_beat_back", "magic/modifiers/modifier_beat_back.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL )
LinkLuaModifier( "modifier_disable_turning", "magic/modifiers/modifier_disable_turning.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL )

function stone_ball_datadriven:GetCastRange(v,t)
    local range = getRangeByName(self,'b')
    return range
end

function stone_ball_datadriven:GetAOERadius()
	local aoe_radius = getAOERadiusByName(self,'b')
	return aoe_radius
end

function stone_ball_datadriven:OnSpellStart()
    createShoot(self)
end

function createShoot(ability)
    local caster = ability:GetCaster()
    local magicName = ability:GetAbilityName()
    local keys = getMagicKeys(ability,magicName)

    keys.particles_nm =      "particles/07shitoushu_shengcheng.vpcf"
    keys.soundCast = 		"magic_stone_ball_cast"
    keys.particles_misfire = "particles/07shitoushu_jiluo.vpcf"
    keys.soundMisfire =		"magic_stone_mis_fire"
    keys.particles_miss =    "particles/07shitoushu_xiaoshi.vpcf"
    keys.soundMiss =			"magic_stone_miss"
    
    keys.particles_power = 	"particles/07shitoushu_jiaqiang.vpcf"
    keys.soundPower =		"magic_stone_power_up"
    keys.particles_weak = 	"particles/07shitoushu_xueruo.vpcf"
    keys.soundWeak =			"magic_stone_power_down"	
    
    keys.particles_hit = 	"particles/07shitoushu_mingzhong.vpcf"
    keys.soundHit =			"magic_stone_ball_hit"

    keys.hitTargetDebuff =   "modifier_beat_back"
    keys.hitDisableTurning =	"modifier_disable_turning"

    local skillPoint = ability:GetCursorPosition()
    local casterPoint = caster:GetAbsOrigin()
    local max_distance = ability:GetSpecialValueFor("max_distance")
    local direction = (skillPoint - casterPoint):Normalized()
    local shoot = CreateUnitByName(keys.unitModel, casterPoint, true, nil, nil, caster:GetTeam())
    creatSkillShootInit(keys,shoot,caster,max_distance,direction)
    --过滤掉增加施法距离的操作
	--shoot.max_distance_operation = max_distance
    initDurationBuff(keys)

    local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
    ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
	shoot.particleID = particleID
	EmitSoundOn(keys.soundCast, caster)
    moveShoot(keys, shoot, nil, stoneBallHitCallBack)
    caster.shootOver = 1
end

--技能爆炸,单次伤害
function stoneBallHitCallBack(shoot, unit)
    passAOEOperation(shoot,unit, passOperationCallback)
end


function passOperationCallback(shoot,unit)
	local keys = shoot.keysTable
    local caster = keys.caster
	local playerID = caster:GetPlayerID()
	local ability = keys.ability
    local AbilityLevel = shoot.abilityLevel

    local beatBackDistance = ability:GetSpecialValueFor("beat_back_distance")
    beatBackDistance = getFinalValueOperation(playerID,beatBackDistance,'control',AbilityLevel,nil)--装备数值加强
	beatBackDistance = getApplyControlValue(shoot, beatBackDistance)--相生加强
	local beatBackSpeed = ability:GetSpecialValueFor("beat_back_speed") 
    local shootPos = shoot:GetAbsOrigin()
	local tempShootPos  = Vector(shootPos.x,shootPos.y,0)
	local targetPos= unit:GetAbsOrigin()
	local tempTargetPos = Vector(targetPos.x ,targetPos.y ,0)
	local beatBackDirection =  (tempTargetPos - tempShootPos):Normalized()
	beatBackUnit(keys,shoot,unit,beatBackSpeed,beatBackDistance,beatBackDirection,AbilityLevel,true)

    local damage = getApplyDamageValue(shoot)
    ApplyDamage({victim = unit, attacker = shoot, damage = damage, damage_type = ability:GetAbilityDamageType()})

end 
