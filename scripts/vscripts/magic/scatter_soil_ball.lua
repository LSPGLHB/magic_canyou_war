require('shoot_init')
require('skill_operation')
scatter_soil_ball_datadriven =({})
LinkLuaModifier("scatter_soil_ball_datadriven_modifier_debuff", "magic/modifiers/scatter_soil_ball_modifier_debuff.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)

function scatter_soil_ball_datadriven:GetCastRange(v,t)
    local range = getRangeByName(self,'a')
    return range
end

function scatter_soil_ball_datadriven:OnSpellStart()
    createShoot(self)
end


function createShoot(ability)
    local caster = ability:GetCaster()
    local magicName = ability:GetAbilityName()
    local keys = getMagicKeys(ability,magicName)

    keys.particles_nm =      "particles/42sandantuqiu_shengcheng.vpcf"
    keys.soundCast = 		"magic_scatter_soil_ball_cast"
    keys.particles_misfire = "particles/42sandantuqiu_jiluo.vpcf"
    keys.soundMisfire =		"magic_soil_mis_fire"
    keys.particles_miss =    "particles/42sandantuqiu_xiaoshi.vpcf"
    keys.soundMiss =			"magic_soil_miss"
    keys.particles_power = 	"particles/42sandantuqiu_jiaqiang.vpcf"
    keys.soundPower =		"magic_soil_power_up"
    keys.particles_weak = 	"particles/42sandantuqiu_xueruo.vpcf"
    keys.soundWeak =			"magic_soil_power_down"	
    keys.particles_hit = 	"particles/42sandantuqiu_mingzhong.vpcf"
    keys.soundHit =			"magic_scatter_soil_ball_hit"
    keys.hitTargetDebuff =   "modifier_scatter_soil_ball_debuff_datadriven"

    local skillPoint = ability:GetCursorPosition()
    local max_distance = ability:GetSpecialValueFor("max_distance")
    local angleRate = ability:GetSpecialValueFor("angle_rate")
    local casterPoint = caster:GetAbsOrigin()
    local direction = (skillPoint - casterPoint):Normalized()
    local directionTable ={}
    table.insert(directionTable,direction)
    local angle23 = angleRate * math.pi
    local newX2 = math.cos(math.atan2(direction.y, direction.x) - angle23)
    local newY2 = math.sin(math.atan2(direction.y, direction.x) - angle23)
    local newX3 = math.cos(math.atan2(direction.y, direction.x) + angle23)
    local newY3 = math.sin(math.atan2(direction.y, direction.x) + angle23)
    local direction2 = Vector(newX2, newY2, direction.z)
    table.insert(directionTable,direction2)
    local direction3 = Vector(newX3, newY3, direction.z)
    table.insert(directionTable,direction3)
    initDurationBuff(keys)
    for i = 1, 3, 1 do
        local shoot = CreateUnitByName(keys.unitModel, casterPoint, true, nil, nil, caster:GetTeam())
        creatSkillShootInit(keys,shoot,caster,max_distance,directionTable[i])

        local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
        ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
        shoot.particleID = particleID
        EmitSoundOn(keys.soundCast, shoot)
        moveShoot(keys, shoot, scatterSoilBallBoomCallBack, nil)
    end
end

--技能爆炸,单次伤害
function scatterSoilBallBoomCallBack(shoot)
    boomAOEOperation(shoot, scatterSoilBallAOEOperationCallback)
end


function scatterSoilBallAOEOperationCallback(shoot,unit)
    local keys = shoot.keysTable
    local caster = keys.caster
	local playerID = caster:GetPlayerID()
	local ability = keys.ability
    local AbilityLevel = shoot.abilityLevel
    local hitTargetDebuff = keys.hitTargetDebuff
    local damage = getApplyDamageValue(shoot) / 3
    ApplyDamage({victim = unit, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})

    local debuffDuration = ability:GetSpecialValueFor("debuff_duration") --debuff持续时间
    debuffDuration = getFinalValueOperation(playerID,debuffDuration,'control',AbilityLevel, nil)
    debuffDuration = getApplyControlValue(shoot, debuffDuration)

    --ability:ApplyDataDrivenModifier(caster, unit, hitTargetDebuff, {Duration = debuffDuration})
    unit:AddNewModifier( unit, ability, hitTargetDebuff, {Duration = debuffDuration} )
end 


