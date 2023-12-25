twice_stone_ball_datadriven_modifier_debuff = ({})

function twice_stone_ball_datadriven_modifier_debuff:IsDebuff()
    return ture
end

function twice_stone_ball_datadriven_modifier_debuff:GetEffectName()
	return "particles/chanraoxiaoguo_debuff_1.vpcf"
end

function twice_stone_ball_datadriven_modifier_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function twice_stone_ball_datadriven_modifier_debuff:CheckState()
	local state = {
        --[MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_ROOTED] = true,
        --[MODIFIER_STATE_MUTED] = true,
        --[MODIFIER_STATE_NIGHTMARED] = true
	}
	return state
end


twice_stone_ball_datadriven_modifier_debuff_delay = ({})

function twice_stone_ball_datadriven_modifier_debuff_delay:IsDebuff()
    return ture
end

function twice_stone_ball_datadriven_modifier_debuff_delay:GetEffectName()
	return "particles/17_1tuqiushu_debuff.vpcf"
end

function twice_stone_ball_datadriven_modifier_debuff_delay:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end


modifier_twice_stone_ball_datadriven_buff =({})

function modifier_twice_stone_ball_datadriven_buff:IsBuff()
    return true
end

function modifier_twice_stone_ball_datadriven_buff:OnDestroy()
    --local caster = self:GetCaster()
    if IsServer() then
        local ability = self:GetAbility()
        local magicName = ability:GetAbilityName()
        local unit = self:GetParent()
        local ability_a_name = magicName
        local ability_b_name = magicName.."_stage_b"
        --print("OnDestroy:"..magicName)
        if not unit:IsNull() then
            unit:SwapAbilities( ability_a_name, ability_b_name, true, false )
        end
    end
end


twice_stone_ball_datadriven_modifier_debuff_sp2 = ({})

function twice_stone_ball_datadriven_modifier_debuff_sp2:IsDebuff()
    return ture
end

function twice_stone_ball_datadriven_modifier_debuff_sp2:GetEffectName()
	return "particles/17_2tuqiushu_debuff.vpcf"
end

function twice_stone_ball_datadriven_modifier_debuff_sp2:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
