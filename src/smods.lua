local config_ui = require('zoomer.config_ui')
local config = require('zoomer.config')
local logger = require('zoomer.logger')
local Zoomer = require('zoomer.core')

if not SMODS then
    logger.log_warn('SMODS not found')
    return
end

SMODS.Atlas({
	key = 'modicon',
	path = 'icon.png',
	px = 32,
	py = 32
})

SMODS.current_mod.description_loc_vars = function(self)
    return {
        scale = 1.2,
        background_colour = G.C.CLEAR
    }
end

SMODS.current_mod.config_tab = config_ui.create_config_tab

local g_funcs_exit_mods_ref = G.FUNCS.exit_mods
function G.FUNCS.exit_mods(e)
	config_ui.close_config_menu()
	g_funcs_exit_mods_ref(e)
end

local smods_save_all_config_ref = SMODS.save_all_config
function SMODS.save_all_config()
	smods_save_all_config_ref()
	config.save()
end

function config_ui.close_config_menu()
	if config_ui.is_open then
		config_ui.is_open = false
		Zoomer.set_popup(false)
	end
end
