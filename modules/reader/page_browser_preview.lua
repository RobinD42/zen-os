local Blitbuffer = require("ffi/blitbuffer")
local Geom = require("ui/geometry")
local Screen = require("device").screen
local Size = require("ui/size")
local Widget = require("ui/widget/widget")

local Preview = Widget:extend{}

function Preview:init()
    self.dimen = Geom:new{ w = self.width, h = self.height }
end

function Preview:invalidate()
    if self.bb then self.bb:free(); self.bb = nil end
end

function Preview:setPage(page)
    if self.page == page then return end
    self.page = page
    self:invalidate()
end

function Preview:render()
    local ui, page = self.ui, self.page
    local document = ui.document
    local saved_pos = ui.rolling and document:getCurrentPos()
    local state = {}
    for key, value in pairs(ui.view.state) do state[key] = value end
    state.page = page
    local view = setmetatable({ state = state }, { __index = ui.view })
    local bb = Blitbuffer.new(self.width, self.height, Screen.bb:getType())
    local ok, err = pcall(function()
        bb:fill(ui.view.outer_page_color or Blitbuffer.COLOR_WHITE)
        view:drawPageSurround(bb, 0, 0)
        if ui.rolling then view:drawPageView(bb, 0, 0)
        else view:drawSinglePage(bb, 0, 0) end
        if view.highlight_visible then
            view.highlight = setmetatable({ page_boxes = {} }, { __index = ui.view.highlight })
            view:drawSavedHighlight(bb, 0, 0)
        end
    end)
    if saved_pos then document:gotoPos(saved_pos) end
    if not ok then bb:free(); error(err, 0) end
    self.bb = bb
end

function Preview:paintTo(bb, x, y)
    self.dimen.x, self.dimen.y = x, y
    if not self.bb then self:render() end
    bb:blitFrom(self.bb, x, y, 0, 0, self.width, self.height)
    if self.focused then
        bb:paintBorder(x, y + self.top, self.width, self.height - self.top - self.bottom,
            Size.border.thick, Blitbuffer.COLOR_BLACK)
    end
end

function Preview:onFocus()
    self.focused = true
    return true
end

function Preview:onUnfocus()
    self.focused = false
    return true
end

Preview.free = Preview.invalidate

return Preview
