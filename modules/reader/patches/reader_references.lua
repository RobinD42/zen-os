return function()
    local References = require("modules/reader/references")
    local plugin = rawget(_G, "__ZEN_UI_PLUGIN")
    References.configure(plugin)
    require("modules/reader/pin_footer").apply()
    local ReaderGoto = require("apps/reader/modules/readergoto")
    if not ReaderGoto._zen_pins_patched then
        ReaderGoto._zen_pins_patched = true
        local pin = ReaderGoto.onPinPage
        ReaderGoto.onPinPage = function(self, page, remove)
            if not References.enabled(self.ui) then return pin(self, page, remove) end
            if remove and not page then page = References.pinnedPage(self.ui) end
            References.setPin(self.ui, page, remove)
            return true
        end
        local goto_pin = ReaderGoto.onGoToPinnedPage
        ReaderGoto.onGoToPinnedPage = function(self, ...)
            if not References.enabled(self.ui) then return goto_pin(self, ...) end
            References.openPinned(self.ui)
            return true
        end
    end
    local ReaderLink = require("apps/reader/modules/readerlink")
    if ReaderLink._zen_references_patched then return end
    ReaderLink._zen_references_patched = true
    local ReaderHighlight = require("apps/reader/modules/readerhighlight")
    local hold = ReaderHighlight.onHold
    ReaderHighlight.onHold = function(self, arg, ges)
        if not References.enabled(self.ui) then return hold(self, arg, ges) end
        local ImageViewer = require("ui/widget/imageviewer")
        local factory = ImageViewer.new
        -- Intercept native image detection without probing images twice on text holds.
        ImageViewer.new = function(class, spec)
            local position = self.view:screenToPageTransform(ges.pos)
            local page = position and position.page or self.ui:getCurrentPage()
            return References.imageMenu(self, page, ges.pos, spec, function() return factory(class, spec) end)
        end
        local ok, result = pcall(hold, self, arg, ges)
        ImageViewer.new = factory
        if not ok then error(result) end
        return result
    end
    local init = ReaderLink.init
    ReaderLink.init = function(self, ...)
        init(self, ...)
        self.ui:registerPostInitCallback(function()
            require("modules/reader/return_button").attach(self.ui, plugin)
            require("modules/reader/pin_footer").attach(self.ui)
        end)
    end
    local add_location = ReaderLink.addCurrentLocationToStack
    ReaderLink.addCurrentLocationToStack = function(self, ...)
        local result = add_location(self, ...)
        if References.enabled(self.ui) and self.ui._zen_return_button then
            self.ui._zen_return_button:queue(self.location_stack[#self.location_stack])
        end
        return result
    end
    for _i, name in ipairs({ "onGoBackLink", "onSuspend" }) do
        local original = ReaderLink[name]
        ReaderLink[name] = function(self, ...)
            if self.ui._zen_return_button then self.ui._zen_return_button:hide() end
            if original then return original(self, ...) end
        end
    end
    local read_settings = ReaderLink.onReadSettings
    ReaderLink.onReadSettings = function(self, ...)
        References.applyDefaults(self.ui)
        return read_settings(self, ...)
    end
    local ReaderDictionary = require("apps/reader/modules/readerdictionary")
    local lookup = ReaderDictionary.onLookupWord
    ReaderDictionary.onLookupWord = function(self, ...)
        local highlight = self.ui and self.ui.highlight
        -- Dictionary lookup can finish after the selection menu clears its text.
        self._zen_reference_page = References.enabled(self.ui) and highlight and highlight.selected_text
            and References.selectionPage(highlight) or nil
        return lookup(self, ...)
    end
    local original = ReaderLink.showAsFootnotePopup
    ReaderLink.showAsFootnotePopup = function(self, link, ...)
        if not References.enabled(self.ui) then return original(self, link, ...) end
        local FootnoteWidget = require("ui/widget/footnotewidget")
        local original_new = FootnoteWidget.new
        FootnoteWidget.new = function(class, spec, ...)
            local native = original_new(class, spec, ...)
            local Drawer = require("modules/reader/reference_drawer")
            local ok, drawer = pcall(Drawer.new, Drawer, { ui = self.ui, link = link, footnote = native, plugin = plugin })
            if ok then return drawer end
            require("logger").warn("ZenOS: footnote drawer failed", drawer)
            return native
        end
        local ok, result = pcall(original, self, link, ...)
        FootnoteWidget.new = original_new
        if not ok then error(result) end
        return result
    end
    local close = ReaderLink.onCloseDocument
    ReaderLink.onCloseDocument = function(self, ...)
        References.clear(self.ui)
        if close then return close(self, ...) end
    end
    local dimensions = ReaderLink.onSetDimensions
    ReaderLink.onSetDimensions = function(self, ...)
        local state = self.ui._zen_references
        if state and state.drawer then
            local footnote = state.drawer.footnote ~= nil
            local index = state.drawer.pin_index
            state.drawer:onClose()
            require("ui/uimanager"):nextTick(function()
                if not References.enabled(self.ui) then return end
                if footnote then References.openFootnote(self.ui) else References.openPinned(self.ui, index) end
            end)
        end
        if dimensions then return dimensions(self, ...) end
    end
end
