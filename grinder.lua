local Grinder = {}
Grinder.__index = Grinder

function Grinder.new(x,y, radius)
    local self = setmetatable({}, Grinder)
    self.x,self.y = x,y
    self.w,self.h = 64,64
    self.radius = radius or 100
    self.oilProduced = 0

    self.collider = world:newRectangleCollider(x,y,self.w,self.h)
    self.collider:setType("static")
    self.collider:setFixedRotation(true)
    self.image = love.graphics.newImage("sprites/grinder.png")
    return self
end

function Grinder:update(dt,items,player)
    local cx, cy = self.collider:getPosition()
    self.x = cx - self.w / 2
    self.y = cy - self.h / 2
    for i = #items, 1, -1 do
        local item = items[i]
        if not item.picked and not item.consumed then
            local ix, iy = item.x + item.w/2, item.y + item.h/2
            local d = math.sqrt((self.x - ix)^2 + (self.y - iy)^2)
            if d < self.radius then
                player.oil = player.oil + item.oilValue
                self.oilProduced = self.oilProduced + item.oilValue
                table.remove(items, i)
            end
        end
    end
end

function Grinder:draw()
    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(self.image,self.x,self.y)
end

function Grinder:getYDraw()
    return self.y + self.h
end

return Grinder