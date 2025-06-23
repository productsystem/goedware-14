local Item = {}
Item.__index = Item

function Item.new(x,y)
    local self = setmetatable({}, Item)
    self.x,self.y = x,y
    self.w,self.h = 10,10
    self.picked = false
    return self
end

function Item:draw()
    if self.picked then
        return
    end
    love.graphics.setColor(1,1,0.2)
    love.graphics.rectangle("fill",self.x,self.y,self.w,self.h)
end

return Item