require('shoot_init')
require('skill_operation')
control_rock_pre_datadriven = class({})
control_rock_datadriven = class({})
control_rock_pre_datadriven_stage_b = class({})
control_rock_datadriven_stage_b = class({})
LinkLuaModifier( "control_rock_modifier_under_control", "magic/modifiers/control_rock_modifier.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL )

function control_rock_pre_datadriven:OnUpgrade()
	local caster = self:GetCaster()
	LevelUpAbility(caster,self)
end

function control_rock_pre_datadriven:GetCastRange(v,t)
    local range = getRangeByName(self,'c')
    return range
end



function control_rock_pre_datadriven:OnSpellStart()
    createShoot(self)
end

function control_rock_datadriven:OnUpgrade()
	local caster = self:GetCaster()
	LevelUpAbility(caster,self)
end

function control_rock_datadriven:GetCastRange(v,t)
    local range = getRangeByName(self,'c')
    return range
end



function control_rock_datadriven:OnSpellStart()
    createShoot(self)
end

function control_rock_pre_datadriven_stage_b:OnSpellStart()
	EndControl(self)
end

function control_rock_datadriven_stage_b:OnSpellStart()
	EndControl(self)
end

function createShoot(ability)
    local caster = ability:GetCaster()
	local magicName = ability:GetAbilityName()
    local keys = getMagicKeys(ability,magicName)

	keys.isControl = 1
	keys.modifier_caster_syn_name =	"control_rock_modifier_under_control"
	--keys.modifier_caster_syn_name_b = "control_rock_modifier_under_control_b"
	keys.ability_a_name = magicName
	keys.ability_b_name = magicName.."_stage_b"

    keys.particles_nm = "particles/37yinianyanji_shengcheng.vpcf"
    keys.soundCast = "magic_control_rock_cast"
	keys.particles_power = "particles/37yinianyanji_jiaqiang.vpcf"
	keys.soundPower = "magic_stone_power_up"
	keys.particles_weak = "particles/37yinianyanji_xueruo.vpcf"
	keys.soundWeak = "magic_stone_power_down"

	keys.particles_misfire = "particles/37yinianyanji_jiluo.vpcf"
	keys.soundMisfire =		"magic_stone_mis_fire"
	keys.particles_miss =    "particles/37yinianyanji_xiaoshi.vpcf"
	keys.soundMiss =			"magic_stone_miss"
    keys.particles_boom = "particles/37yinianyanji_mingzhong.vpcf"
    keys.soundBoom = "magic_control_rock_boom"

    local skillPoint = ability:GetCursorPosition()
    local max_distance = ability:GetSpecialValueFor("max_distance")
    local angleRate = ability:GetSpecialValueFor("angle_rate") * math.pi
    local casterPoint = caster:GetAbsOrigin()
    
    local direction = (skillPoint - casterPoint):Normalized()
    local shoot = CreateUnitByName(keys.unitModel, casterPoint, true, nil, nil, caster:GetTeam())
    creatSkillShootInit(keys,shoot,caster,max_distance,direction)
    shoot.angleRate = angleRate
    local casterBuff = keys.modifier_caster_syn_name
	--local casterBuff_b = keys.modifier_caster_syn_name_b
	local flyDuration = shoot.max_distance_operation / (shoot.speed / GameRules.speedConstant / 0.02)

	local stageAbility = caster:GetAbilityByIndex(7)

	--print("casterBuff:"..casterBuff)
	--print(caster:GetAbilityByIndex(6):GetAbilityName())
    --stageAbility:ApplyDataDrivenModifier(caster, caster, casterBuff, {Duration = flyDuration})	
	--一个用于实现效果，一个用于hasmodifier监测
	--stageAbility:ApplyDataDrivenModifier(caster, caster, casterBuff_b, {Duration = flyDuration}) 
	caster:AddNewModifier( caster, ability, casterBuff, {Duration = flyDuration})


    local ability_a_name	= keys.ability_a_name
    local ability_b_name	= keys.ability_b_name
    caster:SwapAbilities( ability_a_name, ability_b_name, false, true )
    
    initDurationBuff(keys)

    local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
    ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
	shoot.particleID = particleID
	EmitSoundOn(keys.soundCast, caster)
    moveShoot(keys, shoot, ControlRockBoomCallBack, nil)
	caster.shootOver = 1
	local timeCount = 0
	local interval = 0.1
	
	Timers:CreateTimer(interval,function()
		if not caster:HasModifier(casterBuff) then
			return nil
		end
		--朝向为0-360
		local shootAngles = shoot:GetAnglesAsVector().y
		local casterAngles	= caster:GetAnglesAsVector().y

		local Steering = 1
		if shootAngles ~= casterAngles then
			local resultAngle = casterAngles - shootAngles
			resultAngle = math.abs(resultAngle)
			if resultAngle > 180 then
				if shootAngles < casterAngles then
					Steering = -1
				end
			else
				if shootAngles > casterAngles then
					Steering = -1
				end
			end
			local currentDirection =  shoot:GetForwardVector()
			
			local newX2 = math.cos(math.atan2(currentDirection.y, currentDirection.x) + angleRate * Steering)
			local newY2 = math.sin(math.atan2(currentDirection.y, currentDirection.x) + angleRate * Steering)
			local tempDirection = Vector(newX2, newY2, currentDirection.z)
			shoot:SetForwardVector(tempDirection)
			shoot.direction = tempDirection
		end

		if timeCount < flyDuration then
			timeCount = timeCount + interval
			return interval
		else
			return nil
		end
	end)
end

--技能爆炸,单次伤害
function ControlRockBoomCallBack(shoot)
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
    local damage = getApplyDamageValue(shoot)
    ApplyDamage({victim = unit, attacker = shoot, damage = damage, damage_type = ability:GetAbilityDamageType()})
end



function LevelUpAbility(caster,ability)
	--local this_abilityName = ability:GetAbilityName()
	--print("name:"..ability:GetAbilityName())
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



function EndControl( ability )
	local caster = ability:GetCaster()
	--local unit = ability:GetParent()
	local modifier_caster_syn_name = 'control_rock_modifier_under_control'
	caster:RemoveModifierByName( modifier_caster_syn_name )
	caster.shootOver = -1
end
--[[
function initMagicStage(keys)
	--print("initMagicStage")
	local caster = keys.caster
	-- Swap main ability
	local ability_a_name = keys.ability_a_name
	local ability_b_name = keys.ability_b_name
	caster:SwapAbilities( ability_a_name, ability_b_name, true, false )
	--caster:InterruptMotionControllers( true )
end

--貌似未使用生效

function CheckToInterrupt( keys )
	local caster = keys.caster
	if caster:IsStunned() or caster:IsHexed() or caster:IsFrozen() or caster:IsNightmared() or caster:IsOutOfGame() then
		-- Interrupt the ability
		EndStoneSpear(keys)
	end
end


function LevelUpAbility(keys)
    local caster = keys.caster
	local this_ability = keys.ability
	local this_abilityName = this_ability:GetAbilityName()
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
]]

function OnOrder(keys)
	local caster = keys.caster
	local ability = keys.ability
	--print("GetCursorPosition",caster:GetCursorPosition())
end