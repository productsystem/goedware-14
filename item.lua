local Item = {}
Item.__index = Item

local oilValues = {
    tree = 1,
    enemy = 3,
}

function Item.new(x,y,type)
    local self = setmetatable({}, Item)
    self.x,self.y = x,y
    self.w,self.h = 10,10
    self.picked = false
    self.itemType = type or "tree"
    self.oilValue = oilValues[self.itemType] or 1
    return self
end

function Item:draw()
    if self.picked or self.consumed then
        return
    end
    if self.itemType == "tree" then
        love.graphics.setColor(0.6, 0.4, 0.2)
    elseif self.itemType == "enemy" then
        love.graphics.setColor(1, 0.3, 0.3)
    end
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
end

function Item:getYDraw()
    return self.y + self.h
end

return Item