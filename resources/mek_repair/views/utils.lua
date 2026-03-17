local screenX, screenY = guiGetScreenSize()
local animateData = {}

local bindKey_ = bindKey
local unbindKey_ = unbindKey

function bind(keys, state, func)
    if type(keys) == "table" then
        for index, value in ipairs(keys) do
            bindKey(value, state, func)
        end
        return
    end
    return bindKey_(keys, state, func)
end

function unbind(keys, state, func)
    if type(keys) == "table" then
        for index, value in ipairs(keys) do
            unbindKey(value, state, func)
        end
        return
    end
    return unbindKey_(keys, state, func)
end

function animate(key, data, duration, animateType)
    local duration = duration or 500
    local animateType = animateType or "Linear"

    if not animateData[key] then
        animateData[key] = {
            tick = getTickCount(),
            from = data.from,
            to = data.to,
            lastAction = data.state
        }
    elseif animateData[key].lastAction then
        if data.state ~= animateData[key].lastAction then
            animateData[key].tick = getTickCount()
            animateData[key].from = data.from
            animateData[key].to = data.to
            animateData[key].lastAction = data.state
        end
    end

    animateData[key].lastAction = data.state
    local startTick = animateData[key].tick

    local elapsedTime = nowTick - startTick
    local duration = (startTick + duration) - startTick
    local progress = elapsedTime / duration

    local a, b, c = interpolateBetween(
            animateData[key]["from"][1], animateData[key]["from"][2], animateData[key]["from"][3],
            animateData[key]["to"][1], animateData[key]["to"][2], animateData[key]["to"][3],
            progress, animateType
    )

    return { a, b, c }
end

txd = engineLoadTXD("models/Wrench1.txd")
engineImportTXD(txd, 2709)
dff = engineLoadDFF("models/Wrench1.dff")
engineReplaceModel(dff, 2709)