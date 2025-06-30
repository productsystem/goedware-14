local Player = {}

local Item = require("item")
--simulates OOP
Player.__index = Player

hitSound = love.audio.newSource("sounds/player_damage.wav", "static")

function Player.new(x,y,world)
    --lookup meta data from the table
    local self = setmetatable({}, Player)
    self.x,self.y = x,y
    self.w,self.h = 32,64
    self.speed = 200
    self.oil = 10
    self.attackRadius = 100
    self.angle = 0
    self.swingTimer = 0
    self.swingDuration = 0.2
    local colliderW, colliderH = 32, 32
    local cx = x + self.w / 2
    local cy = y + self.h - colliderH/2
    self.collider = world:newBSGRectangleCollider(cx, cy, colliderW, colliderH, 5)
    self.collider:setFixedRotation(true)
    self.collider:getBody():setUserData(self)
    self.image = love.graphics.newImage("sprites/player_anim.png")
    local g = anim8.newGrid(32, 64, self.image:getWidth(), self.image:getHeight())
    self.animations = {
        down = {
            idle = anim8.newAnimation(g('1-1',1), 0.5),
            walk = anim8.newAnimation(g('1-2',1), 0.2)
        },
        right = {
            idle = anim8.newAnimation(g('3-3',1), 0.5),
            walk = anim8.newAnimation(g('3-4',1), 0.2)
        },
        up = {
            idle = anim8.newAnimation(g('5-5',1), 0.5),
            walk = anim8.newAnimation(g('5-6',1), 0.2)
        }
    }
    self.currentDir = "down"
    self.moving = false
    self.facingLeft = false
    self.currentAnim = self.animations.down.idle
    self.tag = "Player"
    self.holdingItem = nil
    self.hitEntities = {}
    self.invincible = false
    self.invincibilityTimer = 0
    self.invincibilityDuration = 1
    self.boarded = false
    self.dead = false
    return self
end

--Player:update(dt) == Player.update(self,dt)
function Player:update(dt,entities,items, cam,enemies)
    if self.boarded or not self.collider then return end
    self:handleMovement(dt,cam)
    if self:canAttack() then
        self.swingTimer = self.swingDuration
        self.hitEntities = {}
    end

    if(self.swingTimer > 0) then
        self.swingTimer = self.swingTimer - dt
        self:attemptSlash(entities,items,enemies)
    end

    if love.keyboard.wasPressed and love.keyboard.wasPressed["e"] then
        self:pickupAndDrop(items)
    end

    if self.invincible then
        self.invincibilityTimer = self.invincibilityTimer -dt
        if self.invincibilityTimer <= 0 then
            self.invincible = false
        end
    end
    if self.moving then
        self.currentAnim = self.animations[self.currentDir].walk
    else
        self.currentAnim = self.animations[self.currentDir].idle
    end

    self.currentAnim:update(dt)

end

function Player:die()
    Menu.showDeath()
end

function Player:takeDamage(amt)
    if not self.invincible and self.oil > 0 then
        self.oil = self.oil - amt
        self.invincible = true
        self.invincibilityTimer = self.invincibilityDuration
        hitSound:play()
    end

    if self.oil <= 0 and not self.dead then
        self.dead = true
        self:die()
    end
end

function Player:pickupAndDrop(items)
    if self.holdingItem then
        self.holdingItem.x = self.x + self.w/2 - self.holdingItem.w/2
        self.holdingItem.y = self.y + self.h/2 - self.holdingItem.h/2
        self.holdingItem.picked = false
        self.holdingItem = nil
    else
        local px,py = self.x + self.w/2,self.y + self.h/2
        for _,item in ipairs(items) do
            if not item.picked then
                local ix,iy = item.x + item.w/2, item.y + item.h/2
                if math.sqrt((px-ix)^2 + (py-iy)^2) < 30 then
                    item.picked = true
                    self.holdingItem = item
                    break
                end
            end
        end
    end
    
end

function Player:attemptSlash(entities,items,enemies)
    for _, e in ipairs(entities) do
        if not e.harvested and not self.hitEntities[e] then
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
                    e:hit()
                    self.hitEntities[e] = true
                    if e.harvested then
                        local item = Item.new(e.x + e.w / 2, e.y + e.h / 2, e.type)
                        table.insert(items, item)
                    end
                end
            end
        end
    end
    for _, enemy in ipairs(enemies) do
        local ex = enemy.x + enemy.w / 2
        local ey = enemy.y + enemy.h / 2
        local px = self.x + self.w / 2
        local py = self.y + self.h / 2
        local dx = ex - px
        local dy = ey - py
        local dist = math.sqrt(dx * dx + dy * dy)

        if dist < self.attackRadius then
            local angleToEnemy = math.atan2(dy, dx)
            local diff = math.abs(angleToEnemy - self.angle)
            if diff > math.pi then diff = 2 * math.pi - diff end

            if diff < math.rad(30) and not self.hitEntities[enemy] then
                enemy:takeDamage(1)
                self.hitEntities[enemy] = true
            end
        end

        -- if dist < 34 then
        --     self:takeDamage(1)
        -- end
    end
end

function Player:handleMovement(dt,cam)
    if not self.collider then return end
    local cx, cy = self.collider:getPosition()
    self.x = cx - self.w / 2
    self.y = cy - self.h + 16

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
        -- self.x = self.x + (dx/len) * self.speed * dt
        -- self.y = self.y + (dy/len) * self.speed * dt
        self.collider:setLinearVelocity((dx/len) * self.speed,(dy/len) * self.speed)
    else
        self.collider:setLinearVelocity(0,0)
    end
    self.moving = len > 0
    if self.moving then
        if math.abs(dx) > math.abs(dy) then
            self.currentDir = "right"
            self.facingLeft = dx < 0
        elseif dy < 0 then
            self.currentDir = "up"
            self.facingLeft = false
        else
            self.currentDir = "down"
            self.facingLeft = false
        end
    end


    local mx,my = cam:worldCoords(love.mouse.getPosition())
    local px,py = self.x + self.w/2, self.y + self.h/2
    self.angle = math.atan2(my-py,mx-px)
end

function Player:canAttack()
    return love.mouse.isDown(1) and self.swingTimer <= 0 and not self.holdingItem
end

function Player:draw()
    if self.boarded then return end
    if self.invincible then
        love.graphics.setColor(1, 1, 1, 0.3)
    else
        love.graphics.setColor(1, 1, 1, 1)
    end
    local scaleX = self.facingLeft and -1 or 1
    local offsetX = self.facingLeft and self.w or 0
    self.currentAnim:draw(self.image, self.x + offsetX, self.y, 0, scaleX, 1)
    if self.swingTimer > 0 then
        local alpha = self.swingTimer / self.swingDuration
        local px = self.x + self.w / 2
        local py = self.y + self.h / 2
        local r = 40
        local segments = 20
        local arcAngle = math.rad(60)
        local startAngle = self.angle - arcAngle / 2
        local endAngle = self.angle + arcAngle / 2

        love.graphics.setColor(1, 0.5, 0, alpha)
        love.graphics.setLineWidth(8)
        love.graphics.arc("line", "open", px, py, r, startAngle, endAngle, segments)
        love.graphics.setLineWidth(1)
    end

    if self.holdingItem then
        love.graphics.setColor(1,1,1,1)
        local drawX = self.x + self.w / 2 - (self.holdingItem.image:getWidth()/ 2)
        local drawY = self.y - self.holdingItem.image:getHeight() - 5
        love.graphics.draw(self.holdingItem.image, drawX, drawY)
    end
end

function Player:getYDraw()
    return self.y + self.h
end

return Player