modifier_small_hurricane_shoot_debuff=({})

function modifier_small_hurricane_shoot_debuff:IsDebuff()
    return true
end

function modifier_small_hurricane_shoot_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION
	}
	return funcs
end

function modifier_small_hurricane_shoot_debuff:GetOverrideAnimation(keys)
    return ACT_DOTA_FLAIL
end

function modifier_small_hurricane_shoot_debuff:CheckState()
	local state = {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true
	}
	return state
end


modifier_small_hurricane_aoe_debuff=({})

function modifier_small_hurricane_shoot_debuff:IsDebuff()
    return true
end

function modifier_sleep_debuff_datadriven:GetEffectName()
	return "particles/hunshui_debuff.vpcf"
end

function modifier_sleep_debuff_datadriven:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end


