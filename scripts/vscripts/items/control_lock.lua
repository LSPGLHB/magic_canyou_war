require('player_power')
require('shoot_init')
item_control_lock = ({})
item_control_lock_2 = ({})
item_control_lock_3 = ({})
modifier_item_control_lock_datadriven = ({})
modifier_item_control_lock_2_datadriven = ({})
modifier_item_control_lock_3_datadriven = ({})
modifier_item_control_lock_debuff = ({})
LinkLuaModifier("modifier_item_control_lock_datadriven", "items/control_lock.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_item_control_lock_2_datadriven", "items/control_lock.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_item_control_lock_3_datadriven", "items/control_lock.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_item_control_lock_debuff", "items/control_lock.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)

function item_control_lock:GetIntrinsicModifierName()
	return "modifier_item_control_lock_datadriven"
end

function item_control_lock:GetCastRange(v,t)
    local range = getRangeByName(self,'item')
    return range
end

function item_control_lock_2:GetIntrinsicModifierName()
	return "modifier_item_control_lock_2_datadriven"
end

function item_control_lock_2:GetCastRange(v,t)
    local range = getRangeByName(self,'item')
    return range
end

function item_control_lock_3:GetIntrinsicModifierName()
	return "modifier_item_control_lock_2_datadriven"
end

function item_control_lock_3:GetCastRange(v,t)
    local range = getRangeByName(self,'item')
    return range
end

function modifier_item_control_lock_datadriven:IsHidden()
	return true
end

function modifier_item_control_lock_datadriven:OnCreated()
    if IsServer() then
        print("OnCreated")
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshItemBuff(keys,true)
    end 
end

function modifier_item_control_lock_datadriven:OnDestroy()
    if IsServer() then
        print("OnDestroy")
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshItemBuff(keys,false)
    end
end

function modifier_item_control_lock_2_datadriven:IsHidden()
	return true
end

function modifier_item_control_lock_2_datadriven:OnCreated()
    if IsServer() then
        print("OnCreated")
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshItemBuff(keys,true)
    end 
end

function modifier_item_control_lock_2_datadriven:OnDestroy()
    if IsServer() then
        print("OnDestroy")
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshItemBuff(keys,false)
    end
end

function modifier_item_control_lock_3_datadriven:IsHidden()
	return true
end

function modifier_item_control_lock_3_datadriven:OnCreated()
    if IsServer() then
        print("OnCreated")
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshItemBuff(keys,true)
    end 
end

function modifier_item_control_lock_3_datadriven:OnDestroy()
    if IsServer() then
        print("OnDestroy")
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshItemBuff(keys,false)
    end
end

function refreshItemBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local item_health = ability:GetSpecialValueFor("item_health")
    local item_ability_speed_percent_base = ability:GetSpecialValueFor("item_ability_speed_percent_base")
    local item_damage = ability:GetSpecialValueFor("item_damage")
    local item_mana_regen = ability:GetSpecialValueFor("item_mana_regen")

    setPlayerPower(playerID, "player_health", flag, item_health)
    setPlayerPower(playerID, "player_ability_speed_percent_base", flag, item_ability_speed_percent_base)
    setPlayerPower(playerID, "player_damage_a", flag, item_damage)
    setPlayerPower(playerID, "player_damage_b", flag, item_damage)
    setPlayerPower(playerID, "player_damage_c", flag, item_damage)
    setPlayerPower(playerID, "player_damage_d", flag, item_damage)
    setPlayerPower(playerID, "player_mana_regen", flag, item_mana_regen)

    setPlayerBuffByNameAndBValue(keys,"health",GameRules.playerBaseHealth)
    setPlayerBuffByNameAndBValue(keys,"mana_regen",GameRules.playerBaseManaRegen)
end

function item_control_lock:OnSpellStart()
    itemControlLockOnSpellStart(self)
end

function item_control_lock_2:OnSpellStart()
    itemControlLockOnSpellStart(self)
end

function item_control_lock_3:OnSpellStart()
    itemControlLockOnSpellStart(self)
end

function itemControlLockOnSpellStart(self)
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local ability = self
    local item_control_time = ability:GetSpecialValueFor("item_control_time")
    local casterPoint = caster:GetAbsOrigin()
    local targetPoint = target:GetAbsOrigin()
    local max_distance = (targetPoint - casterPoint):Length2D()
    local direction = (targetPoint - casterPoint):Normalized()

    local keys = getItemMagicKeys(ability)

    keys.particles_nm = "particles/tiesuo_suotou.vpcf"
    keys.soundCast = "magic_big_fire_ball_cast"

    keys.particles_boom = "particles/tiesuo_suolian.vpcf"
    keys.soundBoom = "magic_big_fire_ball_boom"

    keys.modifierDebuffName = "modifier_item_control_lock_debuff"

    keys.direction = direction
    keys.max_distance_operation = max_distance

    keys.speed = ability:GetSpecialValueFor("speed") * GameRules.speedConstant * 0.02
    keys.damage = 0
    keys.hit_range = 50

    local shoot = CreateUnitByName(keys.unitModel, casterPoint, true, nil, nil, caster:GetTeam())

    shoot.isTrack = 1
    shoot.target = target
    --shoot.intervalCallBack = intervalCallBack(shoot)
    creatTowerSkillInit(keys,shoot,caster)


    shoot.newLocationCp = 1
    --local particleID = ParticleManager:CreateParticle(posParticle, PATTACH_ABSORIGIN_FOLLOW, shoot)
    local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
    ParticleManager:SetParticleControlEnt(particleID, 0 , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)

	
    shoot.particleID = particleID
	EmitSoundOn(keys.soundCast, caster)

    cannonMoveShoot(keys, shoot, itemControlLockCallback)
end

function itemControlLockCallback(shoot)
    boomAOEOperation(shoot, controlLockOperationCallback)
end


function controlLockOperationCallback(shoot,unit)
    local keys = shoot.keysTable
    local caster = shoot.owner
    local ability = keys.ability
    local debuffDuration = ability:GetSpecialValueFor("item_control_time")
    local fromPoint = GetGroundPosition(caster:GetAbsOrigin(), caster)
    local toPoint = GetGroundPosition(unit:GetAbsOrigin(), unit)
    local hight = 50

    local particleBoom = ParticleManager:CreateParticle(keys.particles_boom, PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(particleBoom, 0, Vector(fromPoint.x,fromPoint.y,fromPoint.z + hight))
	ParticleManager:SetParticleControl(particleBoom, 1, Vector(toPoint.x,toPoint.y,toPoint.z + hight))

    caster:AddNewModifier(unit,ability,keys.modifierDebuffName, {Duration = debuffDuration})
    unit:AddNewModifier(unit,ability,keys.modifierDebuffName, {Duration = debuffDuration})

    Timers:CreateTimer(debuffDuration,function()
        ParticleManager:DestroyParticle(particleBoom, true)
    end)
end


function modifier_item_control_lock_debuff:IsDebuff()
    return true
end

function modifier_item_control_lock_debuff:GetEffectName()
	return "particles/tiesuo_buff.vpcf"
end

function modifier_item_control_lock_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_item_control_lock_debuff:CheckState()
	local state = {
        [MODIFIER_STATE_ROOTED] = true
	}
	return state
end

function modifier_item_control_lock_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION
	}
	return funcs
end

function modifier_item_control_lock_debuff:GetOverrideAnimation(keys)
    return ACT_DOTA_DISABLED
end
