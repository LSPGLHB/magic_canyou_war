ice_skeleton_datadriven_modifier_debuff = ({})
function ice_skeleton_datadriven_modifier_debuff:IsDebuff()
    return ture
end

function ice_skeleton_datadriven_modifier_debuff:GetEffectName()
	return "particles/hunluan_debuff_lanse_1.vpcf"
end

function ice_skeleton_datadriven_modifier_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function ice_skeleton_datadriven_modifier_debuff:CheckState()
	local state = {
        [MODIFIER_STATE_SILENCED] = true
	}
	return state
end
