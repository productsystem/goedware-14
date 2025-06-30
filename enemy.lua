local Enemy = {}
Enemy.__index = Enemy

local anim8 = require("libs.anim8")
local hitSound = love.audio.newSource("sounds/harvest.wav", "static")

function Enemy.new(x,y,world)
    local self = setmetatable({},Enemy)
    self.x,self.y = x,y
    self.w,self.h = 64,64
    self.startX,self.startY = x,y
    self.speed = 100
    self.health = 3
    self.chaseRadius = 150
    self.leaveRadius = 250
    self.active = false

    self.collider = world:newRectangleCollider(x, y, self.w, self.h)
    self.collider:setFixedRotation(true)
    self.collider:getBody():setUserData(self)
    self.tag = "Enemy"
    self.image = love.graphics.newImage("sprites/crab.png")
    local g = anim8.newGrid(64,64,self.image:getWidth(),self.image:getHeight())
    self.animations = {
        idle=anim8.newAnimation(g('1-1',1),1),
        walk = anim8.newAnimation(g('1-4',1),0.1),
    }
    self.currentAnim = self.animations.idle
    self.hitFlashTimer = 0
    self.hitFlashDuration = 0.2

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

    if self.active then
        self.currentAnim = self.animations.walk
    else
        self.currentAnim = self.animations.idle
    end

    self.currentAnim:update(dt)
    if self.hitFlashTimer > 0 then
        self.hitFlashTimer = self.hitFlashTimer - dt
    end
end

function Enemy:draw()
    if self.hitFlashTimer > 0 then
        love.graphics.setColor(1, 0.4, 0.4, 0.6)
    else
        love.graphics.setColor(1, 1, 1, 1)
    end

    self.currentAnim:draw(self.image, self.x, self.y)
    love.graphics.setColor(1, 1, 1, 1)
end

function Enemy:getYDraw()
    return self.y + self.h
end

function Enemy:takeDamage(amt)
    self.health = self.health - amt
    hitSound:stop()
    hitSound:setPitch(0.9 + math.random() * 0.2)
    hitSound:play()
    self.hitFlashTimer = self.hitFlashDuration
end


function Enemy:isDead()
    return self.health <= 0
end

return Enemy