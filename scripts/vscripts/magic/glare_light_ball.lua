require('shoot_init')
require('skill_operation')
require('player_power')
--刺眼光波
glare_light_ball_datadriven = ({})
LinkLuaModifier( "glare_light_ball_datadriven_modifier_debuff", "magic/modifiers/glare_light_ball_modifier_debuff.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL )

function glare_light_ball_datadriven:GetCastRange(v,t)
    local range = getRangeByName(self,'b')
    return range
end

function glare_light_ball_datadriven:GetAOERadius()
	local aoe_radius = getAOERadiusByName(self,'b')
	return aoe_radius
end

function glare_light_ball_datadriven:OnSpellStart()
    createShoot(self)
end


function createShoot(ability)
    local caster = ability:GetCaster()
    local magicName = ability:GetAbilityName()
    local keys = getMagicKeys(ability,magicName)

	keys.particles_nm =      "particles/36ciyanguangbo_shengcheng.vpcf"
	keys.soundCast = 		"magic_glare_light_ball_cast"
	keys.particles_misfire = "particles/36ciyanguangbo_jiluo.vpcf"
	keys.soundMisfire =		"magic_light_mis_fire"
	keys.particles_miss =    "particles/36ciyanguangbo_xiaoshi.vpcf"
	keys.soundMiss =			"magic_light_miss"
	keys.particles_power = 	"particles/36ciyanguangbo_jiaqiang.vpcf"
	keys.soundPower =		"magic_light_power_up"
	keys.particles_weak = 	"particles/36ciyanguangbo_xueruo.vpcf"
	keys.soundWeak =			"magic_light_power_down"	
	keys.particles_boom = 	"particles/02tuqiushu_mingzhong.vpcf"
	keys.soundBoom =			"magic_glare_light_ball_boom"
	keys.particles_defense = "particles/duobizhimangbuff_1.vpcf"
	keys.soundDefense =      "magic_defence"
	keys.hitTargetDebuff =   "glare_light_ball_datadriven_modifier_debuff"

    local skillPoint = ability:GetCursorPosition()
    --local speed = ability:GetSpecialValueFor("speed")
	local aoe_radius = ability:GetSpecialValueFor("aoe_radius") 
    local casterPoint = caster:GetAbsOrigin()
    local max_distance = ability:GetSpecialValueFor("max_distance") 
    local direction = (skillPoint - casterPoint):Normalized()
    local shoot = CreateUnitByName(keys.unitModel, casterPoint, true, nil, nil, caster:GetTeam())
    creatSkillShootInit(keys,shoot,caster,max_distance,direction)
    initDurationBuff(keys)
	shoot.aoe_radius = aoe_radius --重置aoe范围，不受攻击范围加强
    local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
    ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
	shoot.particleID = particleID
	EmitSoundOn(keys.soundCast, caster)
    shoot.intervalCallBack = glareLightBallBoomCallBack --周期运行
    moveShoot(keys, shoot, nil, nil)
end

--技能爆炸,单次伤害
function glareLightBallBoomCallBack(shoot)
	local keys = shoot.keysTable
	local caster = keys.caster
	local ability = keys.ability
	local playerID = caster:GetPlayerID()
	local AbilityLevel = shoot.abilityLevel
    local aoe_radius = shoot.aoe_radius
    local faceAngle = ability:GetSpecialValueFor("face_angle")
    local defenceParticles = keys.particles_defense

	local position=shoot:GetAbsOrigin()
	local casterTeam = caster:GetTeam()
	local aroundUnits = FindUnitsInRadius(casterTeam, 
										position,
										nil,
										aoe_radius,
										DOTA_UNIT_TARGET_TEAM_BOTH,
										DOTA_UNIT_TARGET_ALL,
										0,
										0,
										false)
	for k,unit in pairs(aroundUnits) do
		--local unitTeam = unit:GetTeam()
		--local unitHealth = unit.energy_point
		--local lable = unit:GetUnitLabel()
		--只作用于敌方,非技能单位
		if checkIsEnemyHero(shoot,unit) and checkIsHitUnit(shoot,unit) then
            local isface = isFaceByFaceAngle(shoot, unit, faceAngle)
            if isface then
				local damage = getApplyDamageValue(shoot)
	        	ApplyDamage({victim = unit, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})  
                local debuffDuration = ability:GetSpecialValueFor("debuff_duration") --debuff持续时间
				debuffDuration = getFinalValueOperation(playerID,debuffDuration,'control',AbilityLevel,nil)--装备数值加强
				debuffDuration = getApplyControlValue(shoot,debuffDuration)--相生相克计算
                --ability:ApplyDataDrivenModifier(caster, unit, keys.hitTargetDebuff, {Duration = debuffDuration}) 
				unit:AddNewModifier(caster,ability,hitTargetDebuff, {Duration = debuffDuration})
				shootSoundAndParticle(shoot, "boom")
            else
                local defenceParticlesID =ParticleManager:CreateParticle(defenceParticles, PATTACH_OVERHEAD_FOLLOW , unit)
                ParticleManager:SetParticleControlEnt(defenceParticlesID, 3 , unit, PATTACH_OVERHEAD_FOLLOW, nil, shoot:GetAbsOrigin(), true)

                EmitSoundOn(keys.soundDefense, unit)

                Timers:CreateTimer(0.5, function()
                    ParticleManager:DestroyParticle(defenceParticlesID, true)
                    return nil
                end)
            end
		end
		--如果是技能则进行加强或减弱操作
		if checkIsSkill(shoot,unit) then
            checkHitAbilityToMark(shoot, unit)
		end
	end 

   
end

