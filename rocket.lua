local Rocket = {}
Rocket.__index = Rocket

function Rocket.new(x,y,maxOil)
    local self = setmetatable({}, Rocket)
    self.x,self.y = x,y
    self.w,self.h = 32,64
    self.maxOil = maxOil or 50
    self.currOil = 0
    self.finished = false
    self.siphonTimer = 0
    self.siphonBuffer = 0
    return self
end

function Rocket:update(dt,player)
    if self.finished then return end
    if player.oil > 1 and love.keyboard.isDown("r") then
        self.siphonTimer = self.siphonTimer + dt
        local rate = math.min(1 + self.siphonTimer * 2,10)
        self.siphonBuffer = self.siphonBuffer + rate*dt
        if self.siphonBuffer >0 then
            local amount = math.floor(self.siphonBuffer)
            local transfer = math.min(amount,player.oil,self.maxOil-self.currOil)
            player.oil = player.oil - transfer
            self.currOil = self.currOil + transfer
            self.siphonBuffer = self.siphonBuffer - transfer

            if self.currOil >=self.maxOil then
                self.currOil = self.maxOil
                self.finished = true
            end
        end
    else
        self.siphonTimer = 0
        self.siphonBuffer = 0
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