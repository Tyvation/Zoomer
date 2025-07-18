Zoomer = {}

local config = require('zoomer.config')
local scalerUI = require('zoomer.scalerUI')
local config_ui = require('zoomer.config_ui')
local logger = require('zoomer.logger')

local SCALE_OPTIONS = {0.5, 0.75, 1, 1.25, 1.5, 1.75, 2}

    config.load()
    config.save()


G.FUNCS.zoomer_cycle_tooltip_scale = function(e)
    local val = SCALE_OPTIONS[e.to_key]
    if not val then return end
    logger.log_debug("tooltip_scale: " .. val)
    config.tooltip_scale = val
end

G.FUNCS.zoomer_cycle_game_buttons_scale = function(e)
    local val = SCALE_OPTIONS[e.to_key]
    if not val then return end
    logger.log_debug("game_buttons_scale: " .. val)
    config.game_buttons_scale = val
end

G.FUNCS.zoomer_cycle_main_menu_scale = function(e)
    local val = SCALE_OPTIONS[e.to_key]
    if not val then return end
    logger.log_debug("main_menu_scale: " .. val)
    config.main_menu_scale = val
end

G.FUNCS.zoomer_toggle_hide_card_buttons = function(e)
    config.hide_card_buttons = e.to_val
    logger.log_debug("hide_card_buttons: " .. tostring(config.hide_card_buttons))
end



local g_funcs_exit_overlay_menu_ref = G.FUNCS.exit_overlay_menu
function G.FUNCS.exit_overlay_menu(e)
	config_ui.close_config_menu()
	config.save()
	return g_funcs_exit_overlay_menu_ref(e)
end

function Zoomer.set_popup(state)
	if config.clock_persistent then
		Zoomer.draw_as_popup = true
	elseif Zoomer.draw_as_popup ~= state then
		Zoomer.draw_as_popup = state
	end
end


return Zoomer