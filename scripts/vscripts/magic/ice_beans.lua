require('shoot_init')
require('skill_operation')
require('player_power')

ice_beans_datadriven_stage_b = class({})
LinkLuaModifier("ice_beans_datadriven_modifier_debuff", "magic/modifiers/ice_beans_modifier_debuff.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL )

function ice_beans_datadriven_stage_b:GetCastRange(v,t)
    local range = getRangeByName(self,'b')
    return range
end

function ice_beans_datadriven_stage_b:OnSpellStart()
    LaunchFire(self)
end


function LaunchFire(ability)

    local caster = ability:GetCaster()
    local magicName = 'ice_beans_datadriven'
    local keys = getMagicKeys(ability,magicName)

	keys.particles_nm =      "particles/39bingdou_shengcheng.vpcf"
	keys.soundCast = 		"magic_ice_beans_cast"
	keys.particles_boom =    "particles/39bingdou_mingzhong.vpcf" 
	keys.soundBoom =			"magic_ice_beans_hit"
	keys.particles_misfire = "particles/39bingdou_jiluo.vpcf"
	keys.soundMisfire =		"magic_ice_mis_fire"
	keys.particles_miss =    "particles/39bingdou_xiaoshi.vpcf"
	keys.soundMiss =			"magic_ice_miss"
	keys.particles_power = 	"particles/39bingdou_jiaqiang.vpcf"
	keys.soundPower =		"magic_ice_power_up"
	keys.particles_weak = 	"particles/39bingdou_xueruo.vpcf"
	keys.soundWeak =			"magic_ice_power_down"
	keys.hitTargetDebuff =  		"ice_beans_datadriven_modifier_debuff"
	keys.ability_a_name =			"ice_beans_datadriven"
	keys.modifier_stage_a_name =	"modifier_ice_beans_datadriven_buff"

	local modifierName	= keys.modifier_stage_a_name
	local skillPoint = ability:GetCursorPosition()
	local casterPoint = caster:GetAbsOrigin()

	local shootCount =  ability:GetSpecialValueFor("shoot_count")
	local max_distance = ability:GetSpecialValueFor("max_distance")
	local direction = (skillPoint - casterPoint ):Normalized() 
	local ability_a_name = caster:FindAbilityByName(keys.ability_a_name)

	local currentStack	= caster:GetModifierStackCount( modifierName, ability_a_name )
	currentStack = currentStack - 1
	
	caster:SetModifierStackCount( modifierName, ability_a_name, currentStack )
	local tempCount = 0

	Timers:CreateTimer(0,function ()
		local shoot = CreateUnitByName(keys.unitModel, casterPoint, true, nil, nil, caster:GetTeam())
		creatSkillShootInit(keys,shoot,caster,max_distance,direction)
		local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
		ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
		shoot.particleID = particleID
		EmitSoundOn(keys.soundCast, shoot)
		moveShoot(keys, shoot, iceBeansBoomCallBack, nil)
		tempCount = tempCount+1
		if tempCount == shootCount then
			return nil
		end
		return 0.2
	end)

	if currentStack == 0 then
		caster:RemoveModifierByName( modifierName )
	end
  
end

function stageOne (keys)
    local caster	= keys.caster
	local ability	= keys.ability
    local modifierStageName	= keys.modifier_stage_a_name
	local chargeCount	= ability:GetSpecialValueFor("charge_count")

    caster.fire_spirits_numSpirits	= chargeCount
	caster:SetModifierStackCount( modifierStageName, ability, chargeCount )
    local ability_b_name	= keys.ability_b_name
	local ability_a_name	= keys.ability_a_name
	caster:SwapAbilities( ability_a_name, ability_b_name, false, true )

    initDurationBuff(keys)
end

function LevelUpAbility(keys)
    local caster = keys.caster
	local this_ability = keys.ability
	--local this_abilityName = this_ability:GetAbilityName()
	local this_abilityLevel = this_ability:GetLevel()

	-- The ability to level up
	local ability_b_name = keys.ability_b_name
	local ability_handle = caster:FindAbilityByName(ability_b_name)
	local ability_level = ability_handle:GetLevel()

	-- Check to not enter a level up loop
	if ability_level ~= this_abilityLevel then
		ability_handle:SetLevel(this_abilityLevel)
	end
end

function initStage(keys)
    local caster	= keys.caster
	local ability	= keys.ability

	local ability_a_name = keys.ability_a_name
	local ability_b_name = keys.ability_b_name
	caster:SwapAbilities( ability_a_name, ability_b_name, true, false )
end




--技能爆炸,单次伤害
function iceBeansBoomCallBack(shoot)
    --ParticleManager:DestroyParticle(shoot.particleID, true) --子弹特效消失
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
	local ability = keys.ability
	local playerID = caster:GetPlayerID()
    local AbilityLevel = shoot.abilityLevel
    local hitTargetDebuff = keys.hitTargetDebuff
    local damage = getApplyDamageValue(shoot) / ability:GetSpecialValueFor("charge_count") / ability:GetSpecialValueFor("shoot_count")
    ApplyDamage({victim = unit, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})
	local abilityName = caster:FindAbilityByName(ability:GetAbilityName())
	local currentStack = unit:GetModifierStackCount(hitTargetDebuff, abilityName)
	currentStack = currentStack + 1
    local debuffDuration = ability:GetSpecialValueFor("debuff_duration") --debuff持续时间
    debuffDuration = getFinalValueOperation(playerID,debuffDuration,'control',AbilityLevel,nil)
    debuffDuration = getApplyControlValue(shoot, debuffDuration)
	debuffDuration = debuffDuration * currentStack
    --ability:ApplyDataDrivenModifier(caster, unit, hitTargetDebuff, {Duration = debuffDuration})  
	unit:AddNewModifier(caster,ability,hitTargetDebuff, {Duration = debuffDuration})
	unit:SetModifierStackCount( hitTargetDebuff, abilityName, currentStack )
end


function channelInterrupted(keys)
	local caster	= keys.caster
	local ability	= keys.ability
	--可返回CD和蓝
	--ability:EndCooldown()
	--ability:RefundManaCost()
end