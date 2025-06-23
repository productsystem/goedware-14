local Player = require("player")
local Entity = require("entity")

local player
local entities = {}

function love.load()
    love.window.setTitle("Project Oil")
    love.window.setMode(800,600)

    player = Player.new(400,300)

    for _ = 1, 10 do
        local x = math.random(100, 700)
        local y = math.random(100, 500)
        table.insert(entities, Entity.new(x, y))
    end

end

function love.update(dt)
    player:update(dt,entities)
end

function love.draw()
    player:draw()

    for _,e in ipairs(entities) do
        e:draw()
    end

    love.graphics.setColor(1,1,1,1)
    love.graphics.print("Oil : " .. tostring(player.oil), 10,10)
    love.graphics.print("Player: " .. math.floor(player.x) .. ", " .. math.floor(player.y), 10, 30)

end