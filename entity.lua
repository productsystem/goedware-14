local Entity = {}
Entity.__index = Entity

local imageCache = {} --so that images load only once
local hitSound = love.audio.newSource("sounds/harvest.wav", "static")


local function getTileImageFromGID(gid)
    if imageCache[gid] then return imageCache[gid] end

    for _, tileset in ipairs(gameMap.tilesets) do
        local firstgid = tileset.firstgid
        local tileid = gid - firstgid
        for _, tile in ipairs(tileset.tiles) do
            if tile.id == tileid then
                local path = tile.image:gsub("%.%.%/", "") --remove the ../
                local img = love.graphics.newImage(path)
                imageCache[gid] = img
                return img
            end
        end
    end
    return nil
end

function Entity.new(x,y,gid,resourceType,world)
    local self = setmetatable({}, Entity)
    self.x,self.y = x,y
    self.gid = gid
    self.type = resourceType or "tree"
    local image = getTileImageFromGID(gid)
    self.image = image
    if image then
        self.w = image:getWidth()
        self.h = image:getHeight()
    else
        self.w, self.h = 32, 64
    end
    self.harvested = false
    self.hitTimer = 0
    self.hitDuration = 0.2
    if self.type == "tree" then
        self.health = 2
        local cx = x
        local cy = y + self.h - 16
        self.collider = world:newRectangleCollider(cx, cy, 32, 16)
        self.collider:setType("static")
    elseif self.type == "rock" then
        self.health = 3
        local cx = x
        local cy = y
        self.collider = world:newRectangleCollider(cx, cy, 32, 32)
        self.collider:setType("static")
    elseif self.type == "flower" then
        self.health = 1
        self.collider = nil
    end
    return self
end

function Entity:draw()
    if self.harvested then return end

    local alpha = 1
    if self.hitTimer > 0 then
        alpha = 0.5 + 0.5 * math.sin(self.hitTimer * 50) -- flicker effect
    end

    love.graphics.setColor(1, 1, 1, alpha)

    if self.image then
        love.graphics.draw(self.image, self.x, self.y)
    else
        love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
    end

    love.graphics.setColor(1, 1, 1, 1)
end

function Entity:getYDraw()
    return self.y + self.h
end

function Entity:hit()
    self.health = self.health - 1
    self.hitTimer = self.hitDuration
    hitSound:stop()
    hitSound:setPitch(0.9 + math.random() * 0.2)
    hitSound:play()
    if self.health <= 0 then
        self.harvested = true
        if self.collider then
            self.collider:destroy()
            self.collider = nil
        end
    end
end

function Entity:update(dt)
    if self.hitTimer > 0 then
        self.hitTimer = self.hitTimer - dt
    end
end


return Entity
