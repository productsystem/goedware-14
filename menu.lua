local Menu = {}

Menu.buttons = {
    start = {x=540, y= 300, w = 200, h = 50, text = "Start"},
    exit = { x=540,y=370,w=200,h=50,text = "Exit"},
}

function Menu.draw()
    love.graphics.setBackgroundColor(0.1, 0.1, 0.1)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("PROJECT OIL", 0, 150, 1280, "center")

    for _, btn in pairs(Menu.buttons) do
        love.graphics.setColor(0.2, 0.6, 1)
        love.graphics.rectangle("fill", btn.x, btn.y, btn.w, btn.h, 10)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(btn.text, btn.x, btn.y + 15, btn.w, "center")
    end
end

function Menu.mousepressed(x, y, button)
    if button ~= 1 then return end
    local bx = Menu.buttons

    if x > bx.start.x and x < bx.start.x + bx.start.w and y > bx.start.y and y < bx.start.y + bx.start.h then
        return "start"
    elseif x > bx.exit.x and x < bx.exit.x + bx.exit.w and y > bx.exit.y and y < bx.exit.y + bx.exit.h then
        return "exit"
    end
    return nil
end

return Menu