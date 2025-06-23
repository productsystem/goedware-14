local Player = require("player")
local Entity = require("entity")
local Item = require("item")
local Grinder = require("grinder")

local player
local entities = {}
local items = {}
local grinder

function love.load()
    love.window.setTitle("Project Oil")
    love.window.setMode(800,600)

    player = Player.new(400,300)
    grinder = Grinder.new(600,400)

    for _ = 1, 10 do
        local x = math.random(100, 700)
        local y = math.random(100, 500)
        table.insert(entities, Entity.new(x, y))
    end

end

function love.update(dt)
    player:update(dt,entities,items)
    grinder:update(dt,items,player)
    love.keyboard.wasPressed = {}
end

function love.draw()
    player:draw()

    for _,e in ipairs(entities) do
        e:draw()
    end

    for _,i in ipairs(items) do
        i:draw()
    end

    grinder:draw()

    love.graphics.setColor(1,1,1,1)
    love.graphics.print("Oil : " .. tostring(player.oil), 10,10)
    love.graphics.print("Player: " .. math.floor(player.x) .. ", " .. math.floor(player.y), 10, 30)
    love.graphics.print(_VERSION, 10, 50)

end

function love.keypressed(key)
    if not love.keyboard.wasPressed then love.keyboard.wasPressed = {} end
    love.keyboard.wasPressed[key] = true
    
end