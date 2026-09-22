-- 脚本的位置是 "{命名空间}:{路径}"，那么 require 的格式为 "{命名空间}_{路径}"
-- 注意！require 取得的内容不应该被修改，应仅调用
local default = require("daffas_arsenal_default_daffas_state_machine")
local STATIC_TRACK_LINE = default.STATIC_TRACK_LINE
local BOLT_CAUGHT_TRACK = default.BOLT_CAUGHT_TRACK
local bolt_caught_states = default.bolt_caught_states

local normal_state = setmetatable({}, {__index = bolt_caught_states.normal})


-- 检查当前是否还有弹药
local function isNoAmmo(context)
    -- 这里同时检查了枪管和弹匣
    return (not context:hasBulletInBarrel()) and (context:getAmmoCount() <= 0)
end

-- 更新"不空挂"状态
function normal_state.update(this, context)
    -- 如果弹药数量是 0 了,那么立刻手动触发一次转到"空挂"状态的输入
    if (isNoAmmo(context)) then
        context:stopAnimation(context:getTrack(STATIC_TRACK_LINE, BOLT_CAUGHT_TRACK))
        context:trigger(this.INPUT_BOLT_CAUGHT)
    else
        local a = context:getAmmoCount()
        if (a < 9) then
            context:setAnimationProgress(context:getTrack(STATIC_TRACK_LINE, BOLT_CAUGHT_TRACK),0.1+(8-a)*0.5,false)
        else
            context:setAnimationProgress(context:getTrack(STATIC_TRACK_LINE, BOLT_CAUGHT_TRACK),0.1,false)
        end
    end
end

-- 进入"不空挂"状态
function normal_state.entry(this, context)
    context:runAnimation("static_ammo_display", context:getTrack(STATIC_TRACK_LINE, BOLT_CAUGHT_TRACK), false, PLAY_ONCE_STOP, 0)
    this.bolt_caught_states.normal.update(this, context)
end






















local GUN_KICK_TRACK_LINE = default.GUN_KICK_TRACK_LINE
local gun_kick_state = default.gun_kick_state
local main_track_states = default.main_track_states
local idle_state = setmetatable({}, {__index = main_track_states.idle})




-- Shoot animations
local shoot_animations = {
    "shoot_1", "shoot_2", "shoot_3", "shoot_4",
    "shoot_5", "shoot_6", "shoot_7", "shoot_8", "shoot_9"
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







































-- 用元表的方式继承默认状态机的属性
local M = setmetatable({
    gun_kick_state = setmetatable({}, { __index = shoot_state }),
    bolt_caught_states = setmetatable({
        normal = normal_state,
    }, {__index = bolt_caught_states}),
}, {__index = default})
function M:initialize(context)
    default.initialize(self, context)
end
-- 继承默认状态机需要重新初始化状态
function M:states()
    return {
        self.base_track_state,
        self.bolt_caught_states.normal,
        self.over_heat_states.normal,
        self.main_track_states.start,
        self.gun_kick_state,
        self.movement_track_states.idle,
        self.ADS_states.normal,
        self.slide_states.normal
    }
end
-- 导出状态机
return M