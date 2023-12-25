whirlwind_axe_datadriven_modifier_debuff = ({})

function whirlwind_axe_datadriven_modifier_debuff:IsBuff()
    return true
end

function whirlwind_axe_datadriven_modifier_debuff:CheckState()
	local state = {
        [MODIFIER_STATE_SILENCED] = true,
        [MODIFIER_STATE_ROOTED] = true
	}
	return state
end

modifier_whirlwind_axe_caster_buff=({})

function modifier_whirlwind_axe_caster_buff:IsDebuff()
    return true
end