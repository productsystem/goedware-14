local Rocket = {}
Rocket.__index = Rocket

function Rocket.new(x,y,maxOil)
    local self = setmetatable({}, Rocket)
    self.x,self.y = x,y
    self.w,self.h = 32,64
    self.maxOil = maxOil or 50
    self.currOil = 0
    self.finished = false
    return self
end

function Rocket:update(dt,player)
    if not self.finished and player.holdingItem and love.keyboard.wasPressed and love.keyboard.wasPressed["r"] then
        local item = player.holdingItem
        if item and item.oilValue then
            self.currOil = self.currOil + item.oilValue
            player.holdingItem = nil
            if self.currOil >= self.maxOil then
                self.finished = true
            end
        end
    end
end
function Rocket:draw()
    if self.finished then
        love.graphics.setColor(0,1,0)
    else
        love.graphics.setColor(0.8,0.8,0.8)
    end
    love.graphics.rectangle("fill",self.x,self.y,self.w,self.h)
    love.graphics.setColor(0.2, 0.6, 1)
    local barW = self.w
    local fill = (self.currOil / self.maxOil)
    love.graphics.rectangle("fill", self.x, self.y - 10, barW * fill, 5)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Oil: " .. tostring(self.currOil) .. "/" .. self.maxOil, self.x, self.y + self.h + 5)
end

function Rocket:getYDraw()
    return self.y + self.h
end

return Rocket