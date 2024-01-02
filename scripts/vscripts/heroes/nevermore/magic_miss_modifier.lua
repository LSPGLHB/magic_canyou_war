modifier_speed_up_cast = ({})
function modifier_speed_up_cast:DeclareFunctions()
	local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        --MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
	return funcs
end

function modifier_speed_up_cast:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("passive_speed_up_percent")
end

modifier_magic_miss_passive = ({})

intervalNeverMorePassive = nil

if IsServer() then
    function modifier_magic_miss_passive:OnCreated()
        local caster = self:GetCaster()
        local ability = self:GetAbility()
        local unit = self:GetParent()
        local aoe_radius = ability:GetSpecialValueFor("aoe_radius")
        intervalNeverMorePassive = 0.02
        Timers:CreateTimer(
            
           
            return intervalNeverMorePassive
        )
    end
end

if IsServer() then
    function modifier_magic_miss_passive:OnDestroy()
        intervalNeverMorePassive = nil
    end
end
