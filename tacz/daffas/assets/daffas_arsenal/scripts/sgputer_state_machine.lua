-- 脚本位置 "{命名空间}:{路径}"，require 格式 "{命名空间}_{路径}"
local default = require("tacz_manual_action_state_machine")
local STATIC_TRACK_LINE = default.STATIC_TRACK_LINE
local MAIN_TRACK = default.MAIN_TRACK
local main_track_states = default.main_track_states

-- override idle state
local idle_state = setmetatable({}, {__index = main_track_states.idle})

-- custom reload state
local reload_state = {
    need_ammo = 0,
    loaded_ammo = 0
}

-- override start state so we control the draw animation
local start_state = setmetatable({}, { __index = main_track_states.start })


local end_state = setmetatable({}, { __index = main_track_states["end"] })



function end_state.transition(this, context, input)
    if input == INPUT_PUT_AWAY then
        local track = context:getTrack(STATIC_TRACK_LINE, MAIN_TRACK)
        local ammo = context:getAmmoCount() or 0
        local hasBarrel = context:hasBulletInBarrel()

        if ammo <= 0 and not hasBarrel then
            context:runAnimation("put_away_empty", track, false, PLAY_ONCE_STOP, 0.15)
        else
            context:runAnimation("put_away", track, false, PLAY_ONCE_STOP, 0.15)
        end

        return nil
    end

    if main_track_states["end"] and main_track_states["end"].transition then
        return main_track_states["end"].transition(this, context, input)
    end
    return nil
end






-------------------------------------------------------
-- UTILITY
-------------------------------------------------------
local function get_ejection_time(context)
    local ejection_time = context:getStateMachineParams().intro_shell_ejecting_time
    if (ejection_time) then
        ejection_time = ejection_time * 1000
    else
        ejection_time = 0
    end
    return ejection_time
end

-------------------------------------------------------
-- INSPECT ANIM
-------------------------------------------------------
local function runInspectAnimation(context)
    local track = context:getTrack(STATIC_TRACK_LINE, MAIN_TRACK)
    local ammo = context:getAmmoCount()
    local hasBarrel = context:hasBulletInBarrel()

    if (ammo <= 0 and not hasBarrel) then
        context:runAnimation("inspect_empty", track, false, PLAY_ONCE_STOP, 0.2)
    elseif (ammo <= 0) then
        context:runAnimation("inspect_01", track, false, PLAY_ONCE_STOP, 0.2)
    else
        context:runAnimation("inspect", track, false, PLAY_ONCE_STOP, 0.2)
    end
end

-------------------------------------------------------
-- START (DRAW) OVERRIDE — plays draw_empty when ammo == 0
-------------------------------------------------------
function start_state.transition(this, context, input)
    -- when weapon is drawn the state machine sends INPUT_DRAW
    if input == INPUT_DRAW then
        local track = context:getTrack(STATIC_TRACK_LINE, MAIN_TRACK)
        local ammo = context:getAmmoCount() or 0
        -- check chambered bullet too if you want fully empty detection:
        local hasBarrel = context:hasBulletInBarrel()
        if ammo <= 0 and not hasBarrel then
            -- completely empty: draw_empty
            context:runAnimation("draw_empty", track, false, PLAY_ONCE_STOP, 0.15)
        else
            -- has ammo somewhere: normal draw
            context:runAnimation("draw", track, false, PLAY_ONCE_STOP, 0.15)
        end

        -- after draw, go to idle
        return this.main_track_states.idle
    end

    -- any other inputs: delegate to default start transition
    if main_track_states.start and main_track_states.start.transition then
        return main_track_states.start.transition(this, context, input)
    end
    return nil
end

-------------------------------------------------------
-- IDLE TRANSITION OVERRIDE (reload + inspect)
-------------------------------------------------------
function idle_state.transition(this, context, input)
    if input == INPUT_PUT_AWAY then
        local track = context:getTrack(STATIC_TRACK_LINE, MAIN_TRACK)
        local ammo = context:getAmmoCount() or 0
        local hasBarrel = context:hasBulletInBarrel()

        if ammo <= 0 and not hasBarrel then
            context:runAnimation("put_away_empty", track, false, PLAY_ONCE_HOLD, 0.15)
        else
            context:runAnimation("put_away", track, false, PLAY_ONCE_HOLD, 0.15)
        end

        -- let default machine go to end state
        return this.main_track_states["end"]
    end

    if input == INPUT_RELOAD then
        return this.main_track_states.reload
    end

    if input == INPUT_INSPECT then
        runInspectAnimation(context)
        return this.main_track_states.inspect
    end

    return main_track_states.idle.transition(this, context, input)
end


-------------------------------------------------------
-- RELOAD ENTRY
-------------------------------------------------------
function reload_state.entry(this, context)
    local state = this.main_track_states.reload

    local ammo = context:getAmmoCount() or 0
    local hasBarrel = context:hasBulletInBarrel()
    local empty = (ammo <= 0 and not hasBarrel)

    local track = context:getTrack(STATIC_TRACK_LINE, MAIN_TRACK)

    if empty then
        state.timestamp = context:getCurrentTimestamp()
        state.ejection_time = get_ejection_time(context)
        context:runAnimation("reload_intro_empty", track, false, PLAY_ONCE_HOLD, 0.2)
    else
        state.timestamp = -1
        state.ejection_time = 0
        context:runAnimation("reload_intro", track, false, PLAY_ONCE_HOLD, 0.2)
    end

    state.need_ammo = context:getMaxAmmoCount() - context:getAmmoCount()
    state.loaded_ammo = 0
end

-------------------------------------------------------
-- RELOAD UPDATE
-------------------------------------------------------
function reload_state.update(this, context)
    local state = this.main_track_states.reload

    -- empty intro shell eject
    if (state.timestamp ~= -1 and context:getCurrentTimestamp() - state.timestamp > state.ejection_time) then
        context:popShellFrom(0)
        state.timestamp = -1
    end

    if (state.loaded_ammo > state.need_ammo or not context:hasAmmoToConsume()) then
        context:trigger(this.INPUT_RELOAD_RETREAT)
        return
    end

    local track = context:getTrack(STATIC_TRACK_LINE, MAIN_TRACK)
    if (context:isHolding(track)) then
        context:runAnimation("reload_loop", track, false, PLAY_ONCE_HOLD, 0)
        state.loaded_ammo = state.loaded_ammo + 1
    end
end

-------------------------------------------------------
-- RELOAD TRANSITION END
-------------------------------------------------------
function reload_state.transition(this, context, input)
    if (input == this.INPUT_RELOAD_RETREAT or input == INPUT_CANCEL_RELOAD) then
        context:runAnimation("reload_end", context:getTrack(STATIC_TRACK_LINE, MAIN_TRACK), false, PLAY_ONCE_STOP, 0.2)
        return this.main_track_states.idle
    end
    return this.main_track_states.idle.transition(this, context, input)
end

-------------------------------------------------------
-- EXPORT MACHINE
-------------------------------------------------------
local M = setmetatable({
    main_track_states = setmetatable({
        start  = start_state,
        idle   = idle_state,
        reload = reload_state,
        ["end"] = end_state,
    }, { __index = main_track_states }),
    INPUT_RELOAD_RETREAT = "reload_retreat",
}, { __index = default })



function M:initialize(context)
    default.initialize(self, context)
    self.main_track_states.reload.need_ammo = 0
    self.main_track_states.reload.loaded_ammo = 0
end

return M
