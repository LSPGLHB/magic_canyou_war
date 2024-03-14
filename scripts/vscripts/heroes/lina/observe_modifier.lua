modifier_observe_buff = ({})
function modifier_observe_buff:IsBuff()
    return true
end

function modifier_observe_buff:DeclareFunctions()
	local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE
	}
	return funcs
end

function modifier_observe_buff:OnCreated()
    if IsServer() then
        local unit = self:GetParent()
        unit.linaPassiveArray = {}
    end

end

function modifier_observe_buff:OnTakeDamage(keys)
    local shoot = keys.attacker
    if IsServer() and shoot.owner == self:GetParent() then
        
        local ability = self:GetAbility()
        local unit = keys.unit --受伤的人
        if unit.linaPassiveArray == nil then
            unit.linaPassiveArray = {}
        end
        local isContain = checkContainsArrayValue(unit.linaPassiveArray, shoot)
        if not isContain then
            --print(shoot:GetName())
            table.insert(unit.linaPassiveArray,shoot)
            local cooldown_reduce = ability:GetSpecialValueFor("cooldown_reduce")
            local cooldownTimeRemaining = ability:GetCooldownTimeRemaining()
            cooldownTimeRemaining = cooldownTimeRemaining - cooldown_reduce
            if cooldownTimeRemaining > 0 then
                ability:EndCooldown()
                ability:StartCooldown(cooldownTimeRemaining)
            end
            local caster = shoot.owner
            local particleID = ParticleManager:CreateParticle("particles/guanchage_beidong.vpcf", PATTACH_POINT_FOLLOW, caster)
            local location = 
            ParticleManager:SetParticleControl(particleID, 0, caster:GetAbsOrigin())
        end
    end
end

