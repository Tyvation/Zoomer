local locale = {}

if not SMODS then
    locale = {
        ['en-us'] = require('zoomer.locale.en-us').misc.dictionary,
        ['zh_TW'] = require('zoomer.locale.zh_tw').misc.dictionary
    }
end

function locale.translate(key)
    if SMODS then return localize(key) end
    return locale[G.SETTINGS.language][key] or locale['en-us'][key] or 'ERROR'
end

return locale
