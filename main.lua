local Player = require("player")
local Entity = require("entity")
local Item = require("item")
local Grinder = require("grinder")

local player
local entities = {}
local items = {}
local grinder

sti = require("libs.sti")
gameMap = sti('maps/testMap.lua')
camera = require("libs.camera")
cam = camera()
wf = require('libs.windfield')
world = wf.newWorld(0,0)

local walls = {}

function love.load()
    love.window.setTitle("Project Oil")
    love.window.setMode(800,600)

    player = Player.new(400,300,world)
    grinder = Grinder.new(600,400)
    

    for _ = 1, 10 do
        local x = math.random(100, 700)
        local y = math.random(100, 500)
        table.insert(entities, Entity.new(x, y))
    end

    if gameMap.layers["Walls"] then
        for i,o in ipairs(gameMap.layers["Walls"].objects) do
            local wall = world:newRectangleCollider(o.x,o.y,o.width,o.height)
            wall:setType('static')
            table.insert(walls, wall)
        end
    end

end

function love.update(dt)
    player:update(dt,entities,items,cam)
    grinder:update(dt,items,player)
    love.keyboard.wasPressed = {}

    world:update(dt)

    player.x = player.collider:getX()
    player.y = player.collider:getY()

    cam:lookAt(player.x,player.y)
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()

    if cam.x < w/2 then
        cam.x = w/2
    end

    if cam.y < h/2 then
        cam.y = h/2
    end

    local mapW = gameMap.width * gameMap.tilewidth
    local mapH = gameMap.height * gameMap.tileheight

    if cam.x > (mapW - w/2) then
        cam.x = mapW - w/2
    end
    if cam.y > (mapH - h/2) then
        cam.y = (mapH - h/2)
    end
end

function love.draw()
    cam:attach()
        gameMap:drawLayer(gameMap.layers["Ground"])
        gameMap:drawLayer(gameMap.layers["Trees"])
        player:draw()

        for _,e in ipairs(entities) do
            e:draw()
        end

        for _,i in ipairs(items) do
            i:draw()
        end

        grinder:draw()
        world:draw()
    cam:detach()
    love.graphics.setColor(1,1,1,1)
    love.graphics.print("Oil : " .. tostring(player.oil), 10,10)
    love.graphics.print("Player: " .. math.floor(player.x) .. ", " .. math.floor(player.y), 10, 30)
    love.graphics.print(_VERSION, 10, 50)

end

function love.keypressed(key)
    if not love.keyboard.wasPressed then love.keyboard.wasPressed = {} end
    love.keyboard.wasPressed[key] = true
    
end