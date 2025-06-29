local Player = require("player")
local Entity = require("entity")
local Item = require("item")
local Grinder = require("grinder")
local Enemy = require("enemy")
local Rocket = require("rocket")
Menu = require("menu")
local Cutscene = require("cutscene")

local player
local entities = {}
local items = {}
local grinder
local walls = {}
local enemies = {}
local secretZone = {}
local secretFlowers = {}
local orbSpawned = false
local gameState = "menu"
local orbLoc = {}
local gameJustStarted = false

local oilFont

sti = require("libs.sti")
camera = require("libs.camera")
wf = require('libs.windfield')
anim8 = require('libs.anim8')

gameMap = nil
cam = nil
world = nil

local orbShineImg = love.graphics.newImage("sprites/orb_shine.png")
local orbBigImg = love.graphics.newImage("sprites/orb.png")

function lerp(a, b, t)
    return a + (b - a) * t
end

function startOrbCutscene(orbPos)
    local initialZoom = cam.scale
    local initialX, initialY = cam.x, cam.y
    local targetZoom = 2.5
    local targetX, targetY = orbPos.x, orbPos.y

    Cutscene.start({
        {
            duration = 0.6,
            update = function(t)
                cam:zoomTo(lerp(initialZoom, targetZoom, t))
                cam:lookAt(lerp(initialX, targetX, t), lerp(initialY, targetY, t))
            end,
            draw = function()
                love.graphics.draw(orbShineImg, orbPos.x - 32, orbPos.y - 32)
            end
        },
        {
            duration = 0.8,
            draw = function()
                love.graphics.draw(orbBigImg, orbPos.x - 16, orbPos.y - 16)
            end
        },
        {
            duration = 0.5,
            draw = function()
                local scale = 1 - Cutscene.timer / 0.5
                love.graphics.draw(orbBigImg, orbPos.x, orbPos.y, 0, scale, scale, 16, 16)
            end
        },
        {
            duration = 0.3,
            action = function()
                local orb = Item.new(orbPos.x, orbPos.y, "orb")
                table.insert(items, orb)
            end
        },
        {
            duration = 0.6,
            update = function(t)
                cam:zoomTo(lerp(targetZoom, 1, t))
                cam:lookAt(lerp(targetX, player.x, t), lerp(targetY, player.y, t))
            end
        }
    })
end

function startIntroCutscene()
    local initialZoom = cam.scale
    local initialX, initialY = player.x, player.y
    local targetZoom = 2.2
    local targetX, targetY = rocket.x + rocket.w / 2, rocket.y + rocket.h / 2

    Cutscene.start({
        {
            duration = 0.8,
            update = function(t)
                cam:zoomTo(lerp(initialZoom, targetZoom, t))
                cam:lookAt(lerp(initialX, targetX, t), lerp(initialY, targetY, t))
            end
        },
        {
            duration = 1.5, -- pause on rocket
        },
        {
            duration = 0.8,
            update = function(t)
                cam:zoomTo(lerp(targetZoom, 1, t))
                cam:lookAt(lerp(targetX, player.x, t), lerp(targetY, player.y, t))
            end
        },
        {
            duration = 0.1,
            action = function()
                gameJustStarted = false
            end
        }
    })
end


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
    
    player = nil
    entities = {}
    items = {}
    grinder = nil
    walls = {}
    enemies = {}
    secretZone = {}
    secretFlowers = {}
    orbSpawned = false
    orbLoc = {}
    gameJustStarted = false
    gameState = "game"
    local orbLoc = {}
    local gameJustStarted = false
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
            elseif obj.type == "Orb" then
                orbLoc = {x=obj.x,y=obj.y}
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
    gameJustStarted = true
    startIntroCutscene()
end

function updateGame(dt)
    if Cutscene.isActive() or gameJustStarted then
        Cutscene.update(dt)
        return
    end

    if not player.boarded then
        player:update(dt, entities, items, cam, enemies)
    end
    grinder:update(dt, items, player)
    rocket:update(dt, player)
    world:update(dt)

    love.keyboard.wasPressed = {}

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
                        startOrbCutscene(orbLoc)
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
    Cutscene.draw()
    cam:detach()

    drawOilUI()
    love.graphics.setColor(1, 1, 1, 1)
end

function drawOilUI()
    local oilText = "Oil: " .. tostring(player.oil)
    local padding = 10

    love.graphics.setFont(oilFont)
    local textW = oilFont:getWidth(oilText)
    local textH = oilFont:getHeight()

    local boxX = 20
    local boxY = 20
    local boxW = textW + padding * 2
    local boxH = textH + padding * 2

    love.graphics.setColor(0.1, 0.1, 0.1, 0.7)
    love.graphics.rectangle("fill", boxX, boxY, boxW, boxH, 12, 12)

    love.graphics.setColor(1, 1, 1)
    love.graphics.print(oilText, boxX + padding, boxY + padding)

    love.graphics.setColor(1, 1, 1, 1)
end


function love.load()
    oilFont = love.graphics.newFont("fonts/PressStart2P-Regular.ttf",24)
    love.window.setTitle("Project Oil")
    love.window.setMode(1280, 720)
    Menu.load()
end

function love.update(dt)
    if Menu.isOpen() then

    else
        updateGame(dt)
    end
end

function love.draw()
    if Menu.isOpen() then
        Menu.draw()
    else
        drawGame()
    end
end

function love.keypressed(key)
    if not love.keyboard.wasPressed then love.keyboard.wasPressed = {} end
    love.keyboard.wasPressed[key] = true

    if key == "escape" and not Menu.isOpen() then
        Menu.pause()
    end
end


function love.mousepressed(x, y, button)
    if Menu.isOpen() then
        Menu.mousepressed(x, y, button)
    end
end
