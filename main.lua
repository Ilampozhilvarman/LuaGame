local player
local spikeData
local game = {}
local laserData

local function resetGame()
    game.score = 0
    game.level = 1
    game.totalTime = 0
    game.timeTillNextBoost = 0
    game.gameOver = false
    player.speed = 300
    player.y = love.graphics.getHeight() / 2
    player.x = love.graphics.getWidth() / 8
    spikeData.speed = 400
    game.spikes = {}
    for i = 1, 3 do
        local newSpike = {
            x = game.rightSide + (i * 300),
            y = math.random(0, spikeData.spikeLimit),
            width = spikeData.spikeWidth,
            height = spikeData.spikeHeight
        }
        table.insert(game.spikes, newSpike)
    end
end

function love.load()
    local monitorWidth, monitorHeight = love.window.getDesktopDimensions()
    game.rightSide = monitorWidth
    player = {}
    player.speed = 300
    player.y = monitorHeight / 2
    player.x = monitorWidth / 8
    player.width = 60
    player.height = 60
    player.upperlimit = 0
    player.bottomlimit = monitorHeight - player.height
    game.timeTillNextBoost = 0
    game.totalTime = 0
    game.speedInc = 100
    game.score = 0
    game.upgradeTime = 15
    game.gameOver = false
    local success, font = pcall(love.graphics.newFont, "JetBrainsMono-Regular.ttf", 18)
    game.myFont = success and font or love.graphics.newFont(18)
    game.spikes = {}
    game.lasers = {}
    game.level = 1
    laserData = {
        width = monitorWidth,
        height = 100,
        bottomlimit = monitorHeight - laserData.height,
        upperlimit = 0,
        warningTime = 2,
        activeTime = 1,
        timer = 0,
        warning = true,
        active = false,
        blinkRate = 0.15,
        visible = true,
        blinkTimer = 0
    }
    spikeData = {
        spikeHeight = 20,
        speed = 400,
        spikeWidth = 20
    }
    spikeData.spikeLimit = monitorHeight - spikeData.spikeHeight
    for i = 1, 3 do
        local newSpike = {
            x = game.rightSide + (i * 300),
            y = math.random(0, spikeData.spikeLimit),
            width = spikeData.spikeWidth,
            height = spikeData.spikeHeight
        }
        table.insert(game.spikes, newSpike)
    end
end

function checkCollision(a, b)
    return a.x < b.x + b.width and
           b.x < a.x + a.width and
           a.y < b.y + b.height and
           b.y < a.y + a.height
end

local function getRandYForSpikes()
    local y = math.random(0, spikeData.spikeLimit)
    return y
end

local function getRandYForLasers()
    local y = math.random(0, laserData.bottomlimit)
    return y
end

local function newSpike()
    local newSpike = {
        x = game.rightSide,
        y =  getRandYForSpikes(),
        width = spikeData.spikeWidth,
        height = spikeData.spikeHeight
    }
    table.insert(game.spikes, newSpike)
end

local function newLaser()
    local monitorHeight = love.graphics.getWidth()
    local newLaser = {
        width = monitorHeight,
        height = 100,
        bottomlimit = monitorHeight - laserData.height,
        upperlimit = 0,
        warningTime = 2,
        activeTime = 1,
        timer = 0,
        warning = true,
        active = false,
        blinkRate = 0.15,
        visible = true,
        blinkTimer = 0
    }
    table.insert(game.lasers, newLaser)
end

local function moveSpikeBack(spike)
    spike.x = game.rightSide
    spike.y = getRandYForSpikes()
end

local function moveSpike(spike, dt)
    if spike.x <= -spikeData.spikeWidth then
        moveSpikeBack(spike)
    else
        spike.x = spike.x - (spikeData.speed * dt)
    end
end

function love.update(dt)
    if not game.gameOver then
        game.timeTillNextBoost = game.timeTillNextBoost + dt
        game.totalTime = game.totalTime + dt

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

        for _, spike in ipairs(game.spikes) do
            if checkCollision(player, spike) then
                game.gameOver = true
            end
            moveSpike(spike, dt)
        end

        if game.timeTillNextBoost >= game.upgradeTime then
            player.speed = player.speed + game.speedInc
            game.timeTillNextBoost = 0
            game.score = game.score + 1
            spikeData.speed = spikeData.speed + (game.speedInc + 1)
            game.level = game.level + 1
            newSpike()
        end

        for _, laser in ipairs(game.lasers) do
            if checkCollision(player, laser) then
                game.gameOver = true
            end
            laser.timer = laser.timer + dt
            if laser.warning then
                laser.blinkTimer = laser.blinkTimer + dt
                if laser.blinkTimer >= laser.blinkRate then
                    laser.visible = not laser.visible
                    laser.blinkTimer = 0
                end
                if laser.timer >= laser.warningTime then
                    laser.warning = false
                    laser.active = true
                    laser.timer = 0
                    laser.visible = true
                end
            elseif laser.active then
                if laser.timer >= laser.activeTime then
                    laser.active = false
                    laser.warning = true
                    laser.timer = 0
                end
            end
        end
    else
        if love.keyboard.isDown("r") then
            game.gameOver = false
            resetGame()
        end
    end
end

function love.draw()
    if not game.gameOver then
        love.graphics.setFont(game.myFont)
        love.graphics.setColor(0.3, 1, 0.3)
        love.graphics.rectangle("fill", player.x, player.y, player.width, player.height)
        love.graphics.setColor(1, 0.3, 0.3)
        love.graphics.setColor(1, 0.3, 0.3)
        for _, spike in ipairs(game.spikes) do
            love.graphics.rectangle("fill", spike.x, spike.y, spike.spikeWidth or 20, spikeData.spikeHeight)
        end
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(string.format("game.score: %03d", game.score), 20, 20)
        love.graphics.print(string.format("Speed: %03d", player.speed), 20, 40)
        love.graphics.print(string.format("Time till next boost: %02d", game.upgradeTime - game.timeTillNextBoost), 20, 60)
        love.graphics.print(string.format("Total time: %03d", game.totalTime), 20, 80)
        love.graphics.print(string.format("game.level: %02d", game.level), 20, 100)
    else
        love.graphics.setColor(1, 0, 0)
        local windowWidth = love.graphics.getWidth()
        local windowHeight = love.graphics.getHeight()
        local targetY = windowHeight / 2
        love.graphics.printf("Game Over. Press r to try again.", 0, targetY, windowWidth, "center")
        love.graphics.setColor(1, 1, 1)
    end
end