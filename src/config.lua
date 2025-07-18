local config = {}

local logger = require('zoomer.logger')

-- 預設配置
local DEFAULTS = {
    ['tooltip_scale'] = 1.0,
    ['game_buttons_scale'] = 1.0,
    ['main_menu_scale'] = 1.0,
    ['hide_card_buttons'] = false
}

local SAVE_FILE_NAME = 'Zoomer.jkr'
local SAVE_DIR = 'config'
local SAVE_PATH = SAVE_DIR .. '/' .. SAVE_FILE_NAME

-- 序列化配置
local function serialize_config(tbl, indent)
    indent = indent or 1
    local str = "{\n"
    
    local function v_to_str(v, indent)
        if (type(v) == 'table') then
            return serialize_config(v, indent + 1)
        elseif (type(v) == 'number' or type(v) == 'boolean') then
            return tostring(v)
        else
            return "\'" .. tostring(v) .. "\'"
        end
    end
    
    for k, v in pairs(tbl) do
        if type(v) ~= 'function' then
            str = str .. string.rep("\t", indent)
            str = str .. "[\'" .. tostring(k) .. "\'] = "
            str = str .. v_to_str(v, indent) .. ",\n"
        end
    end
    
    str = str .. string.rep("\t", indent - 1) .. "}"
    return str
end

-- 儲存配置
function config.save()
    if not love.filesystem.getInfo(SAVE_DIR) then
        love.filesystem.createDirectory(SAVE_DIR)
    end
    
    local success, err = love.filesystem.write(
        SAVE_PATH,
        'return ' .. serialize_config(config or config.DEFAULTS)
    )
    print("Save success?", success, "Error:", err)

end

-- 載入配置
function config.load()
    -- 先設定預設值
    for k, v in pairs(DEFAULTS) do
        config[k] = v
    end
    
    -- 載入儲存的配置
    if love.filesystem.getInfo(SAVE_PATH) then
        local config_contents = love.filesystem.read(SAVE_PATH)
        if config_contents then
            local success, loaded_config = pcall(function()
                return load(config_contents, 'zoomer_load_config')()
            end)
            if success and type(loaded_config) == 'table' then
                for k, v in pairs(loaded_config) do
                    config[k] = v
                end
            end
        end
    end
    
    logger.log_info("Config loaded")

    return config
end

-- 重置為預設值
function config.reset_to_defaults()
    for k, v in pairs(DEFAULTS) do
        config[k] = v
    end
    config.save()
    logger.log_info("Config reset to defaults")
    
end

return config