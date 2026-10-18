local _ = require("gettext")
local M = {}

function M.defaults()
    local entries = {
        { "font", _("Font"), "appbar.textsize" },
        { "contrast", _("Contrast"), "appbar.contrast" },
        { "page", _("Page"), "appbar.pageview" },
        { "document", _("Document"), "book_closed" },
        { "book_info", _("Book info"), "info" },
        { "toc", _("TOC"), "toc" },
        { "bookmarks", _("Bookmarks"), "bookmark" },
        { "search", _("Search"), "quick_search" },
        { "profiles", _("Profiles"), "bookshelf" },
        { "themes", _("Themes"), "quick_nightmode" },
        { "vocabulary", _("Vocabulary builder"), "tab_vocab" },
        { "page_browser", _("Page Browser"), "grid_slide", false },
        { "koreader_menu", _("KOReader reader menu"), "koreader", false },
    }
    local buttons = {}
    for _i, entry in ipairs(entries) do
        buttons[#buttons + 1] = { id = "reader_" .. entry[1], type = "reader_control",
            control = entry[1], label = entry[2], icon = entry[3], enabled = entry[4] }
    end
    return buttons
end

function M.ensure(config)
    local cfg = config.reader_controls or { entries = {}, next_id = 0 }
    config.reader_controls = cfg
    if cfg.show_page_chevrons == nil then cfg.show_page_chevrons = not require("device"):isTouchDevice() end
    if not cfg.buttons_initialized then
        local entries = M.defaults()
        for _i, entry in ipairs(cfg.entries or {}) do entries[#entries + 1] = entry end
        cfg.entries = entries
        cfg.buttons_initialized = true
    end
    if not cfg.annotations_merged then
        local position, has_search
        for i = #cfg.entries, 1, -1 do
            local entry = cfg.entries[i]
            if entry.type == "reader_control" and entry.control == "highlights" then
                table.remove(cfg.entries, i)
                position = i
            elseif entry.type == "reader_control" and entry.control == "search" then has_search = true end
        end
        if not has_search then
            for _i, entry in ipairs(M.defaults()) do
                if entry.control == "search" then
                    table.insert(cfg.entries, position or #cfg.entries + 1, entry)
                    break
                end
            end
        end
        cfg.annotations_merged = true
    end
    if not cfg.contrast_split then
        local font, position, has_contrast
        for i, entry in ipairs(cfg.entries) do
            if entry.type == "reader_control" then
                if entry.control == "font" then font, position = entry, i + 1 end
                if entry.control == "contrast" then has_contrast = true end
            end
        end
        if not has_contrast then
            for _i, entry in ipairs(M.defaults()) do
                if entry.control == "contrast" then
                    entry.enabled = font and font.enabled
                    if not font then entry.enabled = false end
                    if font and font.label ~= _("Font") then entry.label = font.label end
                    if font and font.icon ~= "appbar.textsize" then entry.icon = font.icon end
                    table.insert(cfg.entries, position or 1, entry)
                    break
                end
            end
        end
        cfg.contrast_split = true
    end
    if not cfg.menu_buttons_added then
        local present = {}
        for _i, entry in ipairs(cfg.entries) do
            if entry.control then present[entry.control] = true end
        end
        for _i, entry in ipairs(M.defaults()) do
            if (entry.control == "vocabulary" or entry.control == "page_browser" or entry.control == "koreader_menu")
                    and not present[entry.control] then
                cfg.entries[#cfg.entries + 1] = entry
            end
        end
        cfg.menu_buttons_added = true
    end
    return cfg
end

function M.visible(config, group)
    local entries = {}
    for _i, entry in ipairs(M.ensure(config).entries) do
        if entry.enabled ~= false and (entry.control ~= "document" or group == "kopt")
                and (entry.control ~= "themes" or group == "copt")
                and (entry.control ~= "font" or group == "copt")
                and (entry.control ~= "contrast" or group == "kopt") then
            entries[#entries + 1] = entry
        end
    end
    return entries
end

return M
