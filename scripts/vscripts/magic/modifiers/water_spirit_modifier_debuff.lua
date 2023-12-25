water_spirit_datadriven_modifier_debuff = ({})


function water_spirit_datadriven_modifier_debuff:IsDebuff()
    return ture
end

function water_spirit_datadriven_modifier_debuff:GetEffectName()
	return "particles/zhuanshen_debuff.vpcf"
end

function water_spirit_datadriven_modifier_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function water_spirit_datadriven_modifier_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
	return funcs
end

function water_spirit_datadriven_modifier_debuff:GetModifierTurnRate_Percentage()
    return self:GetAbility():GetSpecialValueFor("turn_rate_percent")
end

function water_spirit_datadriven_modifier_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("speed_percent")
end

