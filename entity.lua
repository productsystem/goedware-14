local Entity = {}
Entity.__index = Entity

local imageCache = {} --so that images load only once


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

function Entity.new(x,y,gid,resourceType)
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
    return self
end

function Entity:draw()
    if self.harvested then
        return
    end

    if self.image then
        love.graphics.setColor(1,1,1)
        love.graphics.draw(self.image,self.x,self.y)
    else
        love.graphics.setColor(0.2,0.8,0.4)
        love.graphics.rectangle("fill",self.x,self.y,self.w,self.h)
    end
end

return Entity
