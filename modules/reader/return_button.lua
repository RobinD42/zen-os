local Blitbuffer = require("ffi/blitbuffer")
local ButtonLabels = require("common/ui/button_labels")
local ColorIconWidget = require("common/ui/color_icon_widget")
local ColorTextWidget = require("common/ui/color_text_widget")
local FrameContainer = require("ui/widget/container/framecontainer")
local HorizontalGroup = require("ui/widget/horizontalgroup")
local HorizontalSpan = require("ui/widget/horizontalspan")
local ReaderThemes = require("common/reader_themes")
local ReaderStatusBar = require("common/reader_status_bar")
local References = require("modules/reader/references")
local Screen = require("device").screen
local Size = require("ui/size")
local UIManager = require("ui/uimanager")
local Widget = require("ui/widget/widget")
local _ = require("gettext")
local T = require("ffi/util").template
local utils = require("common/utils")
local icons_dir = require("common/plugin_root") .. "/icons/"

local ReturnButton = Widget:extend{ duration = 30 }

function ReturnButton:isVisible()
    return self.visible == true and not not References.enabled(self.ui)
end

function ReturnButton:refresh()
    UIManager:setDirty(self.ui, function() return "ui", self.dimen end)
end

function ReturnButton:hide(refresh)
    if self.pending_callback then UIManager:unschedule(self.pending_callback); self.pending_callback = nil end
    if self.expire then UIManager:unschedule(self.expire); self.expire = nil end
    local visible = self.visible
    self.visible, self.location = false, nil
    if visible and refresh ~= false then self:refresh() end
end

function ReturnButton:queue(location)
    if self.pending_callback then UIManager:unschedule(self.pending_callback) end
    self.pending_callback = function()
        self.pending_callback = nil
        if not References.enabled(self.ui) or self.ui.link:compareLocationToCurrent(location) then return end
        self:hide(false)
        self.visible, self.location = true, location
        self.expire = function() self:hide() end
        UIManager:scheduleIn(self.duration, self.expire)
        self:refresh()
    end
    -- History is saved before navigation; inspect the destination after it settles.
    UIManager:nextTick(self.pending_callback)
end

function ReturnButton:paintTo(bb, x, y)
    if bb ~= Screen.bb or not self:isVisible() then return end
    local top = UIManager:getTopmostVisibleWidget()
    if top ~= self.ui and top ~= self.ui.show_parent and (not top or top.show_parent ~= self.ui) then return end
    local page = References.locationPage(self.ui, self.location)
    if not page then return end
    self.text = T(_("Return to page %1"), References.pageLabel(self.ui, page))
    local foreground = ReaderThemes.getTextColor(self.plugin) or Blitbuffer.COLOR_BLACK
    local icon_size, gap = Screen:scaleBySize(16), Screen:scaleBySize(4)
    local padding, border = Screen:scaleBySize(8), Screen:scaleBySize(1)
    local cfg = self.plugin and self.plugin.config and self.plugin.config.reader_top_status_bar
    local label = ColorTextWidget:new{
        text = self.text,
        face = ReaderStatusBar.getHeaderFace(cfg), fgcolor = foreground, invert_night_mode = false,
        max_width = math.floor(Screen:getWidth() * 0.48) - 2 * (padding + border) - icon_size - gap,
    }
    local icon = ColorIconWidget:new{ icon = utils.resolveLocalIcon(icons_dir, "return"),
        width = icon_size, height = icon_size, alpha = true, fgcolor = foreground }
    ButtonLabels.alignIcon(icon, label)
    local frame = FrameContainer:new{
        bordersize = border, margin = 0, radius = Size.radius.window,
        padding_left = padding, padding_right = padding,
        padding_top = Screen:scaleBySize(2), padding_bottom = Screen:scaleBySize(2) + Size.radius.window,
        background = ReaderThemes.getBackgroundColor(self.plugin) or Blitbuffer.COLOR_WHITE,
        color = foreground, HorizontalGroup:new{ allow_mirroring = false,
            icon,
            HorizontalSpan:new{ width = gap }, label,
        },
    }
    local left = ReaderStatusBar.getHorizontalMargins(self.ui.document, self.ui.view.footer.horizontal_margin, self.plugin)
    frame:paintTo(bb, x + left, y + Screen:getHeight() - frame:getSize().h + frame.radius)
    self.dimen = frame.dimen
    frame:free()
end

function ReturnButton:onTap(ges)
    if not self:isVisible() or not self.dimen or not self.dimen:contains(ges.pos) then return false end
    require("common/ui/button_feedback").flashButton(self.dimen)
    self:hide(false)
    References.goBack(self.ui)
    return true
end

function ReturnButton.attach(ui, plugin)
    if ui._zen_return_button then return end
    local button = ReturnButton:new{ ui = ui, plugin = plugin }
    ui._zen_return_button = button
    local ReaderView = require("apps/reader/modules/readerview")
    -- Keep the overlay above class patches, including a status bar enabled later.
    ui.view.paintTo = function(view, bb, x, y)
        if bb == Screen.bb and button.location and ui.link:compareLocationToCurrent(button.location) then button:hide(false) end
        ReaderView.paintTo(view, bb, x, y)
        button:paintTo(bb, x, y)
    end
    local overrides = { "readerlink_tap", "readerhighlight_tap", "readermenu_tap", "readermenu_ext_tap",
        "tap_top_left_corner", "tap_forward", "tap_backward" }
    for id, zone in pairs(ui._zones or {}) do
        if zone.def.ges == "tap" then overrides[#overrides + 1] = id end
    end
    ui:registerTouchZones{{ id = "zen_reference_return", ges = "tap",
        screen_zone = { ratio_x = 0, ratio_y = 0, ratio_w = 1, ratio_h = 1 }, overrides = overrides,
        handler = function(ges) return button:onTap(ges) end,
    }}
end

return ReturnButton
