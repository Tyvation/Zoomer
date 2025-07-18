local config_ui = {}

local logger = require('zoomer.logger')
local config = require('zoomer.config')
local locale = require('zoomer.locale')

local SCALE_OPTIONS = {0.5, 0.75, 1, 1.25, 1.5, 1.75, 2}

function config_ui.create_config_tab()
    config_ui.is_open = true
    Zoomer.set_popup(true)

    return {
        n = G.UIT.ROOT,
        config = { 
            r = 0.1,
            minh = 6,
            minw = 6,
            align = 'cm',
            colour = G.C.CLEAR
        },
        nodes = {
            { n = G.UIT.C, nodes = {{
                n = G.UIT.ROOT, config = { align = 'cm', minw = 10, r = 0.1, emboss = 0.1, colour = G.C.GREY }, nodes = {
                    -- Tooltip Scale row
                    { n = G.UIT.R, config = { align = 'cm', padding = 0.1}, nodes = {
                        { n = G.UIT.C, config = { minw = 0.5 }},
                        { n = G.UIT.C, config = { align = 'cl', minw = 4, padding = 0.1 }, nodes = {
                            { n = G.UIT.R, nodes = {
                                { n = G.UIT.T, config = { text = locale.translate('ct_Tooltip'), scale = 0.4, colour = G.C.UI.TEXT_LIGHT }},
                            }},
                            { n = G.UIT.R, nodes = {
                                { n = G.UIT.T, config = { text = locale.translate('cti_Tooltip'), scale = 0.3, colour = G.C.UI.TEXT_LIGHT }}
                            }}
                        }},
                        { n = G.UIT.C, config = { align = 'cm', minw = 5 }, nodes = {
                            create_option_cycle({
                                scale = 0.8,
                                w = 4,
                                options = SCALE_OPTIONS,
                                opt_callback = 'zoomer_cycle_tooltip_scale',
                                current_option = (function()
                                    for i, option in ipairs(SCALE_OPTIONS) do
                                        if option == config.tooltip_scale then return i end
                                    end
                                    return 3
                                end)(),
                                colour = G.C.RED
                            })
                        }}
                    }},
                    -- Game Buttons Scale row
                    { n = G.UIT.R, config = { align = 'cm', padding = 0.1 }, nodes = {
                        { n = G.UIT.C, config = { minw = 0.5 }},
                        { n = G.UIT.C, config = { align = 'cl', minw = 4, padding = 0.1 }, nodes = {
                            { n = G.UIT.R, nodes = {
                                { n = G.UIT.T, config = { text = locale.translate('ct_GameButton'), scale = 0.4, colour = G.C.UI.TEXT_LIGHT }},
                            }},
                            { n = G.UIT.R, nodes = {
                                { n = G.UIT.T, config = { text = locale.translate('cti_GameButton'), scale = 0.3, colour = G.C.UI.TEXT_LIGHT }}
                            }}
                        }},
                        { n = G.UIT.C, config = { align = 'cm', minw = 5}, nodes = {
                            create_option_cycle({
                                scale = 0.8,
                                w = 4,
                                options = SCALE_OPTIONS,
                                opt_callback = 'zoomer_cycle_game_buttons_scale',
                                current_option = (function()
                                    for i, option in ipairs(SCALE_OPTIONS) do
                                        if option == config.game_buttons_scale then return i end
                                    end
                                    return 3
                                end)(),
                                colour = G.C.RED
                            })
                        }}
                    }},
                    -- Main Menu Scale row
                    { n = G.UIT.R, config = { align = 'cm', padding = 0.1}, nodes = {
                        { n = G.UIT.C, config = { minw = 0.5 }},
                        { n = G.UIT.C, config = { align = 'cl', minw = 4, padding = 0.1 }, nodes = {
                            { n = G.UIT.R, nodes = {
                                { n = G.UIT.T, config = { text = locale.translate('ct_MainMenu'), scale = 0.4, colour = G.C.UI.TEXT_LIGHT }},
                            }},
                            { n = G.UIT.R, nodes = {
                                { n = G.UIT.T, config = { text = locale.translate('cti_MainMenu'), scale = 0.3, colour = G.C.UI.TEXT_LIGHT }}
                            }}
                        }},
                        { n = G.UIT.C, config = { align = 'cm', minw = 5 }, nodes = {
                            create_option_cycle({
                                scale = 0.8,
                                w = 4,
                                options = SCALE_OPTIONS,
                                opt_callback = 'zoomer_cycle_main_menu_scale',
                                current_option = (function()
                                    for i, option in ipairs(SCALE_OPTIONS) do
                                        if option == config.main_menu_scale then return i end
                                    end
                                    return 3
                                end)(),
                                colour = G.C.RED
                            })
                        }}
                    }},
                    -- Hide Card Buttons row
                    { n = G.UIT.R, config = { align = 'cm', padding = 0.1 }, nodes = {
                        { n = G.UIT.C, config = { minw = 0.5 }},
                        { n = G.UIT.C, config = { align = 'cl', minw = 4 , padding = 0.1 }, nodes = {
                            { n = G.UIT.R, nodes = {
                                { n = G.UIT.T, config = { text = locale.translate('ct_HideCardButton'), scale = 0.4, colour = G.C.UI.TEXT_LIGHT }}
                            }},
                            { n = G.UIT.R, nodes = {
                                { n = G.UIT.T, config = { text = locale.translate('cti_HideCardButton'), scale = 0.3, colour = G.C.UI.TEXT_LIGHT }}
                            }}
                        }},
                        { n = G.UIT.C, config = { align = 'cm', minw = 5}, nodes = {
                            create_toggle({
                                label = "",
                                w = 0,
                                text_scale = 0.8,
                                ref_table = config,
                                ref_value = 'hide_card_buttons',
                                toggle_callback = 'zoomer_toggle_hide_card_buttons'
                            })
                        }}
                    }}
                    
                }
            }}}
        }
    }
end

return config_ui
