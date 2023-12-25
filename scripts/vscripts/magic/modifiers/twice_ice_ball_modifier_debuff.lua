twice_ice_ball_datadriven_modifier_debuff = ({})

function twice_ice_ball_datadriven_modifier_debuff:IsDebuff()
    return ture
end

function twice_ice_ball_datadriven_modifier_debuff:GetEffectName()
	return "particles/jiansu_debuff.vpcf"
end

function twice_ice_ball_datadriven_modifier_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function twice_ice_ball_datadriven_modifier_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
	return funcs
end

function twice_ice_ball_datadriven_modifier_debuff:GetModifierTurnRate_Percentage()
    return self:GetAbility():GetSpecialValueFor("turn_rate_percent")
end

function twice_ice_ball_datadriven_modifier_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("speed_percent")
end


modifier_twice_ice_ball_datadriven_buff =({})

function modifier_twice_ice_ball_datadriven_buff:IsBuff()
    return true
end

function modifier_twice_ice_ball_datadriven_buff:OnDestroy()
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
