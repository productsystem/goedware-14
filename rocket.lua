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
    self.siphonRadius = 100
    self.image = love.graphics.newImage("sprites/rocket_scaled.png")
    self.collider = world:newRectangleCollider(self.x, self.y + self.h - 32, self.w, 32)
    self.collider:setType("static")
    self.collider:setCollisionClass("Rocket")
    self.collider:setUserData(self)
    self.launched = false
    self.boardingEnabled = false
    self.launchTimer = 0
    self.boardingRadius = 100
    self.markedGameOver = false
    self.orbReceived = false
    return self
end

function Rocket:update(dt, player)
    if self.launched then
        self.launchTimer = self.launchTimer + dt
        self.y = self.y - 60*dt
    end
    if not self.launched and self.currOil >= self.maxOil then
        self.finished = true
        self.boardingEnabled = true
    end

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
    if self.boardingEnabled then
        local px = player.x + player.w / 2
        local py = player.y + player.h / 2
        local bx = self.x + self.w / 2
        local by = self.y + self.h

        local dx = bx - px
        local dy = by - py
        local dist = math.sqrt(dx * dx + dy * dy)

        if dist < self.boardingRadius and love.keyboard.wasPressed and love.keyboard.wasPressed["e"] then
            self.launched = true
            player.boarded = true
            player.collider:setActive(false)
        end
        
    end
    if not self.orbReceived
        and player.holdingItem
        and player.holdingItem.itemType == "orb"
        and dist < self.boardingRadius
        and love.keyboard.wasPressed
        and love.keyboard.wasPressed["r"] then

        self.orbReceived = true
        player.holdingItem.consumed = true
        player.holdingItem = nil
    end


    if self.launched and self.launchTimer > 3 and not self.markedGameOver then
        local orbGot = self.orbReceived
        Menu.showGameOver(orbGot)
        self.markedGameOver = true
    end
end
function Rocket:draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.image, self.x, self.y)
    if not self.launched then
        love.graphics.setColor(0.2, 0.6, 1)
    local barW = self.w
    local fill = (self.currOil / self.maxOil)
    love.graphics.rectangle("fill", self.x, self.y - 10, barW * fill, 5)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Oil: " .. tostring(self.currOil) .. "/" .. self.maxOil, self.x, self.y + self.h + 5)
    else
        love.graphics.setColor(1, 1, 0)
        love.graphics.print("Launching...", self.x, self.y + self.h + 5)
    end
end

function Rocket:getYDraw()
    return self.y + self.h
end

return Rocket