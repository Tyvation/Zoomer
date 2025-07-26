local config = require('zoomer.config')

config.load()

-- Override desc_from_rows to scale hardcoded dimensions and add text scaling
local orig_desc_from_rows = desc_from_rows
function desc_from_rows(desc_nodes, empty, maxw)
  -- First, scale the text in desc_nodes before passing to original function
  local scaled_desc_nodes = desc_nodes
  if config.tooltip_scale ~= 1.0 then
    scaled_desc_nodes = {}
    for k, v in ipairs(desc_nodes) do
      scaled_desc_nodes[k] = {}
      for i, node in ipairs(v) do
        scaled_desc_nodes[k][i] = {}
        -- Copy all properties
        for key, val in pairs(node) do
          scaled_desc_nodes[k][i][key] = val
        end
        -- Scale text properties
        if node.config then
          if not scaled_desc_nodes[k][i].config then 
            scaled_desc_nodes[k][i].config = {}
            for key, val in pairs(node.config) do
              scaled_desc_nodes[k][i].config[key] = val
            end
          end
          if node.config.scale then
            scaled_desc_nodes[k][i].config.scale = node.config.scale * config.tooltip_scale
          end
        end
        -- Scale DynaText objects
        if node.config and node.config.object and type(node.config.object) == "table" and node.config.object.config then
          if not scaled_desc_nodes[k][i].config.object then
            scaled_desc_nodes[k][i].config.object = {}
            for key, val in pairs(node.config.object) do
              scaled_desc_nodes[k][i].config.object[key] = val
            end
          end
          if not scaled_desc_nodes[k][i].config.object.config then
            scaled_desc_nodes[k][i].config.object.config = {}
            for key, val in pairs(node.config.object.config) do
              scaled_desc_nodes[k][i].config.object.config[key] = val
            end
          end
          if node.config.object.config.scale then
            scaled_desc_nodes[k][i].config.object.config.scale = node.config.object.config.scale * config.tooltip_scale
          end
        end
      end
    end
  end
  
  -- Call original function with scaled nodes
  local result = orig_desc_from_rows(scaled_desc_nodes, empty, maxw and (maxw * config.tooltip_scale) or maxw)
  
  -- Apply scaling to container dimensions
  if config.tooltip_scale ~= 1.0 then
    -- Scale the hardcoded dimensions
    result.config.r = (result.config.r or 0.1) * config.tooltip_scale
    result.config.padding = (result.config.padding or 0.04) * config.tooltip_scale  
    result.config.minw = (result.config.minw or 2) * config.tooltip_scale
    result.config.minh = (result.config.minh or 0.8) * config.tooltip_scale
    result.config.emboss = result.config.emboss and (result.config.emboss * config.tooltip_scale)
    
    -- Scale the inner padding
    if result.nodes and result.nodes[1] and result.nodes[1].config and result.nodes[1].config.padding then
      result.nodes[1].config.padding = result.nodes[1].config.padding * config.tooltip_scale
    end
  end
  
  return result
end

-- Override name_from_rows to scale hardcoded dimensions  
local orig_name_from_rows = name_from_rows  
function name_from_rows(name_nodes, background_colour)
  -- First, scale the text in name_nodes before passing to original function
  local scaled_name_nodes = name_nodes
  if name_nodes and type(name_nodes) == 'table' and config.tooltip_scale ~= 1.0 then
    scaled_name_nodes = {}
    for i, node in ipairs(name_nodes) do
      scaled_name_nodes[i] = {}
      -- Copy all properties
      for key, val in pairs(node) do
        scaled_name_nodes[i][key] = val
      end
      -- Scale text properties
      if node.config then
        if not scaled_name_nodes[i].config then 
          scaled_name_nodes[i].config = {}
          for key, val in pairs(node.config) do
            scaled_name_nodes[i].config[key] = val
          end
        end
        if node.config.scale then
          scaled_name_nodes[i].config.scale = node.config.scale * config.tooltip_scale
        end
      end
      -- Scale DynaText objects  
      if node.config and node.config.object and type(node.config.object) == "table" and node.config.object.config then
        if not scaled_name_nodes[i].config.object then
          scaled_name_nodes[i].config.object = {}
          for key, val in pairs(node.config.object) do
            scaled_name_nodes[i].config.object[key] = val
          end
        end
        if not scaled_name_nodes[i].config.object.config then
          scaled_name_nodes[i].config.object.config = {}
          for key, val in pairs(node.config.object.config) do
            scaled_name_nodes[i].config.object.config[key] = val
          end
        end
        if node.config.object.config.scale then
          scaled_name_nodes[i].config.object.config.scale = node.config.object.config.scale * config.tooltip_scale
        end
      end
    end
  end
  
  -- Call original function with scaled nodes
  local result = orig_name_from_rows(scaled_name_nodes, background_colour)
  
  -- Apply scaling to container dimensions
  if result and config.tooltip_scale ~= 1.0 then
    result.config.padding = (result.config.padding or 0.05) * config.tooltip_scale
    result.config.r = (result.config.r or 0.1) * config.tooltip_scale
    result.config.emboss = result.config.emboss and (result.config.emboss * config.tooltip_scale)
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
  -- First, scale the text in desc_nodes before passing to original function
  local scaled_desc_nodes = desc_nodes
  if config.tooltip_scale ~= 1.0 then
    scaled_desc_nodes = {}
    for k, v in ipairs(desc_nodes) do
      scaled_desc_nodes[k] = {}
      for i, node in ipairs(v) do
        scaled_desc_nodes[k][i] = {}
        -- Copy all properties
        for key, val in pairs(node) do
          scaled_desc_nodes[k][i][key] = val
        end
        -- Scale text properties
        if node.config then
          if not scaled_desc_nodes[k][i].config then 
            scaled_desc_nodes[k][i].config = {}
            for key, val in pairs(node.config) do
              scaled_desc_nodes[k][i].config[key] = val
            end
          end
          if node.config.scale then
            scaled_desc_nodes[k][i].config.scale = node.config.scale * config.tooltip_scale
          end
        end
        -- Scale DynaText objects
        if node.config and node.config.object and type(node.config.object) == "table" and node.config.object.config then
          if not scaled_desc_nodes[k][i].config.object then
            scaled_desc_nodes[k][i].config.object = {}
            for key, val in pairs(node.config.object) do
              scaled_desc_nodes[k][i].config.object[key] = val
            end
          end
          if not scaled_desc_nodes[k][i].config.object.config then
            scaled_desc_nodes[k][i].config.object.config = {}
            for key, val in pairs(node.config.object.config) do
              scaled_desc_nodes[k][i].config.object.config[key] = val
            end
          end
          if node.config.object.config.scale then
            scaled_desc_nodes[k][i].config.object.config.scale = node.config.object.config.scale * config.tooltip_scale
          end
        end
      end
    end
  end
  
  -- Call original function with scaled nodes
  local result = orig_info_tip_from_rows(scaled_desc_nodes, name)
  
  if result and config.tooltip_scale ~= 1.0 then
    -- Scale the root container properties
    if result.config then
      result.config.r = (result.config.r or 0.1) * config.tooltip_scale
    end
    
    -- Scale the direct child nodes (title and content containers)
    if result.nodes then
      for _, node in ipairs(result.nodes) do
        if node.config then
          if node.config.padding then node.config.padding = node.config.padding * config.tooltip_scale end
          if node.config.minh then node.config.minh = node.config.minh * config.tooltip_scale end  
          if node.config.minw then node.config.minw = node.config.minw * config.tooltip_scale end
          if node.config.r then node.config.r = node.config.r * config.tooltip_scale end
          -- Scale text scale if present
          if node.config.scale then node.config.scale = node.config.scale * config.tooltip_scale end
          -- Scale text in nested nodes
          if node.nodes and node.nodes[1] and node.nodes[1].config and node.nodes[1].config.scale then
            node.nodes[1].config.scale = node.nodes[1].config.scale * config.tooltip_scale
          end
        end
      end
    end
  end
  
  return result
end