local default = require("tacz_default_state_machine")
local GUN_KICK_TRACK_LINE = default.GUN_KICK_TRACK_LINE
local gun_kick_state = default.gun_kick_state
local main_track_states = default.main_track_states
local idle_state = setmetatable({}, {__index = main_track_states.idle})

-- Shoot animations
local shoot_animations = {
    "shoot_1", "shoot_2", "shoot_3", "shoot_4",
    "shoot_5", "shoot_6", "shoot_7", "shoot_8"
}
local last_shoot_animation = "shoot_last"
local bolt_catch_animation = "static_bolt_caught"

local function getNextShootAnimation()
    return shoot_animations[math.random(#shoot_animations)]
end

-- ===========================================================================================================================================================================

-- Idle state bolt catch after last shot
function idle_state.transition(this, context, input)
    local track = context:findIdleTrack(GUN_KICK_TRACK_LINE, false)

    if context:getAmmoCount() == 0
            and context:getFlag("played_shoot_last")
            and not context:isTrackPlaying(track) then
        context:runAnimation(bolt_catch_animation, track, true, PLAY_ONCE_STOP, 0)
        context:setFlag("played_shoot_last", false)
    end

    return main_track_states.idle.transition(this, context, input)
end

-- ===========================================================================================================================================================================

-- Random shooting state
local shoot_state = setmetatable({}, { __index = gun_kick_state })

function shoot_state.transition(this, context, input)
    if input ~= INPUT_SHOOT then return nil end

    local fireMode = context:getFireMode()
    if fireMode ~= SEMI and fireMode ~= AUTO and fireMode ~= BURST then
        return nil
    end

    local track = context:findIdleTrack(GUN_KICK_TRACK_LINE, false)

    if context:getAmmoCount() == 0 then
        context:runAnimation(last_shoot_animation, track, true, PLAY_ONCE_STOP, 0)
        context:runAnimation("last_shoot", context:getTrack(STATIC_TRACK_LINE, BOLT_CAUGHT_TRACK), true, PLAY_ONCE_HOLD, 0)
    else
        local anim = getNextShootAnimation()
        context:runAnimation(anim, track, true, PLAY_ONCE_STOP, 0)
    end

    return nil
end



-- Return module
local M = setmetatable({
    gun_kick_state = setmetatable({}, { __index = shoot_state }),
    idle = idle_state
}, { __index = default })

return M
