modifier_thunder_spirit_caster_buff = ({})

function modifier_thunder_spirit_caster_buff:IsBuff()
    return true
end


function modifier_thunder_spirit_caster_buff:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_DISABLE_TURNING
	}
	return funcs
end

function modifier_thunder_spirit_caster_buff:GetModifierDisableTurning()
	return 1
end


function modifier_thunder_spirit_caster_buff:CheckState()
	local state = {
		[MODIFIER_STATE_SILENCED] = true,
	}
	return state
end



