local player
local score
local timeTillNextBoost
local speedInc
local upgradeTime
local myFont
local rightSide
local totalTime
local spikes
local spikeData
local level
local gameOver

local function resetGame()
    score = 0
    level = 1
    totalTime = 0
    timeTillNextBoost = 0
    gameOver = false
    
    player.speed = 300
    player.y = love.graphics.getHeight() / 2
    player.x = love.graphics.getWidth() / 8

    spikeData.speed = 400

    spikes = {}
    for i = 1, 3 do
        local newSpike = {
            x = rightSide + (i * 300),
            y = math.random(0, spikeData.spikeLimit),
            width = spikeData.spikeWidth,
            height = spikeData.spikeHeight
        }
        table.insert(spikes, newSpike)
    end
end

function love.load()
    local monitorWidth, monitorHeight = love.window.getDesktopDimensions()
    rightSide = monitorWidth
    player = {}
    player.speed = 300
    player.y = monitorHeight / 2
    player.x = monitorWidth / 8
    player.width = 80
    player.height = 80
    player.upperlimit = 0
    player.bottomlimit = monitorHeight - player.height
    timeTillNextBoost = 0
    totalTime = 0
    speedInc = 100
    score = 0
    upgradeTime = 15
    gameOver = false
    local success, font = pcall(love.graphics.newFont, "JetBrainsMono-Regular.ttf", 18)
    myFont = success and font or love.graphics.newFont(18)
    spikes = {}
    level = 1
    spikeData = {
        spikeHeight = 20,
        speed = 400,
        spikeWidth = 20
    }
    spikeData.spikeLimit = monitorHeight - spikeData.spikeHeight
    for i = 1, 3 do
        local newSpike = {
            x = rightSide + (i * 300),
            y = math.random(0, spikeData.spikeLimit),
            width = spikeData.spikeWidth,
            height = spikeData.spikeHeight
        }
        table.insert(spikes, newSpike)
    end
end

function checkCollision(a, b)
    return a.x < b.x + b.width and
           b.x < a.x + a.width and
           a.y < b.y + b.height and
           b.y < a.y + a.height
end

local function getRandY()
    local y = math.random(0, spikeData.spikeLimit)
    return y
end

local function newSpike()
    local newSpike = {
        x = rightSide,
        y =  getRandY(),
        width = spikeData.spikeWidth,
        height = spikeData.spikeHeight
    }
    table.insert(spikes, newSpike)
end

local function moveSpikeBack(spike)
    spike.x = rightSide
    spike.y = getRandY()
end

local function moveSpike(spike, dt)
    if spike.x <= -spikeData.spikeWidth then
        moveSpikeBack(spike)
    else
        spike.x = spike.x - (spikeData.speed * dt)
    end
end

function love.update(dt)
    if not gameOver then
        timeTillNextBoost = timeTillNextBoost + dt
        totalTime = totalTime + dt

        if love.keyboard.isDown("space") then
            if not (player.y <= player.upperlimit) then
                player.y  = player.y - (player.speed * dt)
            else
                player.y = player.bottomlimit
            end
        else
            if not (player.y >= player.bottomlimit) then
                player.y = player.y + (player.speed * dt)
            else
                player.y = player.upperlimit
            end
        end

        for _, spike in ipairs(spikes) do
            if checkCollision(player, spike) then
                gameOver = true
            end
            moveSpike(spike, dt)
        end

        if timeTillNextBoost >= upgradeTime then
            player.speed = player.speed + speedInc
            timeTillNextBoost = 0
            score = score + 1
            spikeData.speed = spikeData.speed + (speedInc + 1)
            level = level + 1
            newSpike()
        end
    else
        if love.keyboard.isDown("r") then
            gameOver = false
            resetGame()
        end
    end
end

function love.draw()
    if not gameOver then
        love.graphics.setFont(myFont)
        love.graphics.setColor(0.3, 1, 0.3)
        love.graphics.rectangle("fill", player.x, player.y, player.width, player.height)
        love.graphics.setColor(1, 0.3, 0.3)
        love.graphics.setColor(1, 0.3, 0.3)
        for _, spike in ipairs(spikes) do
            love.graphics.rectangle("fill", spike.x, spike.y, spike.spikeWidth or 20, spikeData.spikeHeight)
        end
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(string.format("Score: %03d", score), 20, 20)
        love.graphics.print(string.format("Speed: %03d", player.speed), 20, 40)
        love.graphics.print(string.format("Time till next boost: %02d", upgradeTime - timeTillNextBoost), 20, 60)
        love.graphics.print(string.format("Total time: %03d", totalTime), 20, 80)
        love.graphics.print(string.format("Level: %02d", level), 20, 100)
    else
        love.graphics.setColor(1, 0, 0)
        local windowWidth = love.graphics.getWidth()
        local windowHeight = love.graphics.getHeight()
        local targetY = windowHeight / 2
        love.graphics.printf("Game Over. Press r to try again.", 0, targetY, windowWidth, "center")
        love.graphics.setColor(1, 1, 1)
    end
end