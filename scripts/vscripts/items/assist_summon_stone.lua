require('game_init')
require('player_power')
item_assist_summon_stone = ({})
item_assist_summon_stone_2 = ({})
item_assist_summon_stone_3 = ({})
modifier_item_assist_summon_stone_datadriven = ({})
modifier_item_assist_summon_stone_2_datadriven = ({})
modifier_item_assist_summon_stone_3_datadriven = ({})
modifier_item_assist_summon_stone_status = ({})
LinkLuaModifier("modifier_item_assist_summon_stone_datadriven", "items/assist_summon_stone.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_item_assist_summon_stone_2_datadriven", "items/assist_summon_stone.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_item_assist_summon_stone_3_datadriven", "items/assist_summon_stone.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_item_assist_summon_stone_status", "items/assist_summon_stone.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)

function item_assist_summon_stone:GetIntrinsicModifierName()
	return "modifier_item_assist_summon_stone_datadriven"
end

function item_assist_summon_stone_2:GetIntrinsicModifierName()
	return "modifier_item_assist_summon_stone_2_datadriven"
end

function item_assist_summon_stone_3:GetIntrinsicModifierName()
	return "modifier_item_assist_summon_stone_3_datadriven"
end

function modifier_item_assist_summon_stone_datadriven:IsHidden()
	return true
end

function modifier_item_assist_summon_stone_datadriven:OnCreated()
    if IsServer() then
        print("OnCreated")
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshItemBuff(keys,true)
    end 
end

function modifier_item_assist_summon_stone_datadriven:OnDestroy()
    if IsServer() then
        print("OnDestroy")
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshItemBuff(keys,false)
    end
end

function modifier_item_assist_summon_stone_2_datadriven:IsHidden()
	return true
end

function modifier_item_assist_summon_stone_2_datadriven:OnCreated()
    if IsServer() then
        print("OnCreated")
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshItemBuff(keys,true)
    end 
end

function modifier_item_assist_summon_stone_2_datadriven:OnDestroy()
    if IsServer() then
        print("OnDestroy")
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshItemBuff(keys,false)
    end
end

function modifier_item_assist_summon_stone_3_datadriven:IsHidden()
	return true
end

function modifier_item_assist_summon_stone_3_datadriven:OnCreated()
    if IsServer() then
        print("OnCreated")
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshItemBuff(keys,true)
    end 
end

function modifier_item_assist_summon_stone_3_datadriven:OnDestroy()
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
    
    local item_control_percent_base = ability:GetSpecialValueFor("item_control_percent_base") 
    local item_range_percent_base = ability:GetSpecialValueFor("item_range_percent_base") 
    local item_health = ability:GetSpecialValueFor("item_health")
    local item_mana_regen = ability:GetSpecialValueFor("item_mana_regen")
    local item_speed = ability:GetSpecialValueFor("item_speed")

    setPlayerPower(playerID, "player_control_percent_base", flag, item_control_percent_base)
    setPlayerPower(playerID, "player_range_percent_base", flag, item_range_percent_base)  
    setPlayerPower(playerID, "player_health", flag, item_health)
    setPlayerPower(playerID, "player_mana_regen", flag, item_mana_regen)
    setPlayerPower(playerID, "player_speed", flag, item_speed)


    setPlayerSimpleBuff(keys,"range_percent_base")
    setPlayerBuffByNameAndBValue(keys,"health",GameRules.playerBaseHealth)
    setPlayerSimpleBuff(keys,"cooldown_percent_final")
    setPlayerBuffByNameAndBValue(keys,"speed",GameRules.playerBaseSpeed)
end

function item_assist_summon_stone:GetCastRange(v,t)
    local range = getRangeByName(self,'item')
    return range
end

function item_assist_summon_stone:OnSpellStart()
    itemSummonStoneOnSpellStart(self)
end

function item_assist_summon_stone_2:GetCastRange(v,t)
    local range = getRangeByName(self,'item')
    return range
end

function item_assist_summon_stone_2:OnSpellStart()
    itemSummonStoneOnSpellStart(self)
end

function item_assist_summon_stone_3:GetCastRange(v,t)
    local range = getRangeByName(self,'item')
    return range
end

function item_assist_summon_stone_3:OnSpellStart()
    itemSummonStoneOnSpellStart(self)
end

function itemSummonStoneOnSpellStart(self)
    local caster = self:GetCaster()
    local ability = self
    local targetPoint = ability:GetCursorPosition()
    local stoneHealth = ability:GetSpecialValueFor("summon_health") 
    local duration = ability:GetSpecialValueFor("duration") 

    local stone = CreateUnitByName("summonStone", targetPoint, true, nil, nil, caster:GetTeam())

    local particleID = ParticleManager:CreateParticle("particles/zhaohuanshitou.vpcf", PATTACH_ABSORIGIN_FOLLOW, stone)
	local groundPos = GetGroundPosition(stone:GetAbsOrigin(), stone)
	ParticleManager:SetParticleControl(particleID, 0, Vector(groundPos.x,groundPos.y,groundPos.z+50))
	ParticleManager:SetParticleControl(particleID, 1, groundPos)
    stone:SetMaxHealth(stoneHealth)
    stone:AddNewModifier( stone, ability, "modifier_item_assist_summon_stone_status", {Duration = duration} )
    Timers:CreateTimer(duration,function()
        if stone ~= nil and stone:IsAlive() then
            stone:ForceKill(true)
        end
    end)
end

--function modifier_item_assist_summon_stone_status:IsHidden()
--    return true
--end

function modifier_item_assist_summon_stone_status:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_UNSELECTABLE] = false,
    }
    return state
end