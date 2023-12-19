electric_wall_datadriven_modifier_debuff = ({})

function electric_wall_datadriven_modifier_debuff:IsDebuff()
    return ture
end

function electric_wall_datadriven_modifier_debuff:GetEffectName()
	return "particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_stunned_symbol.vpcf"
end

function electric_wall_datadriven_modifier_debuff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function electric_wall_datadriven_modifier_debuff:CheckState()
	local state = {
        [MODIFIER_STATE_STUNNED] = true,
        --[MODIFIER_STATE_ROOTED] = true,
        --[MODIFIER_STATE_MUTED] = true,
        --[MODIFIER_STATE_NIGHTMARED] = true
	}
	return state
end

function electric_wall_datadriven_modifier_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION
	}
	return funcs
end

function electric_wall_datadriven_modifier_debuff:GetOverrideAnimation(keys)
    return ACT_DOTA_DISABLED
end

