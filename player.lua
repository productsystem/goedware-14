local Player = {}

local Item = require("item")
--simulates OOP
Player.__index = Player

local function getItemColor(itemType)
    if itemType == "tree" then
        return 0.6, 0.4, 0.2
    elseif itemType == "enemy" then
        return 1, 0.3, 0.3
    else
        return 1, 1, 0.2
    end
end


function Player.new(x,y,world)
    --lookup meta data from the table
    local self = setmetatable({}, Player)
    self.x,self.y = x,y
    self.w,self.h = 20,20
    self.speed = 200
    self.oil = 0
    self.attackRadius = 100
    self.angle = 0
    self.swingTimer = 0
    self.swingDuration = 0.2
    local cx = x + self.w / 2
    local cy = y + self.h / 2
    self.collider = world:newBSGRectangleCollider(cx, cy, self.w, self.h, 5)
    self.collider:setFixedRotation(true)
    self.holdingItem = nil
    self.hitEntities = {}
    return self
end

--Player:update(dt) == Player.update(self,dt)
function Player:update(dt,entities,items, cam,enemies)
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
                    e.harvested = true
                    if e.collider then
                        e.collider:destroy()
                        e.collider = nil
                    end
                    self.hitEntities[e] = true
                    -- self.oil = self.oil + 1
                    local item = Item.new(e.x + e.w/2,e.y + e.h/2,e.type)
                    table.insert(items,item)
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
    end
end

function Player:handleMovement(dt,cam)
    local cx, cy = self.collider:getPosition()
    self.x = cx - self.w / 2
    self.y = cy - self.h / 2

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

    local mx,my = cam:worldCoords(love.mouse.getPosition())
    local px,py = self.x + self.w/2, self.y + self.h/2
    self.angle = math.atan2(my-py,mx-px)
end

function Player:canAttack()
    return love.mouse.isDown(1) and self.swingTimer <= 0 and not self.holdingItem
end

function Player:draw()
    love.graphics.setColor(1,1,0,1)
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
    if self.swingTimer > 0 then
        local alpha = self.swingTimer / self.swingDuration
        love.graphics.setColor(1, 0.5, 0, alpha)
        local px = self.x + self.w / 2
        local py = self.y + self.h / 2
        local offsetX = math.cos(self.angle) * 20
        local offsetY = math.sin(self.angle) * 20
        love.graphics.rectangle("fill", px + offsetX, py + offsetY, 10, 10)
    end

    if self.holdingItem then
        love.graphics.setColor(getItemColor(self.holdingItem.itemType))
        love.graphics.rectangle("fill", self.x + self.w / 2 - 5, self.y - 15, 10, 10)
    end
end

function Player:getYDraw()
    return self.y + self.h
end

return Player