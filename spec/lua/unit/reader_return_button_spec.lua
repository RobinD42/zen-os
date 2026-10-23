describe("temporary reader return button", function()
    local saved, Button, button, ui, enabled, timers, queued, dirty, returns
    local painted_frame, saved_settings
    local names = { "modules/reader/return_button", "modules/reader/references", "ffi/blitbuffer",
        "common/ui/color_text_widget", "ui/font", "ui/widget/container/framecontainer", "ui/geometry",
        "common/reader_themes", "device", "ui/size", "ui/uimanager", "ui/widget/widget", "gettext", "ffi/util",
        "common/ui/button_feedback", "common/ui/color_icon_widget", "common/utils", "common/plugin_root",
        "ui/widget/horizontalgroup", "ui/widget/horizontalspan", "common/reader_status_bar", "common/ui/button_labels" }

    before_each(function()
        saved, timers, queued, dirty, returns, enabled = {}, {}, {}, {}, 0, true
        painted_frame = nil
        saved_settings = G_reader_settings
        _G.G_reader_settings = ZenSpec.memorySettings({ footer = { text_font_face = "NotoSans-Bold.ttf" } })
        for _i, name in ipairs(names) do saved[name] = package.loaded[name] end
        for _i, name in ipairs(names) do ZenSpec.replace(name, {}) end
        local Widget = {}
        function Widget:extend(values) return setmetatable(values or {}, { __index = self }) end
        Widget.new = Widget.extend
        ZenSpec.replace("ui/widget/widget", Widget)
        ZenSpec.replace("ui/size", { radius = { window = 7 } })
        ZenSpec.replace("gettext", function(text) return text end)
        ZenSpec.replace("device", { screen = { bb = {}, getWidth = function() return 600 end,
            getHeight = function() return 800 end,
            scaleBySize = function(_self, size) return size end } })
        ZenSpec.replace("common/plugin_root", ZenSpec.root)
        ZenSpec.replace("common/utils", { resolveLocalIcon = function(dir, name) return dir .. name .. ".svg" end })
        for _i, name in ipairs({ "common/ui/color_icon_widget", "common/ui/color_text_widget",
            "ui/widget/horizontalgroup", "ui/widget/horizontalspan" }) do
            ZenSpec.replace(name, { new = function(_self, spec) return spec end })
        end
        ZenSpec.replace("ui/font", { getFace = function(_self, name, size)
            if name ~= "/missing/header.ttf" then return { name = name, size = size } end
        end })
        ZenSpec.replace("common/reader_themes", { getTextColor = function() return "sepia" end,
            getBackgroundColor = function() return "paper" end })
        ZenSpec.replace("ui/widget/container/framecontainer", { new = function(_self, spec)
            painted_frame = spec
            spec.getSize = function()
                return { w = 180, h = math.max(spec[1][1].height, spec[1][3].face.size)
                    + spec.padding_top + spec.padding_bottom + 2 * spec.bordersize }
            end
            spec.paintTo = function(_frame, _bb, x, y)
                local size = spec:getSize()
                spec.dimen = { x = x, y = y, w = size.w, h = size.h }
            end
            spec.free = function() end
            return spec
        end })
        ZenSpec.replace("ffi/util", { template = function(text, value) return (text:gsub("%%1", tostring(value))) end })
        ZenSpec.replace("ui/geometry", { new = function(_self, values) return values end })
        ZenSpec.replace("ui/uimanager", {
            nextTick = function(_self, callback) queued[#queued + 1] = callback end,
            scheduleIn = function(_self, delay, callback) timers[callback] = delay end,
            unschedule = function(_self, callback) timers[callback] = nil end,
            setDirty = function(_self, widget, mode) dirty[#dirty + 1] = mode end,
            getTopmostVisibleWidget = function() return ui end,
        })
        ZenSpec.replace("common/ui/button_feedback", { flashButton = function() end })
        ZenSpec.replace("common/ui/button_labels", { alignIcon = function(icon, label) icon.aligned_label = label end })
        ZenSpec.replace("modules/reader/references", { enabled = function() return enabled and ui or false end,
            locationPage = function(_ui, location) return location.page end,
            pageLabel = function(_ui, page) return tostring(page) end,
            goBack = function() returns = returns + 1 end })
        ZenSpec.unload("modules/reader/return_button")
        ZenSpec.unload("common/reader_status_bar")
        Button = require("modules/reader/return_button")
        ui = { page = 3, view = { footer = { horizontal_margin = 10 } } }
        ui.link = { compareLocationToCurrent = function(_self, location) return location.page == ui.page end }
        button = Button:new{ ui = ui }
    end)

    after_each(function()
        _G.G_reader_settings = saved_settings
        for _i, name in ipairs(names) do package.loaded[name] = saved[name] end
    end)

    it("waits for an actual jump, then expires after 30 seconds", function()
        button:queue({ page = 3 })
        queued[#queued]()
        assert.is_false(button:isVisible())
        assert.same({}, timers)
        button:queue({ page = 3 })
        ui.page = 20
        queued[#queued]()
        assert.is_true(button:isVisible())
        assert.equals(30, timers[button.expire])
        button:paintTo(require("device").screen.bb, 0, 0)
        local mode, region = dirty[#dirty]()
        assert.equals("ui", mode)
        assert.same(button.dimen, region)
        local expire = button.expire
        ui.page = 21
        assert.equals(expire, button.expire)
        expire()
        assert.is_false(button:isVisible())
        assert.same({}, timers)
        local hide_mode, hide_region = dirty[#dirty]()
        assert.equals("ui", hide_mode)
        assert.same(region, hide_region)
    end)

    it("puts the themed return SVG before the renamed label within the width limit", function()
        button:queue({ page = 7 })
        queued[#queued]()
        button:paintTo(require("device").screen.bb, 0, 0)
        local row = painted_frame[1]
        assert.equals("Return to page 7", button.text)
        assert.matches("/icons/return.svg$", row[1].icon)
        assert.equals(row[3], row[1].aligned_label)
        assert.equals("sepia", row[1].fgcolor)
        assert.equals("Return to page 7", row[3].text)
        assert.equals("sepia", row[3].fgcolor)
        assert.same({ name = "NotoSans-Bold.ttf", size = 14 }, row[3].face)
        assert.is_true(row[3].max_width + row[1].width + row[2].width
            + painted_frame.padding_left + painted_frame.padding_right + 2 * painted_frame.bordersize <= 600 * 0.48)
    end)

    it("follows the header font and size, including inheritance and unavailable fonts", function()
        button:queue({ page = 7 })
        queued[#queued]()
        button.plugin = { config = {} }
        for _i, case in ipairs({
            { face = "default", size = 18, expected = "NotoSans-Bold.ttf" },
            { face = "NotoSerif-Regular.ttf", size = 20, expected = "NotoSerif-Regular.ttf" },
            { face = "/missing/header.ttf", size = 16, expected = "cfont" },
        }) do
            button.plugin.config.reader_top_status_bar = { font_face = case.face, font_size = case.size }
            button:paintTo(require("device").screen.bb, 0, 0)
            assert.same({ name = case.expected, size = case.size }, painted_frame[1][3].face)
        end
    end)

    it("anchors a rounded tab to the bottom left with its label fully on screen", function()
        button:queue({ page = 7 })
        queued[#queued]()
        local screen = require("device").screen
        for _i, size in ipairs({ { w = 600, h = 800 }, { w = 800, h = 600 } }) do
            screen.getWidth = function() return size.w end
            screen.getHeight = function() return size.h end
            for _j, font_size in ipairs({ 14, 32 }) do
                button.plugin = { config = { reader_top_status_bar = { font_size = font_size } } }
                button:paintTo(screen.bb, 0, 0)
                local bounds = button.dimen
                assert.equals(10, bounds.x)
                assert.equals(require("ui/size").radius.window, painted_frame.radius)
                assert.equals(2, painted_frame.padding_top)
                assert.equals(2, painted_frame.padding_bottom - painted_frame.radius)
                assert.is_true(bounds.y > size.h / 2)
                assert.equals(size.h + painted_frame.radius, bounds.y + bounds.h)
                local content_bottom = bounds.y + painted_frame.bordersize + painted_frame.padding_top
                    + math.max(painted_frame[1][1].height, painted_frame[1][3].face.size)
                assert.is_true(content_bottom < size.h)
            end
        end
    end)

    it("follows the footer margin setting and asymmetric book margins without double scaling", function()
        button:queue({ page = 7 })
        queued[#queued]()
        button.plugin = { config = { features = { reader_status_bar_margins = true } } }
        ui.document = { getPageMargins = function() return { left = 61, right = 43 } end }
        local screen = require("device").screen
        screen.scaleBySize = function(_self, size) return 2 * size end
        button:paintTo(screen.bb, 0, 0)
        assert.equals(61, button.dimen.x)
        ui.document.getPageMargins = nil
        ui.document.configurable = { h_page_margins = { 31, 22 } }
        button:paintTo(screen.bb, 0, 0)
        assert.equals(62, button.dimen.x)
        button.plugin.config.features.reader_status_bar_margins = false
        button:paintTo(screen.bb, 0, 0)
        assert.equals(10, button.dimen.x)
    end)

    it("replaces the timer on a new jump and cancels pending work on hide", function()
        button:queue({ page = 1 })
        queued[#queued]()
        local first = button.expire
        button:queue({ page = 2 })
        queued[#queued]()
        assert.is_nil(timers[first])
        assert.equals(30, timers[button.expire])
        assert.equals(2, button.location.page)
        button:queue({ page = 4 })
        button:hide()
        assert.is_nil(button.pending_callback)
        assert.is_nil(button.expire)
        assert.same({}, timers)
    end)

    it("does not arm a disabled feature and consumes only return-button taps", function()
        button:queue({ page = 1 })
        enabled = false
        queued[#queued]()
        assert.same({}, timers)
        enabled = true
        button:queue({ page = 1 })
        queued[#queued]()
        button.dimen = { contains = function(_self, pos) return pos.inside end }
        assert.is_false(button:onTap({ pos = {} }))
        assert.equals(0, returns)
        assert.is_true(button:onTap({ pos = { inside = true } }))
        assert.equals(1, returns)
        assert.same({}, timers)
    end)
end)
