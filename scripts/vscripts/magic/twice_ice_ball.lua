require('shoot_init')
require('skill_operation')
twice_ice_ball_datadriven = ({})
twice_ice_ball_datadriven_stage_b = ({})
LinkLuaModifier("twice_ice_ball_datadriven_modifier_debuff", "magic/modifiers/twice_ice_ball_modifier_debuff.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_twice_ice_ball_datadriven_buff", "magic/modifiers/twice_ice_ball_modifier_debuff.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)
function twice_ice_ball_datadriven:OnUpgrade()
	LevelUpAbility(self)
end

function twice_ice_ball_datadriven:GetCastRange(v,t)
    local range = getRangeByName(self,'c')
    return range
end

function twice_ice_ball_datadriven:OnSpellStart()
    stepOne(self)
end
function twice_ice_ball_datadriven_stage_b:OnSpellStart()
    stepTwo(self)
end

function stepOne(ability)
    local caster = ability:GetCaster()
    local magicName = ability:GetAbilityName()
    local keys = getMagicKeys(ability,magicName)

    keys.particles_nm =      "particles/34_1bingerlianjian_shengcheng.vpcf"
    keys.soundCast =			"magic_twice_ice_ball_cast_sp1"
    keys.particles_power = 	"particles/34_1bingerlianjian_jiaqiang.vpcf"
    keys.soundPower =		"magic_ice_power_up"
    keys.particles_weak = 	"particles/34_1bingerlianjian_xueruo.vpcf"
    keys.soundWeak =			"magic_ice_power_down"
    keys.particles_misfire = "particles/34_1bingerlianjian_jiluo.vpcf"
    keys.soundMisfire =		"magic_ice_mis_fire"
    keys.particles_miss =    "particles/34_1bingerlianjian_xiaoshi.vpcf"
    keys.soundMiss =			"magic_ice_miss"
    keys.particles_boom = 	"particles/34_1bingerlianjian_mingzhong.vpcf"
    keys.soundBoom =			"magic_twice_ice_ball_boom"
    keys.hitTargetDebuff =        "twice_ice_ball_datadriven_modifier_debuff"
    keys.modifier_caster_stage_name =	   "modifier_twice_ice_ball_datadriven_buff"
    keys.ability_a_name =		   magicName
    keys.ability_b_name =		   magicName.."_stage_b"

    local skillPoint = ability:GetCursorPosition()  
    local casterPoint = caster:GetAbsOrigin()
    local max_distance = ability:GetSpecialValueFor("max_distance")

    local direction = (skillPoint - casterPoint):Normalized()

    local shoot = CreateUnitByName(keys.unitModel, casterPoint, true, nil, nil, caster:GetTeam())
    creatSkillShootInit(keys,shoot,caster,max_distance,direction)
   

    local ability_a_name	= keys.ability_a_name
    local ability_b_name	= keys.ability_b_name
    caster:SwapAbilities( ability_a_name, ability_b_name, false, true )
    
    caster.twice_ice_ball_on = 1
    local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
    ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
	shoot.particleID = particleID
	EmitSoundOn(keys.soundCast, caster)
    local casterBuff = keys.modifier_caster_stage_name
    --ability:ApplyDataDrivenModifier(caster, caster, casterBuff, {Duration = 5})
    caster:AddNewModifier(caster,ability,casterBuff, {Duration = 5})
--[[
    Timers:CreateTimer(5, function()
        if caster.twice_ice_ball_on == 1 then
            initStage(keys)
            if caster:HasModifier(casterBuff) then
                caster:RemoveModifierByName(casterBuff) 
            end
        end
        return nil
    end)]]
    moveShoot(keys, shoot, twiceIceBallBoomCallBackSp1, nil)
end

function stepTwo(ability)
    local caster = ability:GetCaster()
    local magicName = 'twice_ice_ball_datadriven'
    local keys = getMagicKeys(ability,magicName)

    keys.particles_nm =      "particles/34_2bingerlianjian_shengcheng.vpcf"
    keys.soundCast =			"magic_twice_ice_ball_cast_sp2"   
    keys.particles_power = 	"particles/34_2bingerlianjian_jiaqiang.vpcf"
    keys.soundPower =		"magic_ice_power_up"
    keys.particles_weak = 	"particles/34_2bingerlianjian_xueruo.vpcf"
    keys.soundWeak =			"magic_ice_power_down"
    keys.particles_misfire = "particles/34_2bingerlianjian_jiluo.vpcf"
    keys.soundMisfire =		"magic_ice_mis_fire"
    keys.particles_miss =    "particles/34_2bingerlianjian_xiaoshi.vpcf"
    keys.soundMiss =			"magic_ice_miss"
    keys.particles_boom = 	"particles/34_2bingerlianjian_mingzhong.vpcf"
    keys.soundBoom =			"magic_twice_ice_ball_boom"
    keys.modifier_caster_stage_name =	   "modifier_twice_ice_ball_datadriven_buff"
    keys.ability_a_name =	   magicName
    keys.ability_b_name =	   magicName.."_stage_b"

    local skillPoint = ability:GetCursorPosition()
    local casterPoint = caster:GetAbsOrigin()
    local max_distance = ability:GetSpecialValueFor("max_distance")

    local direction = (skillPoint - casterPoint):Normalized()

    local shoot = CreateUnitByName(keys.unitModel, casterPoint, true, nil, nil, caster:GetTeam())
    creatSkillShootInit(keys,shoot,caster,max_distance,direction)

    --过滤掉增加施法距离的操作
	--shoot.max_distance_operation = max_distance
    initDurationBuff(keys)

    caster.twice_ice_ball_on = 0
    local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
    ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
	shoot.particleID = particleID
	EmitSoundOn(keys.soundCast, caster)
    --initStage(keys)
    local casterBuff = keys.modifier_caster_stage_name
    if caster:HasModifier(casterBuff) then
        caster:RemoveModifierByName(casterBuff) 
    end
    moveShoot(keys, shoot, twiceIceBallBoomCallBackSp2, nil)
end

function twiceIceBallBoomCallBackSp1(shoot)
	twiceIceBallBoomAOERenderParticles(shoot)
    boomAOEOperation(shoot, twiceIceBallAOEOperationCallbackSp1)
end

function twiceIceBallBoomCallBackSp2(shoot)
	twiceIceBallBoomAOERenderParticles(shoot)
    boomAOEOperation(shoot, twiceIceBallAOEOperationCallbackSp2)
end

function twiceIceBallBoomAOERenderParticles(shoot)
    local particlesName = shoot.particles_boom
	local newParticlesID = ParticleManager:CreateParticle(particlesName, PATTACH_ABSORIGIN_FOLLOW , shoot)
	ParticleManager:SetParticleControlEnt(newParticlesID, shoot.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
end

function twiceIceBallAOEOperationCallbackSp1(shoot,unit)
    local keys = shoot.keysTable
    local caster = keys.caster
	
	local ability = keys.ability

    local damage = getApplyDamageValue(shoot) * (6 / 18)
    ApplyDamage({victim = unit, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})

    local AbilityLevel = shoot.abilityLevel
    local hitTargetDebuff = keys.hitTargetDebuff
    local playerID = caster:GetPlayerID()

    local debuffDuration = ability:GetSpecialValueFor("debuff_duration") --debuff持续时间
    debuffDuration = getFinalValueOperation(playerID,debuffDuration,'control',AbilityLevel,nil)
    debuffDuration = getApplyControlValue(shoot, debuffDuration)
    --ability:ApplyDataDrivenModifier(caster, unit, hitTargetDebuff, {Duration = debuffDuration})  
    unit:AddNewModifier(caster,ability,hitTargetDebuff, {Duration = debuffDuration})
     
end

function twiceIceBallAOEOperationCallbackSp2(shoot,unit)
    local keys = shoot.keysTable
    local caster = keys.caster
	local ability = keys.ability
    local damage_by_distance = ability:GetSpecialValueFor("damage_by_distance")
    local damage = getApplyDamageValue(shoot) * (12 / 18) + (shoot.traveled_distance / damage_by_distance)
    ApplyDamage({victim = unit, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()}) 
end

function LevelUpAbility(self)
    local caster = self:GetCaster()
	local ability = self
	local abilityName = ability:GetAbilityName()
	local abilityLevel = ability:GetLevel()
	-- The ability to level up
	local ability_b_name = abilityName.."_stage_b"
	local ability_handle = caster:FindAbilityByName(ability_b_name)
	local ability_level = ability_handle:GetLevel()
	-- Check to not enter a level up loop
	if ability_level ~= abilityLevel then
		ability_handle:SetLevel(abilityLevel)
	end
end

--[[
function initStage(keys)
    local caster	= keys.caster
	local ability	= keys.ability

    local ability_a_name	= keys.ability_a_name
    local ability_b_name	= keys.ability_b_name
    caster:SwapAbilities( ability_a_name, ability_b_name, true, false )
end]]

