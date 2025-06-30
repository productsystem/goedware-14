local Menu = {}

currentMenu = nil
local buttons = {}
local font = love.graphics.newFont("fonts/PressStart2P-Regular.ttf", 24)
local titleFont = love.graphics.newFont("fonts/PressStart2P-Regular.ttf",48)

local title = ""
local backgroundColor = {0.1, 0.1, 0.1, 0.8}
    love.graphics.setDefaultFilter("nearest", "nearest")

local planetImage = love.graphics.newImage("sprites/planet.png")
local playerImage = love.graphics.newImage("sprites/player.png")
local playerAngle = 0

local gameOverMessage = ""

cutsceneStage = nil
local cutsceneData = {
    {
        sprite = love.graphics.newImage("sprites/planet.png"),
        text = "This is Ferion-5, a planet with crab-like species. You have been sent here on a mission to retreive the [REDACTED]."
    },
    {
        sprite = love.graphics.newImage("sprites/player.png"),
        text = "Juno. Use WASD to move. Left click to attack in that direction to harvest items. Press E to pick-up items."
    },
    {
        sprite = love.graphics.newImage("sprites/grinder.png"),
        text = "This is Mr.Grinder, scary, but your friend. Toss items with E inside to gain oil. Oil doubles as your health, so be careful."
    },
    {
        sprite = love.graphics.newImage("sprites/rocket.png"),
        text = "Load oil into the Rocket to launch it with holding R and complete your mission. [REDACTED] must also be injected with R. Good luck!"
    }
}


function Menu.resume()
    Menu.load()
end


function Menu.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    currentMenu = "main"
    title = "Project Oil"
    backgroundColor = {0.05, 0.05, 0.05, 0.9}
    buttons = {
        { label = "Start Game", action = function()
            currentMenu = nil
            cutsceneStage = 0
        end },
        { label = "Exit", action = function()
            love.event.quit()
        end }
    }
end

function Menu.pause()
    currentMenu = "pause"
    title = "Paused"
    backgroundColor = {0, 0, 0, 0.6}
    buttons = {
        { label = "Resume", action = function()
            currentMenu = nil
        end },
        { label = "Exit to Menu", action = function()
            Menu.load()
        end }
    }
end

function Menu.update(dt)
    if currentMenu == "main" then
        playerAngle = playerAngle + dt * 0.5
    end
end

function Menu.showDeath()
    currentMenu = "death"
end


function Menu.draw()
    if cutsceneStage ~= nil then
        local stage = cutsceneData[cutsceneStage + 1]
        if stage then
            local screenW, screenH = love.graphics.getWidth(), love.graphics.getHeight()
            love.graphics.setColor(0.05, 0.05, 0.05, 0.9)
            love.graphics.rectangle("fill", 0, 0, screenW, screenH)
            local sprite = stage.sprite
            local scale = 3
            local sx = 100
            local sy = screenH / 2 - (sprite:getHeight() * scale) / 2
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(sprite, sx, sy, 0, scale, scale)

            local textboxW = screenW * 0.45
            local textboxX = screenW * 0.5
            local textboxY = screenH * 0.25
            love.graphics.setColor(0.2, 0.2, 0.2, 0.8)
            love.graphics.rectangle("fill", textboxX, textboxY, textboxW, 300, 12, 12)

            love.graphics.setColor(1, 1, 1)
            love.graphics.setFont(font)

            local text = stage.text
            love.graphics.printf(text, textboxX + 20, textboxY + 20, textboxW - 40)

            love.graphics.setFont(font)
            love.graphics.print("Click to continue...", textboxX + 20, textboxY + 210)

            return
        end
    end

    local screenW, screenH = love.graphics.getWidth(), love.graphics.getHeight()
    love.graphics.setColor(backgroundColor)
    love.graphics.rectangle("fill", 0, 0, screenW, screenH)

    if currentMenu == "main" then
        if planetImage then
            local scale = 3
            local planetW = planetImage:getWidth() * scale
            local planetH = planetImage:getHeight() * scale
            local planetX = 100
            local planetY = screenH - planetH - 80
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(planetImage, planetX, planetY, 0, scale, scale)
        end

        if playerImage then
            local px = 200
            local py = 180
            local cx = playerImage:getWidth() / 2
            local cy = playerImage:getHeight() / 2
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(playerImage, px, py, playerAngle, 1, 1, cx, cy)
        end

        local rightX = screenW * 0.75
        local titleY = 160

        love.graphics.setFont(titleFont)
        local titleW = titleFont:getWidth(title)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(title, rightX - titleW / 2, titleY)


        love.graphics.setFont(font)
        for i, btn in ipairs(buttons) do
            local textW = font:getWidth(btn.label)
            local textH = font:getHeight()
            local x = rightX - textW / 2
            local y = 200 + i * 70

            love.graphics.setColor(0.2, 0.2, 0.2)
            love.graphics.rectangle("fill", x - 20, y - 10, textW + 40, textH + 20, 10, 10)

            love.graphics.setColor(1, 1, 1)
            love.graphics.print(btn.label, x, y)
        end
    elseif currentMenu == "gameover" then
    local screenW, screenH = love.graphics.getWidth(), love.graphics.getHeight()
    local textboxW = screenW * 0.6
    local textboxX = (screenW - textboxW) / 2
    local textboxY = screenH * 0.3

    love.graphics.setColor(0.1, 0.1, 0.1, 0.8)
    love.graphics.rectangle("fill", textboxX, textboxY, textboxW, 200, 12, 12)

    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont("fonts/PressStart2P-Regular.ttf", 20))
    love.graphics.printf(gameOverMessage, textboxX + 20, textboxY + 20, textboxW - 40)

    love.graphics.setFont(love.graphics.newFont("fonts/PressStart2P-Regular.ttf", 16))
    love.graphics.printf("Press ESC to return to main menu", textboxX + 20, textboxY + 150, textboxW - 40)

        elseif currentMenu == "death" then
    local screenW, screenH = love.graphics.getWidth(), love.graphics.getHeight()
    local textboxW = screenW * 0.6
    local textboxX = (screenW - textboxW) / 2
    local textboxY = screenH * 0.3

    love.graphics.setColor(0.1, 0.1, 0.1, 0.8)
    love.graphics.rectangle("fill", textboxX, textboxY, textboxW, 150, 12, 12)

    love.graphics.setColor(1, 0.2, 0.2)
    love.graphics.setFont(love.graphics.newFont("fonts/PressStart2P-Regular.ttf", 24))
    love.graphics.printf("You Died", textboxX + 20, textboxY + 20, textboxW - 40, "center")

    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(font)
    local label = "Exit to Main Menu"
    local textW = font:getWidth(label)
    local textH = font:getHeight()
    local btnX = screenW / 2 - textW / 2
    local btnY = textboxY + 80

    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", btnX - 20, btnY - 10, textW + 40, textH + 20, 10, 10)

    love.graphics.setColor(1, 1, 1)
    love.graphics.print(label, btnX, btnY)

    

    else
        love.graphics.setFont(titleFont)
        local titleW = titleFont:getWidth(title)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(title, screenW / 2 - titleW / 2, 100)

        love.graphics.setFont(font)
        for i, btn in ipairs(buttons) do
            local textW = font:getWidth(btn.label)
            local textH = font:getHeight()
            local x = screenW / 2 - textW / 2
            local y = 200 + i * 70

            love.graphics.setColor(0.2, 0.2, 0.2)
            love.graphics.rectangle("fill", x - 20, y - 10, textW + 40, textH + 20, 10, 10)

            love.graphics.setColor(1, 1, 1)
            love.graphics.print(btn.label, x, y)
        end
    end
end

function Menu.mousepressed(x, y, button)
    if button ~= 1 then return end

    local screenW = love.graphics.getWidth()
    local menuX = (currentMenu == "main") and (screenW * 0.75) or (screenW / 2)

    if cutsceneStage ~= nil then
        if cutsceneStage + 1 >= #cutsceneData then
            cutsceneStage = nil
            currentMenu = nil
            initGame()
        else
            cutsceneStage = cutsceneStage + 1
        end
        return
    end

        if currentMenu == "death" then
        local label = "Exit to Main Menu"
        local textW = font:getWidth(label)
        local textH = font:getHeight()
        local btnX = screenW / 2 - textW / 2
        local btnY = love.graphics.getHeight() * 0.3 + 80
        local boxW, boxH = textW + 40, textH + 20

        if x > btnX - 20 and x < btnX - 20 + boxW and y > btnY - 10 and y < btnY - 10 + boxH then
            Menu.load()
        end
        return
    end


    for i, btn in ipairs(buttons) do
        local textW = font:getWidth(btn.label)
        local textH = font:getHeight()
        local bx = menuX - textW / 2
        local by = 200 + i * 70
        local boxW, boxH = textW + 40, textH + 20

        if x > bx - 20 and x < bx - 20 + boxW and y > by - 10 and y < by - 10 + boxH then
            btn.action()
        end
    end
end

function Menu.isOpen()
    return currentMenu ~= nil
end

function Menu.showGameOver(orbCollected)
    currentMenu = "gameover"
    if orbCollected then
        gameOverMessage = "Mission complete. You’ve recovered the [REDACTED]. We are safe... for now."
    else
        gameOverMessage = "Mission complete. But the [REDACTED] was never found. What lies ahead is uncertain..."
    end
end



return Menu
