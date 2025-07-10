local mq = require('mq')
local class = require('classes.classbase')
local conditions = require('routines.conditions')
local common = require('common')
local state = require('state')

local Monk = class:new()

--[[
    http://forums.eqfreelance.net/index.php?topic=17466.0
]]
--[[
self:addAA('Distant Strike') -- pull ability
self:addAA('Magnanimous Force') -- knockback + memblur
self:addAA('Moving Mountains') -- fling mob to you
self:addAA('Purify Body') -- self remove detrimental affects, 4min cd
self:addAA('Swift Tails\' Chant') -- restore 6000 end to group, 10 min cd, timer 8
self:addAA('Ton Po\'s Stance') -- extra crits + attacks, 5 min cd, timer 9
self:addAA('Devastating Assault') -- 2 minutes of aoe melee, 5 min cd, timer 30
self:addAA('Dragon Force') -- knockback
self:addAA('Focused Destructive Force') -- 42 seconds of extra melee attacks on target, 15 min cd, timer 2
self:addAA('Grappling Strike') -- pulls target towards you
self:addAA('Neshika\'s Blink') -- leap
self:addAA('Vehement Rage') -- inc base dmg and minimum dmg, 5 min cd, timer 61
]]
function Monk:init()
    self.classOrder = {'assist', 'aggro', 'heal', 'mash', 'burn', 'recover', 'buff', 'rest', 'rez'}
    self:initBase('MNK')

    self:initClassOptions()
    self:loadSettings()
    self:initAbilities()
    self:addCommonAbilities()

    self.useCommonListProcessor = true
end

function Monk:initClassOptions()
    self:addOption('USEFD', 'Use Feign Death', true, nil, 'Toggle Use of Feign Death to reduce aggro', 'checkbox', nil, 'UseFD', 'bool')
    self:addOption('USEFADE', 'Use Imitate Death', true, nil, 'Toggle use of Imitate Death in combat', 'checkbox', nil, 'UseFade', 'bool')
    self:addOption('USEIMPENETRABLE', 'Use Impenetrable', true, nil, 'Toggle use of Impenetrable Discipline in combat', 'checkbox', nil, 'UseFade', 'bool')
end

Monk.Abilities = {
    -- DPS
    { -- strong kick + inc kick dmg
        Type='Disc',
        Group='synergy',
        Names={'Fatewalker\'s Synergy', 'Bloodwalker\'s Synergy', 'Icewalker\'s Synergy', 'Firewalker\'s Synergy', 'Doomwalker\'s Synergy'},
        Options={dps=true, condition=conditions.withinMeleeDistance, emu=false}
    },
    { -- 3x tiger claw + monk synergy proc
        Type='Disc',
        Group='fists',
        Names={'Flurry of Fists', 'Buffeting of Fists', 'Barrage of Fists', 'Firestorm of Fists', 'Torrent of Fists'},
        Options={dps=true, condition=conditions.withinMeleeDistance, emu=false}
    },
    { -- inc dmg from DS
        Type='Disc',
        Group='curse',
        Names={'Curse of Sixteen Shadows', 'Curse of Fifteen Strikes', 'Curse of Fourteen Fists', 'Curse of the Thirteen Fingers'},
        Options={dps=true, condition=conditions.withinMeleeDistance, emu=false}
    },
    { -- a nuke?
        Type='Disc',
        Group='fang',
        Names={'Uncia\'s Fang', 'Zlexak\'s Fang', 'Hoshkar\'s Fang', 'Zalikor\'s Fang', --[[emu cutoff]] 'Dragon Fang', 'Clawstriker\'s Flurry', 'Leopard Claw'},
        Options={dps=true, condition=conditions.withinMeleeDistance}
    },
    -- { -- free flying kick + a stun, emu only?
    --     Type='AA',
    --     Name='Stunning Kick',
    --     Options={dps=true, condition=conditions.withinMeleeDistance}
    -- },
    { -- free tiger claw, emu only?
        Type='AA',
        Name='Eye Gouge',
        Options={dps=true, condition=conditions.withinMeleeDistance, emu=true}
    },
    {
        Type='Skill',
        Name='Flying Kick',
        Options={dps=true, condition=conditions.withinMeleeDistance}
    },
    {
        Type='Skill',
        Name='Round Kick',
        Options={dps=function() return mq.TLO.Me.Skill('Flying Kick')() == 0 end, condition=conditions.withinMeleeDistance}
    },
    {
        Type='Skill',
        Name='Kick',
        Options={dps=function() return mq.TLO.Me.Skill('Round Kick')() == 0 end, condition=conditions.withinMeleeDistance}
    },
    {
        Type='Skill',
        Name='Tiger Claw',
        Options={dps=true, condition=conditions.withinMeleeDistance}
    },
    { -- shuriken attack + buffs shuriken dmg
        Type='Disc',
        Group='precision',
        Names={'Bloodwalker\'s Precision Strike', 'Icewalker\'s Precision Strike', 'Firewalker\'s Precision Strike', 'Doomwalker\'s Precision Strike'},
        Options={dps=true, condition=conditions.withinMeleeDistance, emu=false}
    },
    {
        Type='Disc',
        Group='alliance',
        Names={'Bloodwalker\'s Conjunction', 'Icewalker\'s Coalition', 'Firewalker\'s Covenant', 'Doomwalker\'s Alliance'},
        Options={dps=true, condition=conditions.withinMeleeDistance, emu=false}
    },

    -- Burns
    { -- double dmg taken from special punches, doesn't stack across monks
        Type='AA',
        Name='Two-Finger Wasp Touch',
        Options={first=true, third=true, emu=false}
    },
    { -- defensive
        Type='Disc',
        Group='reflexes',
        Names={'Disciplined Reflexes', 'Decisive Reflexes', 'Rapid Reflexes', 'Nimble Reflexes'},
        Options={first=true, emu=false}
    },
    { -- inc melee dmg
        Type='Disc',
        Group='ironfist',
        Names={'Ironfist'},
        Options={first=true}
    },
    {  -- inc chance for wep procs
        Type='AA',
        Name='Spire of the Sensei',
        Options={first=true, emu=false}
    },
    {
        Type='AA',
        Name='Fundament: Second Spire of the Sensei',
        Options={first=true, emu=true}
    },
    { -- adds extra attacks
        Type='Disc',
        Group='poise',
        Names={'Tiger\'s Symmetry', 'Dragon\'s Poise', 'Eagle\'s Poise', 'Tiger\'s Poise', 'Dragon\'s Balance'},
        Options={first=true, emu=false}
    },
    { -- laz specific
        Type='AA',
        Name='Zan Fi\'s Thunderous Whistle',
        Options={first=true}
    },
    {
        Type='Disc',
        Group='stance',
        Names={'Crane Stance'},
        Options={first=true, emu=false}
    },
    { -- doubles attack speed
        Type='Disc',
        Group='speedfocus',
        Names={'Speed Focus Discipline'},
        Options={second=true}
    },
    { -- large nuke, 10 min cd, should FD after
        Type='AA',
        Name='Five Point Palm',
        Options={first=true, condition=conditions.withinMeleeDistance}--dps=true,
    },
    -- 2nd burn
    { -- if another monks has faded
        Type='Disc',
        Group='palm',
        Names={'Terrorpalm Discipline', 'Crystalpalm Discipline', 'Innerflame Discipline'},
        Options={second=true, condition=function() return not Monk.speedfocus or not mq.TLO.Me.CombatAbilityReady(Monk.speedfocus.Name)() end}
    },
    { -- doubles number of primary hand attacks
        Type='AA',
        Name='Focused Destructive Force',
        Options={second=true, emu=false}
    },
    { -- doubles number of primary hand attacks
        Type='AA',
        Name='Destructive Force',
        Options={second=true, opt='USEAOE'}
    },
    -- 3rd burn
    {
        Type='Disc',
        Group='heel',
        Names={'Heel of Zagali', 'Heel of Kai', 'Heel of Kanji'},
        Options={third=true, condition=function() return (not Monk.palm or not mq.TLO.Me.CombatAbilityReady(Monk.palm.Name)()) and (not Monk.speedfocus or not mq.TLO.Me.CombatAbilityReady(Monk.speedfocus.Name)()) end}
    },
    { -- inc dmg, inc min dmg
        Type='Disc',
        Group='eyeofthestorm',
        Names={'Eye of the Storm'},
        Options={third=true, emu=false}
    },

    -- Buffs
    {
        Type='Disc',
        Group='aura',
        Names={'Master\'s Aura', 'Disciple\'s Aura'},
        Options={aurabuff=true, CheckFor='Disciples Aura', condition=function() return mq.TLO.Me.Level() >= 70 and not mq.TLO.Me.Song('Master\'s Aura')() and not mq.TLO.Me.Song('Disciple\'s Aura')() end}
    },
    {
        Type='Item',
        Name='Ancient Fistwraps of Immortality',
        Options={combatbuff=true, delay=1000}
    },
    {
        Type='Item',
        Name='Transcended Fistwraps of Immortality',
        Options={combatbuff=true, delay=1000}
    },
    {
        Type='Item',
        Name='Fistwraps of Celestial Discipline',
        Options={combatbuff=true, delay=1000}
    },
    {
        Type='Disc',
        Group='wu',
        Names={'Fists of Wu'},
        Options={combatbuff=true}
    },
    {
        Type='AA',
        Name='Zan Fi\'s Whistle',
        Options={combatbuff=true}
    },
    {
        Type='AA',
        Name='Infusion of Thunder',
        Options={combatbuff=true, emu=true}
    },
    { -- large bonus dmg
        Type='Disc',
        Group='composite',
        Names={'Ecliptic Form', 'Composite Form', 'Dissident Form', 'Dichotomic Form'},
        Options={combatbuff=true, emu=false}
    },
    {
        Type='Item',
        Name='Blood Drinker\'s Coating',
        Options={combatbuff=true, condition=function() return mq.TLO.Me.Buff('Five Point Palm Technique')() end}
    },

    -- Defensives
    {
        Type='Disc',
        Group='impenetrable',
        Names={'Impenetrable Discipline'},
        Options={opt='USEIMPENETRABLE', defensive=true, condition=function() return mq.TLO.Target.Named() end}
    },
    {
        Type='AA',
        Name='Imitate Death',
        Options={fade=true, opt='USEFADE', postcast=function() mq.delay(500) mq.cmd('/stand') mq.cmd('/makemevis') end}
    },
    {
        Type='Disc',
        Group='earthforce',
        Names={'Earthforce Discipline'},
        Options={defensive=true, emu=false}
    },
    {
        Type='Skill',
        Name='Feign Death',
        Options={aggroreducer=true, opt='USEFD', postcast=function() mq.delay(500) mq.cmd('/stand') mq.cmd('/makemevis') end}
    },

    -- Heals
    {
        Type='Skill',
        Name='Mend',
        Options={heal=true, me=60, self=true}
    }
}

-- local speedFocus = common.getBestDisc({'Speed Focus Discipline'})
-- local crystalPalm = common.getBestDisc({'Crystalpalm Discipline', 'Innerflame Discipline'}, {condition=function() return not speedFocus or not mq.TLO.Me.CombatAbilityReady(speedFocus.Name)() end})
-- local heel = common.getBestDisc({'Heel of Kai', 'Heel of Kanji'}, {condition=function() return not crystalPalm or not mq.TLO.Me.CombatAbilityReady(crystalPalm.Name)() end})

--[[
        -- Burns
    -- Instant activations for start of burn
    -- bp click -- add dmg to next x kicks
    table.insert(self.burnAbilities, self:addAA('Two-Finger Wasp Touch', {first=true})) -- double dmg taken from special punches, doesn't stack across monks
    --Zan Fi's Whistle -- big melee dmg bonus, combat buff
    table.insert(self.burnAbilities, common.getBestDisc({'Disciplined Reflexes', 'Decisive Reflexes', 'Rapid Reflexes', 'Nimble Reflexes'}, {first=true})) -- defensive
    table.insert(self.burnAbilities, common.getBestDisc({'Ironfist'}, {first=true})) -- inc melee dmg
    table.insert(self.burnAbilities, self:addAA('Spire of the Sensei', {first=true}))  -- inc chance for wep procs
    table.insert(self.burnAbilities, common.getBestDisc({'Tiger\'s Symmetry', 'Dragon\'s Poise', 'Eagle\'s Poise', 'Tiger\'s Poise', 'Dragon\'s Balance'}, {first=true})) -- adds extra attacks
    table.insert(self.burnAbilities, self:addAA('Infusion of Thunder', {first=true})) -- chance to inc melee dmg + nuke

    -- Burn spam
    table.insert(self.burnAbilities, common.getBestDisc({'Crane Stance'}, {first=true})) -- 2 big kicks
    table.insert(self.burnAbilities, self:addAA('Five Point Palm', {first=true})) -- big dragon punch with nuke
    -- click off ironfist?
    -- click bp here?
    table.insert(self.burnAbilities, common.getBestDisc({'Heel of Zagali'}, {first=true}))
    -- spam kick abilities

    -- 2nd Burn
    table.insert(self.burnAbilities, common.getBestDisc({'Speed Focus'}, {second=true})) -- doubles attack speed
    table.insert(self.burnAbilities, self:addAA('Focused Destructive Force', {second=true})) -- doubles number of primary hand attacks

    -- 3rd Burn
    table.insert(self.burnAbilities, self:addAA('Two-Finger Wasp Touch', {third=true})) -- if another monks has faded
    table.insert(self.burnAbilities, common.getBestDisc({'Terrorpalm'}, {third=true})) -- inc dmg from melee, inc min dmg

    -- 4th Burn
    --table.insert(self.burnAbilities, common.getBestDisc({'Ironfist'})) -- if not used yet
    table.insert(self.burnAbilities, common.getBestDisc({'Eye of the Storm'}, {third=true})) -- inc dmg, inc min dmg

    -- 5th Burn
    table.insert(self.burnAbilities, common.getBestDisc({'Earthforce'})) -- defensive, adds heroic str
]]

return Monk
