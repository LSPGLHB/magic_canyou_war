require('game_init')
require('shoot_init')
blink = ({})

function blink:GetCastRange(v,t)
    local range = getRangeByName(self,'blink')
    return range
end

function blink:OnSpellStart()
    local caster = self:GetCaster()
    local ability = self
    local fromParticle = "particles/items_fx/blink_dagger_start.vpcf"
    local toParticle = "particles/items_fx/blink_dagger_end.vpcf"
    EmitSoundOn("scene_voice_blink_cast", caster)
    blinkOperation(caster, ability, fromParticle, toParticle)
    
    caster.shootOver = -1
end

