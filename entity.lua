local Entity = {}
Entity.__index = Entity

function Entity.new(x,y)
    local self = setmetatable({}, Entity)
    self.x,self.y = x,y
    self.w,self.h = 20,20
    self.harvested = false
    return self
end

function Entity:draw()
    if self.harvested then
        return
    end
    love.graphics.setColor(0.2,0.8,0.4)
    love.graphics.rectangle("fill", self.x,self.y,self.w,self.h)
    
end

return Entity