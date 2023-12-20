require('shoot_init')
require('skill_operation')
penetrate_thunder_ball_datadriven =({})
LinkLuaModifier( "modifier_sleep_debuff_datadriven", "magic/modifiers/modifier_sleep_debuff.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL )

function penetrate_thunder_ball_datadriven:GetCastRange(v,t)
    local range = getRangeByName(self,'c')
    return range
end

function penetrate_thunder_ball_datadriven:OnSpellStart()
    createShoot(self)
end

function createShoot(ability)
    local caster = ability:GetCaster()
    local magicName = ability:GetAbilityName()
    local keys = getMagicKeys(ability,magicName)

    keys.particles_nm =      "particles/33guanchuanleiqiu_shengcheng.vpcf"
    keys.soundCast = 		"magic_penetrate_thunder_ball_cast"
    keys.particles_misfire = "particles/33guanchuanleiqiu_jiluo.vpcf"
    keys.soundMisfire =		"magic_thunder_mis_fire"
    keys.particles_miss =    "particles/33guanchuanleiqiu_xiaoshi.vpcf"
    keys.soundMiss =			"magic_thunder_miss"
    keys.particles_power = 	"particles/33guanchuanleiqiu_jiaqiang.vpcf"
    keys.soundPower =		"magic_thunder_power_up"
    keys.particles_weak = 	"particles/33guanchuanleiqiu_xueruo.vpcf"
    keys.soundWeak =			"magic_thunder_power_down"	
    keys.particles_hit = 	"particles/33guanchuanleiqiu_mingzhong.vpcf"
    keys.soundHit =			"magic_penetrate_thunder_ball_hit"
    keys.hitTargetDebuff =   "modifier_sleep_debuff_datadriven"
                
    local skillPoint = ability:GetCursorPosition()
    local max_distance = ability:GetSpecialValueFor("max_distance")

    local casterPoint = caster:GetAbsOrigin()
    local direction = (skillPoint - casterPoint):Normalized()
    local shoot = CreateUnitByName(keys.unitModel, casterPoint, true, nil, nil, caster:GetTeam())
    creatSkillShootInit(keys,shoot,caster,max_distance,direction)

    local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
    ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
    shoot.particleID = particleID
    EmitSoundOn(keys.soundCast, shoot)
    moveShoot(keys, shoot, nil, penetrateThunderBallHitCallBack)
end

--技能爆炸,单次伤害
function penetrateThunderBallHitCallBack(shoot, unit)
    passAOEOperation(shoot,unit, passOperationCallback)
end


function passOperationCallback(shoot,unit)
    local keys = shoot.keysTable
    local caster = keys.caster
	local playerID = caster:GetPlayerID()
	local ability = keys.ability
    local AbilityLevel = shoot.abilityLevel
    local hitTargetDebuff = keys.hitTargetDebuff
    local damage = getApplyDamageValue(shoot)
    ApplyDamage({victim = unit, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})
    local debuffDuration = ability:GetSpecialValueFor("debuff_duration") --debuff持续时间
    debuffDuration = getFinalValueOperation(playerID,debuffDuration,'control',AbilityLevel,owner)
    debuffDuration = getApplyControlValue(shoot, debuffDuration)
    --ability:ApplyDataDrivenModifier(caster, unit, hitTargetDebuff, {Duration = debuffDuration})
    unit:AddNewModifier( unit, ability, hitTargetDebuff, {Duration = debuffDuration} )
end



