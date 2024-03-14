modifier_earth_spirit_defence_passive = ({})

function modifier_earth_spirit_defence_passive:IsBuff()
    return true
end

function modifier_earth_spirit_defence_passive:OnCreated()
    if IsServer() then
        local unit = self:GetParent()
        unit.earthSpiritPassiveArray = {}
        earthSpiritCount = 0
    end
end

function modifier_earth_spirit_defence_passive:OnDestroy()
    if IsServer() then
        local unit = self:GetParent()
        unit.earthSpiritPassiveArray = {}
        earthSpiritCount = 0
    end
end

function modifier_earth_spirit_defence_passive:DeclareFunctions()
	local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE
	}
	return funcs
end


function modifier_earth_spirit_defence_passive:OnTakeDamage(keys)
    --受伤的是buff主人
    if IsServer() and keys.unit == self:GetParent() then
        --local caster = self:GetCaster()
        local ability = self:GetAbility()
        local unit = self:GetParent()
        local damage = keys.damage
        local shoot = keys.attacker
        if unit.earthSpiritPassiveArray == nil then
            unit.earthSpiritPassiveArray = {}
        end
        local isContain = checkContainsArrayValue(unit.earthSpiritPassiveArray, shoot)
        if not isContain then
            local modifierName = "modifier_earth_spirit_defence_passive"
            table.insert(unit.earthSpiritPassiveArray,shoot)
            earthSpiritCount = earthSpiritCount + 1
            local refresh_count = ability:GetSpecialValueFor("refresh_count")
            if earthSpiritCount >= refresh_count then 
                ability:EndCooldown()
                unit:RemoveModifierByName(modifierName)
                unit:AddNewModifier(unit, ability, modifierName, {Duration = -1})
            end
            unit:SetModifierStackCount(modifierName,unit,earthSpiritCount)
        end
        --print("damage"..damage)    
    end
    --[[攻击者为buff主人
    if IsServer() and keys.attacker == self:GetParent() then
        print("222222222")
    end]]
end


modifier_earth_spirit_defence_buff = ({})

function modifier_earth_spirit_defence_buff:GetEffectName()
	return "particles/tiekuai_buff.vpcf"
end

function modifier_earth_spirit_defence_buff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_earth_spirit_defence_buff:DeclareFunctions()
	local funcs = {
        --MODIFIER_EVENT_ON_TAKEDAMAGE,
        --MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
	return funcs
end

function modifier_earth_spirit_defence_buff:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("speed_percent")
end

if IsServer() then
    function modifier_earth_spirit_defence_buff:OnCreated()
        refreshDefenceBuff(self,true)
    end
end

if IsServer() then
    function modifier_earth_spirit_defence_buff:OnDestroy()
        refreshDefenceBuff(self,false)
    end
end

function refreshDefenceBuff(self,flag)
    local caster = self:GetCaster()
    local ability = self:GetAbility()
    local keys = {}
    keys.caster = caster
    keys.ability = ability
    local unit = self:GetParent()
    local playerID = unit:GetPlayerID()
    local defence_percent = ability:GetSpecialValueFor("defence_percent")
    setPlayerPower(playerID, "talent_defense", flag, defence_percent)
    setPlayerBuffByNameAndBValue(keys,"defense",GameRules.playerBaseDefense)
end

