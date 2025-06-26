local Rocket = {}
Rocket.__index = Rocket

function Rocket.new(x,y,maxOil,world)
    local self = setmetatable({}, Rocket)
    self.x,self.y = x,y
    self.w,self.h = 64,192
    self.maxOil = maxOil or 50
    self.currOil = 0
    self.finished = false
    self.siphonTimer = 0
    self.siphonBuffer = 0
    self.siphonRadius = 64
    self.image = love.graphics.newImage("sprites/rocket_scaled.png")
    self.collider = world:newRectangleCollider(self.x, self.y + self.h - 32, self.w, 32)
    self.collider:setType("static")
    self.collider:setCollisionClass("Rocket")
    self.collider:setUserData(self)
    return self
end

function Rocket:update(dt, player)
    if self.finished then return end

    local playerX = player.x + player.w / 2
    local playerY = player.y + player.h / 2
    local baseX = self.x + self.w / 2
    local baseY = self.y + self.h

    local dx = baseX - playerX
    local dy = baseY - playerY
    local dist = math.sqrt(dx * dx + dy * dy)

    if dist <= self.siphonRadius and player.oil > 1 and love.keyboard.isDown("r") then
        self.siphonTimer = self.siphonTimer + dt
        local rate = math.min(1 + self.siphonTimer * 2, 10)
        self.siphonBuffer = self.siphonBuffer + rate * dt
        if self.siphonBuffer > 0 then
            local amount = math.floor(self.siphonBuffer)
            local transfer = math.min(amount, player.oil, self.maxOil - self.currOil)
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
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.image, self.x, self.y)
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