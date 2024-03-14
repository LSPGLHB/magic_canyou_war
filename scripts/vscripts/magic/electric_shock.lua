require('shoot_init')
require('skill_operation')

electric_shock_datadriven = class({})
electric_shock_datadriven_stage_b = class({})
LinkLuaModifier( "modifier_electric_shock_datadriven_buff", "magic/modifiers/electric_shock_modifier_debuff.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL )
LinkLuaModifier( "modifier_electric_shock_stun", "magic/modifiers/electric_shock_modifier_debuff.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL )
LinkLuaModifier( "modifier_sleep_debuff_datadriven", "magic/modifiers/modifier_sleep_debuff.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL )


function electric_shock_datadriven:OnUpgrade()
	LevelUpAbility(self)
end

function electric_shock_datadriven:GetCastRange(v,t)
    local range = getRangeByName(self,'b')
    return range
end

function electric_shock_datadriven:OnSpellStart()
    stepOne(self)
end

function electric_shock_datadriven_stage_b:GetCastRange(v,t)
    local range = getRangeByName(self,'b')
    return range
end

function electric_shock_datadriven_stage_b:OnSpellStart()
    stepTwo(self)
end

function stepOne(ability)

    local caster = ability:GetCaster()
    local magicName = ability:GetAbilityName()
    local keys = getMagicKeys(ability,magicName)

    keys.particles_nm =      "particles/23_2zhengfudianji_shengcheng.vpcf"
    keys.soundCast =			"magic_electric_shock_cast"
    
    keys.particles_power = 	"particles/23_2zhengfudianji_jiaqiang.vpcf"
    keys.soundPower =		"magic_electric_power_up"
    keys.particles_weak = 	"particles/23_2zhengfudianji_xueruo.vpcf"
    keys.soundWeak =			"magic_electric_power_down"
    keys.particles_misfire = "particles/23_2zhengfudianji_jiluo.vpcf"
    keys.soundMisfire =		"magic_electric_mis_fire"
    keys.particles_miss =    "particles/23_2zhengfudianji_xiaoshi.vpcf"
    keys.soundMiss =			"magic_electric_miss"

    keys.particles_hit = 	"particles/23_2zhengfudianji_mingzhong.vpcf"
    keys.soundHit =			"magic_electric_shock_hit"
    keys.particles_boom = 	"particles/zhengfudianjibaozha.vpcf"
    keys.soundBoom =			"magic_electric_shock_boom"

    keys.stunDebuff =        "modifier_electric_shock_stun"

    keys.modifier_caster_syn_name =	   "modifier_electric_shock_datadriven_buff"--"electric_shock_datadriven_modifier_debuff"

    keys.ability_a_name =		   'electric_shock_datadriven'
    keys.ability_b_name =		   "electric_shock_datadriven_stage_b"

    local skillPoint = ability:GetCursorPosition()  
    local casterPoint = caster:GetAbsOrigin()
    local max_distance = ability:GetSpecialValueFor("max_distance")
    local playerID = caster:GetPlayerID()
    local AbilityLevel = keys.AbilityLevel
    --local set_distance = getFinalValueOperation(playerID,max_distance,'range',AbilityLevel,nil)
    local direction = (skillPoint - casterPoint):Normalized()
    local shootPoint = skillPoint--casterPoint + set_distance * direction

	
    local shoot = CreateUnitByName(keys.unitModel, shootPoint, true, nil, nil, caster:GetTeam())
    local groundPos = GetGroundPosition(shootPoint, shoot)
    local shootPos = Vector(groundPos.x, groundPos.y, groundPos.z + 100)
    shoot:SetAbsOrigin(shootPos)
    creatSkillShootInit(keys,shoot,caster,max_distance,direction)

    shoot.aoe_radius = getApplyControlValue(shoot, shoot.aoe_radius)
    shoot.speed = 0
    --过滤掉增加施法距离的操作
	--shoot.max_distance_operation = max_distance
    --initDurationBuff(keys)


    local casterBuff = keys.modifier_caster_syn_name
    --ability:ApplyDataDrivenModifier(caster, caster, casterBuff, {Duration = 5})
    caster:AddNewModifier(caster,ability,casterBuff, {Duration = 5} )
    

    shoot.launchElectricShock = 0
    local ability_a_name	= keys.ability_a_name
    local ability_b_name	= keys.ability_b_name
    caster:SwapAbilities( ability_a_name, ability_b_name, false, true )

    local timeCount = 0
    Timers:CreateTimer(0.1 ,function()
        if shoot.energy_point == 0 then
            if caster:HasModifier(casterBuff) then
                caster:RemoveModifierByName(casterBuff) 
            end
            return nil
        end
        timeCount = timeCount + 0.1
        if timeCount >= 5 then
            return nil
        end
        return 0.1
    end)

    

    local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
    ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
	shoot.particleID = particleID
	EmitSoundOn(keys.soundCast, caster)

    --PlayerPower[playerID]["electric_shock_a"] = shoot
    caster.electric_shock_a = shoot
    shoot.playerID = playerID
    --moveShoot(keys, shoot, electricBallBoomCallBack, nil)
    caster.shootOver = 1
end

function stepTwo(ability)

    local caster = ability:GetCaster()
    --local magicName = ability:GetAbilityName()
    local keys = getMagicKeys(ability,'electric_shock_datadriven')

    keys.particles_nm =      "particles/23_1zhengfudianji_shengcheng.vpcf"
    keys.soundCast =			"magic_electric_shock_cast"
    
    keys.particles_power = 	"particles/23_1zhengfudianji_jiaqiang.vpcf"
    keys.soundPower =		"magic_electric_power_up"
    keys.particles_weak = 	"particles/23_1zhengfudianji_xueruo.vpcf"
    keys.soundWeak =			"magic_electric_power_down"
    keys.particles_misfire = "particles/23_1zhengfudianji_jiluo.vpcf"
    keys.soundMisfire =		"magic_electric_mis_fire"
    keys.particles_miss =    "particles/23_1zhengfudianji_xiaoshi.vpcf"
    keys.soundMiss =			"magic_electric_miss"

    keys.particles_hit = 	"particles/23_1zhengfudianji_mingzhong.vpcf"
    keys.soundHit =			"magic_electric_shock_hit_2"
    keys.particles_boom = 	"particles/zhengfudianjibaozha.vpcf"
    keys.soundBoom =			"magic_electric_shock_boom"


    keys.sleepDebuff =   "modifier_sleep_debuff_datadriven"
    keys.stunDebuff =    "modifier_electric_shock_stun"


    keys.modifier_caster_syn_name =	   "modifier_electric_shock_datadriven_buff"
    keys.ability_a_name =		   "electric_shock_datadriven"
    keys.ability_b_name =		   "electric_shock_datadriven_stage_b"

    
    local skillPoint = ability:GetCursorPosition()
    local casterPoint = caster:GetAbsOrigin()
    local max_distance = ability:GetSpecialValueFor("max_distance")
    local playerID = caster:GetPlayerID()
    local AbilityLevel = keys.AbilityLevel
    --local set_distance = getFinalValueOperation(playerID,max_distance,'range',AbilityLevel,nil)
    local direction = (skillPoint - casterPoint):Normalized()
    local shootPoint = skillPoint--casterPoint + set_distance * direction
    local shoot = CreateUnitByName(keys.unitModel, shootPoint, true, nil, nil, caster:GetTeam())
    local groundPos = GetGroundPosition(shootPoint, shoot)
    local shootPos = Vector(groundPos.x, groundPos.y, groundPos.z + 100)
    shoot:SetAbsOrigin(shootPos)
    creatSkillShootInit(keys,shoot,caster,max_distance,direction)

    shoot.aoe_radius = getApplyControlValue(shoot, shoot.aoe_radius)
    shoot.speed = 0
    --过滤掉增加施法距离的操作
	--shoot.max_distance_operation = max_distance
    initDurationBuff(keys)
    

    local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
    ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
	shoot.particleID = particleID
	EmitSoundOn(keys.soundCast, caster)

    --PlayerPower[playerID]["electric_shock_b"] = shoot
    caster.electric_shock_b = shoot
    shoot.playerID = playerID
    local shoot_a =  caster.electric_shock_a --PlayerPower[playerID]["electric_shock_a"] 
    shoot_a.launchElectricShock = 1
    local casterBuff = keys.modifier_caster_syn_name
    if caster:HasModifier(casterBuff) then
        caster:RemoveModifierByName(casterBuff) 
    end
    Timers:CreateTimer(0.5,function()
        launchElectricShock(keys)
    end)
    caster.shootOver = 1
end

function launchElectricShock(keys)
    local caster = keys.caster
    local playerID = caster:GetPlayerID()

    local shoot_a = caster.electric_shock_a --PlayerPower[playerID]["electric_shock_a"]
    local shoot_b = caster.electric_shock_b --PlayerPower[playerID]["electric_shock_b"]

    local a_point = shoot_a:GetAbsOrigin()
    local b_point = shoot_b:GetAbsOrigin()

    local a_direction = (b_point - a_point):Normalized()
    local b_direction = (a_point - b_point):Normalized()

    local max_distance = (b_point - a_point):Length2D()

    creatSkillShootInit(keys,shoot_a,caster,max_distance,a_direction)
    creatSkillShootInit(keys,shoot_b,caster,max_distance,b_direction)
    shoot_b.isBoom = 1
    shoot_a.intervalCallBack = electricShockIntervalCallBack
    shoot_b.intervalCallBack = electricShockIntervalCallBack
    

    moveShoot(keys, shoot_a, nil, electricShockAHitCallback)
    moveShoot(keys, shoot_b, nil, electricShockBHitCallback)
end

function electricShockAHitCallback(shoot,unit)
    local keys = shoot.keysTable
    local caster = keys.caster
	local playerID = caster:GetPlayerID()
	local ability = keys.ability
    local AbilityLevel = shoot.abilityLevel
    local debuffName = keys.stunDebuff
    local damage = getApplyDamageValue(shoot) / 4
    ApplyDamage({victim = unit, attacker = shoot, damage = damage, damage_type = ability:GetAbilityDamageType()})

    local debuffDuration = ability:GetSpecialValueFor("stun_debuff_duration") --debuff持续时间
    debuffDuration = getFinalValueOperation(playerID,debuffDuration,'control',AbilityLevel,nil)
    debuffDuration = getApplyControlValue(shoot, debuffDuration)
    debuffDuration = debuffDuration * (shoot.speed -200 * 0.02) / (800 * 0.02)
    --print("AdebuffDuration:",debuffDuration)
    --ability:ApplyDataDrivenModifier(caster, unit, debuffName, {Duration = debuffDuration})
    unit:AddNewModifier(unit,ability,debuffName, {Duration = debuffDuration})
end

function electricShockBHitCallback(shoot,unit)
    local keys = shoot.keysTable
    local caster = keys.caster
	local playerID = caster:GetPlayerID()
	local ability = keys.ability
    local AbilityLevel = shoot.abilityLevel
    local debuffName = keys.sleepDebuff
    local damage = getApplyDamageValue(shoot) / 4
    ApplyDamage({victim = unit, attacker = shoot, damage = damage, damage_type = ability:GetAbilityDamageType()})

    local debuffDuration = ability:GetSpecialValueFor("sleep_debuff_duration") --debuff持续时间
    debuffDuration = getFinalValueOperation(playerID,debuffDuration,'control',AbilityLevel,nil)
    debuffDuration = getApplyControlValue(shoot, debuffDuration)
    debuffDuration = debuffDuration * (shoot.speed - 200 * 0.02) / (800 * 0.02)
    --print("BdebuffDuration:",debuffDuration)
    --ability:ApplyDataDrivenModifier(caster, unit, debuffName, {Duration = debuffDuration})
    unit:AddNewModifier(unit,ability,debuffName, {Duration = debuffDuration} )
end


function electricShockIntervalCallBack(shoot)
    local keys = shoot.keysTable
	local caster = keys.caster
    local playerID = caster:GetPlayerID()
    local interval = 0.02
    local shoot_a = caster.electric_shock_a --PlayerPower[playerID]["electric_shock_a"]
    local shoot_b = caster.electric_shock_b --PlayerPower[playerID]["electric_shock_b"]
    local energy_point_a = shoot_a.energy_point
    local energy_point_b = shoot_b.energy_point
    --print("electricShockIntervalCallBack-a",energy_point_a,"b:",energy_point_b)
    if energy_point_a == 0 and energy_point_b > 0 then
        shootSoundAndParticle(shoot_b, 'miss')
        shootKill(shoot_b)
    end
    if energy_point_b == 0 and energy_point_a > 0 then
        shootSoundAndParticle(shoot_a, 'miss')
        shootKill(shoot_a)
    end

	local ability = keys.ability
    --local debuff_aoe_radius = ability:GetSpecialValueFor("hit_range")
    local hit_range = ability:GetSpecialValueFor("hit_range")

    local a_position=shoot_a:GetAbsOrigin()
    local b_position=shoot_b:GetAbsOrigin()
    local distance = (b_position - a_position):Length2D() 
    local a_direction = (b_position - a_position):Normalized()
    shoot_a.direction = a_direction
    local b_direction = (a_position - b_position):Normalized()
    shoot_b.direction = b_direction
    --print("electricShockIntervalCallBack:",distance)
    local max_speed = 1000 * interval
    if shoot_a.speed < max_speed then 
        shoot_a.speed = shoot_a.speed + 800 * interval  / (1.5 / interval)
        shoot_b.speed = shoot_b.speed + 800 * interval / (1.5 / interval)
    end

    if shoot_b.distance_ab == nil then
        shoot_b.distance_ab = distance
    end
    --print("shoot.isBoom:",shoot.isBoom)
    if (distance < hit_range or distance > shoot_b.distance_ab) and shoot.isBoom == 1 then      
        electricShockBoomCallBack(shoot_b)
        shootKill(shoot_a)
    end
    shoot_b.distance_ab = distance
end


function electricShockBoomCallBack(shoot)
	electricShockBoomAOERenderParticles(shoot)
    boomAOEOperation(shoot, electricShockAOEOperationCallback)
end

function electricShockBoomAOERenderParticles(shoot)
    local keys = shoot.keysTable
	local caster = keys.caster
	--local ability = keys.ability
	local radius = shoot.aoe_radius--ability:GetSpecialValueFor("aoe_radius") 
	local particleBoom = ParticleManager:CreateParticle(keys.particles_boom, PATTACH_WORLDORIGIN, caster)
	local groundPos = GetGroundPosition(shoot:GetAbsOrigin(), shoot)
    local shootPos = Vector(groundPos.x, groundPos.y, groundPos.z + 100)
	ParticleManager:SetParticleControl(particleBoom, 0, shootPos)
	ParticleManager:SetParticleControl(particleBoom, 10, Vector(radius, 0, 0))
end

function electricShockAOEOperationCallback(shoot,unit)
    local keys = shoot.keysTable
    local caster = keys.caster
	local playerID = caster:GetPlayerID()
	local ability = keys.ability
    local AbilityLevel = shoot.abilityLevel
    local stunDebuff = keys.stunDebuff  
    local sleepDebuff = keys.sleepDebuff   

    local damage = getApplyDamageValue(shoot) / 2 
    ApplyDamage({victim = unit, attacker = shoot, damage = damage, damage_type = ability:GetAbilityDamageType()})

    local stunDebuffDuration = ability:GetSpecialValueFor("stun_debuff_duration")--debuff持续时间
    local sleepDebuffDuration = ability:GetSpecialValueFor("sleep_debuff_duration") 
    
    stunDebuffDuration = getFinalValueOperation(playerID,stunDebuffDuration,'control',AbilityLevel,nil)
    stunDebuffDuration = getApplyControlValue(shoot, stunDebuffDuration)
    stunDebuffDuration = stunDebuffDuration * (shoot.speed -200 * 0.02) / (800 * 0.02)

    sleepDebuffDuration = getFinalValueOperation(playerID,sleepDebuffDuration,'control',AbilityLevel,nil)
    sleepDebuffDuration = getApplyControlValue(shoot, sleepDebuffDuration)
    sleepDebuffDuration = sleepDebuffDuration * (shoot.speed -200 * 0.02) / (800 * 0.02)

    --ability:ApplyDataDrivenModifier(caster, unit, stunDebuff,  {Duration = stunDebuffDuration})
    --ability:ApplyDataDrivenModifier(caster, unit, sleepDebuff, {Duration = sleepDebuffDuration})

    unit:AddNewModifier(unit,ability,stunDebuff, {Duration = stunDebuffDuration})
    unit:AddNewModifier(unit,ability,sleepDebuff, {Duration = sleepDebuffDuration})
     
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




