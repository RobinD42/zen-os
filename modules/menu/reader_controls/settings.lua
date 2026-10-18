local Event = require("ui/event")
local util = require("util")
local _ = require("gettext")

local M = {}

function M.group(reader)
    return reader.config and reader.config.options and reader.config.options.prefix
        or (reader.rolling and "copt" or "kopt")
end

function M.options(reader)
    local options = {}
    for _i, panel in ipairs(reader.config and reader.config.options or {}) do
        for _j, option in ipairs(panel.options or {}) do
            options[option.name] = option
        end
    end
    return options
end

function M.panel(reader, icon)
    for _i, panel in ipairs(reader.config and reader.config.options or {}) do
        if panel.icon == icon then return panel end
    end
end

function M.available(reader, option)
    if not option or option.show == false then return false end
    local configurable = reader.document.configurable
    return (not option.show_func or option.show_func(configurable, reader.document))
        and (not option.enabled_func or option.enabled_func(configurable, reader.document))
end

function M.label(reader, option)
    if option.name == "h_page_margins" then return _("Left/Right Margins") end
    if option.name == "sync_t_b_page_margins" then return _("Sync Top/Bottom Margins") end
    return option.name_text_func and option.name_text_func(reader.document.configurable)
        or option.name_text or option.alt_name_text or option.name:gsub("_", " ")
end

function M.syncedMargins(reader)
    if reader.typeset and reader.typeset.sync_t_b_page_margins ~= nil then
        return reader.typeset.sync_t_b_page_margins == true
    end
    return reader.document.configurable.sync_t_b_page_margins == 1
end

function M.valueText(reader, option, value)
    if option.name == "font_base_weight" then return tostring(400 + value * 100) end
    if option.name == "h_page_margins" and type(value) == "table" and value[1] == value[2] then
        return tostring(value[1])
    end
    if option.show_true_value_func then return option.show_true_value_func(value) end
    local params = option.more_options_param or {}
    if params.value_table then return tostring(params.value_table[value + (params.value_table_shift or 0)] or value) end
    for i, candidate in ipairs(option.values or {}) do
        if util.tableEquals and type(value) == "table" and type(candidate) == "table"
                and util.tableEquals(value, candidate)
                or candidate == value then
            local label = (option.labels or option.toggle or option.item_text or {})[i]
            if label ~= nil then return tostring(label) end
            break
        end
    end
    if type(value) == "table" then
        local parts = {}
        for _i, part in ipairs(value) do parts[#parts + 1] = tostring(part) end
        return table.concat(parts, " / ")
    end
    return tostring(value)
end

function M.apply(reader, name, value, callback)
    if name == "font_face" then
        reader:handleEvent(Event:new("SetFont", value))
        if callback then callback() end
        return true
    end
    local option = M.options(reader)[name]
    if not option then return false end
    local params = option.more_options_param
    if params and params.names and type(value) == "table" then
        for i, key in ipairs(params.names) do reader:handleEvent(Event:new("ConfigChange", key, value[i])) end
        reader:handleEvent(Event:new(params.event or option.event, value, callback))
        return true
    end
    local arg = value
    for i, candidate in ipairs(option.values or {}) do
        if candidate == value then
            if option.args then arg = option.args[i] end
            break
        end
    end
    reader:handleEvent(Event:new("ConfigChange", name, util.tableDeepCopy(value)))
    if option.event then
        reader:handleEvent(Event:new(option.event, arg, callback))
    elseif callback then
        callback()
    end
    return true
end

function M.preview(reader, name, value)
    local input = require("device").input
    local inhibit, inhibit_until = input.inhibitInput, input.inhibitInputUntil
    -- Native rerendering resets touch detection; keep the current drag alive.
    input.inhibitInput = function() end
    input.inhibitInputUntil = input.inhibitInput
    local ok, result = pcall(M.apply, reader, name, value)
    input.inhibitInput, input.inhibitInputUntil = inhibit, inhibit_until
    if not ok then error(result) end
    return result
end

-- UI-only slider positions are integers; native values can be fractional or paired.
function M.slider(reader, name, visible_presets)
    local options = M.options(reader)
    local option = options[name]
    if not M.available(reader, option) then return end
    local conf = reader.document.configurable
    local value = option.current_func and option.current_func() or conf[name]
    if value == nil then return end
    local fine = name == "font_size" and options.font_fine_tune
    local params = fine and fine.more_options_param or option.more_options_param or {}
    local values = option.values or {}
    local function scalar(v) return type(v) == "table" and (v[1] + v[2]) / 2 or v end
    local position, decode, advance, maximum
    if fine or #values < 2 then
        local lo = params.value_min or values[1]
        local hi = params.value_max or values[#values]
        local step = fine and fine.args and math.abs(fine.args[1]) or params.value_step or 1
        if type(lo) ~= "number" or type(hi) ~= "number" or hi <= lo then return end
        maximum = math.floor((hi - lo) / step + 0.5)
        position = function(v) return math.max(0, math.min(maximum, (scalar(v) - lo) / step)) end
        decode = function(index)
            local v = tonumber(string.format("%.6f", math.min(hi, lo + index * step)))
            return name == "h_page_margins" and { v, v } or v
        end
        advance = function(current, direction)
            local v = tonumber(string.format("%.6f", math.max(lo, math.min(hi, scalar(current) + direction * step))))
            return name == "h_page_margins" and { v, v } or v
        end
    else
        for _i, v in ipairs(values) do if type(scalar(v)) ~= "number" then return end end
        maximum = #values - 1
        position = function(v)
            v = scalar(v)
            for i = 1, #values - 1 do
                local a, b = scalar(values[i]), scalar(values[i + 1])
                if a ~= b and v >= math.min(a, b) and v <= math.max(a, b) then
                    return i - 1 + (v - a) / (b - a)
                end
            end
            return math.abs(v - scalar(values[1])) <= math.abs(v - scalar(values[#values])) and 0 or maximum
        end
        decode = function(index) return util.tableDeepCopy(values[index + 1]) end
        advance = function(current, direction)
            local sign = (scalar(values[#values]) > scalar(values[1]) and 1 or -1) * direction
            for i = direction > 0 and 1 or #values, direction > 0 and #values or 1, direction do
                if (scalar(values[i]) - scalar(current)) * sign > 0.000001 then
                    return util.tableDeepCopy(values[i])
                end
            end
            return util.tableDeepCopy(current)
        end
    end
    local default = G_reader_settings:readSetting(M.group(reader) .. "_" .. name)
    if default == nil then default = option.default_value end
    local current = position(value)
    local default_position = default ~= nil and position(default) or nil
    local minimum, visible_maximum = 0, maximum
    if #values >= 2 then
        local anchor, center = default_position or current, 1
        for i = 2, #values do
            if math.abs(position(values[i]) - anchor) < math.abs(position(values[center]) - anchor) then center = i end
        end
        local count = visible_presets or 5
        local first = math.max(1, math.min(#values - count + 1, center - math.floor(count / 2)))
        minimum = math.min(position(values[first]), math.floor(current), math.floor(anchor))
        visible_maximum = math.max(position(values[math.min(#values, first + count - 1)]), math.ceil(current), math.ceil(anchor))
    end
    return {
        option = option,
        value = current,
        default_value = default_position,
        value_min = minimum,
        value_max = visible_maximum,
        position = position,
        decode = decode,
        advance = advance,
    }
end

function M.defaults(reader)
    local rows = {}
    local conf = reader.document.configurable
    local prefix = M.group(reader)
    for name, option in pairs(M.options(reader)) do
        local value = conf[name]
        if value ~= nil and option.default_value ~= nil and not name:find("fine_tune", 1, true) then
            rows[#rows + 1] = {
                key = prefix .. "_" .. name,
                label = M.label(reader, option),
                value = util.tableDeepCopy(value),
                display = M.valueText(reader, option, value),
            }
        end
    end
    if reader.font then
        rows[#rows + 1] = { key = "cre_font", label = _("Font"),
            value = reader.font.font_face, display = reader.font.font_face }
    end
    if prefix == "copt" then
        local typography = reader.typography or {}
        local extras = {
            { key = reader.document.is_fb2 and "copt_fb2_css" or "copt_css", label = _("Style sheet"),
                value = reader.typeset and reader.typeset.css },
            { key = "cre_font_family_fonts", label = _("Font-family fonts"),
                value = reader.font and reader.font.font_family_fonts },
            { key = "text_lang_default", label = _("Typography language"), value = typography.text_lang_tag },
        }
        local typography_labels = {
            text_lang_embedded_langs = _("Embedded language tags"), hyphenation = _("Hyphenation"),
            hyph_trust_soft_hyphens = _("Trust soft hyphens"), hyph_soft_hyphens_only = _("Soft hyphens only"),
            hyph_force_algorithmic = _("Force algorithmic hyphenation"), floating_punctuation = _("Floating punctuation"),
        }
        for _i, key in ipairs({ "text_lang_embedded_langs", "hyphenation", "hyph_trust_soft_hyphens",
                "hyph_soft_hyphens_only", "hyph_force_algorithmic", "floating_punctuation" }) do
            extras[#extras + 1] = { key = key, label = typography_labels[key], value = typography[key] }
        end
        if reader.rolling then
            extras[#extras + 1] = { key = "hide_nonlinear_flows", label = _("Hide non-linear fragments"),
                value = reader.rolling.hide_nonlinear_flows }
            extras[#extras + 1] = { key = "cre_partial_rerendering", label = _("Enable partial renderings"),
                value = reader.rolling.partial_rerendering }
        end
        for _i, row in ipairs(extras) do
            if row.value ~= nil then
                row.value = util.tableDeepCopy(row.value)
                row.display = type(row.value) == "table" and _("Current book") or tostring(row.value)
                rows[#rows + 1] = row
            end
        end
    end
    table.sort(rows, function(a, b) return a.label < b.label end)
    return rows
end

function M.saveDefaults(reader, selected, store)
    store = store or G_reader_settings
    local count = 0
    for _i, row in ipairs(M.defaults(reader)) do
        if selected == true or selected[row.key] then
            store:saveSetting(row.key, util.tableDeepCopy(row.value))
            count = count + 1
        end
    end
    if count > 0 and store.flush then store:flush() end
    return count
end

return M
