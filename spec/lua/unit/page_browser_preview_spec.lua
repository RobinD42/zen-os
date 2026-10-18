describe("full-size page-browser preview", function()
    local Preview, saved_modules, buffers, rendered, document, ui, target
    local module_names = {
        "ffi/blitbuffer", "ui/geometry", "device", "ui/size", "ui/widget/widget",
        "modules/reader/page_browser_preview",
    }

    before_each(function()
        saved_modules = {}
        for _i, name in ipairs(module_names) do saved_modules[name] = package.loaded[name] or false end
        local Widget = {}
        function Widget:extend(values) return setmetatable(values or {}, { __index = self }) end
        function Widget:new(values)
            local instance = self:extend(values)
            instance:init()
            return instance
        end
        buffers, rendered = {}, {}
        ZenSpec.replace("ui/widget/widget", Widget)
        ZenSpec.replace("ui/geometry", { new = function(_self, values) return values end })
        ZenSpec.replace("ui/size", { border = { thick = 3 } })
        ZenSpec.replace("device", { screen = { bb = { getType = function() return "screen type" end } } })
        ZenSpec.replace("ffi/blitbuffer", {
            COLOR_WHITE = "white", COLOR_BLACK = "black",
            new = function(width, height, kind)
                local bb = { width = width, height = height, kind = kind, frees = 0 }
                function bb:fill(color) self.background = color end
                function bb:free() self.frees = self.frees + 1 end
                buffers[#buffers + 1] = bb
                return bb
            end,
        })
        document = {
            position = 120,
            getCurrentPos = function(self) return self.position end,
            gotoPos = function(self, pos) self.position = pos end,
        }
        ui = {
            rolling = {}, document = document,
            view = {
                document = document,
                state = { page = 2, gamma = 1.7, zoom = 1.25, rotation = 90,
                    offset = { x = 11, y = 23 } },
                outer_page_color = "reader margin",
                visible_area = { x = 4, y = 8, w = 540, h = 720 },
                highlight_visible = true,
                highlight = { page_boxes = { original = true } },
                drawPageSurround = function(self, bb, x, y)
                    rendered[#rendered + 1] = { method = "surround", view = self, bb = bb, x = x, y = y }
                end,
                drawPageView = function(self, bb, x, y)
                    self.document.position = self.state.page * 100
                    rendered[#rendered + 1] = { method = "rolling", view = self, bb = bb,
                        x = x + self.state.offset.x, y = y + self.state.offset.y }
                end,
                drawSinglePage = function(self, bb, x, y)
                    rendered[#rendered + 1] = { method = "single", view = self, bb = bb,
                        x = x + self.state.offset.x, y = y + self.state.offset.y }
                end,
                drawSavedHighlight = function(self)
                    self.highlight.page_boxes.preview = true
                end,
            },
        }
        target = { blits = {} }
        function target:blitFrom(...) self.blits[#self.blits + 1] = { ... } end
        ZenSpec.unload("modules/reader/page_browser_preview")
        Preview = require("modules/reader/page_browser_preview")
    end)

    after_each(function()
        for _i, name in ipairs(module_names) do package.loaded[name] = saved_modules[name] or nil end
    end)

    it("renders the reader's unscaled page and caches it without changing live state", function()
        local preview = Preview:new{ ui = ui, page = 7, width = 600, height = 800 }
        preview:paintTo(target, 20, 30)
        assert.are.equal(1, #buffers)
        assert.are.same({ 600, 800, "screen type", "reader margin" },
            { buffers[1].width, buffers[1].height, buffers[1].kind, buffers[1].background })
        assert.are.equal("surround", rendered[1].method)
        assert.are.equal("rolling", rendered[2].method)
        local view = rendered[2].view
        assert.are.equal(7, view.state.page)
        assert.are.equal(1.7, view.state.gamma)
        assert.are.equal(1.25, view.state.zoom)
        assert.are.equal(90, view.state.rotation)
        assert.are.same({ 11, 23 }, { rendered[2].x, rendered[2].y })
        assert.are.equal(ui.view.visible_area, view.visible_area)
        assert.are.equal(2, ui.view.state.page)
        assert.are.equal(120, document.position)
        assert.are.same({ original = true }, ui.view.highlight.page_boxes)
        assert.are.same({ buffers[1], 20, 30, 0, 0, 600, 800 }, target.blits[1])
        preview:paintTo(target, 5, 10)
        assert.are.equal(1, #buffers)
        assert.are.equal(2, #rendered)
        assert.are.same({ buffers[1], 5, 10, 0, 0, 600, 800 }, target.blits[2])
        assert.are.same({ x = 5, y = 10, w = 600, h = 800 }, preview.dimen)
    end)

    it("restores the EPUB position and frees an incomplete render when drawing fails", function()
        document.position = 0
        ui.view.drawPageView = function(self)
            self.document.position = 700
            error("page render failed", 0)
        end
        local preview = Preview:new{ ui = ui, page = 7, width = 600, height = 800 }
        assert.has_error(function() preview:paintTo(target, 0, 0) end, "page render failed")
        assert.are.equal(0, document.position)
        assert.are.equal(1, buffers[1].frees)
        assert.is_nil(preview.bb)
        assert.are.equal(0, #target.blits)
    end)

    it("frees stale pages and rerenders with updated reader settings after invalidation", function()
        local preview = Preview:new{ ui = ui, page = 7, width = 600, height = 800 }
        preview:paintTo(target, 0, 0)
        preview:setPage(7)
        assert.are.equal(0, buffers[1].frees)
        preview:setPage(8)
        assert.are.equal(1, buffers[1].frees)
        assert.is_nil(preview.bb)
        preview:paintTo(target, 0, 0)
        assert.are.equal(8, rendered[4].view.state.page)
        ui.view.state.gamma = 2.5
        preview:invalidate()
        assert.are.equal(1, buffers[2].frees)
        preview:paintTo(target, 0, 0)
        assert.are.equal(2.5, rendered[6].view.state.gamma)
        preview:free()
        preview:free()
        assert.are.equal(1, buffers[3].frees)
        assert.is_nil(preview.bb)
    end)

    it("draws PDF pages with current contrast and offsets without navigating the document", function()
        ui.rolling = nil
        ui.view.highlight_visible = false
        document.getCurrentPos = function() error("PDF position was read") end
        document.gotoPos = function() error("PDF position was changed") end
        local preview = Preview:new{ ui = ui, page = 9, width = 600, height = 800 }
        preview:paintTo(target, 0, 0)
        assert.are.equal(2, #rendered)
        assert.are.equal("single", rendered[2].method)
        assert.are.equal(9, rendered[2].view.state.page)
        assert.are.equal(1.7, rendered[2].view.state.gamma)
        assert.are.same({ 11, 23 }, { rendered[2].x, rendered[2].y })
        assert.are.equal(2, ui.view.state.page)
        assert.are.equal(120, document.position)
    end)
end)
