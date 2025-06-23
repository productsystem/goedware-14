local Player = {}
--simulates OOP
Player.__index = Player

function Player.new(x,y)
    --lookup meta data from the table
    local self = setmetatable({}, Player)
    self.x,self.y = x,y
    self.w,self.h = 20,20
    self.speed = 200
    self.oil = 0
    self.attackRadius = 40
    self.angle = 0
    self.swingTimer = 0
    self.swingDuration = 0.2
    return self
end

--Player:update(dt) == Player.update(self,dt)
function Player:update(dt,entities)
    local dx,dy =0,0
    if love.keyboard.isDown("w") then
        dy = dy-1
    end
    if love.keyboard.isDown("s") then
        dy = dy+1
    end
    if love.keyboard.isDown("a") then
        dx = dx-1
    end
    if love.keyboard.isDown("d") then
        dx = dx+1
    end

    local len = math.sqrt(dx*dx + dy*dy)
    if len>0 then
        self.x = self.x + (dx/len) * self.speed * dt
        self.y = self.y + (dy/len) * self.speed * dt
    end

    local mx,my = love.mouse.getPosition()
    local px,py = self.x + self.w/2, self.y + self.h/2
    self.angle = math.atan2(my-py,mx-px)

    if love.mouse.isDown(1) and self.swingTimer <= 0 then
        self.swingTimer = self.swingDuration
    end

    if(self.swingTimer > 0) then
        self.swingTimer = self.swingTimer - dt
        for _, e in ipairs(entities) do
    if not e.harvested then
        local ex = e.x + e.w / 2
        local ey = e.y + e.h / 2
        local px = self.x + self.w / 2
        local py = self.y + self.h / 2
        local dx = ex - px
        local dy = ey - py
        local dist = math.sqrt(dx * dx + dy * dy)

        if dist < self.attackRadius then
            local angleToEntity = math.atan2(dy, dx)
            local diff = math.abs(angleToEntity - self.angle)

            if diff > math.pi then
                diff = 2 * math.pi - diff
            end

            if diff < math.rad(30) then
                e.harvested = true
                self.oil = self.oil + 1
            end
        end
    end
end
    end
end  

function Player:draw()
    love.graphics.setColor(1,1,0,1)
    love.graphics.push()
    local cx,cy = self.x + self.w/2,self.y + self.h/2
    love.graphics.translate(cx,cy)
    love.graphics.rotate(self.angle)
    love.graphics.rectangle("fill", -self.w/2,-self.h/2, self.w,self.h)
    if(self.swingTimer > 0) then
        local alpha = self.swingTimer/self.swingDuration
        love.graphics.setColor(1,0.5,0,alpha)
        love.graphics.rectangle("fill", self.w/2, 0, 10,30) --TODO: Change
    end
    love.graphics.pop()
end

return Player