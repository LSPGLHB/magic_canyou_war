fire_arrow_bomb_datadriven_modifier_debuff = ({})

function fire_arrow_bomb_datadriven_modifier_debuff:IsDebuff()
    return ture
end

function fire_arrow_bomb_datadriven_modifier_debuff:GetEffectName()
	return "particles/41huojianshu_debuff.vpcf"
end

function fire_arrow_bomb_datadriven_modifier_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end