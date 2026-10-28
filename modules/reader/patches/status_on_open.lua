local function apply_status_on_open()
    local plugin = rawget(_G, "__ZEN_UI_PLUGIN")
    local ReaderUI = require("apps/reader/readerui")
    if ReaderUI._zen_new_status_on_open_patched then return end
    ReaderUI._zen_new_status_on_open_patched = true

    local book_status = require("common/book_status")
    local orig_onReaderReady = ReaderUI.onReaderReady

    function ReaderUI:onReaderReady(...)
        if orig_onReaderReady then
            orig_onReaderReady(self, ...)
        end
        local doc_settings = self.doc_settings
        local file = doc_settings and doc_settings.data and doc_settings.data.doc_path
        local summary = type(doc_settings and doc_settings.readSetting) == "function"
            and doc_settings:readSetting("summary") or {}
        local was_tbr = false
        if file then
            pcall(function()
                local TBRIndex = require("common/tbr_index")
                was_tbr = TBRIndex.isExplicit(file)
                if was_tbr then TBRIndex.setExplicit(file, false) end
            end)
        end
        local was_on_hold = summary.status == "abandoned"
        if was_tbr or was_on_hold then
            summary.status = "reading"
            require("apps/filemanager/filemanagerutil").saveSummary(doc_settings, summary)
            require("ui/widget/booklist").setBookInfoCacheProperty(file, "status", "reading")
            book_status.invalidate(file)
        end
        local acknowledged = book_status.acknowledgeNewVersion(doc_settings)
        if (was_tbr or was_on_hold or acknowledged)
                and type(doc_settings.flush) == "function" then
            doc_settings:flush()
        end
        pcall(function()
            if file then require("common/tbr_index").refreshPath(file, doc_settings) end
        end)
        local meta = plugin and plugin.config and plugin.config._meta
        if type(meta) == "table" and meta.reader_defaults_apply_on_next_open == true then
            local ok_defaults, applied = pcall(function()
                return require("common/reader_defaults").applyDeferredToReader(self)
            end)
            if ok_defaults and applied == true then
                meta.reader_defaults_apply_on_next_open = false
                plugin:saveConfig()
            end
        end
        if self.rolling and self.typeset and not doc_settings:isTrue("zen_vertical_margins_migrated")
                and (doc_settings:readSetting("copt_t_page_margin") ~= nil
                    or doc_settings:readSetting("copt_b_page_margin") ~= nil) then
            local ReaderDefaults = require("common/reader_defaults")
            if ReaderDefaults.isZenPreset(require("config/preset_store").getActivePreset("reader")) then
                local configurable = self.document.configurable
                configurable.t_page_margin = ReaderDefaults.DEFAULT_VERTICAL_MARGIN
                configurable.b_page_margin = ReaderDefaults.DEFAULT_VERTICAL_MARGIN
                self.typeset:onSetPageTopAndBottomMargin({ configurable.t_page_margin, configurable.b_page_margin })
                doc_settings:saveSetting("zen_vertical_margins_migrated", true)
                self:saveSettings()
            end
        end
        -- Default to synced T/B margins once per book when they're already equal; later toggles stick.
        if self.rolling and self.typeset and not doc_settings:isTrue("zen_margin_sync_defaulted") then
            local configurable = self.document.configurable
            if configurable.t_page_margin == configurable.b_page_margin then
                configurable.sync_t_b_page_margins = 1
                self.typeset.sync_t_b_page_margins = true
            end
            doc_settings:saveSetting("zen_margin_sync_defaulted", true)
        end
    end
end

return apply_status_on_open
