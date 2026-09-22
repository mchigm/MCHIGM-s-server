-- daffas_arsenal/delay_logic.lua
local M = {}

-- Called when player starts pressing fire
-- Returns true to start ticking (wait until delay elapsed)
function M.start_shoot(api)
    local params = api:getScriptParams() or {}
    local delay_s = params.shoot_delay or 0
    local delay_ms = delay_s * 1000

    -- Quick checks: do we have ammo or a bullet?
    if not api:hasAmmoInBarrel() and not api:hasAmmoToConsume() then
        return false -- can't shoot
    end

    -- If currently reloading, bail out
    if api:getReloadStateType() ~= 0 then
        return false
    end

    local cache = {
        start_time = api:getCurrentTimestamp(),
        delay = delay_ms,
        fired = false,
        cancelled = false,
        consume = api:isShootingNeedConsumeAmmo()
    }
    api:cacheScriptData(cache)

    -- If no delay configured, fire immediately and stop ticking
    if delay_ms <= 0 then
        api:shootOnce(cache.consume)
        cache.fired = true
        api:cacheScriptData(cache)
        return false
    end

    -- otherwise keep ticking until delay passes
    return true
end

-- Called every tick while shooting state is active
function M.tick_shoot(api)
    local cache = api:getCachedScriptData()
    if not cache then
        return false
    end

    -- if something cancelled (reload started / user released / etc) stop
    if cache.cancelled then
        return false
    end

    -- If we became out of ammo or started reloading while waiting, cancel
    if (not api:hasAmmoInBarrel() and not api:hasAmmoToConsume()) or api:getReloadStateType() ~= 0 then
        return false
    end

    local elapsed = api:getCurrentTimestamp() - cache.start_time
    if elapsed >= cache.delay then
        -- (Optional) adjust client-side shoot timestamp if that function exists in your environment
        if adjustClientShootInterval ~= nil then
            pcall(adjustClientShootInterval, cache.delay) -- safe call if present
        end

        api:shootOnce(cache.consume)
        cache.fired = true
        api:cacheScriptData(cache)
        return false -- finished
    end

    return true -- keep waiting
end

-- If the engine can call an interrupt when the shoot is aborted
function M.interrupt_shoot(api)
    local cache = api:getCachedScriptData()
    if cache then
        cache.cancelled = true
        api:cacheScriptData(cache)
    end
end

return M
