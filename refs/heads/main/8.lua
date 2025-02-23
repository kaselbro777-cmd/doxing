-- Libraries
local vector        = require "vector"
local csgo_weapons  = require "gamesense/csgo_weapons"
local anti_aim      = require "gamesense/antiaim_funcs"
local trace         = require "gamesense/trace"
local http = require "gamesense/http"
local clipboard     = require "gamesense/clipboard"
local base64 = require "gamesense/base64"
local pui = require "gamesense/pui"
local ffi = require ("ffi")
local c_entity = require('gamesense/entity')
local json = require("json")
local bit = require 'bit'
local steamworks = require('gamesense/steamworks')
local surface = require 'gamesense/surface'

local defer, error, getfenv, setfenv, getmetatable, setmetatable,
ipairs, pairs, next, printf, rawequal, rawset, rawlen, readfile, writefile, require, select,
tonumber, tostring, toticks, totime, type, unpack, pcall, xpcall =
defer, error, getfenv, setfenv, getmetatable, setmetatable,
ipairs, pairs, next, printf, rawequal, rawset, rawlen, readfile, writefile, require, select,
tonumber, tostring, toticks, totime, type, unpack, pcall, xpcall

local filesystem = {} do
    local m, i = "filesystem_stdio.dll", "VFileSystem017"
    local add_search_path        = vtable_bind(m, i, 11, "void (__thiscall*)(void*, const char*, const char*, int)")
    local remove_search_path     = vtable_bind(m, i, 12, "bool (__thiscall*)(void*, const char*, const char*)")

    local get_game_directory = vtable_bind("engine.dll", "VEngineClient014", 36, "const char*(__thiscall*)(void*)")
    filesystem.game_directory = string.sub(ffi.string(get_game_directory()), 1, -5)

    add_search_path(filesystem.game_directory, "ROOT_PATH", 0)
    defer(function () remove_search_path(filesystem.game_directory, "ROOT_PATH") end)

    filesystem.create_directory = vtable_bind(m, i, 22, "void (__thiscall*)(void*, const char*, const char*)")
end

filesystem.create_directory("luminary", "ROOT_PATH")

local texts = {"Мага Сиял, Сияй и ты с Luminary.lua"}

local timer, display_time, is_displaying, random_text, random_text1  = 0, 2, false, ""
 
math.randomseed(math.floor(globals.realtime() * 1000))
random_text = texts[math.random(1, #texts)]

local motion = { base_speed = 6, _list = {} }
motion.new = function(name, new_value, speed, init)
    speed = speed or motion.base_speed
    motion._list[name] = motion._list[name] or (init or 0)
    motion._list[name] = math.lerp(motion._list[name], new_value, speed)
    return motion._list[name]
end

local file_texture = readfile("luminary/Sample photo-fotor-20250217185654.png")
local load_textures = function(data)
    meowhook = renderer.load_png(data, 1024, 1024)
    meowhook_s = renderer.load_png(data, 64, 64)
end

if not file_texture then
    http.get("https://github.com/kaselbro777-cmd/luminary/blob/main/Sample%20photo-fotor-20250217185654.png", function(success, raw)
        if success and string.sub(raw.body, 2, 4) == "PNG" then
            load_textures(raw.body)
            writefile("luminary/Sample photo-fotor-20250217185654.png", raw.body)
        end
    end)
else
    load_textures(file_texture)
end

client.set_event_callback('paint', function()
    local width, height = client.screen_size()
    local alpha_value = motion.new("alpha_value", is_displaying and 145 or 0, 6)
    local text_alpha = motion.new("text_alpha", is_displaying and 255 or 0, 6) 

    local texture_alpha = motion.new("texture_alpha", is_displaying and 255 or 0, 6)

    renderer.rectangle(0, 0, width, height, 0, 0, 0, alpha_value)

    local texture_w, texture_h = 200, 24
    renderer.texture(meowhook, width / 2 - texture_w / 2, height / 2 - texture_h / 2, texture_w, texture_h, 255, 255, 255, texture_alpha, "f")

    local rw, rh = renderer.measure_text(verdana, random_text)
    renderer.text(width / 2 - rw / 2, height / 2 + texture_h / 2 + 10, 255, 255, 255, text_alpha, 0, 0, random_text)

    if is_displaying and globals.realtime() - timer > display_time then
        is_displaying = false
    elseif not is_displaying and timer == 0 then
        timer, is_displaying = globals.realtime(), true
    end
end)


local a = function (...) return ... end

local surface_create_font, surface_get_text_size, surface_draw_text = surface.create_font, surface.get_text_size, surface.draw_text
local verdana = surface_create_font('Verdana', 12, 400, {})
client.exec("Clear")
local sp = {}
sp.one = function (t, r, k) local result = {} for i, v in ipairs(t) do n = k and v[k] or i result[n] = r == nil and i or v[r] end return result end
sp.two = function (t, j)  for i = 1, #t do if t[i] == j then return i end end  end
sp.three = function (t)  local res = {} for i = 1, table.maxn(t) do if t[i] ~= nil then res[#res+1] = t[i] end end return res  end
local gram_create = function(value, count) local gram = { }; for i=1, count do gram[i] = value; end return gram; end
local gram_update = function(tab, value, forced)
    local new_tab = tab or {}
    if forced or new_tab[#new_tab] ~= value then
        _G._G.table.insert(new_tab, value)
        _G.table.remove(new_tab, 1)
    end
    tab = new_tab
end
local get_average = function(tab) local elements, sum = 0, 0; for k, v in pairs(tab) do sum = sum + v; elements = elements + 1; end return sum / elements; end
function get_velocity(player)
    local x,y,z = entity.get_prop(player, "m_vecVelocity")
    if x == nil then return end
    return math.sqrt(x*x + y*y + z*z)
end

function ui.multiReference(tab, groupbox, name)
    local ref1, ref2, ref3 = ui.reference(tab, groupbox, name)
    return { ref1, ref2, ref3 }
end
binds = {
    legMovement = ui.multiReference("AA", "Other", "Leg movement"),
    flenabled = ui.multiReference("AA", "Fake lag", "Enabled"),
    slowmotion = ui.multiReference("AA", "Other", "Slow motion"),
    OSAAA = ui.multiReference("AA", "Other", "On shot anti-aim"),
    AAfake = ui.multiReference("AA", "Other", "Fake peek"),
    fakelag_amount = ui.reference("AA", "Fake lag", "Amount"),
    fakelag_limit = ui.reference("AA", "Fake lag", "Limit"),
    fakelag_variance = ui.reference("AA", "Fake lag", "Variance"),
}

function traverse_table_on(tbl, prefix)
    prefix = prefix or ""
    local stack = {{tbl, prefix}}

    while #stack > 0 do
        local current = _G.table.remove(stack)
        local current_tbl = current[1]
        local current_prefix = current[2]

        for key, value in pairs(current_tbl) do
            local full_key = current_prefix .. key
            if type(value) == "table" then
                _G.table.insert(stack, {value, full_key .. "."})
            else
                ui.set_visible(value, true)
            end
        end
    end
end

function traverse_table(tbl, prefix)
    prefix = prefix or ""
    local stack = {{tbl, prefix}}

    while #stack > 0 do
        local current = _G.table.remove(stack)
        local current_tbl = current[1]
        local current_prefix = current[2]

        for key, value in pairs(current_tbl) do
            local full_key = current_prefix .. key
            if type(value) == "table" then
                _G.table.insert(stack, {value, full_key .. "."})
            else 
                ui.set_visible(value, false)
            end
        end
    end
end

renderer.rounded_rectangle = function(x, y, w, h, r, g, b, a, radius)
    y = y + radius
    local data_circle = {
        {x + radius, y, 180},
        {x + w - radius, y, 90},
        {x + radius, y + h - radius * 2, 270},
        {x + w - radius, y + h - radius * 2, 0},
    }

    local data = {
        {x + radius, y, w - radius * 2, h - radius * 2},
        {x + radius, y - radius, w - radius * 2, radius},
        {x + radius, y + h - radius * 2, w - radius * 2, radius},
        {x, y, radius, h - radius * 2},
        {x + w - radius, y, radius, h - radius * 2},
    }

    for _, data in next, data_circle do
        renderer.circle(data[1], data[2], r, g, b, a, radius, data[3], 0.25)
    end

    for _, data in next, data do
        renderer.rectangle(data[1], data[2], data[3], data[4], r, g, b, a)
    end
end

function lerp(a, b, t)
    return a + (b - a) * t
end

math.max_lerp_low_fps = (1 / 45) * 100
math.lerp = function(start, end_pos, time)
    if start == end_pos then return end_pos end
    local frametime = globals.frametime() * 170
    time = time * math.min(frametime, math.max_lerp_low_fps)
    local val = start + (end_pos - start) * globals.frametime() * time
    return math.abs(val - end_pos) < 0.01 and end_pos or val
end

local motion = { base_speed = 20, _list = {} }
motion.new = function(name, new_value, speed, init)
    speed = speed or motion.base_speed
    motion._list[name] = motion._list[name] or (init or 0)
    motion._list[name] = math.lerp(motion._list[name], new_value, speed)
    return motion._list[name]
end

local data = {
    name = "kasel",
    version = "beta",
    update = "17.02.25",
    steamname = panorama.open("CSGOHud").MyPersonaAPI.GetName(),
}

local groups = {
    main = pui.group("aa", "anti-aimbot angles"),
    fakelag = pui.group("aa", "fake lag"),
    other = pui.group("aa", "other"),
    debug = pui.group("Lua", "A"),
}

menu = {
    main = {
        username = groups.other:label("User › \v" .. data.steamname),
        build = groups.other:label("Version › \v" .. data.version),
        update = groups.other:label("Last Update › \v" .. data.update),
        link = groups.other:button("\vhttps://discord.gg/rFeyaVpj"),
    },
}

local titan = {}

titan.database = {
    configs = ":titan-yaw::configs:",
    locations = ":titan-yaw::locations:"
}


titan.presets = {}

titan.locations     = database.read(titan.database.locations) or {}

titan.antiaim       = {
    states          = {" Default", " Standing", " Moving", " Ducking", " Air", " Air Duck", " Slowwalk", " Use", " Freestanding"},
    state           = " Default"
}

titan.ui            = {
    aa              = {
        state       = {},
        states      = {}
    },
    config         = {},
}

titan.handlers      = {
    ui              = {
        elements    = {},
        config      = {}
    },
    aa              = {
        state       = {}
    },
    rage            = {},
    visuals         = {},
    misc            = {}
}

titan.refs          = {
    aa              = {},
    fakelag         = {},
    rage            = {},
    misc            = {}
}

local screen = vector(client.screen_size())
local center = vector(screen.x/2, screen.y/2)

-- References

titan.refs.aa.master                                            = ui.reference("AA", "Anti-aimbot angles", "Enabled")
titan.refs.aa.yaw_base                                          = ui.reference("AA", "Anti-aimbot angles", "Yaw base")
titan.refs.aa.pitch                                             = ui.reference("AA", "Anti-aimbot angles", "Pitch")
titan.refs.aa.yaw, titan.refs.aa.yaw_offset                     = ui.reference("AA", "Anti-aimbot angles", "Yaw")
titan.refs.aa.yaw_jitter, titan.refs.aa.yaw_jitter_offset       = ui.reference("AA", "Anti-aimbot angles", "Yaw jitter")
    titan.refs.aa.body_yaw, titan.refs.aa.body_yaw_offset           = ui.reference("AA", "Anti-aimbot angles", "Body yaw")
titan.refs.aa.freestanding_body_yaw                             = ui.reference("AA", "Anti-aimbot angles", "Freestanding body yaw")
-- titan.refs.aa.edge_yaw                                          = ui.reference("AA", "Anti-aimbot angles", "Edge yaw")
-- .refs.aa.fake_yaw_limit                                    = ui.reference("AA", "Anti-aimbot angles", "Fake yaw limit")
titan.refs.aa.roll_offset                                       = ui.reference("AA", "Anti-aimbot angles", "Roll")


titan.refs.misc.hide_shots, titan.refs.misc.hide_shots_key      = ui.reference("AA", "Other", "On shot anti-aim")
titan.refs.misc.fakeducking                                     = ui.reference("RAGE", "Other", "Duck peek assist")
titan.refs.misc.legs                                            = ui.reference("AA", "Other", "Leg movement")
titan.refs.misc.slow_motion, titan.refs.misc.slow_motion_key    = ui.reference("AA", "Other", "Slow motion")
titan.refs.misc.menu_color                                      = ui.reference("Misc", "Settings", "Menu color")

titan.refs.rage.double_tap, titan.refs.rage.double_tap_key      = ui.reference("RAGE", "Aimbot", "Double tap")
-- titan.refs.rage.sv_maxusrcmdprocessticks                        = ui.reference("MISC", "Settings", "sv_maxusrcmdprocessticks")
-- titan.refs.rage.holdaim                                         = ui.reference("MISC", "Settings", "sv_maxusrcmdprocessticks_holdaim")
titan.refs.rage.force_bodyaim                                   = ui.reference("RAGE", "Aimbot", "Force body aim")
titan.refs.rage.prefer_bodyaim                                  = ui.reference("RAGE", "Aimbot", "Prefer body aim")
titan.refs.rage.prefer_safepoint                                = ui.reference("RAGE", "Aimbot", "Prefer safe point")
titan.refs.rage.force_safepoint                                 = ui.reference("RAGE", "Aimbot", "Force safe point")
titan.refs.rage.minimum_damage = ui.reference("RAGE", "Aimbot", "Minimum damage")
titan.refs.rage.minimum_damage_override, titan.refs.rage.minimum_damage_override_key = ui.reference("RAGE", "Aimbot", "Minimum damage override")
titan.refs.rage.fs = ui.reference("AA", "Anti-aimbot angles", "Freestanding")

titan.refs.fakelag.limit                                        = ui.reference("AA", "Fake lag", "Limit")
titan.refs.fakelag.type                                         = ui.reference("AA", "Fake lag", "Amount")
titan.refs.fakelag.variance                                     = ui.reference("AA", "Fake lag", "Variance")
titan.refs.fov = ui.reference("Misc", "Miscellaneous", "Override fov")

-- UI handler
titan.handlers.ui.new = function(element, condition, config, callback)
    condition = condition or true
    config = config or false
    callback = callback or function() end

    local update = function()
        for k, v in pairs(titan.handlers.ui.elements) do
            if type(v.condition) == "function" then
                ui.set_visible(v.element, v.condition())
            else
                ui.set_visible(v.element, v.condition)
            end
        end
    end

    table.insert(titan.handlers.ui.elements, { element = element, condition = condition})

    if config then
        table.insert(titan.handlers.ui.config, element)
    end

    ui.set_callback(element, function(value)
        update()
        callback(value)
    end)

    update()

    return element
end

-- Useful Functions
function contains(t, v)
    for i, vv in pairs(t) do
        if vv == v then
            return true
        end
    end
    return false
end

split = function(string, sep)
    local result = {}
    for str in (string):gmatch("([^"..sep.."]+)") do
        table.insert(result, str)
    end
    return result
end

function set_aa_visibility(visible)
    for k, v in pairs(titan.refs.aa) do
        ui.set_visible(v, visible)
    end
end

function get_config(name)
    local database = database.read(titan.database.configs) or {}

    for i, v in pairs(database) do
        if v.name == name then
            return {
                config = v.config,
                index = i
            }
        end
    end

    for i, v in pairs(titan.presets) do
        if v.name == name then
            return {
                config = base64.decode(v.config),
                index = i
            }
        end
    end

    return false
end

function save_config(name)
    local db = database.read(titan.database.configs) or {}
    local config = {}

    if name:match("[^%w]") ~= nil then
        return
    end

    for _, v in pairs(titan.handlers.ui.config) do
        local val = ui.get(v)

        if type(val) == "table" then
            if #val > 0 then
                val = table.concat(val, "|")
            else
                val = nil
            end
        end

        table.insert(config, tostring(val))
    end

    local cfg = get_config(name)

    if not cfg then
        table.insert(db, { name = name, config = table.concat(config, ":") })
    else
        db[cfg.index].config = table.concat(config, ":")
    end

    database.write(titan.database.configs, db)
end

function delete_config(name)
    local db = database.read(titan.database.configs) or {}

    for i, v in pairs(db) do
        if v.name == name then
            table.remove(db, i)
            break
        end
    end

    for i, v in pairs(titan.presets) do
        if v.name == name then
            return false
        end
    end

    database.write(titan.database.configs, db)
end

function get_config_list()
    local database = database.read(titan.database.configs) or {}
    local config = {}
    local presets = titan.presets

    for i, v in pairs(presets) do
        table.insert(config, v.name)
    end

    for i, v in pairs(database) do
        table.insert(config, v.name)
    end

    return config
end

function config_tostring()
    local config = {}
    for _, v in pairs(titan.handlers.ui.config) do
        local val = ui.get(v)
        if type(val) == "table" then
            if #val > 0 then
                val = table.concat(val, "|")
            else
                val = nil
            end
        end
        table.insert(config, tostring(val))
    end

    return table.concat(config, ":")
end

function load_settings(config)
    local type_from_string = function(input)
        if type(input) ~= "string" then return input end

        local value = input:lower()

        if value == "true" then
            return true
        elseif value == "false" then
            return false
        elseif tonumber(value) ~= nil then
            return tonumber(value)
        else
            return tostring(input)
        end
    end

    config = split(config, ":")

    for i, v in pairs(titan.handlers.ui.config) do
        if string.find(config[i], "|") then
            local values = split(config[i], "|")
            ui.set(v, values)
        else
            ui.set(v, type_from_string(config[i]))
        end
    end
end

function export_settings()
    local config = config_tostring()
    local encoded = base64.encode(config)
    clipboard.set(encoded)
end

function import_settings()
    local config = clipboard.get()
    local decoded = base64.decode(config)
    load_settings(decoded)
end

function load_config(name)
    local config = get_config(name)
    load_settings(config.config)
    if name == "*t0ggle" and not build == "Debug" then
        hide_t0g = true
    else
        hide_t0g = false
    end
    return hide_t0g
end

local tickbase_max = 0

defensive_checks = {
    is_defensive_active = function()
        local lp = entity.get_local_player()
        if lp == nil or not entity.is_alive(lp) then return end
        local tickbase = entity.get_prop(lp, 'm_nTickBase')
    
        if math.abs(tickbase - tickbase_max) > globals.tickinterval() * 4096 then
            tickbase_max = 0
        end
    
        local defensive_ticks_left = 0;
    
        if tickbase > tickbase_max then
            tickbase_max = tickbase
        elseif tickbase_max > tickbase then
            defensive_ticks_left = math.min(14, math.max(0, tickbase_max - tickbase - 1))
        end
    
        return tickbase_max and defensive_ticks_left > 2
    end
}

client.set_event_callback("predict_command", defensive_checks.is_defensive_active)

set_invert = false
set_tick = 0
get_invert = function (ref, cmd)
    local me = entity.get_local_player()
    if not me then return end

    if globals.tickcount() > set_tick + ref then
        if cmd.chokedcommands == 0 then
            set_invert = not set_invert
            set_tick = globals.tickcount()
        end
    end

    if globals.tickcount() < set_tick then
        set_tick = globals.tickcount()
    end

    return set_invert
end


titan.ui.aa.master = titan.handlers.ui.new(ui.new_checkbox("AA", "Other", "        Enable \v L U M I N A R Y"))

menu = {
    main = {
        categories_other = groups.other:label("\a333333FF⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯"),
    },
}

titan.ui.tab = titan.handlers.ui.new(ui.new_combobox("AA", "Other", "\v Menu categories L U M I N A R Y", {"  Anti-Aim System", "  Ragebot helper", "  Visual Features", "  Miscellaneous", "  Config System"}), function()
     return ui.get(titan.ui.aa.master) 
end)

titan.ui.aa.anti_backstab = titan.handlers.ui.new(ui.new_checkbox("AA", "Anti-aimbot angles", "\vEnable - \vAnti backstab "), function() return ui.get(titan.ui.tab) == "  Anti-Aim System" and ui.get(titan.ui.aa.master) end)
titan.ui.aa.anti_backstab_distance = titan.handlers.ui.new(ui.new_slider("AA", "Anti-aimbot angles", "\vAnti backstab - \vDistance", 50, 400, 180, true, "u", 1, true), function() return ui.get(titan.ui.tab) == "  Anti-Aim System" and ui.get(titan.ui.aa.master) and ui.get(titan.ui.aa.anti_backstab) end)

titan.ui.aa.fixes = titan.handlers.ui.new(ui.new_checkbox("AA", "Anti-aimbot angles", "\vEnable - \vFixes  "), function() return ui.get(titan.ui.tab) == "  Anti-Aim System" and ui.get(titan.ui.aa.master) end)
titan.ui.aa.hs_fix = titan.handlers.ui.new(ui.new_checkbox("AA", "Anti-aimbot angles", " > \vFixes - \vHideshots   "), function() return ui.get(titan.ui.tab) == "  Anti-Aim System" and ui.get(titan.ui.aa.master) and ui.get(titan.ui.aa.fixes) end)
titan.ui.aa.airstop = titan.handlers.ui.new(ui.new_checkbox("AA", "Anti-aimbot angles", " > \vFixes - \vAir Stop   "), function() return ui.get(titan.ui.tab) == "  Anti-Aim System" and ui.get(titan.ui.aa.master) and ui.get(titan.ui.aa.fixes) end)
titan.ui.aa.legbreak = titan.handlers.ui.new(ui.new_checkbox("AA", "Anti-aimbot angles", " > \vFixes - \vModern Leg Breaker   "), function() return ui.get(titan.ui.tab) == "  Anti-Aim System" and ui.get(titan.ui.aa.master) and ui.get(titan.ui.aa.fixes) end)

calculateGradien = function(color1, color2, text, speed)
    
    local curtime = globals.curtime()
    
    for idx = 0, #text - 1 do  
    local x = idx * 10
    local wave = math.cos(8 * speed * curtime + x / 30)

    local r = lerp(color1[1], color2[1], clamp(wave, 0, 1))
    local g = lerp(color1[2], color2[2], clamp(wave, 0, 1))
    local b = lerp(color1[3], color2[3], clamp(wave, 0, 1))
    local a = color1[4] 

    local color = ('\a%02x%02x%02x%02x'):format(r, g, b, a)
    
    output = output .. color .. text:sub(idx + 1, idx + 1)
    end
end

local rgba_to_hex = function(b, c, d, e)
    return string.format('%02x%02x%02x%02x', b, c, d, e)
end

function lerp(a, b, t)
    return a + (b - a) * t
end

function clamp(x, minval, maxval)
    if x < minval then
        return minval
    elseif x > maxval then
        return maxval
    else
        return x
    end
end

local function text_fade_animation(x, y, speed, color1, color2, text, flag)
    local final_text = ''
    local curtime = globals.curtime()
    for i = 0, #text do
        local x = i * 10  
        local wave = math.cos(8 * speed * curtime + x / 30)
        local color = rgba_to_hex(
            lerp(color1.r, color2.r, clamp(wave, 0, 1)),
            lerp(color1.g, color2.g, clamp(wave, 0, 1)),
            lerp(color1.b, color2.b, clamp(wave, 0, 1)),
            color1.a
        ) 
        final_text = final_text .. '\a' .. color .. text:sub(i, i) 
    end
    
    renderer.text(x, y, color1.r, color1.g, color1.b, color1.a, flag, nil, final_text)
end

local x_ind, y_ind = client.screen_size()
titan.ui.aa.watermark = titan.handlers.ui.new(
    ui.new_checkbox("AA", "Anti-aimbot angles", "        \vEnable - \vWatermark "),
    function()
        return ui.get(titan.ui.tab) == "  Visual Features" and ui.get(titan.ui.aa.master)
    end
)

titan.ui.aa.watermark_color = titan.handlers.ui.new(
    ui.new_color_picker("AA", "Anti-aimbot angles", "        \vWatermark Color"),
    function()
        return ui.get(titan.ui.tab) == "  Visual Features" and ui.get(titan.ui.aa.master) and ui.get(titan.ui.aa.watermark)
    end
)

titan.ui.aa.watermark_style = titan.handlers.ui.new(
    ui.new_combobox("AA", "Anti-aimbot angles", "        \vWatermark Style", {"Default", "Modern", "Legacy", "Branded"}),
    function()
        return ui.get(titan.ui.tab) == "  Visual Features" and ui.get(titan.ui.aa.master) and ui.get(titan.ui.aa.watermark)
    end
)

local function watermark()
    if not ui.get(titan.ui.aa.watermark) then return end

    local r, g, b, a = ui.get(titan.ui.aa.watermark_color)
    local style = ui.get(titan.ui.aa.watermark_style)
    
    if style == "Default" then
        text_fade_animation(x_ind / 2, y_ind - 10, -1, {r = r, g = g, b = b, a = 255}, {r = 150, g = 150, b = 150, a = 255}, "LUMINARY RECODE", "cd-")
    elseif style == "Modern" then
        text_fade_animation(x_ind / 2, y_ind - 20, -1, {r = r, g = g, b = b, a = 255}, {r = 150, g = 150, b = 150, a = 255}, "LUMINARY RECODE", "cd-")
        text_fade_animation(x_ind / 2, y_ind - 10, -1, {r = 255, g = 255, b = 255, a = 255}, {r = 150, g = 150, b = 150, a = 255}, "BUILD: BETA", "cd-")
    elseif style == "Legacy" then
        text_fade_animation(x_ind / 2, y_ind - 10, -1, {r = r, g = g, b = b, a = 255}, {r = 150, g = 150, b = 150, a = 255}, "luminary", "cdb")
    elseif style == "Branded" then
        text_fade_animation(x_ind / 2, y_ind - 10, -1, {r = r, g = g, b = b, a = 255}, {r = 255, g = 255, b = 255, a = 255}, "L U M I N A R Y", "cd")
        renderer.text(x_ind / 2 + renderer.measure_text("cd", "L U M I N A R Y ") + -15, y_ind - 10, 255, 0, 0, 255, "cd", 0, "[ BETA ]")        
    end
end

client.set_event_callback("paint", watermark)

-- Создание чекбокса

titan.ui.aa.scope = titan.handlers.ui.new(
    ui.new_checkbox("AA", "Anti-aimbot angles", "        \vEnable - \vAnimated Scope "),
    function()
        return ui.get(titan.ui.tab) == "  Visual Features" and ui.get(titan.ui.aa.master)
    end
)

-- Слайдеры для FOV и скорости анимации
local animation_fov = ui.new_slider("AA", "Anti-aimbot angles", "› Amount FOV", -40, 70, 0, true, "%", 1)
local animation_speed = ui.new_slider("AA", "Anti-aimbot angles", "› Amount Speed", 0, 30, 0, true, "ms", 0.1)

-- Добавление зависимостей для слайдеров
ui.set_visible(animation_fov, false)
ui.set_visible(animation_speed, false)

ui.set_callback(titan.ui.aa.scope, function()
    local scope_enabled = ui.get(titan.ui.aa.scope)
    ui.set_visible(animation_fov, scope_enabled)
    ui.set_visible(animation_speed, scope_enabled)
end)

-- Получение ссылки на Override FOV
local refs = {
    fov = ui.reference("misc", "miscellaneous", "override fov")
}

-- Переменная для плавного изменения FOV
local zoom = 0

-- Функция плавного изменения значения
local function smooth(a, b, s)
    return a + (b - a) * s
end

-- Обработчик события override_view
client.set_event_callback("override_view", function(v)
    -- Получаем текущее значение Override FOV
    local d_fov = ui.get(titan.refs.fov)

    -- Проверяем, включен ли чекбокс Animated Scope
    if not ui.get(titan.ui.aa.scope) then
        zoom = smooth(zoom, d_fov, 0.05)
        v.fov = zoom
        return
    end

    -- Получаем значение скорости анимации
    local animation_speed = ui.get(animation_speed) / 1000
    local clamped_speed = math.max(0.01, math.min(0.03, animation_speed))

    -- Получаем локального игрока
    local me = entity.get_local_player()
    if not me or not entity.is_alive(me) then
        return
    end

    -- Получаем оружие игрока
    local w = entity.get_player_weapon(me)
    if not w then
        return
    end

    -- Проверяем, находится ли игрок в прицеливании
    local scoped = entity.get_prop(me, "m_bIsScoped") == 1
    if not scoped then
        zoom = smooth(zoom, d_fov, clamped_speed)
        v.fov = zoom
        return
    end

    -- Получаем значение FOV для анимации
    local zoom_offset = ui.get(animation_fov) or 0
    local zoom_level = entity.get_prop(w, "m_zoomLevel") or 0
    local target_fov = d_fov - zoom_offset - (zoom_level == 2 and 45 or 30)
    target_fov = math.max(30, math.min(200, target_fov))

    -- Применяем плавное изменение FOV
    zoom = smooth(zoom, target_fov, clamped_speed)
    v.fov = zoom
end)


titan.ui.aa.damage_indicator = titan.handlers.ui.new(
    ui.new_checkbox("AA", "Anti-aimbot angles", "        \vEnable - \vDamage Indicators "),
    function()
        return ui.get(titan.ui.tab) == "  Visual Features" and ui.get(titan.ui.aa.master)
    end
)

titan.ui.aa.damage_indicator_mode = titan.handlers.ui.new(
    ui.new_combobox("AA", "Anti-aimbot angles", "        \vMode - Damage Indicator ", {"On Bind", "Always"}),
    function()
        return ui.get(titan.ui.tab) == "  Visual Features" and ui.get(titan.ui.aa.master) and ui.get(titan.ui.aa.damage_indicator)
    end
)

titan.ui.aa.damage_indicator_style = titan.handlers.ui.new(
    ui.new_combobox("AA", "Anti-aimbot angles", "        \vStyle - Damage Indicator ", {"Default", "Pixel"}),
    function()
        return ui.get(titan.ui.tab) == "  Visual Features" and ui.get(titan.ui.aa.master) and ui.get(titan.ui.aa.damage_indicator)
    end
)

local function damage_indicator()
    if not ui.get(titan.ui.aa.damage_indicator) then return end

    local sizeX, sizeY = client.screen_size()
    local mode = ui.get(titan.ui.aa.damage_indicator_mode)
    local style = ui.get(titan.ui.aa.damage_indicator_style)

    local main_font = style == "Default" and "d" or "-d"

    local weapon = entity.get_player_weapon(entity.get_local_player())
    if weapon and entity.get_classname(weapon) ~= "CKnife" then
        if mode == "Always" then
            if not (ui.get(titan.refs.rage.minimum_damage_override_key) and ui.get(titan.refs.rage.minimum_damage_override)) then
                renderer.text(sizeX / 2 + 3, sizeY / 2 - 15, 255, 255, 255, 255, main_font, 0, ui.get(titan.refs.rage.minimum_damage))
            else
                renderer.text(sizeX / 2 + 3, sizeY / 2 - 15, 255, 255, 255, 255, main_font, 0, ui.get(titan.refs.rage.minimum_damage_override))
            end
        elseif ui.get(titan.refs.rage.minimum_damage_override_key) and ui.get(titan.refs.rage.minimum_damage_override) and mode == "On Bind" then
            local dmg = ui.get(titan.refs.rage.minimum_damage_override)
            renderer.text(sizeX / 2 + 3, sizeY / 2 - 15, 255, 255, 255, 255, main_font, 0, dmg)
        end
    end
end

client.set_event_callback('paint', damage_indicator)

titan.ui.aa.imdeeiteteleport = titan.handlers.ui.new(ui.new_checkbox("AA", "Anti-aimbot angles", "        \vEnable - \vImmediate Teleport ♺"), function() 
    return ui.get(titan.ui.tab) == "  Ragebot helper" and ui.get(titan.ui.aa.master) 
end)

local checkbox = titan.ui.aa.imdeeiteteleport

local g_quick_peek, g_quick_peek_key = ui.reference('RAGE', 'Other', 'Quick peek assist')
local g_master_switch = checkbox

local g_shot_someone = true

local g_setup_command = function(cmd)
    if g_shot_someone then
        cmd.discharge_pending = true
        g_shot_someone = false
    end
end

local g_aim_fire = function()
    g_shot_someone = ui.get(g_quick_peek) and ui.get(g_quick_peek_key)
end

local g_ui_callback = function()
    local fn = ui.get(g_master_switch) and client.set_event_callback or client.unset_event_callback
  
    fn('setup_command', g_setup_command)
    fn('aim_fire', g_aim_fire)
end

ui.set_callback(checkbox, g_ui_callback)

g_ui_callback()

titan.ui.aa.chat_revealer = titan.handlers.ui.new(ui.new_checkbox("AA", "Anti-aimbot angles", "        \vEnable - \vEnemy chat revealer "), function() 
    return ui.get(titan.ui.tab) == "  Miscellaneous" and ui.get(titan.ui.aa.master) 
end)

local checkbox = titan.ui.aa.chat_revealer

local chat = require "gamesense/chat"
local localize = require "gamesense/localize"

local GameStateAPI = panorama.open().GameStateAPI

local lastChatMessage = {}

local function onPlaySay(e)
    local sender = client.userid_to_entindex(e.userid)
    if not entity.is_enemy(sender) then return end

    if GameStateAPI.IsSelectedPlayerMuted(GameStateAPI.GetPlayerXuidStringFromEntIndex(sender)) then return end

    client.delay_call(0.2, function()
        if lastChatMessage[sender] ~= nil and math.abs(globals.realtime() - lastChatMessage[sender]) < 0.4 then
            return
        end

        local enemyTeamName = entity.get_prop(entity.get_player_resource(), "m_iTeam", sender) == 2 and "T" or "CT"

        local placeName = entity.get_prop(sender, "m_szLastPlaceName")
        local enemyName = entity.get_player_name(sender)
    
        local localizeStr = ("Cstrike_Chat_%s_%s"):format(enemyTeamName, entity.is_alive(sender) and "Loc" or "Dead")
        local msg = localize(localizeStr, {
            s1 = enemyName,
            s2 = e.text,
            s3 = localize(placeName ~= "" and placeName or "UI_Unknown")
        })

        chat.print_player(sender, msg)
    end)
end

local function onPlayChat(e)
    if not entity.is_enemy(e.entity) then return end
    lastChatMessage[e.entity] = globals.realtime()
end

client.set_event_callback("paint", function()
    if ui.get(checkbox) then
        client.set_event_callback("player_say", onPlaySay)
        client.set_event_callback("player_chat", onPlayChat)
    else
        client.unset_event_callback("player_say", onPlaySay)
        client.unset_event_callback("player_chat", onPlayChat)
    end
end)

-- Создание чекбокса Anim Breakers
    titan.ui.aa.anim_breaker = titan.handlers.ui.new(
        ui.new_checkbox("AA", "Anti-aimbot angles", "        \vEnable - \vAnim breakers "),
        function()
            return ui.get(titan.ui.tab) == "  Miscellaneous" and ui.get(titan.ui.aa.master)
        end
    )

    -- Создание элементов интерфейса
    local animation_ground = ui.new_combobox("AA", "Anti-aimbot angles", "  \rGround", {"Static", "Jitter"})
    local animation_value = ui.new_slider("AA", "Anti-aimbot angles", "  \rValue", 0, 10, 5)
    local animation_air = ui.new_combobox("AA", "Anti-aimbot angles", "  \rIn Air", {"Off", "Static"})
    local animation_addons = ui.new_multiselect("AA", "Anti-aimbot angles", "  \rAddons", {"Body Lean", "Smoothing", "Earthquake"})
    local animation_body_lean = ui.new_slider("AA", "Anti-aimbot angles", "Body Lean Value", 0, 100, 0, true, "%", 0.01, {[0] = "Disabled", [35] = "Low", [50] = "Medium", [75] = "High", [100] = "Extreme"})

    -- Скрытие элементов интерфейса по умолчанию
    ui.set_visible(animation_ground, false)
    ui.set_visible(animation_value, false)
    ui.set_visible(animation_air, false)
    ui.set_visible(animation_addons, false)
    ui.set_visible(animation_body_lean, false)

    -- Привязка видимости элементов к чекбоксу
    ui.set_callback(titan.ui.aa.anim_breaker, function()
        local enabled = ui.get(titan.ui.aa.anim_breaker)
        ui.set_visible(animation_ground, enabled)
        ui.set_visible(animation_value, enabled)
        ui.set_visible(animation_air, enabled)
        ui.set_visible(animation_addons, enabled)
        ui.set_visible(animation_body_lean, enabled)
    end)

    -- Функция Anim Breaker
    local function anim_breaker()
        local lp = entity.get_local_player()
        if not lp or not entity.is_alive(lp) then
            return
        end

        local self_index, self_anim_state = c_entity.new(lp), c_entity.new(lp):get_anim_state()
        if not self_anim_state then
            return
        end

        local self_anim_overlay = self_index:get_anim_overlay(12)
        if not self_anim_overlay then
            return
        end

        if math.abs(entity.get_prop(lp, "m_vecVelocity[0]") or 0) >= 3 then
            self_anim_overlay.weight = 1
        end

        local gm, am = ui.get(animation_ground), ui.get(animation_air)
        if gm == "Static" then
            entity.set_prop(lp, "m_flPoseParameter", 1, 0)
            ui.set(reference.lgm, "Always slide")
        elseif gm == "Jitter" then
            entity.set_prop(lp, "m_flPoseParameter", (globals.tickcount() % 4 > 1) and ui.get(animation_value) / 10 or 0, 0)
        else
            entity.set_prop(lp, "m_flPoseParameter", math.random(ui.get(animation_value), 10) / 10, 0)
        end

        if am == "Static" then
            entity.set_prop(lp, "m_flPoseParameter", 1, 6)
        elseif am == "Randomize" then
            entity.set_prop(lp, "m_flPoseParameter", math.random(0, 10) / 10, 6)
        end
    end

    -- Обработчик события pre_render для Anim Breaker
    client.set_event_callback('pre_render', function()
        if ui.get(titan.ui.aa.anim_breaker) then
            anim_breaker()
        end
    end)

    -- Обработчик события pre_render для Addons
    client.set_event_callback("pre_render", function()
        local lp = entity.get_local_player()
        if not lp or not entity.is_alive(lp) then
            return
        end

        local anim_state = c_entity.new(lp):get_anim_state()
        if not anim_state then
            return
        end

        if ui.get(animation_addons, "Body Lean") then
            local overlay = c_entity.new(lp):get_anim_overlay(12)
            if overlay and math.abs(entity.get_prop(lp, "m_vecVelocity[0]")) >= 3 then
                overlay.weight = ui.get(animation_body_lean) / 100
            elseif ui.get(animation_addons, "Smoothing") then
                local overlay_smooth = c_entity.new(lp):get_anim_overlay(2)
                if overlay_smooth then
                    overlay_smooth.weight = 0
                end
            end
        end
    end)

    -- Обработчик события pre_render для Earthquake
    client.set_event_callback("pre_render", function()
        if not ui.get(animation_addons, "Earthquake") then
            return
        end

        local lp = entity.get_local_player()
        if lp then
            local speed = ui.get(animation_body_lean) -- Замените на соответствующий слайдер или значение
            local magnitude = ui.get(animation_value) / 100 -- Замените на соответствующий слайдер или значение
            local indexes = {1, 2, 3} -- Замените на соответствующие индексы
            local state = nil

            if ui.get(animation_addons, "Air-C") and id == 8 then
                state = "Air Crouching"
                speed = speed * 10
                magnitude = magnitude * 10
            elseif ui.get(animation_addons, "Running") and id == 3 then
                state = "Running"
                speed = speed * 10
                magnitude = ui.get(animation_value) / 8
            elseif ui.get(animation_addons, "Air") and id == 7 then
                state = "Air"
                speed = speed * 10
                magnitude = magnitude * 10
            end

            if state then
                for _, index in ipairs(indexes) do
                    local value = math.random(-magnitude * 15, magnitude * 15) / 15
                    for _ = 1, speed do
                        entity.set_prop(lp, "m_flPoseParameter", value, index)
                    end
                end
            end
        end
    end)


titan.ui.aa.clantag = titan.handlers.ui.new(ui.new_checkbox("AA", "Anti-aimbot angles", "        \vEnable - \vClantag "), function() 
    return ui.get(titan.ui.tab) == "  Miscellaneous" and ui.get(titan.ui.aa.master) 
end)

local checkbox = titan.ui.aa.clantag

local function time_to_ticks(time)
	return math_floor(time / globals_tickinterval() + .5)
end

local skeet_tag_name = "titan.xyz (current)"

local clan_tag_prev = ""
local enabled_prev = "Off"

local function gamesense_anim(text, indices)
	local text_anim = "               " .. text .. "                      " 
	local tickinterval = globals_tickinterval()
	local tickcount = globals_tickcount() + time_to_ticks(client_latency())
	local i = tickcount / time_to_ticks(0.3)
	i = math_floor(i % #indices)
	i = indices[i+1]+1

	return string_sub(text_anim, i, i+15)
end

local function run_tag_animation()
	local clan_tag = gamesense_anim("luminary.lua", {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 11, 11, 11, 11, 11, 11, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22})
	if clan_tag ~= clan_tag_prev then
		client_set_clan_tag(clan_tag)
	end
	clan_tag_prev = clan_tag
end

local function on_paint(ctx)
	if ui.get(checkbox) then
		local local_player = entity_get_local_player()
		if local_player ~= nil and (not entity_is_alive(local_player)) and globals_tickcount() % 2 == 0 then
			run_tag_animation()
		end
	elseif enabled_prev == skeet_tag_name then
		client_set_clan_tag("\0")
	end
	enabled_prev = ui.get(checkbox) and skeet_tag_name or "Off"
end
client.set_event_callback("paint", on_paint)

local function on_run_command(e)
	if ui.get(checkbox) then
		if e.chokedcommands == 0 then
			run_tag_animation()
		end
	end
end
client.set_event_callback("run_command", on_run_command)


titan.ui.aa.hitmarker = titan.handlers.ui.new(ui.new_checkbox("AA", "Anti-aimbot angles", "        \vEnable - \vHitmarker "), function() 
    return ui.get(titan.ui.tab) == "  Visual Features" and ui.get(titan.ui.aa.master) 
end)

local checkbox = titan.ui.aa.hitmarker


local queue = {}

local function aim_fire(c)
    if ui.get(checkbox) then
	queue[globals.tickcount()] = {c.x,c.y,c.z, globals.curtime() + 2}
end
end

local function paint(c)
    if ui.get(checkbox) then
	for tick, data in pairs(queue) do
        if globals.curtime() <= data[4] then
            local x1, y1 = renderer.world_to_screen(data[1], data[2], data[3])
            if x1 ~= nil and y1 ~= nil then
               --renderer.circle_outline(x1,y1,255,255,255,255,5,0,1.0,1)
			   renderer.line(x1 - 6,y1,x1 + 6,y1,0,255,255,255)
			   renderer.line(x1,y1 - 6,x1,y1 + 6 ,0,255,0,255)
            end
        end
    end
end
end



client.set_event_callback("aim_fire",aim_fire)
client.set_event_callback("paint",paint)

client.set_event_callback("round_prestart", function()
    queue = {}
end)

titan.ui.aa.state = titan.handlers.ui.new(ui.new_combobox("AA", "Anti-aimbot angles", "Player state", titan.antiaim.states), function() 
    return ui.get(titan.ui.aa.master) and ui.get(titan.ui.tab) == "  Anti-Aim System"
end)

for k, v in pairs(titan.antiaim.states) do
    titan.ui.aa.states[v] = {}

    if v ~= "Default" then
        titan.ui.aa.states[v].master = titan.handlers.ui.new(ui.new_checkbox("AA", "Anti-aimbot angles", "Enable \v" .. v, false), function()
             return ui.get(titan.ui.aa.state) == v and ui.get(titan.ui.aa.master) and ui.get(titan.ui.tab) == "  Anti-Aim System"
        end, true)
    end

    local show = function() return ui.get(titan.ui.aa.state) == v and ui.get(titan.ui.aa.master) and ui.get(titan.ui.tab) == "  Anti-Aim System" and (v == "Default" and true or ui.get(titan.ui.aa.states[v].master)) end

    titan.ui.aa.states[v].pitch                 = titan.handlers.ui.new(ui.new_combobox("AA", "Anti-aimbot angles", "\v" .. v .. " -\aCDCDCDFF" .. " Pitch", {"Off", "Default", "Up", "Down", "Minimal", "Random"}), function() return show() and not hide_t0g end, true)
    titan.ui.aa.states[v].yaw_base              = titan.handlers.ui.new(ui.new_combobox("AA", "Anti-aimbot angles", "\v" .. v .. " -\aCDCDCDFF" .. " Yaw base", {"Local view", "At targets"}), function() return show() and not hide_t0g end, true)
    titan.ui.aa.states[v].yaw                   = titan.handlers.ui.new(ui.new_combobox("AA", "Anti-aimbot angles", "\v" .. v .. " -\aCDCDCDFF" .. " Yaw", {"Off", "180", "Slow", "Spin", "Static", "180 Z", "Crosshair"}), function() return show() and not hide_t0g end, true)
    titan.ui.aa.states[v].yaw_offset_slow       = titan.handlers.ui.new(  ui.new_slider("AA", "Anti-aimbot angles", "\v" .. v .. " -\aCDCDCDFF" .. " Yaw offset \vTick", 0, 14, 0, true, "°"), function() return show() and ui.get(titan.ui.aa.states[v].yaw) == "Slow" and not hide_t0g end, true)
    titan.ui.aa.states[v].yaw_offset_left       = titan.handlers.ui.new(  ui.new_slider("AA", "Anti-aimbot angles", "\v" .. v .. " -\aCDCDCDFF" .. " Yaw offset \vleft", -180, 180, 0, true, "°"), function() return show() and ui.get(titan.ui.aa.states[v].yaw) ~= "Off" and not hide_t0g end, true)
    titan.ui.aa.states[v].yaw_offset_right      = titan.handlers.ui.new(  ui.new_slider("AA", "Anti-aimbot angles", "\v" .. v .. " -\aCDCDCDFF" .. " Yaw offset \vright", -180, 180, 0, true, "°"), function() return show() and ui.get(titan.ui.aa.states[v].yaw) ~= "Off" and not hide_t0g end, true)
    titan.ui.aa.states[v].yaw_jitter            = titan.handlers.ui.new(ui.new_combobox("AA", "Anti-aimbot angles", "\v" .. v .. " -\aCDCDCDFF" .. " Yaw jitter", {"Off", "Offset", "Center", "Random"}), function() return show() and not hide_t0g end, true)
    titan.ui.aa.states[v].yaw_jitter_offset     = titan.handlers.ui.new(  ui.new_slider("AA", "Anti-aimbot angles", "\n" .. v .. " - Yaw jitter", -180, 180, 0, true, "°"), function() return show() and ui.get(titan.ui.aa.states[v].yaw_jitter) ~= "Off" and not hide_t0g end, true)
    titan.ui.aa.states[v].body_yaw              = titan.handlers.ui.new(ui.new_combobox("AA", "Anti-aimbot angles", "\v" .. v .. " -\aCDCDCDFF" .. " Body yaw", {"Off", "Opposite", "Jitter", "Static"}), function() return show() and not hide_t0g end, true)
    titan.ui.aa.states[v].body_yaw_offset       = titan.handlers.ui.new  (ui.new_slider("AA", "Anti-aimbot angles", "\n" .. v .. " - Body yaw offset", -58, 58, 0, true, "°"), function() return show() and ui.get(titan.ui.aa.states[v].body_yaw) ~= "Off" and ui.get(titan.ui.aa.states[v].body_yaw) ~= "Opposite" and not hide_t0g end, true)
    titan.ui.aa.states[v].defensive_enable      = titan.handlers.ui.new(ui.new_checkbox("AA", "Anti-aimbot angles",  "\v" .. v .. " -\aCDCDCDFF" .. "Enable Defensive"),function() return show() and not hide_t0g end, true)
    titan.ui.aa.states[v].defensive_type        = titan.handlers.ui.new(ui.new_combobox("AA", "Anti-aimbot angles", "\v" .. v .. " -\aCDCDCDFF" .. "Defensive Yaw", {"Yaw", "Spin", "Jitter", "Custom"}), function() return show() and not hide_t0g and ui.get(titan.ui.aa.states[v].defensive_enable) end, true)
    titan.ui.aa.states[v].customdfyaw           = titan.handlers.ui.new(  ui.new_slider("AA", "Anti-aimbot angles", "\v" .. v .. " -\aCDCDCDFF" .. " Custom Yaw", -180, 180, 0, true, "°"), function() return show() and not hide_t0g and ui.get(titan.ui.aa.states[v].defensive_type) == "Custom" end, true)
    titan.ui.aa.states[v].customdf_pitch           = titan.handlers.ui.new(  ui.new_slider("AA", "Anti-aimbot angles", "\v" .. v .. " -\aCDCDCDFF" .. " Custom Pitch", -89, 89, 0, true, "°"), function() return show() and not hide_t0g and ui.get(titan.ui.aa.states[v].defensive_type) == "Custom" end, true)
    titan.ui.aa.states[v].customdf_pitch           = titan.handlers.ui.new(  ui.new_slider("AA", "Anti-aimbot angles", "\v" .. v .. " -\aCDCDCDFF" .. " Custom Pitch", -89, 89, 0, true, "°"), function() return show() and not hide_t0g and ui.get(titan.ui.aa.states[v].defensive_type) == "Yaw" end, true)
    titan.ui.aa.states[v].customdf_pitch           = titan.handlers.ui.new(  ui.new_slider("AA", "Anti-aimbot angles", "\v" .. v .. " -\aCDCDCDFF" .. " Custom Pitch", -89, 89, 0, true, "°"), function() return show() and not hide_t0g and ui.get(titan.ui.aa.states[v].defensive_type) == "Spin" end, true)
    titan.ui.aa.states[v].customdf_pitch           = titan.handlers.ui.new(  ui.new_slider("AA", "Anti-aimbot angles", "\v" .. v .. " -\aCDCDCDFF" .. " Custom Pitch", -89, 89, 0, true, "°"), function() return show() and not hide_t0g and ui.get(titan.ui.aa.states[v].defensive_type) == "Jitter" end, true)
    titan.ui.aa.states[v].freestanding_body_yaw = titan.handlers.ui.new(ui.new_checkbox("AA", "Anti-aimbot angles", "\v" .. v .. " -\aCDCDCDFF" .. " Freestanding body yaw", false), function() return show() and ui.get(titan.ui.aa.states[v].body_yaw) ~= "Off" and not hide_t0g end, true)
    titan.ui.aa.states[v].roll                  = titan.handlers.ui.new(  ui.new_slider("AA", "Anti-aimbot angles", "\v" .. v .. " -\aCDCDCDFF" .. " Roll", -50, 50, 0, true, "°"), function() return show() and ui.get(titan.ui.aa.states[v].body_yaw) ~= "Off" and not hide_t0g end, true)
    titan.ui.aa.states[v].bruteforce            = titan.handlers.ui.new(ui.new_checkbox("AA", "Anti-aimbot angles", "\v" .. v .. " -\aCDCDCDFF" .. " Anti bruteforce", false), function() return show() and ui.get(titan.ui.aa.states[v].body_yaw) ~= "Off" and not hide_t0g end, true)end
    titan.ui.aa.config_loaded_lab = titan.handlers.ui.new(ui.new_hotkey("AA", "Anti-aimbot angles", "\vConfig - \aCDCDCDFFt0ggles settings are set to hide AA", true), function() return ui.get(titan.ui.aa.master) and ui.get(titan.ui.tab) == "  Anti-Aim System"  and hide_t0g end)

titan.ui.config.list = titan.handlers.ui.new(ui.new_listbox("AA", "Anti-aimbot angles", "Configs", ""), function() 
    return ui.get(titan.ui.tab) == "  Config System" and ui.get(titan.ui.aa.master)
end)

titan.ui.config.name = titan.handlers.ui.new(ui.new_textbox("AA", "Anti-aimbot angles", "Config name", ""), function() 
    return ui.get(titan.ui.tab) == "  Config System" and ui.get(titan.ui.aa.master)
end)

titan.ui.config.load = titan.handlers.ui.new(ui.new_button("AA", "Anti-aimbot angles", "\vLoad   ⮞  ", function() end), function() 
    return ui.get(titan.ui.tab) == "  Config System" and ui.get(titan.ui.aa.master)
    end)
    
    titan.ui.config.save = titan.handlers.ui.new(ui.new_button("AA", "Anti-aimbot angles", "\vSave  ⮞  ", function() end), function() 
    return ui.get(titan.ui.tab) == "  Config System" and ui.get(titan.ui.aa.master)
    end)
    
    titan.ui.config.delete = titan.handlers.ui.new(ui.new_button("AA", "Anti-aimbot angles", "\vDelete  ⮞  ", function() end), function() 
    return ui.get(titan.ui.tab) == "  Config System" and ui.get(titan.ui.aa.master)
    end)
    
    -- import
    titan.ui.config.import = titan.handlers.ui.new(ui.new_button("AA", "Anti-aimbot angles", "\vImport settings  ⮞  ", function() end), function() 
    return ui.get(titan.ui.tab) == "  Config System" and ui.get(titan.ui.aa.master)
    end)
    
    -- export
    titan.ui.config.export = titan.handlers.ui.new(ui.new_button("AA", "Anti-aimbot angles", "\vExport settings  ⮞  ", function() end), function() 
    return ui.get(titan.ui.tab) == "  Config System" and ui.get(titan.ui.aa.master)
    end)

distance_knife = {}
distance_knife.anti_knife_dist = function (x1, y1, z1, x2, y2, z2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2 + (z2 - z1)^2)
end



titan.handlers.aa.anti_backstab = function()
    if ui.get(titan.ui.aa.anti_backstab) then
        local players = entity.get_players(true)
        local lx, ly, lz = entity.get_prop(entity.get_local_player(), "m_vecOrigin")
        if players == nil then return end
        for i=1, #players do
            local x, y, z = entity.get_prop(players[i], "m_vecOrigin")
            local distance = distance_knife.anti_knife_dist(lx, ly, lz, x, y, z)
            local weapon = entity.get_player_weapon(players[i])
            if entity.get_classname(weapon) == "CKnife" and distance <= ui.get(titan.ui.aa.anti_backstab_distance) then
                ui.set(titan.refs.aa.yaw_offset, 180)
                ui.set(titan.refs.aa.pitch, "Off")
                ui.set(titan.refs.aa.yaw_base, "At targets")
            end
        end
    end
end

function init_database()
    if database.read(titan.database.configs) == nil then
        database.write(titan.database.configs, {})
    end

    local user, token = "aston12421", "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"

    http.get("https://raw.githubusercontent.com/aston12421/titan/main/presets.json?token=", {authorization = {user, token}}, function(success, response)
        if not success then
            print("Failed to get presets")
            return
        end
    
        presets = json.parse(response.body)
        if not presets then return end
    
        for i, preset in pairs(presets.presets) do
            table.insert(titan.presets, { name = "*"..preset.name, config = preset.config})
        end
    
        ui.update(titan.ui.config.list, get_config_list())
    end)
end

init_database()

local ground_ticks = 0

titan.handlers.aa.state.update = function(cmd)
    local me    = entity.get_local_player()
    local flags = entity.get_prop(me, "m_fFlags")
    local vel1, vel2, vel3 = entity.get_prop(me, 'm_vecVelocity')
    local speed = math.floor(math.sqrt(vel1 * vel1 + vel2 * vel2))

    local ducking       = cmd.in_duck == 1
    local air           = ground_ticks < 5
    local walking       = speed >= 2
    local standing      = speed <= 1
    local slow_motion   = ui.get(titan.refs.misc.slow_motion) and ui.get(titan.refs.misc.slow_motion_key)
    local fakeducking   = ui.get(titan.refs.misc.fakeducking)
    ground_ticks = bit.band(flags, 1) == 0 and 0 or (ground_ticks < 5 and ground_ticks + 1 or ground_ticks)

    local state = " Default"
    
    if air and not ducking then
        state = " Air"
    elseif air and ducking then
        state = " Air Duck"
    elseif fakeducking or ducking then
        state = " Ducking"
    elseif slow_motion then
        state = " Slowwalk"
    elseif walking and ducking then
        state = " Lowwalk"
    elseif walking then
        state = " Moving"
    elseif standing then
        state = " Standing"
    else
        state = " Default"
    end

    titan.antiaim.state = state
end

local way3 = 0
local tick_counter = 16

local function should_show_slider(v)
    return not hide_t0g and ui.get(titan.ui.aa.states[v].defensive_type) == "Custom"
end

for v, state_config in pairs(titan.ui.aa.states) do
    titan.ui.aa.states[v].customdf_tick = titan.handlers.ui.new(
        ui.new_slider("AA", "Anti-aimbot angles", "\v" .. v .. " -\aCDCDCDFF" .. " Custom Tick", 0, 16, 0, true, ""),
        function()
            return should_show_slider(v)
        end,
        true
    )
end

function hide_original_menu(state)
    ui.set_visible(titan.refs.aa.master, state)
    ui.set_visible(reference.sw, state)
    ui.set_visible(titan.refs.aa.pitch[1], state)
    ui.set_visible(titan.refs.aa.pitch[2], state)
    ui.set_visible(reference.titan.refs.aa.yaw_base, state)
    ui.set_visible(titan.refs.aa.yaw[1], state)
    ui.set_visible(titan.refs.aa.yaw_offset[2], state)
    ui.set_visible(titan.refs.aa.yaw_jitter[1], state)
    ui.set_visible(titan.refs.aa.roll_offset[1], state)
    ui.set_visible(titan.refs.aa.yaw_jitter[2], state)
    ui.set_visible(titan.refs.aa.body_yaw[1], state)
    ui.set_visible(titan.refs.aa.body_yaw_offset[2], state)
    ui.set_visible(titan.refs.aa.freestanding_body_yaw, state)
    ui.set_visible(reference.edgeyaw, state)
    ui.set_visible(reference.fkp, state)
    ui.set_visible(reference.osaaa, state)
    ui.set_visible(reference.lgm, state)
    ui.set_visible(reference.fke, state)
    ui.set_visible(reference.fkl, state)
    ui.set_visible(reference.fkv, state)
    ui.set_visible(reference.fk, state)
end

client.set_event_callback("setup_command", function(c)
    local state = titan.antiaim.state

    if state ~= " Default" and not ui.get(titan.ui.aa.states[state].master) then
        state = " Default"
    end

    local state_config = titan.ui.aa.states[state]
    local side = get_invert(ui.get(state_config.yaw_offset_slow), c)

    local function set_ui_refs(refs, config)
        ui.set(refs.pitch, ui.get(config.pitch))
        ui.set(refs.yaw_base, ui.get(config.yaw_base))
        ui.set(refs.yaw_jitter, ui.get(config.yaw_jitter))
        ui.set(refs.yaw_jitter_offset, ui.get(config.yaw_jitter_offset))
        ui.set(refs.body_yaw, ui.get(config.body_yaw))
        ui.set(refs.freestanding_body_yaw, ui.get(config.freestanding_body_yaw))
        ui.set(refs.roll_offset, ui.get(config.roll))
    end

    set_ui_refs(titan.refs.aa, state_config)

    local function handle_slow_mode(side, config)
        if ui.get(config.yaw) == "Slow" then
            local yaw_offset = side and ui.get(config.yaw_offset_left) or ui.get(config.yaw_offset_right)
            yaw_offset = math.max(-180, math.min(180, yaw_offset))
            ui.set(titan.refs.aa.yaw_offset, yaw_offset)
            ui.set(config.body_yaw, "Static")
            
            local body_yaw_offset = side and 
                globals.tickcount() % ui.get(config.yaw_offset_slow) < ui.get(config.yaw_offset_slow) / 2 and 
                -ui.get(config.body_yaw_offset) or 
                ui.get(config.body_yaw_offset)
            body_yaw_offset = math.max(-180, math.min(180, body_yaw_offset))
            
            ui.set(titan.refs.aa.body_yaw_offset, body_yaw_offset)
        end
    end

    handle_slow_mode(side, state_config)

    local function set_offsets(side, config)
        local yaw_offset = side and ui.get(config.yaw_offset_left) or ui.get(config.yaw_offset_right)
        local body_yaw_offset = side and -ui.get(config.body_yaw_offset) or ui.get(config.body_yaw_offset)
        
        yaw_offset = math.max(-180, math.min(180, yaw_offset))
        body_yaw_offset = math.max(-180, math.min(180, body_yaw_offset))
        
        ui.set(titan.refs.aa.yaw_offset, yaw_offset)
        ui.set(titan.refs.aa.body_yaw_offset, body_yaw_offset)
        ui.set(titan.refs.aa.body_yaw, ui.get(config.body_yaw))
    end

    set_offsets(side, state_config)
end)

local defer, error, getfenv, setfenv, getmetatable, setmetatable,
ipairs, pairs, next, printf, rawequal, rawset, rawlen, readfile, writefile, require, select,
tonumber, tostring, toticks, totime, type, unpack, pcall, xpcall =
defer, error, getfenv, setfenv, getmetatable, setmetatable,
ipairs, pairs, next, printf, rawequal, rawset, rawlen, readfile, writefile, require, select,
tonumber, tostring, toticks, totime, type, unpack, pcall, xpcall

local filesystem = {} do
    local m, i = "filesystem_stdio.dll", "VFileSystem017"
    local add_search_path        = vtable_bind(m, i, 11, "void (__thiscall*)(void*, const char*, const char*, int)")
    local remove_search_path     = vtable_bind(m, i, 12, "bool (__thiscall*)(void*, const char*, const char*)")

    local get_game_directory = vtable_bind("engine.dll", "VEngineClient014", 36, "const char*(__thiscall*)(void*)")
    filesystem.game_directory = string.sub(ffi.string(get_game_directory()), 1, -5)

    add_search_path(filesystem.game_directory, "ROOT_PATH", 0)
    defer(function () remove_search_path(filesystem.game_directory, "ROOT_PATH") end)

    filesystem.create_directory = vtable_bind(m, i, 22, "void (__thiscall*)(void*, const char*, const char*)")
end

filesystem.create_directory("luminary", "ROOT_PATH")

local texts = {"Мага Сиял, Сияй и ты с Luminary.lua"}
local timer, display_time, is_displaying, random_text = 0, 2, false, ""
 
math.randomseed(math.floor(globals.realtime() * 1000))
random_text = texts[math.random(1, #texts)]

local motion = { base_speed = 6, _list = {} }
motion.new = function(name, new_value, speed, init)
    speed = speed or motion.base_speed
    motion._list[name] = motion._list[name] or (init or 0)
    motion._list[name] = math.lerp(motion._list[name], new_value, speed)
    return motion._list[name]
end

local file_texture = readfile("luminary/Sample photo-fotor-20250217185654.png")
local load_textures = function(data)
    meowhook = renderer.load_png(data, 1024, 1024)
    meowhook_s = renderer.load_png(data, 64, 64)
end

if not file_texture then
    http.get("https://github.com/kaselbro777-cmd/luminary/blob/main/Sample%20photo-fotor-20250217185654.png", function(success, raw)
        if success and string.sub(raw.body, 2, 4) == "PNG" then
            load_textures(raw.body)
            writefile("luminary/Sample photo-fotor-20250217185654.png", raw.body)
        end
    end)
else
    load_textures(file_texture)
end

ui.update(titan.ui.config.list, get_config_list())
ui.set(titan.ui.config.name, #database.read(titan.database.configs) == 0 and "" or database.read(titan.database.configs)[ui.get(titan.ui.config.list)+1].name)
ui.set_callback(titan.ui.config.list, function(value)
    local name = ""

    local configs = get_config_list()

    name = configs[ui.get(value)+1] or ""

    ui.set(titan.ui.config.name, name)
end)

ui.set_callback(titan.ui.config.load, function()
    local name = ui.get(titan.ui.config.name)
    if name == "" then return end

    load_config(name)
end)

ui.set_callback(titan.ui.config.save, function()
    local name = ui.get(titan.ui.config.name)
    if name == "" then return end

    if name:match("[^%w]") ~= nil then
        return
    end
    save_config(name)
end)

ui.set_callback(titan.ui.config.delete, function()
    local name = ui.get(titan.ui.config.name)
    if name == "" then return end

    if delete_config(name) == false then
        ui.update(titan.ui.config.list, get_config_list())
        return
    end
    delete_config(name)
end)

ui.set_callback(titan.ui.config.import, function()
    import_settings()
end)

ui.set_callback(titan.ui.config.export, function()
    export_settings(name)
end)

set_aa_visibility(false)

client.set_event_callback("shutdown", function()
    set_aa_visibility(true)
end)

client.set_event_callback("setup_command", function(cmd)
    if not ui.get(titan.ui.aa.master) then return end
    titan.handlers.aa.state.update(cmd)
    titan.handlers.aa.anti_backstab()
end)

client.set_event_callback("shutdown", function()
    local locations = database.read(titan.database.locations) or {}
    database.write(titan.database.locations, locations)
end)

