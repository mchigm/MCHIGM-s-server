-- 混合轨道行 的 轨道，用于过热动画
local OVER_HEAT_TRACK = increment(blending_track_top)
local OVER_HEATING_TRACK = increment(blending_track_top)

-- 检查当前是否处于过热状态
local function isOverHeat(context)
    return context:isOverHeat()
end

-- 过热部分
-- 过热部分的内容完全参照空挂部分
local over_heat_states = {
    -- normal 是不过热的正常状态
    normal = {},
    -- over_heat 是过热时的状态
    over_heat = {}
}

-- 更新"不过热"状态
function over_heat_states.normal.update(this, context)
    -- 如果进入过热状态，则触发 INPUT_OVER_HEAT
    if (isOverHeat(context)) then
        context:trigger(this.INPUT_OVER_HEAT)
    end
end

-- 进入"不过热"状态
function over_heat_states.normal.entry(this, context)
    -- 直接进入 update 检查是否要切进过热状态
    this.over_heat_states.normal.update(this, context)
end

-- 转出"不过热"状态
function over_heat_states.normal.transition(this, context, input)
    -- 收到过热信号则进入过热状态
    if (input == this.INPUT_OVER_HEAT) then
        return this.over_heat_states.over_heat
    end
end

-- 进入"过热"状态
function over_heat_states.over_heat.entry(this, context)
    -- 在混合轨道播放过热动画
    context:runAnimation("over_heat", context:getTrack(BLENDING_TRACK_LINE, OVER_HEAT_TRACK), false, LOOP, 0)
end

-- 更新"过热"状态
function over_heat_states.over_heat.update(this, context)
    -- 如果热量下降，不再过热，触发 INPUT_OVER_HEAT_NORMAL
    if (not isOverHeat(context)) then
        context:trigger(this.INPUT_OVER_HEAT_NORMAL)
    end
end

-- 转出"过热"状态
function over_heat_states.over_heat.transition(this, context, input)
    -- 收到"恢复正常"信号
    if (input == this.INPUT_OVER_HEAT_NORMAL) then
        -- 停止过热动画
        context:stopAnimation(context:getTrack(BLENDING_TRACK_LINE, OVER_HEAT_TRACK))
        return this.over_heat_states.normal
    end
end
