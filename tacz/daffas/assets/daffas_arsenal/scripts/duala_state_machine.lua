-- 脚本的位置是 "{命名空间}:{路径}"，那么 require 的格式为 "{命名空间}_{路径}"
-- 注意！require 取得的内容不应该被修改，应仅调用
local default = require("daffas_arsenal_default_daffas_state_machine")
local STATIC_TRACK_LINE = default.STATIC_TRACK_LINE
local MAIN_TRACK = default.MAIN_TRACK
local main_track_states = default.main_track_states
local static_track_top = default.static_track_top
local GUN_KICK_TRACK_LINE = default.GUN_KICK_TRACK_LINE
local gun_kick_state = default.gun_kick_state

local inspect_state = setmetatable({}, {__index = main_track_states.inspect})
local idle_state = setmetatable({}, {__index = main_track_states.idle})

-- 相当于 obj.value++
local function increment(obj)
    obj.value = obj.value + 1
    return obj.value - 1
end

local FIRE_MODE_TRACK = increment(static_track_top)
local SWITCH_MODE_TRACK = increment(static_track_top)

-- 检查当前是否还有弹药
local function isNoAmmo(context)
    return (not context:hasBulletInBarrel()) and (context:getAmmoCount() <= 0)
end

local function runReloadAnimation(context)
    local track = context:getTrack(STATIC_TRACK_LINE, MAIN_TRACK)
    local ext = context:getMagExtentLevel()
    if (isNoAmmo(context)) then
        if (ext == 0) then
            context:runAnimation("reload_empty", track, false, PLAY_ONCE_STOP, 0.2)
        elseif (ext == 1) then
            context:runAnimation("reload_empty_xmag_1", track, false, PLAY_ONCE_STOP, 0.2)
        elseif (ext == 2) then
            context:runAnimation("reload_empty_xmag_2", track, false, PLAY_ONCE_STOP, 0.2)
        elseif (ext == 3) then
            context:runAnimation("reload_empty_xmag_3", track, false, PLAY_ONCE_STOP, 0.2)
        else
            context:runAnimation("reload_empty", track, false, PLAY_ONCE_STOP, 0.2)
        end
    else
        if (ext == 0) then
            context:runAnimation("reload_tactical", track, false, PLAY_ONCE_STOP, 0.2)
        elseif (ext == 1) then
            context:runAnimation("reload_tactical_xmag_1", track, false, PLAY_ONCE_STOP, 0.2)
        elseif (ext == 2) then
            context:runAnimation("reload_tactical_xmag_2", track, false, PLAY_ONCE_STOP, 0.2)
        elseif (ext == 3) then
            context:runAnimation("reload_tactical_xmag_3", track, false, PLAY_ONCE_STOP, 0.2)
        else
            context:runAnimation("reload_tactical", track, false, PLAY_ONCE_STOP, 0.2)
        end
    end
end

local function runInspectAnimation(context)
    local track = context:getTrack(STATIC_TRACK_LINE, MAIN_TRACK)
    local ext = context:getMagExtentLevel()
    if (isNoAmmo(context)) then
        if (ext == 0) then
            context:runAnimation("inspect_empty", track, false, PLAY_ONCE_STOP, 0.2)
        elseif (ext == 1) then
            context:runAnimation("inspect_empty", track, false, PLAY_ONCE_STOP, 0.2)
        elseif (ext == 2) then
            context:runAnimation("inspect_empty", track, false, PLAY_ONCE_STOP, 0.2)
        elseif (ext == 3) then
            context:runAnimation("inspect_empty_xmag_3", track, false, PLAY_ONCE_STOP, 0.2)
        else
            context:runAnimation("inspect_empty", track, false, PLAY_ONCE_STOP, 0.2)
        end
    else
        if (ext == 0) then
            context:runAnimation("inspect", track, false, PLAY_ONCE_STOP, 0.2)
        elseif (ext == 1) then
            context:runAnimation("inspect_xmag_12", track, false, PLAY_ONCE_STOP, 0.2)
        elseif (ext == 2) then
            context:runAnimation("inspect_xmag_12", track, false, PLAY_ONCE_STOP, 0.2)
        elseif (ext == 3) then
            context:runAnimation("inspect_xmag_3", track, false, PLAY_ONCE_STOP, 0.2)
        else
            context:runAnimation("inspect", track, false, PLAY_ONCE_STOP, 0.2)
        end
    end
end

-- ========== 27-ROUND MAG, BULLET-BASED SHOOT SYSTEM ==========

local shoot_by_bullet = {}
for i = 1, 27 do
    shoot_by_bullet[i] = "shoot_" .. tostring(i)
end

local shoot_last_animation = "shoot_last"

local shoot_state = setmetatable({}, { __index = gun_kick_state })

function shoot_state.transition(this, context, input)
    if input ~= INPUT_SHOOT then return nil end

    local fireMode = context:getFireMode()
    if fireMode ~= SEMI and fireMode ~= AUTO and fireMode ~= BURST then return nil end

    -- ===== Get the actual gun kick track =====
    local track = context:findIdleTrack(GUN_KICK_TRACK_LINE, false)

    -- ===== Ammo calculation =====
    local mag = context:getAmmoCount() or 0
    local chambered = context:hasBulletInBarrel() and true or false
    local total_before = mag + (chambered and 1 or 0)

    if total_before <= 0 then
        return nil
    end

    -- ===== Last shot =====
    if (total_before - 1) == 0 then
        context:runAnimation("last_shoot", context:getTrack(STATIC_TRACK_LINE, BOLT_CAUGHT_TRACK), true, PLAY_ONCE_HOLD, 0)
        context:runAnimation(shoot_last_animation, track, true, PLAY_ONCE_STOP, 0)
        context:runAnimation("last_shoot", context:getTrack(STATIC_TRACK_LINE, MAIN_TRACK), true, PLAY_ONCE_HOLD, 0)
        return nil
    end

    -- ===== Normal shoot (27 → 1) =====
    -- Map ammo 27 → shoot_27, 1 → shoot_1
    local animIndex = math.max(1, math.min(27, mag))
    local anim = shoot_by_bullet[animIndex] or "shoot_1"

    context:runAnimation(anim, track, true, PLAY_ONCE_STOP, 0)
    return nil
end






-- Bolt catch after empty
-- === bolt / bullet visual state (replaces fragile idle-based bolt logic) ===
local BOLT_CAUGHT_TRACK = default.BOLT_CAUGHT_TRACK
local bolt_caught_states = default.bolt_caught_states

local normal_bolt_states = setmetatable({}, { __index = bolt_caught_states.normal })
local caught_bolt_states  = setmetatable({}, { __index = bolt_caught_states.bolt_caught })

-- entry: start a dedicated 'bullet_state' animation on the bolt track
function normal_bolt_states.entry(this, context)
    local track = context:getTrack(STATIC_TRACK_LINE, BOLT_CAUGHT_TRACK)
    context:runAnimation("bullet_state", track, false, PLAY_ONCE_STOP, 0)
    return this.bolt_caught_states.normal
end

local function isNoAmmoSimple(context)
    -- use whatever ammo semantics you prefer here (chambered handled elsewhere)
    return (context:getAmmoCount() or 0) <= 0
end

function normal_bolt_states.update(this, context)
    if isNoAmmoSimple(context) then
        context:trigger(this.INPUT_BOLT_CAUGHT)
        return
    end

    local track = context:getTrack(STATIC_TRACK_LINE, BOLT_CAUGHT_TRACK)
    local ammo = context:getAmmoCount() or 0
    local maxAmmo = context:getMaxAmmoCount() or 1
    -- progress goes from 0..1; adjust mapping if your bullet_state expects different
    local progress = 1 - (ammo / maxAmmo)
    context:setAnimationProgress(track, progress, false)
end

function caught_bolt_states.update(this, context)
    if (not isNoAmmoSimple(context)) then
        context:trigger(this.INPUT_BOLT_NORMAL)
    end
end

-- Inject the override into the module table later (M will pick this up)
-- === end bolt visual override ===


-- === single, safe idle transition (input handling only) ===
function idle_state.transition(this, context, input)
    -- INPUT_RELOAD: run reload animations and fall back to the parent's idle state
    if (input == INPUT_RELOAD) then
        runReloadAnimation(context)
        return main_track_states.idle
    end

    -- INPUT_PUT_AWAY: play put_away on MAIN_TRACK and go to final
    if (input == INPUT_PUT_AWAY) then
        local put_away_time = context:getPutAwayTime()
        local track_main = context:getTrack(STATIC_TRACK_LINE, MAIN_TRACK)
        context:stopAnimation(context:getTrack(STATIC_TRACK_LINE, SWITCH_MODE_TRACK))
        context:runAnimation("put_away", track_main, false, PLAY_ONCE_HOLD, put_away_time * 0.75)
        context:setAnimationProgress(track_main, 1, true)
        context:adjustAnimationProgress(track_main, -put_away_time, false)
        return main_track_states.final
    end

    -- INPUT_INSPECT: run inspect animation and switch to the inspect state
    if (input == INPUT_INSPECT) then
        runInspectAnimation(context)
        return inspect_state
    end

    -- default: delegate to the original main_track_states idle transition
    return main_track_states.idle.transition(this, context, input)
end

-- =============================================================


function idle_state.transition(this, context, input)
    if (input == INPUT_RELOAD) then
        runReloadAnimation(context)
        return this.main_track_states.idle
    end
    if (input == INPUT_PUT_AWAY) then
        local put_away_time = context:getPutAwayTime()
        local track = context:getTrack(STATIC_TRACK_LINE, MAIN_TRACK)
        context:stopAnimation(context:getTrack(STATIC_TRACK_LINE, SWITCH_MODE_TRACK))
        context:runAnimation("put_away", track, false, PLAY_ONCE_HOLD, put_away_time * 0.75)
        context:setAnimationProgress(track, 1, true)
        context:adjustAnimationProgress(track, -put_away_time, false)
        return this.main_track_states.final
    end
    if (input == INPUT_INSPECT) then
        runInspectAnimation(context)
        return inspect_state
    end
    return main_track_states.idle.transition(this, context, input)
end

local fire_mode_state = {
    semi = {},
    auto = {},
    draw = {}
}
function fire_mode_state.draw.update(this, context)
    context:trigger(this.INPUT_MODE_DRAW)
end

function fire_mode_state.draw.transition(this, context,input)
    if (input == this.INPUT_MODE_DRAW) then
        if (context:getFireMode() == SEMI) then
            context:runAnimation("static_semi", context:getTrack(STATIC_TRACK_LINE, FIRE_MODE_TRACK), true, PLAY_ONCE_HOLD, 0)
            return fire_mode_state.semi
        elseif (context:getFireMode() == AUTO) then
            context:runAnimation("static_auto", context:getTrack(STATIC_TRACK_LINE, FIRE_MODE_TRACK), true, PLAY_ONCE_HOLD, 0)
            return fire_mode_state.auto
        end
    end
end

function fire_mode_state.semi.update(this, context)
    local track = context:getTrack(STATIC_TRACK_LINE, FIRE_MODE_TRACK)
    if (context:isHolding(track)) then
        context:runAnimation("static_semi", track, true, PLAY_ONCE_HOLD, 0)
    end
    if (context:getFireMode() == AUTO) then
        context:trigger(this.INPUT_MODE_AUTO)
    end
end

function fire_mode_state.semi.transition(this, context,input)
    if(input == this.INPUT_MODE_AUTO)then
        context:runAnimation("switch_auto", context:getTrack(STATIC_TRACK_LINE, SWITCH_MODE_TRACK), false, PLAY_ONCE_STOP, 0)
        return fire_mode_state.auto
    end
    if(input == INPUT_SHOOT or input == INPUT_RELOAD or input == INPUT_INSPECT)then
        context:stopAnimation(context:getTrack(STATIC_TRACK_LINE, SWITCH_MODE_TRACK))
    end
end

function fire_mode_state.auto.update(this, context)
    local track = context:getTrack(STATIC_TRACK_LINE, FIRE_MODE_TRACK)
    if (context:isHolding(track)) then
        context:runAnimation("static_auto", track, true, PLAY_ONCE_HOLD, 0)
    end
    if (context:getFireMode() == SEMI) then
        context:trigger(this.INPUT_MODE_SEMI)
    end
end

function fire_mode_state.auto.transition(this, context,input)
    if(input == this.INPUT_MODE_SEMI)then
        context:runAnimation("switch_semi", context:getTrack(STATIC_TRACK_LINE, SWITCH_MODE_TRACK), false, PLAY_ONCE_STOP, 0)
        return fire_mode_state.semi
    end
    if(input == INPUT_SHOOT or input == INPUT_RELOAD or input == INPUT_INSPECT)then
        context:stopAnimation(context:getTrack(STATIC_TRACK_LINE, SWITCH_MODE_TRACK))
    end
end

function inspect_state.transition(this, context, input)
    if (input == INPUT_FIRE_SELECT) then
        context:stopAnimation(context:getTrack(STATIC_TRACK_LINE, MAIN_TRACK))
        return this.main_track_states.idle
    end
    return main_track_states.inspect.transition(this, context, input)
end

local M = setmetatable({
    gun_kick_state = setmetatable({}, { __index = shoot_state }),
    bolt_caught_states = setmetatable({
        bolt_caught = caught_bolt_states,
        normal      = normal_bolt_states
    }, { __index = bolt_caught_states }), -- << ensure this line is present
    main_track_states = setmetatable({
        idle = idle_state,
        inspect = inspect_state
    }, {__index = main_track_states}),
    FIRE_MODE_TRACK = FIRE_MODE_TRACK,
    SWITCH_MODE_TRACK = SWITCH_MODE_TRACK,
    INPUT_MODE_SEMI = "input_mode_semi",
    INPUT_MODE_BURST = "input_mode_burst",
    INPUT_MODE_AUTO = "input_mode_auto",
    INPUT_MODE_DRAW = "input_mode_draw",
    fire_mode_state = fire_mode_state
}, {__index = default})

function M:initialize(context)
    default.initialize(self, context)
end

function M:states()
    return {
        self.base_track_state,
        self.bolt_caught_states.normal,
        self.main_track_states.start,
        self.gun_kick_state,
        self.movement_track_states.idle,
        self.ADS_states.normal,
        self.slide_states.normal,
        self.fire_mode_state.draw
    }
end

return M
