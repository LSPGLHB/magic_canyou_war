require('shoot_init')
require('skill_operation')
function createBigFireBall(keys)
    local caster = keys.caster
    local ability = keys.ability
    local skillPoint = ability:GetCursorPosition()
    local speed = ability:GetSpecialValueFor("speed")
    --local max_distance = ability:GetSpecialValueFor("max_distance")
    local angleRate = ability:GetSpecialValueFor("angle_rate") * math.pi
    local casterPoint = caster:GetAbsOrigin()
    local max_distance = (skillPoint - casterPoint ):Length2D()
    local direction = (skillPoint - casterPoint):Normalized()
    local shoot = CreateUnitByName(keys.unitModel, casterPoint, true, nil, nil, caster:GetTeam())

	--[[遥控技能用
    shoot:SetForwardVector(direction)	
    local casterBuff = keys.modifier_caster_name
    local controlDuration = max_distance / speed * 1.66
    ability:ApplyDataDrivenModifier(caster, caster, casterBuff, {Duration = controlDuration})
    local ability_a_name	= keys.ability_a_name
    local ability_b_name	= keys.ability_b_name
    caster:SwapAbilities( ability_a_name, ability_b_name, false, true )
	]]
    creatSkillShootInit(keys,shoot,caster,max_distance,direction)
    --过滤掉增加施法距离的操作
	shoot.max_distance_operation = max_distance
    initDurationBuff(keys)
	--shoot.timer = 0
    local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
    ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
    moveShoot(keys, shoot, particleID, bigFireBallBoomCallBack, nil)

	--[[遥控用
    local timeCount = 0
	local interval = 0.1
	caster:SetContextThink( DoUniqueString( "updateBigFireBall" ), function ( )
		-- Interrupted
		if not caster:HasModifier( casterBuff ) then
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

		if timeCount < controlDuration then
			timeCount = timeCount + interval
			return interval
		else
			return nil
		end
	end, 0)]]
end

--技能爆炸,单次伤害
function bigFireBallBoomCallBack(keys,shoot,particleID)
    ParticleManager:DestroyParticle(particleID, true) --子弹特效消失
    local particleBoom = bigFireBallRenderParticles(keys,shoot) --爆炸粒子效果生成		  
    dealSkillbigFireBallBoom(keys,shoot) --实现aoe爆炸效果
    --bigFireBallDuration(keys,shoot) --实现持续光环效果以及粒子效果
    EmitSoundOn("magic_big_fire_ball_boom", shoot)
	--EndShootControl(keys)--遥控用
    Timers:CreateTimer(1,function ()
        ParticleManager:DestroyParticle(particleBoom, true)
        --EmitSoundOn("Hero_Disruptor.StaticStorm", shoot)
        shoot:ForceKill(true)
        shoot:AddNoDraw()
        return nil
    end)
end

function bigFireBallRenderParticles(keys,shoot)
	local caster = keys.caster
	local ability = keys.ability
	local radius = ability:GetSpecialValueFor("aoe_boom_radius") / 6
	local particleBoom = ParticleManager:CreateParticle(keys.particlesBoom, PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(particleBoom, 3, shoot:GetAbsOrigin())
	ParticleManager:SetParticleControl(particleBoom, 10, Vector(radius, 1, 0))
    return particleBoom
end

function dealSkillbigFireBallBoom(keys,shoot)
	local caster = keys.caster
	local playerID = caster:GetPlayerID()
	local ability = keys.ability
	local AbilityLevel = shoot.abilityLevel
    local visionDebuff = keys.modifierDebuffName
	local radius = ability:GetSpecialValueFor("aoe_boom_radius") --AOE爆炸范围
    
	local position=shoot:GetAbsOrigin()
	local casterTeam = caster:GetTeam()
	
	local aroundUnits = FindUnitsInRadius(casterTeam, 
										position,
										nil,
										radius,
										DOTA_UNIT_TARGET_TEAM_BOTH,
										DOTA_UNIT_TARGET_ALL,
										0,
										0,
										false)
	for k,unit in pairs(aroundUnits) do
		local unitTeam = unit:GetTeam()
		local unitHealth = unit.isHealth
		local lable = unit:GetUnitLabel()
		--只作用于敌方,非技能单位
		if casterTeam ~= unitTeam and lable ~= GameRules.skillLabel then
            local beat_back_one = ability:GetSpecialValueFor("beat_back_one") 
	        local beatBackSpeed = ability:GetSpecialValueFor("beat_back_speed")   
            --local tempDistance = (shoot:GetAbsOrigin() - unit:GetAbsOrigin()):Length2D()
            --local beatBackDistance = beat_back_one - tempDistance   --只击退到AOE的600码
            beatBackUnit(keys,shoot,unit,beat_back_one,beatBackSpeed,1,1)
			local damage = getApplyDamageValue(shoot)
			ApplyDamage({victim = unit, attacker = shoot, damage = damage, damage_type = ability:GetAbilityDamageType()})

			
			local debuff_duration = ability:GetSpecialValueFor("debuff_duration") --debuff持续时间
			debuff_duration = getFinalValueOperation(playerID,debuff_duration,'control',AbilityLevel,owner)
			debuff_duration = getApplyControlValue(shoot, debuff_duration)

			local faceAngle = ability:GetSpecialValueFor("face_angle")
			local blindDirection = shoot:GetAbsOrigin()  - unit:GetAbsOrigin()
			local blindRadian = math.atan2(blindDirection.y, blindDirection.x) * 180 
			local blindAngle = blindRadian / math.pi
			--单位朝向是0-360，相对方向是0~180,0~-180，需要换算
			if blindAngle < 0 then
				blindAngle = blindAngle + 360
			end
			local victimAngle = unit:GetAnglesAsVector().y
			local resultAngle = blindAngle - victimAngle
			resultAngle = math.abs(resultAngle)
			if resultAngle > 180 then
				resultAngle = 360 - resultAngle
			end
			if faceAngle > resultAngle then --固定角度减视野
				ability:ApplyDataDrivenModifier(caster, unit, visionDebuff, {Duration = debuff_duration})
			end
            

		end
		--如果是技能则进行加强或减弱操作
		if lable == GameRules.skillLabel and unitHealth ~= 0 and unit ~= shoot then
            checkHitAbilityToMark(shoot, unit)
		end
	end
    
end

--[[
function bigFireBallDuration(keys,shoot)
    local caster = keys.caster
	local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local AbilityLevel = shoot.abilityLevel
    local visionDebuff = keys.modifierDebuffName
    local aoe_duration_radius = ability:GetSpecialValueFor("aoe_duration_radius") --AOE持续作用范围
    local aoe_duration = ability:GetSpecialValueFor("aoe_duration") --AOE持续作用时间
    aoe_duration = getFinalValueOperation(playerID,aoe_duration,'control',AbilityLevel,owner)
    aoe_duration = getApplyControlValue(shoot, aoe_duration)
    shoot.control = aoe_duration
    --print("aoe_duration:"..aoe_duration)
    --local vision_radius = ability:GetSpecialValueFor("vision_radius") --视野debuff范围
    local debuff_duration = ability:GetSpecialValueFor("debuff_duration") --debuff持续时间
    debuff_duration = getFinalValueOperation(playerID,debuff_duration,'control',AbilityLevel,owner)
    debuff_duration = getApplyControlValue(shoot, debuff_duration)
    print("debuff_duration:"..debuff_duration)
    local position = shoot:GetAbsOrigin()
	local casterTeam = caster:GetTeam()
    local interval = 0.02
    local particleBoom = staticStromRenderParticles(keys,shoot)
    Timers:CreateTimer(0,function ()
        --子弹被销毁的话结束计时器进程
		if shoot.isKill == 1 then
			return nil
		end
		local aroundUnits = FindUnitsInRadius(casterTeam, 
										position,
										nil,
										aoe_duration_radius,
										DOTA_UNIT_TARGET_TEAM_BOTH,
										DOTA_UNIT_TARGET_ALL,
										0,
										0,
										false)
        for k,unit in pairs(aroundUnits) do
            local unitTeam = unit:GetTeam()
            local unitHealth = unit.isHealth
            local lable = unit:GetUnitLabel()
            --只作用于敌方,非技能单位
            if casterTeam ~= unitTeam and lable ~= GameRules.skillLabel then
                local faceAngle = ability:GetSpecialValueFor("face_angle")
                local blindDirection = shoot:GetAbsOrigin()  - unit:GetAbsOrigin()
                local blindRadian = math.atan2(blindDirection.y, blindDirection.x) * 180 
                local blindAngle = blindRadian / math.pi
                --单位朝向是0-360，相对方向是0~180,0~-180，需要换算
                if blindAngle < 0 then
                    blindAngle = blindAngle + 360
                end
                local victimAngle = unit:GetAnglesAsVector().y
                local resultAngle = blindAngle - victimAngle
                resultAngle = math.abs(resultAngle)
                if resultAngle > 180 then
                    resultAngle = 360 - resultAngle
                end
                if faceAngle > resultAngle then --固定角度减视野
                    ability:ApplyDataDrivenModifier(caster, unit, visionDebuff, {Duration = debuff_duration})
                end
            end
            --如果是技能则进行加强或减弱操作，AOE对所有队伍技能有效
            if lable == GameRules.skillLabel and unitHealth ~= 0 and unit ~= shoot then
                checkHitAbilityToMark(shoot, unit)
            end
        end

        return interval
    end)

    Timers:CreateTimer(aoe_duration,function ()
        shoot.isKill = 1
        ParticleManager:DestroyParticle(particleBoom, true)
        EmitSoundOn("Hero_Disruptor.StaticStorm", shoot)	
        shoot:ForceKill(true)
        shoot:AddNoDraw()
        return nil
	end)

  
end

function staticStromRenderParticles(keys,shoot)
	local caster = keys.caster
	local ability = keys.ability
	local duration = shoot.control--ability:GetSpecialValueFor("aoe_duration") --持续时间
   
	local radius = ability:GetSpecialValueFor("aoe_duration_radius")
	local particleBoom = ParticleManager:CreateParticle(keys.durationParticlesBoom, PATTACH_WORLDORIGIN, caster)
    local shootPos = shoot:GetAbsOrigin()
	ParticleManager:SetParticleControl(particleBoom, 0, Vector(shootPos.x, shootPos.y, shootPos.z))
	ParticleManager:SetParticleControl(particleBoom, 1, Vector(radius, 0, 0))
	ParticleManager:SetParticleControl(particleBoom, 2, Vector(duration, 0, 0))
	return particleBoom
end
]]

--遥控用
--[[
function EndShootControl(keys)
    local caster = keys.caster
	caster:RemoveModifierByName( keys.modifier_caster_name )
end

function initSkillStage(keys)
	local caster = keys.caster
	local ability = keys.ability
	-- Swap main ability
	local ability_a_name = keys.ability_a_name
	local ability_b_name = keys.ability_b_name
	caster:SwapAbilities( ability_a_name, ability_b_name, true, false )
	--caster:InterruptMotionControllers( true )
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