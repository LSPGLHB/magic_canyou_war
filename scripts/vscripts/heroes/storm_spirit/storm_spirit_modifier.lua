modifier_storm_spirit_passive = ({})

function modifier_storm_spirit_passive:GetEffectName()
	return "particles/zixinge.vpcf"
end

function modifier_storm_spirit_passive:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_storm_spirit_passive:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_PROVIDES_VISION] = true
	}
	return state
end



function modifier_storm_spirit_passive:OnCreated()
    if IsServer() then
        local unit = self:GetParent()
        local ability = self:GetAbility()
        unit.stormSpiritPassive = true  
        unit.stormSpiritDamageUpPercent = ability:GetSpecialValueFor("damage_up_percent")
    end
end

function modifier_storm_spirit_passive:OnDestroy()
    if IsServer() then
        local unit = self:GetParent()
        local ability = self:GetAbility()
        unit.stormSpiritPassive = false
    end
end

function modifier_storm_spirit_passive:DeclareFunctions()
	local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION
	}
	return funcs
end

function modifier_storm_spirit_passive:GetOverrideAnimation(keys)
    return ACT_DOTA_CAST1_STATUE --ACT_DOTA_OVERRIDE_ABILITY_4
end

function modifier_storm_spirit_passive:OnTakeDamage(keys)
    local shoot = keys.attacker
    if IsServer() and shoot.owner == self:GetParent() then
        local ability = self:GetAbility()
        local unit = self:GetParent() 
        local target = keys.unit
        --print("damage:"..keys.damage)
        local cooldownTimeRemaining = ability:GetCooldownTimeRemaining()
        ability:EndCooldown()

        local targetParticleID = ParticleManager:CreateParticle("particles/zixinge_mingzhong.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit)
        ParticleManager:SetParticleControl(targetParticleID, 0, unit:GetAbsOrigin())
        ParticleManager:SetParticleControl(targetParticleID, 1, target:GetAbsOrigin())

        local unitParticleName = "particles/zixinge_beidong_shuaxin.vpcf"

        if target:IsAlive() then
            unitParticleName = "particles/zixinge_beidong.vpcf"
            local cooldown_reduce_percent = ability:GetSpecialValueFor("cooldown_reduce_percent")
            cooldownTimeRemaining = cooldownTimeRemaining * (1 - cooldown_reduce_percent / 100)
            ability:StartCooldown(cooldownTimeRemaining)
        end

        local unitParticleID = ParticleManager:CreateParticle(unitParticleName, PATTACH_ABSORIGIN_FOLLOW, unit)
        ParticleManager:SetParticleControl(unitParticleID, 0, unit:GetAbsOrigin())
        EmitSoundOn("scene_voice_storm_spirit_passive", unit)
    end
end
