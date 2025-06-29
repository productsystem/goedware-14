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
local secretZone = {}
local secretFlowers = {}
local orbSpawned = false

sti = require("libs.sti")
camera = require("libs.camera")
wf = require('libs.windfield')
anim8 = require('libs.anim8')

gameMap = nil
cam = nil
world = nil

local function getResourceTypeFromGID(gid)
    for _, tileset in ipairs(gameMap.tilesets) do
        local firstgid = tileset.firstgid
        local tileid = gid - firstgid
        for _, tile in ipairs(tileset.tiles) do
            if tile.id == tileid then
                if tile.properties and tile.properties["resourceType"] then
                    return tile.properties["resourceType"]
                end
            end
        end
    end
    return nil
end

function initGame()
    love.graphics.setDefaultFilter("nearest", "nearest")
    math.randomseed(os.time())
    love.window.setTitle("Project Oil")
    love.window.setMode(1280, 720)

    gameMap = sti('maps/playMap.lua')
    cam = camera()
    cam:zoomTo(1)

    world = wf.newWorld(0, 0)
    world:addCollisionClass("Player")
    world:addCollisionClass("Enemy")
    world:addCollisionClass("Rocket")
    world:setCallbacks(function(fixtureA, fixtureB, coll)
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
    end)

    -- Load entities
    if gameMap.layers["Objects"] then
        for _, obj in ipairs(gameMap.layers["Objects"].objects) do
            if obj.gid then
                local heightOffset = 0
                for _, tileset in ipairs(gameMap.tilesets) do
                    local firstgid = tileset.firstgid
                    local tileid = obj.gid - firstgid
                    for _, tile in ipairs(tileset.tiles) do
                        if tile.id == tileid then
                            heightOffset = tile.height or gameMap.tileheight
                        end
                    end
                end
                local x, y = obj.x, obj.y - heightOffset
                local resourceType = getResourceTypeFromGID(obj.gid)
                local entity = Entity.new(x, y, obj.gid, resourceType, world)
                table.insert(entities, entity)
                if obj.name == "flower_secret" then
                    table.insert(secretFlowers, entity)
                end
            end
        end
    end

    if gameMap.layers["Entities"] then
        for _, obj in ipairs(gameMap.layers["Entities"].objects) do
            if obj.type == "Enemy" then
                table.insert(enemies, Enemy.new(obj.x, obj.y, world))
            elseif obj.type == "Player" then
                player = Player.new(obj.x, obj.y, world)
            elseif obj.type == "Grinder" then
                grinder = Grinder.new(obj.x, obj.y)
            elseif obj.type == "Rocket" then
                rocket = Rocket.new(obj.x, obj.y, 10, world)
            end
        end
    end

    if gameMap.layers["Secret"] then
        for _, obj in ipairs(gameMap.layers["Secret"].objects) do
            if obj.name == "secret_zone" then
                secretZone = { x = obj.x, y = obj.y, w = obj.width, h = obj.height }
            end
        end
    end
end

function updateGame(dt)
    if player.boarded then return end -- freeze game logic when launched

    player:update(dt, entities, items, cam, enemies)
    grinder:update(dt, items, player)
    rocket:update(dt, player)
    world:update(dt)

    love.keyboard.wasPressed = {}

    -- Update player position based on collider
    if player.collider then
        local cx, cy = player.collider:getPosition()
        player.x = cx - player.w / 2
        player.y = cy - 48
    end

    for _, e in ipairs(entities) do e:update(dt) end
    for i = #entities, 1, -1 do if entities[i].harvested then table.remove(entities, i) end end

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

    -- Camera follow
    cam:lookAt(player.x, player.y)
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()
    local mapW = gameMap.width * gameMap.tilewidth
    local mapH = gameMap.height * gameMap.tileheight
    cam.x = math.max(w / 2, math.min(mapW - w / 2, cam.x))
    cam.y = math.max(h / 2, math.min(mapH - h / 2, cam.y))

    -- Secret orb logic
    if not orbSpawned and secretZone then
        local allAlive = true
        for _, flower in ipairs(secretFlowers) do
            if flower.harvested then allAlive = false break end
        end
        if allAlive then
            for _, item in ipairs(items) do
                if not item.picked and item.itemType == "flower" then
                    local ix, iy = item.x + item.w / 2, item.y + item.h / 2
                    if ix >= secretZone.x and ix <= secretZone.x + secretZone.w and
                       iy >= secretZone.y and iy <= secretZone.y + secretZone.h then
                        orbSpawned = true
                        local orb = Item.new(secretZone.x, secretZone.y, "orb")
                        table.insert(items, orb)
                        item.picked = true
                        break
                    end
                end
            end
        end
    end
end

function drawGame()
    cam:attach()
    local drawables = {}

    gameMap:drawLayer(gameMap.layers["Ground"])
    table.insert(drawables, player)
    for _, e in ipairs(entities) do table.insert(drawables, e) end
    for _, i in ipairs(items) do table.insert(drawables, i) end
    for _, e in ipairs(enemies) do table.insert(drawables, e) end
    table.insert(drawables, grinder)
    table.insert(drawables, rocket)

    table.sort(drawables, function(a, b)
        return a:getYDraw() < b:getYDraw()
    end)

    for _, obj in ipairs(drawables) do obj:draw() end
    world:draw()
    cam:detach()

    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.print("Oil : " .. tostring(player.oil), 10, 10)
    love.graphics.setColor(1, 1, 1, 1)
end

function love.load()
    initGame()
end

function love.update(dt)
    updateGame(dt)
end

function love.draw()
    drawGame()
end

function love.keypressed(key)
    if not love.keyboard.wasPressed then love.keyboard.wasPressed = {} end
    love.keyboard.wasPressed[key] = true
end