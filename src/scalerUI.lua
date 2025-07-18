local config = require('zoomer.config')

config.load()


-- Override G.UIDEF.card_h_popup to make card tooltips scaleable
local orig_card_h_popup = G.UIDEF.card_h_popup
function G.UIDEF.card_h_popup(card)
  local result = orig_card_h_popup(card)
  
  if result and config.tooltip_scale ~= 1.0 then
    -- Scale the card tooltip
    local function scale_tooltip(nodes)
      for i, node in ipairs(nodes) do
        if node.config then
          -- Scale padding and dimensions
          if node.config.padding then
            node.config.padding = node.config.padding * config.tooltip_scale
          end
          if node.config.minw then
            node.config.minw = node.config.minw * config.tooltip_scale
          end
          if node.config.minh then
            node.config.minh = node.config.minh * config.tooltip_scale
          end
          if node.config.maxw then
            node.config.maxw = node.config.maxw * config.tooltip_scale
          end
          if node.config.r then
            node.config.r = node.config.r * config.tooltip_scale
          end
          
          -- Scale text elements
          if node.config.text and node.config.scale then
            node.config.scale = node.config.scale * config.tooltip_scale
          end
          
          -- Scale DynaText objects
          if node.config.object and node.config.object.config and node.config.object.config.scale then
            node.config.object.config.scale = node.config.object.config.scale * config.tooltip_scale
          end
        end
        
        -- Recursively scale child nodes
        if node.nodes then
          scale_tooltip(node.nodes)
        end
      end
    end
    
    if result.nodes then
      scale_tooltip(result.nodes)
    end
  end
  
  return result
end

-- Override create_shop_card_ui to remove buy/sell/use buttons from shop cards
local orig_create_shop_card_ui = create_shop_card_ui
function create_shop_card_ui(card, type, area)
  -- Check if button hiding is enabled
  if not config.hide_card_buttons then
    return orig_create_shop_card_ui(card, type, area)
  end
  
  -- Only show the price tag, no buttons
  G.E_MANAGER:add_event(Event({
    trigger = 'after',
    delay = 0.43,
    blocking = false,
    blockable = false,
    func = (function()
      if card.opening then return true end
      local t1 = {
        n=G.UIT.ROOT, config = {minw = 0.6, align = 'tm', colour = darken(G.C.BLACK, 0.2), shadow = true, r = 0.05, padding = 0.05, minh = 1}, nodes={
          {n=G.UIT.R, config={align = "cm", colour = lighten(G.C.BLACK, 0.1), r = 0.1, minw = 1, minh = 0.55, emboss = 0.05, padding = 0.03}, nodes={
            {n=G.UIT.O, config={object = DynaText({string = {{prefix = localize('$'), ref_table = card, ref_value = 'cost'}}, colours = {G.C.MONEY},shadow = true, silent = true, bump = true, pop_in = 0, scale = 0.5})}},
          }}
        }}
      
      -- Only add the price tag, no action buttons
      card.children.price = UIBox{
        definition = t1,
        config = {
          align = 'tm',
          offset = {x=0,y=0},
          parent = card,
          type = 'cm',
          r_bond = 'Strong'
        }
      }
      
      -- Remove any existing buttons
      card.children.buy = nil
      card.children.redeem = nil
      card.children.open = nil
      card.children.buy_and_use = nil
      
      return true
    end)
  }))
end

-- Override G.UIDEF.card_focus_ui to remove ALL buy/sell/use buttons from cards
local orig_card_focus_ui = G.UIDEF.card_focus_ui
function G.UIDEF.card_focus_ui(card)
  -- Check if button hiding is enabled
  if not config.hide_card_buttons then
    return orig_card_focus_ui(card)
  end
  
  local card_width = card.T.w + (card.ability.consumeable and -0.1 or card.ability.set == 'Voucher' and -0.16 or 0)
  local playing_card_colour = copy_table(G.C.WHITE)
  playing_card_colour[4] = 1.5
  if G.hand and card.area == G.hand then ease_value(playing_card_colour, 4, -1.5, nil, 'REAL',nil, 0.2, 'quad') end
  local tcnx, tcny = card.T.x + card.T.w/2 - G.ROOM.T.w/2, card.T.y + card.T.h/2 - G.ROOM.T.h/2
  local base_background = UIBox{
    T = {card.VT.x,card.VT.y,0,0},
    definition = 
      (not G.hand or card.area ~= G.hand) and {n=G.UIT.ROOT, config = {align = 'cm', minw = card_width + 0.3, minh = card.T.h + 0.3, r = 0.1, colour = adjust_alpha(G.C.BLACK, 0.7), outline_colour = lighten(G.C.JOKER_GREY, 0.5), outline = 1.5, line_emboss = 0.8}, nodes={
        {n=G.UIT.R, config={id = 'ATTACH_TO_ME'}, nodes={}}
      }} or 
      {n=G.UIT.ROOT, config = {align = 'cm', minw = card_width, minh = card.T.h, r = 0.1, colour = playing_card_colour}, nodes={
        {n=G.UIT.R, config={id = 'ATTACH_TO_ME'}, nodes={}}
      }},
    config = {
        align = 'cm',
        offset = {x= 0.007*tcnx*card.T.w, y = 0.007*tcny*card.T.h}, 
        parent = card,
        r_bond = (not G.hand or card.area ~= G.hand) and 'Weak' or 'Strong'
      }
  }
  base_background.set_alignment = function()
    local cnx, cny = card.T.x + card.T.w/2 - G.ROOM.T.w/2, card.T.y + card.T.h/2 - G.ROOM.T.h/2
    Moveable.set_alignment(card.children.focused_ui, {offset = {x= 0.007*cnx*card.T.w, y = 0.007*cny*card.T.h}})
  end
  
  -- Never add any buttons - just return the background for all card areas
  -- This removes ALL buy/sell/use buttons from every card type and area
  return base_background
end

-- Override G.UIDEF.use_and_sell_buttons to remove buttons from joker and consumable cards
local orig_use_and_sell_buttons = G.UIDEF.use_and_sell_buttons
function G.UIDEF.use_and_sell_buttons(card)
  -- Check if button hiding is enabled
  if not config.hide_card_buttons then
    return orig_use_and_sell_buttons(card)
  end
  
  -- Return empty UI structure instead of nil to prevent crashes
  return {
    n=G.UIT.ROOT, 
    config = {padding = 0, colour = G.C.CLEAR}, 
    nodes={}
  }
end

-- Override create_UIBox_buttons to make game buttons scaleable
local orig_create_UIBox_buttons = create_UIBox_buttons
function create_UIBox_buttons()
  local result = orig_create_UIBox_buttons()
  
  if result and config.game_buttons_scale ~= 1.0 then
    -- Scale both the container and all buttons
    local function scale_buttons(nodes)
      for i, node in ipairs(nodes) do
        if node.config then
          -- Scale all dimensions
          if node.config.padding then
            node.config.padding = node.config.padding * config.game_buttons_scale
          end
          if node.config.minw then
            node.config.minw = node.config.minw * config.game_buttons_scale
          end
          if node.config.minh then
            node.config.minh = node.config.minh * config.game_buttons_scale
          end
          if node.config.maxw then
            node.config.maxw = node.config.maxw * config.game_buttons_scale
          end
          if node.config.r then
            node.config.r = node.config.r * config.game_buttons_scale
          end
          
          -- Scale text elements
          if node.config.text and node.config.scale then
            node.config.scale = node.config.scale * config.game_buttons_scale
          end
        end
        
        -- Recursively scale child nodes
        if node.nodes then
          scale_buttons(node.nodes)
        end
      end
    end
    
    -- Scale the root container
    if result.config then
      if result.config.padding then
        result.config.padding = result.config.padding * config.game_buttons_scale
      end
      if result.config.minw then
        result.config.minw = result.config.minw * config.game_buttons_scale
      end
      if result.config.minh then
        result.config.minh = result.config.minh * config.game_buttons_scale
      end
      if result.config.maxw then
        result.config.maxw = result.config.maxw * config.game_buttons_scale
      end
      if result.config.r then
        result.config.r = result.config.r * config.game_buttons_scale
      end
    end
    
    -- Scale all child buttons
    if result.nodes then
      scale_buttons(result.nodes)
    end
  end
  
  return result
end

-- Override create_UIBox_main_menu_buttons to make main menu container scaleable
local orig_create_UIBox_main_menu_buttons = create_UIBox_main_menu_buttons
function create_UIBox_main_menu_buttons()
  local result = orig_create_UIBox_main_menu_buttons()
  
  if result and config.main_menu_scale ~= 1.0 then
    -- Scale both the container and all buttons
    local function scale_ui(nodes)
      for i, node in ipairs(nodes) do
        if node.config then
          -- Scale all dimensions
          if node.config.padding then
            node.config.padding = node.config.padding * config.main_menu_scale
          end
          if node.config.minw then
            node.config.minw = node.config.minw * config.main_menu_scale
          end
          if node.config.minh then
            node.config.minh = node.config.minh * config.main_menu_scale
          end
          if node.config.maxw then
            node.config.maxw = node.config.maxw * config.main_menu_scale
          end
          if node.config.r then
            node.config.r = node.config.r * config.main_menu_scale
          end
          
          -- Scale text elements
          if node.config.text and node.config.scale then
            node.config.scale = node.config.scale * config.main_menu_scale
          end
        end
        
        -- Recursively scale child nodes
        if node.nodes then
          scale_ui(node.nodes)
        end
      end
    end
    
    -- Scale the root container
    if result.config then
      if result.config.padding then
        result.config.padding = result.config.padding * config.main_menu_scale
      end
      if result.config.minw then
        result.config.minw = result.config.minw * config.main_menu_scale
      end
      if result.config.minh then
        result.config.minh = result.config.minh * config.main_menu_scale
      end
      if result.config.maxw then
        result.config.maxw = result.config.maxw * config.main_menu_scale
      end
      if result.config.r then
        result.config.r = result.config.r * config.main_menu_scale
      end
    end
    
    -- Scale all child elements
    if result.nodes then
      scale_ui(result.nodes)
    end
  end
  
  return result
end


-- Override info_tip_from_rows to make variation tooltips scaleable
local orig_info_tip_from_rows = info_tip_from_rows
function info_tip_from_rows(desc_nodes, name)
  local result = orig_info_tip_from_rows(desc_nodes, name)
  
  if result and config.tooltip_scale ~= 1.0 then
    -- Scale the variation tooltip
    local function scale_variation_tooltip(nodes)
      for i, node in ipairs(nodes) do
        if node.config then
          -- Scale padding and dimensions
          if node.config.padding then
            node.config.padding = node.config.padding * config.tooltip_scale
          end
          if node.config.minw then
            node.config.minw = node.config.minw * config.tooltip_scale
          end
          if node.config.minh then
            node.config.minh = node.config.minh * config.tooltip_scale
          end
          if node.config.maxw then
            node.config.maxw = node.config.maxw * config.tooltip_scale
          end
          if node.config.r then
            node.config.r = node.config.r * config.tooltip_scale
          end
          
          -- Scale outline
          if node.config.outline then
            node.config.outline = node.config.outline * config.tooltip_scale
          end
          
          -- Scale text elements
          if node.config.text and node.config.scale then
            node.config.scale = node.config.scale * config.tooltip_scale
          end
          
          -- Scale DynaText objects
          if node.config.object and node.config.object.config and node.config.object.config.scale then
            node.config.object.config.scale = node.config.object.config.scale * config.tooltip_scale
          end
        end
        
        -- Recursively scale child nodes
        if node.nodes then
          scale_variation_tooltip(node.nodes)
        end
      end
    end
    
    if result.nodes then
      scale_variation_tooltip(result.nodes)
    end
  end
  
  return result
end