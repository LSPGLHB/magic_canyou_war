require('shoot_init')
require('skill_operation')
function createFireBottle(keys)
    local caster = keys.caster
    local ability = keys.ability
    local skillPoint = ability:GetCursorPosition()
    local speed = ability:GetSpecialValueFor("speed")
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
    moveShoot(keys, shoot, particleID, fireBottleBoomCallBack, nil)
end


function fireBottleBoomCallBack(keys,shoot,particleID)
    ParticleManager:DestroyParticle(particleID, true) --子弹特效消失 
    fireBottleDuration(keys,shoot) --实现持续光环效果以及粒子效果
    EmitSoundOn("magic_fire_bottle_boom", shoot)
end



function fireBottleDuration(keys,shoot)
    local caster = keys.caster
	local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local AbilityLevel = shoot.abilityLevel
    local radius = ability:GetSpecialValueFor("aoe_radius") --AOE持续作用范围
    local duration = ability:GetSpecialValueFor("aoe_duration") --AOE持续作用时间
    local position = shoot:GetAbsOrigin()
	local casterTeam = caster:GetTeam()
    local interval = 0.5
    local particleBoom = fireBottleRenderParticles(keys,shoot)

    Timers:CreateTimer(0.8,function ()
        EmitSoundOn("magic_fire_bottle_duration", shoot)
        return nil
    end)

    Timers:CreateTimer(0,function ()
        --子弹被销毁的话结束计时器进程
		if shoot.isKill == 1 then
			return nil
		end
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
            local shootPos = shoot:GetAbsOrigin()
            local unitPos = unit:GetAbsOrigin()
            local distance = (shootPos - unitPos):Length2D()
            --只作用于敌方,非技能单位
            if casterTeam ~= unitTeam and lable ~= GameRules.skillLabel then
                local damage = getApplyDamageValue(shoot) / duration * interval
                --一半范围内伤害加倍
                if distance < 0.5 * radius then
                    damage = damage * 2
                end
			    ApplyDamage({victim = unit, attacker = shoot, damage = damage, damage_type = ability:GetAbilityDamageType()})
            end
            --如果是技能则进行加强或减弱操作，AOE对所有队伍技能有效
            if lable == GameRules.skillLabel and unitHealth ~= 0 and unit ~= shoot then
                checkHitAbilityToMark(shoot, unit)
            end
        end

        return interval
    end)

    Timers:CreateTimer(duration,function ()
        shoot.isKill = 1
        EmitSoundOn("magic_voice_stop", shoot)
        ParticleManager:DestroyParticle(particleBoom, true)
        shoot:ForceKill(true)
        shoot:AddNoDraw()
        return nil
	end)
end


function fireBottleRenderParticles(keys,shoot)
    local caster = keys.caster
	local ability = keys.ability
	local radius = ability:GetSpecialValueFor("aoe_radius")
    local duration = ability:GetSpecialValueFor("aoe_duration")    
	local particleBoom = ParticleManager:CreateParticle(keys.particlesBoom, PATTACH_WORLDORIGIN, caster)
    local groundPos = GetGroundPosition(shoot:GetAbsOrigin(), shoot)
	ParticleManager:SetParticleControl(particleBoom, 3, groundPos)
    ParticleManager:SetParticleControl(particleBoom, 11, Vector(duration, 0, 0))
	ParticleManager:SetParticleControl(particleBoom, 10, Vector(radius, 1, 0))
    return particleBoom
end