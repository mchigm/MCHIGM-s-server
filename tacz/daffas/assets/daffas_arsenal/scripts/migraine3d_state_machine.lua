-- Track line pointers
local track_line_top = {value = 0}
local static_track_top = {value = 0}
local blending_track_top = {value = 0}

local function increment(obj)
    obj.value = obj.value + 1
    return obj.value - 1
end

-- Track line and track assignments
local STATIC_TRACK_LINE = increment(track_line_top)
local BASE_TRACK = increment(static_track_top)
local BOLT_CAUGHT_TRACK = increment(static_track_top)
local SAFETY_TRACK = increment(static_track_top)
local ADS_TRACK = increment(static_track_top)
local MAIN_TRACK = increment(static_track_top)
local AMMO_DISPLAY_TRACK = increment(static_track_top)

local GUN_KICK_TRACK_LINE = increment(track_line_top)

local BLENDING_TRACK_LINE = increment(track_line_top)
local MOVEMENT_TRACK = increment(blending_track_top)
local LOOP_TRACK = increment(blending_track_top)

-- ADS state handling
local lastADSState = nil

local function updateADSAnimation(context)
    local aim = context:getAimingProgress()
    local adsNow = (aim > 0.5)

    if adsNow ~= lastADSState then
        lastADSState = adsNow
        local track = context:getTrack(STATIC_TRACK_LINE, ADS_TRACK)
        if adsNow then
            context:runAnimation("ads_in", track, false, PLAY_ONCE_HOLD, 0.1)
        else
            context:runAnimation("ads_out", track, false, PLAY_ONCE_HOLD, 0.1)
        end
    end
end

-- Export
local M = {
    track_line_top = track_line_top,
    STATIC_TRACK_LINE = STATIC_TRACK_LINE,
    GUN_KICK_TRACK_LINE = GUN_KICK_TRACK_LINE,
    BLENDING_TRACK_LINE = BLENDING_TRACK_LINE,
    static_track_top = static_track_top,
    BASE_TRACK = BASE_TRACK,
    BOLT_CAUGHT_TRACK = BOLT_CAUGHT_TRACK,
    SAFETY_TRACK = SAFETY_TRACK,
    ADS_TRACK = ADS_TRACK,
    MAIN_TRACK = MAIN_TRACK,
    AMMO_DISPLAY_TRACK = AMMO_DISPLAY_TRACK,
    blending_track_top = blending_track_top,
    MOVEMENT_TRACK = MOVEMENT_TRACK,
    LOOP_TRACK = LOOP_TRACK,
    updateADSAnimation = updateADSAnimation
}

function M:initialize(context)
    context:ensureTrackLineSize(track_line_top.value)
    context:ensureTracksAmount(STATIC_TRACK_LINE, static_track_top.value)
    context:ensureTracksAmount(BLENDING_TRACK_LINE, blending_track_top.value)
end

return M
