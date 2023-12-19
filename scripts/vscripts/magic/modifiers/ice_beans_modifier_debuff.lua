ice_beans_datadriven_modifier_debuff = ({})

function ice_beans_datadriven_modifier_debuff:IsDebuff()
    return ture
end

function ice_beans_datadriven_modifier_debuff:GetEffectName()
	return "particles/jiansu_debuff.vpcf"
end

function ice_beans_datadriven_modifier_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function ice_beans_datadriven_modifier_debuff:DeclareFunctions()
	local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
	return funcs
end

function ice_beans_datadriven_modifier_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("speed_percent")
end

