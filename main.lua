local Player = require("player")
local Entity = require("entity")
local Item = require("item")
local Grinder = require("grinder")
local Enemy = require("enemy")
local Rocket = require("rocket")

local player
local entities = {}
local items = {}
local grinder
local walls = {}
local enemies = {}

sti = require("libs.sti")
camera = require("libs.camera")
wf = require('libs.windfield')

gameMap = sti('maps/testMap.lua')
cam = camera()
world = wf.newWorld(0,0) --no gravity
world:addCollisionClass("Player")
world:addCollisionClass("Enemy")

world:setCallbacks(
    function(fixtureA, fixtureB, coll)
        local bodyA = fixtureA:getBody()
        local bodyB = fixtureB:getBody()
        local objA = bodyA:getUserData()
        local objB = bodyB:getUserData()

        if not objA or not objB then return end

        if objA.tag == "Player" and objB.tag == "Enemy" then
            objA:takeDamage(1)
        elseif objA.tag == "Enemy" and objB.tag == "Player" then
            objB:takeDamage(1)
        end
    end
)

function love.load()
    math.randomseed(os.time())
    love.window.setTitle("Project Oil")
    love.window.setMode(800,600)

    player = Player.new(400,300,world)
    grinder = Grinder.new(600,400)
    rocket = Rocket.new(700,300,50)

    if gameMap.layers["Objects"] then
        for _,obj in ipairs(gameMap.layers["Objects"].objects) do
            if obj.gid then
                local x,y = obj.x,obj.y
                local tree = Entity.new(x,y,obj.gid,"tree")
                table.insert(entities,tree)

                local cx = x
                local cy = y + obj.height - 32
                local collider = world:newRectangleCollider(cx,cy,32,32)
                collider:setType("static")
                tree.collider = collider
            end
        end
    end
    if gameMap.layers["Entities"] then
        for _,obj in ipairs(gameMap.layers["Entities"].objects) do
            if obj.type == "Enemy" then
                table.insert(enemies,Enemy.new(obj.x,obj.y,world))
            end
        end
    end
end

function love.update(dt)
    player:update(dt,entities,items,cam,enemies)
    grinder:update(dt,items,player)
    rocket:update(dt,player)
    love.keyboard.wasPressed = {}

    world:update(dt)

    --we basically move the collider and set the the player pos accordingly
    local cx, cy = player.collider:getPosition() 
    player.x = cx - player.w / 2
    player.y = cy - player.h / 2

    cam:lookAt(player.x,player.y)
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()

    --cam bounds check

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

    for i = #entities, 1, -1 do
        if entities[i].harvested then
            table.remove(entities, i)
        end
    end

    for i = #enemies, 1, -1 do
        local e = enemies[i]
        e:update(dt, player)

        if e:isDead() then
            local item = Item.new(e.x + e.w / 2, e.y + e.h / 2, "enemy")
            table.insert(items, item)
            e.collider:destroy()
            table.remove(enemies, i)
        end
    end
end

function love.draw()
    cam:attach()
        local drawables ={}

        gameMap:drawLayer(gameMap.layers["Ground"])
        table.insert(drawables,player)
        for _, e in ipairs(entities) do
            table.insert(drawables, e)
        end

        for _, i in ipairs(items) do
            table.insert(drawables, i)
        end

        for _, e in ipairs(enemies) do
            table.insert(drawables, e)
        end

        table.insert(drawables, grinder)
        table.insert(drawables,rocket)

        table.sort(drawables,function (a,b)
            return a:getYDraw() < b:getYDraw()
        end)

        for _, obj in ipairs(drawables) do
            obj:draw()
        end
        world:draw()
    cam:detach()
    love.graphics.setColor(0,0,0,1)
    love.graphics.print("Oil : " .. tostring(player.oil), 10,10)
    love.graphics.print("Player: " .. math.floor(player.x) .. ", " .. math.floor(player.y), 10, 30)
    love.graphics.print(_VERSION, 10, 50)
    love.graphics.setColor(1,1,1,1)
end

function love.keypressed(key)
    if not love.keyboard.wasPressed then love.keyboard.wasPressed = {} end
    love.keyboard.wasPressed[key] = true
end