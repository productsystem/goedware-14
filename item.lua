local Item = {}
Item.__index = Item

local oilValues = {
    tree = 1,
    enemy = 3,
}

function Item.new(x,y,type)
    local self = setmetatable({}, Item)
    self.x,self.y = x,y
    self.w,self.h = 16,16
    self.picked = false
    self.itemType = type or "tree"
    self.oilValue = oilValues[self.itemType] or 1
    if(self.itemType == "tree") then
        self.image = love.graphics.newImage("sprites/wood_item.png")
    elseif(self.itemType == "enemy") then
        self.image = love.graphics.newImage("sprites/crab_item.png")
    end
    return self
end

function Item:draw()
    if self.picked or self.consumed then
        return
    end
    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(self.image,self.x,self.y)
end

function Item:getYDraw()
    return self.y + self.h
end

return Item