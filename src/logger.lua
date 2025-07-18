local logger = {}

function logger.log_info(message)
    if G.DEBUG then
        print(os.date('%Y-%m-%d %H:%M:%S') .. " :: INFO :: Zoomer :: " .. message)
    end
end

function logger.log_error(message)
    print(os.date('%Y-%m-%d %H:%M:%S') .. " :: ERROR :: Zoomer :: " .. message)
end

function logger.log_warn(message)
    print(os.date('%Y-%m-%d %H:%M:%S') .. " :: WARN :: Zoomer :: " .. message)
end

function logger.log_debug(message)
    if G.DEBUG then 
        print(os.date('%Y-%m-%d %H:%M:%S') .. " :: DEBUG :: Zoomer :: " .. message)
    end
end

return logger