swamp_area_datadriven_modifier_debuff = ({})
function swamp_area_datadriven_modifier_debuff:IsDebuff()
    return ture
end

function swamp_area_datadriven_modifier_debuff:GetEffectName()
	return "particles/chanraoxiaoguo_debuff_1.vpcf"
end

function swamp_area_datadriven_modifier_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function swamp_area_datadriven_modifier_debuff:CheckState()
	local state = {
		[MODIFIER_STATE_ROOTED] = true,
	}
	return state
end
