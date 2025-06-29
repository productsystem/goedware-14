local Menu = {}

local currentMenu = nil
local buttons = {}
local font = love.graphics.newFont(24)
local titleFont = love.graphics.newFont(48)

local title = ""
local backgroundColor = {0.1, 0.1, 0.1, 0.8}

function Menu.load()
    currentMenu = "main"
    title = "Project Oil"
    backgroundColor = {0.05, 0.05, 0.05, 0.9}
    buttons = {
        { label = "Start Game", action = function()
            currentMenu = nil
            initGame()
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
end

function Menu.draw()
    love.graphics.setFont(font)
    love.graphics.setColor(backgroundColor)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setFont(titleFont)
    love.graphics.setColor(1, 1, 1)
    local titleW = titleFont:getWidth(title)
    love.graphics.print(title, love.graphics.getWidth()/2 - titleW/2, 100)

    love.graphics.setFont(font)
    for i, btn in ipairs(buttons) do
        local textW = font:getWidth(btn.label)
        local textH = font:getHeight()
        local x = love.graphics.getWidth() / 2 - textW / 2
        local y = 200 + i * 60

        love.graphics.setColor(0.2, 0.2, 0.2, 1)
        love.graphics.rectangle("fill", x - 20, y - 10, textW + 40, textH + 20, 10, 10)

        love.graphics.setColor(1, 1, 1)
        love.graphics.print(btn.label, x, y)
    end
end

function Menu.mousepressed(x, y, button)
    if button ~= 1 then return end
    for i, btn in ipairs(buttons) do
        local textW = font:getWidth(btn.label)
        local textH = font:getHeight()
        local bx = love.graphics.getWidth() / 2 - textW / 2
        local by = 200 + i * 60
        local boxW, boxH = textW + 40, textH + 20
        if x > bx - 20 and x < bx - 20 + boxW and y > by - 10 and y < by - 10 + boxH then
            btn.action()
        end
    end
end

function Menu.isOpen()
    return currentMenu ~= nil
end

function Menu.showGameOver()
    currentMenu = "gameover"
    title = "Mission Complete"
    backgroundColor = {0, 0, 0, 0.8}
    buttons = {
        { label = "Exit to Menu", action = function()
            Menu.load()
        end },
        { label = "Quit", action = function()
            love.event.quit()
        end }
    }
end


return Menu
