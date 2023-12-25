thunder_area_datadriven_modifier_debuff = ({})
function thunder_area_datadriven_modifier_debuff:IsDebuff()
    return ture
end

function thunder_area_datadriven_modifier_debuff:GetEffectName()
	return "particles/xuanyun_debuff.vpcf"
end

function thunder_area_datadriven_modifier_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

modifier_thunder_area_stun = ({})
function modifier_thunder_area_stun:IsDebuff()
    return ture
end

function modifier_thunder_area_stun:GetEffectName()
	return "particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_stunned_symbol.vpcf"
end

function modifier_thunder_area_stun:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_thunder_area_stun:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION
	}
	return funcs
end

function modifier_thunder_area_stun:GetOverrideAnimation(keys)
    return ACT_DOTA_DISABLED
end

function modifier_thunder_area_stun:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
	}
	return state
end
