local Enemy = {}
Enemy.__index = Enemy

function Enemy.new(x,y,world)
    local self = setmetatable({},Enemy)
    self.x,self.y = x,y
    self.w,self.h = 32,32
    self.startX,self.startY = x,y
    self.speed = 100
    self.health = 3
    self.chaseRadius = 100
    self.leaveRadius = 200
    self.active = false

    self.collider = world:newRectangleCollider(x,y,self.w,self.h)
    self.collider:setFixedRotation(true)
    return self
end

function Enemy:update(dt,player)
    local px,py = player.x+player.w/2,player.y+player.h/2
    local ex,ey = self.x +self.w/2,self.y+self.h/2
    local dx,dy = px-ex,py-ey
    local dist = math.sqrt(dx*dx + dy*dy)

    if not self.active and dist<self.chaseRadius then
        self.active = true
    elseif self.active and dist>self.leaveRadius then
        self.active = false
    end

    if self.active then
        local nx,ny = dx/dist,dy/dist
        self.collider:setLinearVelocity(nx*self.speed,ny*self.speed)
    else
        self.collider:setLinearVelocity(0,0)
    end

    local cx,cy = self.collider:getPosition()
    self.x = cx-self.w/2
    self.y = cy-self.h/2
end

function Enemy:draw()
    love.graphics.setColor(1,0.3,0.3)
    love.graphics.rectangle("fill",self.x,self.y,self.w,self.h)
    
end

function Enemy:getYDraw()
    return self.y + self.h
end

function Enemy:takeDamage(amt)
    self.health = self.health - amt
end

function Enemy:isDead()
    return self.health <= 0
end

return Enemy