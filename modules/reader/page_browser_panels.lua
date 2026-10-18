local Menu = require("ui/widget/menu")
local TitleBar = require("ui/widget/titlebar")
local Screen = require("device").screen
local LibraryFont = require("modules/filebrowser/patches/library_font")
local ReaderFont = require("common/reader_font")
local TitleStyle = require("common/ui/zen_title_style")
local _ = require("gettext")

local M = {}

local function toc_items(pbw, focus_page)
    local items = {}
    for i, entry in ipairs(require("modules/reader/zen_toc_widget").getEntries(pbw.ui)) do
        items[i] = {
            text = string.rep("  ", math.max(0, entry.depth - 1)) .. entry.title,
            mandatory = entry.page_label,
            page = entry.page,
        }
        if entry.page <= focus_page then items.current = i end
    end
    if items.current then items[items.current].bold = true end
    return items
end

local function bookmark_items(pbw, focus_page)
    local bookmark = pbw.ui.bookmark
    local annotations = pbw.ui.annotation and pbw.ui.annotation.annotations or {}
    local items = {}
    if not bookmark then return items end
    bookmark.sorting_mode = G_reader_settings:readSetting("bookmarks_items_sorting") or "page"
    bookmark.is_reverse_sorting = G_reader_settings:isTrue("bookmarks_items_reverse_sorting")
    for i, annotation in ipairs(annotations) do
        local item = {}
        for key, value in pairs(annotation) do item[key] = value end
        item.text_orig = item.text or ""
        item.type = bookmark.getBookmarkType(item)
        item.text = bookmark:getBookmarkItemText(item)
        item.mandatory = bookmark:getBookmarkPageString(item.page)
        item._zen_annotation_index = i
        item._zen_bookmark = true
        item._zen_page_number = bookmark:getBookmarkPageNumber(item)
        item.bold = item._zen_page_number == focus_page
        items[#items + 1] = item
    end
    if bookmark.sorting_mode == "date" then
        table.sort(items, function(a, b) return a.datetime < b.datetime end)
    end
    if bookmark.is_reverse_sorting then
        for i = 1, math.floor(#items / 2) do
            items[i], items[#items - i + 1] = items[#items - i + 1], items[i]
        end
    end
    for i, item in ipairs(items) do
        if item.bold then items.current = i; break end
    end
    return items
end

function M.build(pbw, kind, width, height, on_navigate)
    local is_toc = kind == "toc"
    local focus_page = pbw:_zenFocusedDocumentPage()
    local items = is_toc and toc_items(pbw, focus_page) or bookmark_items(pbw, focus_page)
    local plugin = pbw._zen_plugin
    local config = plugin and plugin.config and plugin.config.page_browser
    local font_size = config and tonumber(config[is_toc and "toc_font_size" or "bookmarks_font_size"])
    if not font_size or font_size < 10 or font_size > 40 then
        font_size = ReaderFont.getInfo(pbw.ui, 18).size
    end
    local title_bar = TitleBar:new{
        width = width,
        title = is_toc and _("Table of contents") or _("Bookmarks"),
        align = "left",
        title_face = TitleStyle.getTitleFace(),
    }
    local menu = LibraryFont.withMenuFaces(function()
        return Menu:new{
            name = is_toc and "page_browser_toc" or nil,
            width = width,
            height = height,
            custom_title_bar = title_bar,
            item_table = items,
            is_borderless = true,
            is_popout = false,
            is_enable_shortcut = false,
            show_parent = pbw,
            items_per_page = math.max(1, math.floor(
                (height - title_bar:getHeight() - Screen:scaleBySize(48))
                / math.max(Screen:scaleBySize(48), font_size * 1.6)
            )),
            items_font_size = font_size,
            items_mandatory_font_size = font_size,
            items_max_lines = not is_toc and pbw.ui.bookmark and pbw.ui.bookmark.items_max_lines or nil,
        }
    end)
    local update_items = menu.updateItems
    menu.updateItems = function(self, ...)
        local args = { ... }
        local result = LibraryFont.withMenuFaces(function() return update_items(self, unpack(args)) end)
        pbw:_zenRebuildFocusLayout()
        return result
    end
    menu.onClose = function() return pbw:onClose() end
    menu.onCloseAllMenus = menu.onClose
    menu.onMenuSelect = function(self, item)
        if item.select_enabled ~= false then
            on_navigate(item._zen_page_number or item.page, item)
        end
        return true
    end
    if not is_toc then
        menu.onMenuHold = function(self, item)
            pbw:onClose()
            pbw.ui.bookmark:showBookmarkDetails(item._zen_annotation_index)
            return true
        end
    end
    return menu
end

return M
