local Grinder = {}
Grinder.__index = Grinder

function Grinder.new(x,y, radius)
    local self = setmetatable({}, Grinder)
    self.x,self.y = x,y
    self.w,self.h = 32,32
    self.radius = radius or 100
    self.oilProduced = 0

    self.collider = world:newRectangleCollider(x,y,self.w,self.h)
    self.collider:setType("static")
    self.collider:setFixedRotation(true)
    return self
end

function Grinder:update(dt,items,player)
    local cx, cy = self.collider:getPosition()
    self.x = cx - self.w / 2
    self.y = cy - self.h / 2
    for _,item in ipairs(items) do
        if not item.picked and not item.consumed then
            local ix, iy = item.x + item.w/2, item.y + item.h/2
            local d = math.sqrt((self.x - ix)^2 + (self.y -iy)^2)
            if d<self.radius then
                item.consumed = true
                player.oil = player.oil + item.oilValue
                self.oilProduced = self.oilProduced + item.oilValue
            end
        end
    end
end

function Grinder:draw()
    love.graphics.setColor(0.2,0.8,1)
    love.graphics.rectangle("fill", self.x, self.y, self.w , self.h)
end

function Grinder:getYDraw()
    return self.y + self.h
end

return Grinder