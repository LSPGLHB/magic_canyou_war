modifier_tie_defence_passive = ({})
function modifier_tie_defence_passive:OnCreated()
    earthSpiritCount = 0

end
function modifier_tie_defence_passive:DeclareFunctions()
	local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE
	}
	return funcs
end


function modifier_tie_defence_passive:OnTakeDamage(keys)
    --受伤的是buff主人
    if IsServer() and keys.unit == self:GetParent() then
        --local caster = self:GetCaster()
        local ability = self:GetAbility()
        local unit = self:GetParent()
        local damage = keys.damage
        earthSpiritCount = earthSpiritCount + 1
        
        local refresh_count = ability:GetSpecialValueFor("refresh_count")
        if earthSpiritCount >= refresh_count then 
            ability:EndCooldown()
            earthSpiritCount = 0
        end
        unit:SetModifierStackCount("modifier_tie_defence_passive",unit,earthSpiritCount)
        --print("damage"..damage)    
    end
    --[[攻击者为buff主人
    if IsServer() and keys.attacker == self:GetParent() then
        print("222222222")
    end]]
end


modifier_tie_defence_buff = ({})

function modifier_tie_defence_buff:GetEffectName()
	return "particles/tiekuai_buff.vpcf"
end

function modifier_tie_defence_buff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_tie_defence_buff:DeclareFunctions()
	local funcs = {
        --MODIFIER_EVENT_ON_TAKEDAMAGE,
        --MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
	return funcs
end

function modifier_tie_defence_buff:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("speed_percent")
end

if IsServer() then
    function modifier_tie_defence_buff:OnCreated()
        refreshDefenceBuff(self,true)
    end
end

if IsServer() then
    function modifier_tie_defence_buff:OnDestroy()
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
    setPlayerPower(playerID, "player_defense", flag, defence_percent)
    setPlayerBuffByNameAndBValue(keys,"defense",GameRules.playerBaseDefense)
end

