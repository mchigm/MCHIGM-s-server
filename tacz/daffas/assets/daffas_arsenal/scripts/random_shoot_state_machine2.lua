local default = require("tacz_default_state_machine")
local GUN_KICK_TRACK_LINE = default.GUN_KICK_TRACK_LINE
local STATIC_TRACK_LINE = default.STATIC_TRACK_LINE
local BOLT_CAUGHT_TRACK = default.BOLT_CAUGHT_TRACK
local gun_kick_state = default.gun_kick_state
local main_track_states = default.main_track_states
local idle_state = setmetatable({}, {__index = main_track_states.idle})

-- === ANIMATION LISTS ===
local shoot_animations_main = {
    "shoot_1", "shoot_2", "shoot_3", "shoot_4",
    "shoot_5", "shoot_6", "shoot_7", "shoot_8"
}

local shoot_animations_secondary = {
    "shoot2_1", "shoot2_2", "shoot2_3", "shoot2_4",
    "shoot2_5", "shoot2_6", "shoot2_7", "shoot2_8"
}

local last_shoot_animation = "shoot_last"
local bolt_catch_animation = "static_bolt_caught"

-- === RANDOM SELECTORS ===
local function getRandomMainShootAnim()
    return shoot_animations_main[math.random(#shoot_animations_main)]
end

local function getRandomSecondaryShootAnim()
    return shoot_animations_secondary[math.random(#shoot_animations_secondary)]
end

-- === SHOOT STATE ===
local shoot_state = setmetatable({}, { __index = gun_kick_state })

function shoot_state.transition(this, context, input)
    if input ~= INPUT_SHOOT then return nil end

    local fireMode = context:getFireMode()
    if fireMode ~= SEMI and fireMode ~= AUTO and fireMode ~= BURST then
        return nil
    end

    local mainTrack = context:findIdleTrack(GUN_KICK_TRACK_LINE, false)
    local secondaryTrack = context:getTrack(STATIC_TRACK_LINE, BOLT_CAUGHT_TRACK)

    if context:getAmmoCount() == 0 then
        -- LAST SHOT (plays bolt caught + sound)
        context:runAnimation(last_shoot_animation, mainTrack, true, PLAY_ONCE_STOP, 0)
        context:runAnimation("last_shoot", secondaryTrack, true, PLAY_ONCE_HOLD, 0)
    else
        -- NORMAL SHOT: play 2 animations at once
        local animMain = getRandomMainShootAnim()
        local animSecondary = getRandomSecondaryShootAnim()

        context:runAnimation(animMain, mainTrack, true, PLAY_ONCE_STOP, 0)
        context:runAnimation(animSecondary, secondaryTrack, true, PLAY_ONCE_STOP, 0)
    end

    return nil
end

-- === IDLE STATE (bolt catch) ===
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

-- === RETURN MODULE ===
local M = setmetatable({
    gun_kick_state = setmetatable({}, { __index = shoot_state }),
    idle = idle_state
}, { __index = default })

return M
