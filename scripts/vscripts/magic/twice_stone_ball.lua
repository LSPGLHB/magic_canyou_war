require('shoot_init')
require('skill_operation')
twice_stone_ball_datadriven = ({})
twice_stone_ball_datadriven_stage_b = ({})
LinkLuaModifier("twice_stone_ball_datadriven_modifier_debuff", "magic/modifiers/twice_stone_ball_modifier_debuff.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("twice_stone_ball_datadriven_modifier_debuff_sp2", "magic/modifiers/twice_stone_ball_modifier_debuff.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("twice_stone_ball_datadriven_modifier_debuff_delay", "magic/modifiers/twice_stone_ball_modifier_debuff.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_twice_stone_ball_datadriven_buff", "magic/modifiers/twice_stone_ball_modifier_debuff.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)
function twice_stone_ball_datadriven:OnUpgrade()
	LevelUpAbility(self)
end

function twice_stone_ball_datadriven:GetCastRange(v,t)
    local range = getRangeByName(self,'c')
    return range
end

function twice_stone_ball_datadriven_stage_b:GetCastRange(v,t)
    local range = getRangeByName(self,'c')
    return range
end

function twice_stone_ball_datadriven:OnSpellStart()
    stepOne(self)
end

function twice_stone_ball_datadriven_stage_b:OnSpellStart()
    stepTwo(self)
end


function stepOne(ability)
    local caster = ability:GetCaster()
    local magicName = ability:GetAbilityName()
    local keys = getMagicKeys(ability,magicName)

    keys.particles_nm =      "particles/17_1tuqiushu_shengcheng.vpcf"
    keys.soundCast =			"magic_twice_stone_ball_cast"
    keys.particles_power = 	"particles/17_1tuqiushu_jiaqiang.vpcf"
    keys.soundPower =		"magic_stone_power_up"
    keys.particles_weak = 	"particles/17_1tuqiushu_xueruo.vpcf"
    keys.soundWeak =			"magic_stone_power_down"
    keys.particles_misfire = "particles/17_1tuqiushu_jiluo.vpcf"
    keys.soundMisfire =		"magic_stone_mis_fire"
    keys.particles_miss =    "particles/17_1tuqiushu_xiaoshi.vpcf"
    keys.soundMiss =			"magic_stone_miss"
    keys.particles_boom = 	"particles/17_1tuqiushu_mingzhong.vpcf"
    keys.soundBoom =			"magic_twice_stone_ball_boom_sp1"
    keys.hitTargetDebuffDelay =	"twice_stone_ball_datadriven_modifier_debuff_delay"
    keys.hitTargetDebuff =        "twice_stone_ball_datadriven_modifier_debuff"
    keys.modifier_caster_stage_name =	   "modifier_twice_stone_ball_datadriven_buff"
    keys.ability_a_name =	magicName
    keys.ability_b_name =	magicName.."_stage_b"

    local skillPoint = ability:GetCursorPosition()  
    local casterPoint = caster:GetAbsOrigin()
    local max_distance = ability:GetSpecialValueFor("max_distance")

    local direction = (skillPoint - casterPoint):Normalized()

    local shoot = CreateUnitByName(keys.unitModel, casterPoint, true, nil, nil, caster:GetTeam())
    creatSkillShootInit(keys,shoot,caster,max_distance,direction)
   

    local ability_a_name	= keys.ability_a_name
    local ability_b_name	= keys.ability_b_name
    caster:SwapAbilities( ability_a_name, ability_b_name, false, true )

    caster.twic_stone_ball_on = 1
    local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
    ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
	shoot.particleID = particleID
	EmitSoundOn(keys.soundCast, caster)
    local casterBuff = keys.modifier_caster_stage_name
    --ability:ApplyDataDrivenModifier(caster, caster, casterBuff, {Duration = 5})
    caster:AddNewModifier(caster,ability,casterBuff, {Duration = 5})

--[[
    Timers:CreateTimer(5, function()
        if caster.twic_stone_ball_on == 1 then
            initStage(keys)
            if caster:HasModifier(casterBuff) then
                caster:RemoveModifierByName(casterBuff) 
            end
        end
        return nil
    end)]]

    moveShoot(keys, shoot, twiceStoneBallBoomCallBackSp1, nil)
    caster.shootOver = 1
end

function stepTwo(ability)
    local caster = ability:GetCaster()
    local magicName = 'twice_stone_ball_datadriven'
    local keys = getMagicKeys(ability,magicName)

    keys.particles_nm =      "particles/17_2boliping_shengcheng.vpcf"
    keys.soundCast =			"magic_twice_stone_ball_cast"   
    keys.particles_power = 	"particles/17_2boliping_jiaqiang.vpcf"
    keys.soundPower =		"magic_stone_power_up"
    keys.particles_weak = 	"particles/17_2boliping_xueruo.vpcf"
    keys.soundWeak =			"magic_stone_power_down"
    keys.particles_misfire = "particles/17_2boliping_jiluo.vpcf"
    keys.soundMisfire =		"magic_stone_mis_fire"
    keys.particles_miss =    "particles/17_2boliping_xiaoshi.vpcf"
    keys.soundMiss =			"magic_stone_miss"
    keys.particles_boom = 	"particles/17_2boliping_mingzhong.vpcf"
    keys.soundBoom =			"magic_twice_stone_ball_boom_sp2"
    keys.modifier_caster_stage_name =	   "modifier_twice_stone_ball_datadriven_buff"
    keys.hitTargetDebuff =	   "twice_stone_ball_datadriven_modifier_debuff_sp2"
    keys.ability_a_name =	magicName
    keys.ability_b_name =	magicName.."_stage_b"

    local skillPoint = ability:GetCursorPosition()
    local casterPoint = caster:GetAbsOrigin()
    local max_distance = ability:GetSpecialValueFor("max_distance")

    local direction = (skillPoint - casterPoint):Normalized()

    local shoot = CreateUnitByName(keys.unitModel, casterPoint, true, nil, nil, caster:GetTeam())
    creatSkillShootInit(keys,shoot,caster,max_distance,direction)

    --过滤掉增加施法距离的操作
	--shoot.max_distance_operation = max_distance
    initDurationBuff(keys)



    caster.twic_stone_ball_on = 0
    local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
    ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
	shoot.particleID = particleID
	EmitSoundOn(keys.soundCast, caster)

    local casterBuff = keys.modifier_caster_stage_name
    if caster:HasModifier(casterBuff) then
        caster:RemoveModifierByName(casterBuff) 
    end
    moveShoot(keys, shoot, twiceStoneBallBoomCallBackSp2, nil)
end

function twiceStoneBallBoomCallBackSp1(shoot)
	twiceStoneBallBoomAOERenderParticles(shoot)
    boomAOEOperation(shoot, twiceStoneBallAOEOperationCallbackSp1)
end

function twiceStoneBallBoomCallBackSp2(shoot)
	twiceStoneBallBoomAOERenderParticles(shoot)
    boomAOEOperation(shoot, twiceStoneBallAOEOperationCallbackSp2)
end

function twiceStoneBallBoomAOERenderParticles(shoot)
    local particlesName = shoot.particles_boom
	local newParticlesID = ParticleManager:CreateParticle(particlesName, PATTACH_ABSORIGIN_FOLLOW , shoot)
	ParticleManager:SetParticleControlEnt(newParticlesID, shoot.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
end

function twiceStoneBallAOEOperationCallbackSp1(shoot,unit)
    local keys = shoot.keysTable
    local caster = keys.caster
	local playerID = caster:GetPlayerID()
	local ability = keys.ability

    local damage = getApplyDamageValue(shoot) * (8 / 20)
    ApplyDamage({victim = unit, attacker = shoot, damage = damage, damage_type = ability:GetAbilityDamageType()})

    local AbilityLevel = shoot.abilityLevel
    local debuffDelay = ability:GetSpecialValueFor("debuff_delay")
    local hitTargetDebuffDelay = keys.hitTargetDebuffDelay
    local hitTargetDebuff = keys.hitTargetDebuff
    --ability:ApplyDataDrivenModifier(caster, unit, hitTargetDebuffDelay, {Duration = debuffDelay})
    unit:AddNewModifier(caster,ability,hitTargetDebuffDelay, {Duration = debuffDelay})
    Timers:CreateTimer(debuffDelay, function()
        local debuffDuration = ability:GetSpecialValueFor("debuff_duration") --debuff持续时间
        debuffDuration = getFinalValueOperation(playerID,debuffDuration,'control',AbilityLevel,owner)
        debuffDuration = getApplyControlValue(shoot, debuffDuration)
        --ability:ApplyDataDrivenModifier(caster, unit, hitTargetDebuff, {Duration = debuffDuration}) 
        unit:AddNewModifier(caster,ability,hitTargetDebuff, {Duration = debuffDuration}) 
    end)
    
    
    
end

function twiceStoneBallAOEOperationCallbackSp2(shoot,unit)
    local keys = shoot.keysTable
    local caster = keys.caster
	local playerID = caster:GetPlayerID()
	local ability = keys.ability
    local AbilityLevel = shoot.abilityLevel
    local hitTargetDebuff = keys.hitTargetDebuff

    local damage = getApplyDamageValue(shoot) * (12 / 20)
    ApplyDamage({victim = unit, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})

    local debuffDuration = ability:GetSpecialValueFor("debuff_duration") --debuff持续时间
    debuffDuration = getFinalValueOperation(playerID,debuffDuration,'control',AbilityLevel,owner)
    debuffDuration = getApplyControlValue(shoot, debuffDuration)
    --ability:ApplyDataDrivenModifier(caster, unit, hitTargetDebuff, {Duration = debuffDuration})  
    unit:AddNewModifier(caster,ability,hitTargetDebuff, {Duration = debuffDuration}) 
    local interval = 0.1
    local timeCount = 0
    unit.tsb_position = unit:GetAbsOrigin()
    Timers:CreateTimer(interval, function()

        local distance = (unit:GetAbsOrigin() - unit.tsb_position):Length2D()
        local damage = distance * ability:GetSpecialValueFor("damage_by_distance")
        --damage = powerLevelOperation(shoot, 'damage', shoot.power_lv, damage) 

        ApplyDamage({victim = unit, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})


        unit.tsb_position = unit:GetAbsOrigin()
        timeCount = timeCount + interval
        if timeCount >=  debuffDuration then
            return nil
        end
        return interval
    end)
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

