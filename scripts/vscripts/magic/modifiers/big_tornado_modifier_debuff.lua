big_tornado_pre_datadriven_modifier_debuff = class({})
function big_tornado_pre_datadriven_modifier_debuff:IsDebuff()
    return true
end

function big_tornado_pre_datadriven_modifier_debuff:GetEffectName()
    return "particles/mohu_debuff.vpcf"
end

function big_tornado_pre_datadriven_modifier_debuff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

big_tornado_datadriven_modifier_debuff = class({})
function big_tornado_datadriven_modifier_debuff:IsDebuff()
    return true
end

function big_tornado_datadriven_modifier_debuff:GetEffectName()
    return "particles/mohu_debuff.vpcf"
end

function big_tornado_datadriven_modifier_debuff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end       