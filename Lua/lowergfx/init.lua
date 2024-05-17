---@type Mq
local mq = require 'mq'

local debug = false

function ToggleCheckbox(windowName, checkboxName, toggleState)
    if debug then printf('Entering ToggleCheckbox(%s, %s, %s)', windowName, checkboxName, toggleState) end
    if mq.TLO.Window(windowName).Child(checkboxName)() == 0 then return end

    if toggleState then
        if not mq.TLO.Window(windowName).Child(checkboxName).Checked() then
            printf('%s enabled.', checkboxName)
            mq.cmdf('/notify %s %s %s', windowName, checkboxName, "leftmouseup")
        end
    else
        if mq.TLO.Window(windowName).Child(checkboxName).Checked() then
            printf('%s disabled.', checkboxName)
            mq.cmdf('/notify %s %s %s', windowName, checkboxName, "leftmouseup")
        end
    end
end

function ToggleComboBox(windowName, comboBoxName, selectedIndex)
    if debug then printf('Entering ToggleComboBox(%s, %s, %s)', windowName, comboBoxName, selectedIndex) end
    if mq.TLO.Window(windowName).Child(comboBoxName)() == 0 then return end

    local currentSelection = mq.TLO.Window(windowName).Child(comboBoxName).GetCurSel()

    if currentSelection ~= selectedIndex then
        printf('Setting %s to index %d.', comboBoxName, selectedIndex)
        mq.cmdf('/invoke %s', mq.TLO.Window(windowName).Child(comboBoxName).Select(selectedIndex))
    end
end

function ToggleValue(windowName, optionName, newValue)
    if debug then printf('Entering ToggleValue(%s, %s, %s)', windowName, optionName, newValue) end
    printf('Setting %s to %d.', optionName, newValue)
    mq.cmdf('/notify %s %s newvalue %s', windowName, optionName, newValue)
end

function Main()
    mq.TLO.Window('OptionsWindow').DoOpen()
    mq.TLO.Window('AdvancedDisplayOptionsWindow').DoOpen()

    --| General
    --| Sound
    ToggleValue('OptionsWindow', 'OGP_SoundRealismSlider', 0)
    ToggleValue('OptionsWindow', 'OGP_MusicVolumeSlider', 0)
    ToggleValue('OptionsWindow', 'OGP_SoundVolumeSlider', 0)
    ToggleCheckbox('OptionsWindow', 'OGP_EnvSoundsCheckbox', false)
    ToggleCheckbox('OptionsWindow', 'OGP_CombatMusicCheckbox', false)
    --| No Drop Item
    ToggleComboBox('OptionsWindow', 'OGP_NoDropItemCombobox', 3)
    --| Use Tell Windows
    ToggleCheckbox('OptionsWindow', 'OGP_UseTellWindowsCheckbox', false)
    --| Auto Consent
    ToggleCheckbox('OptionsWindow', 'OGP_AutoConsentGroupCheckbox', true)
    ToggleCheckbox('OptionsWindow', 'OGP_AutoConsentRaidCheckbox', true)
    ToggleCheckbox('OptionsWindow', 'OGP_AutoConsentGuildCheckbox', true)
    --| Accept Kick Requests
    ToggleCheckbox('OptionsWindow', 'OGP_AutoAcceptKickRequests', true)

    --| Confirmations
    ToggleCheckbox('OptionsWindow', 'OGP_FastItemDestroyCheckbox', true)
    ToggleCheckbox('OptionsWindow', 'OGP_AANoConfirmCheckbox', true)
    ToggleCheckbox('OptionsWindow', 'OGP_AdvMerchantNoConfirmCheckbox', true)
    ToggleCheckbox('OptionsWindow', 'OGP_LeadershipNoConfirmCheckbox', true)
    ToggleCheckbox('OptionsWindow', 'OGP_LootAllConfirmCheckbox', false)
    ToggleCheckbox('OptionsWindow', 'OGP_RaidInviteConfirmCheckbox', true)

    --| Options -> Display, first bunch of checkboxes
    -- Hide NPC Names
    ToggleCheckbox('OptionsWindow', 'ODP_NPCNamesCheckBox', false)
    -- Hide Pet Names
    ToggleCheckbox('OptionsWindow', 'ODP_PetNamesCheckBox', false)
    -- Hide Merc Names
    ToggleCheckbox('OptionsWindow', 'ODP_MercNamesCheckBox', false)
    -- Hide Pet Owner names
    ToggleCheckbox('OptionsWindow', 'ODP_ShowPetOwnerNames', false)
    -- Hide Merc Owner names
    ToggleCheckbox('OptionsWindow', 'ODP_ShowMercOwnerNames', false)
    -- Hide Target Ring
    ToggleCheckbox('OptionsWindow', 'ODP_ShowTargetRingCheckbox', false)
    -- Hide Target Health
    ToggleCheckbox('OptionsWindow', 'ODP_ShowTargetHealthCheckbox', false)
    -- Disabling Level of Detail
    ToggleCheckbox('OptionsWindow', 'ODP_LevelOfDetailCheckbox', false)
    -- Showing My Helm
    ToggleCheckbox('OptionsWindow', 'ODP_ShowHelmCheckbox', false)
    -- Showing Pre-Luclin Mounts
    ToggleCheckbox('OptionsWindow', 'ODP_ShowPreLuclinMounts', true)

    --| Options -> Display, combo boxes at the top right
    ToggleComboBox('OptionsWindow', 'ODP_LoadScreenCombobox', 1)
    ToggleComboBox('OptionsWindow', 'ODP_SkyCombobox', 1)
    ToggleComboBox('OptionsWindow', 'ODP_NewArmorFilterCombobox', 1)

    --| Far Clip Plane = 20%. Valid values are 0 - 20, corresponding to a clip plane of 0 - 100%
    ToggleValue('OptionsWindow', 'ODP_ClipPlaneSlider', 4)

    --| Options -> Display, particle effects
    ToggleComboBox('OptionsWindow', 'ODP_SpellParticlesNearClipCombobox', 1)
    ToggleComboBox('OptionsWindow', 'ODP_SpellParticlesDensityCombobox', 1)
    ToggleComboBox('OptionsWindow', 'ODP_SpellParticlesFilterCombobox', 1)
    ToggleComboBox('OptionsWindow', 'ODP_EnvironmentParticlesNearClipCombobox', 1)
    ToggleComboBox('OptionsWindow', 'ODP_EnvironmentParticlesDensityCombobox', 1)
    ToggleComboBox('OptionsWindow', 'ODP_ActorParticlesNearClipCombobox', 1)
    ToggleComboBox('OptionsWindow', 'ODP_ActorParticlesDensityCombobox', 1)
    ToggleComboBox('OptionsWindow', 'ODP_ActorParticlesFilterCombobox', 1)

    --| LOD Bias = Very Low
    ToggleValue('OptionsWindow', 'ODP_LODBiasSlider', 0)

    --| Advanced Options, combo boxes
    ToggleComboBox('OptionsWindow', 'ADOW_SkyReflectionSizeCombobox', 1)
    ToggleComboBox('OptionsWindow', 'ADOW_SkyUpdateIntervalCombobox', 1)
    ToggleComboBox('OptionsWindow', 'ADOW_TerrainTextureQualityCombobox', 1)
    ToggleComboBox('OptionsWindow', 'ADOW_MemoryModeCombobox', 1)

    --| Advanced Options, checkboxes
    -- Disabling new water in old zones
    ToggleCheckbox('AdvancedDisplayOptionsWindow', 'ADOW_WaterSwapCheckbox', false)
    -- Enabling hw Vertex Shaders
    ToggleCheckbox('AdvancedDisplayOptionsWindow', 'ADOW_VertexShadersCheckbox', true)
    -- Enabling 1.1 Pixel Shaders
    ToggleCheckbox('AdvancedDisplayOptionsWindow', 'ADOW_11PixelShadersCheckbox', true)
    -- Enabling 1.4 Pixel Shaders
    ToggleCheckbox('AdvancedDisplayOptionsWindow', 'ADOW_14PixelShadersCheckbox', true)
    -- Enabling 2.0 Pixel Shaders
    ToggleCheckbox('AdvancedDisplayOptionsWindow', 'ADOW_20PixelShadersCheckbox', true)
    -- Disabling Advanced Lighting
    ToggleCheckbox('AdvancedDisplayOptionsWindow', 'ADOW_AdvancedLightingCheckbox', false)
    -- Disabling Shadows
    ToggleCheckbox('AdvancedDisplayOptionsWindow', 'ADOW_ShadowsCheckbox', false)
    -- Disabling Radial Flora
    ToggleCheckbox('AdvancedDisplayOptionsWindow', 'ADOW_FloraCheckbox', false)
    -- Disabling Stream Item Textures
    ToggleCheckbox('AdvancedDisplayOptionsWindow', 'ADOW_StreamItemTexturesCheckbox', false)
    -- Disabling Tattoos
    ToggleCheckbox('AdvancedDisplayOptionsWindow', 'ADOW_DisableTattoosCheckbox', true)
    -- Disabling Post Bloom Effects
    ToggleCheckbox('AdvancedDisplayOptionsWindow', 'ADOW_EnablePostEffectsCheckbox', false)
    -- Disabling Bloom Lighting
    ToggleCheckbox('AdvancedDisplayOptionsWindow', 'ADOW_EnableBloomCheckbox', false)

    --| Shadow Clip Plane = 0%. Valid values are 0 - 100
    ToggleValue('AdvancedDisplayOptionsWindow', 'ADOW_ShadowClipPlaneSlider', 0)
    --| Actor Clip Plane = 20%. Valid values are 0 - 100
    ToggleValue('AdvancedDisplayOptionsWindow', 'ADOW_ActorClipPlaneSlider', 20)
    --| Max Foreground FPS = 30. Valid values are 0 - 100, corresponding to an fps of 0 - 150
    ToggleValue('AdvancedDisplayOptionsWindow', 'ADOW_MaxFPSSlider', 90)
    --| Max Background FPS = 30. Valid values are 0 - 100, corresponding to an fps of 0 - 150. Slightly different to foreground FPS for some reason
    ToggleValue('AdvancedDisplayOptionsWindow', 'ADOW_MaxBGFPSSlider', 91)

    mq.TLO.Window('AdvancedDisplayOptionsWindow').DoClose()
    mq.TLO.Window('OptionsWindow').DoClose()

    print("\agSettings changed!")
end
Main()
