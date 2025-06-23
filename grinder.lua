local Grinder = {}
Grinder.__index = Grinder

function Grinder.new(x,y, radius)
    local self = setmetatable({}, Grinder)
    self.x,self.y = x,y
    self.w,self.h = 20,20
    self.radius = radius or 100
    self.oilProduced = 0
    return self
end

function Grinder:update(dt,items,player)
    for _,item in ipairs(items) do
        if not item.picked and not item.consumed then
            local ix, iy = item.x + item.w/2, item.y + item.h/2
            local d = math.sqrt((self.x - ix)^2 + (self.y -iy)^2)
            if d<self.radius then
                item.consumed = true
                player.oil = player.oil + 1
                self.oilProduced = self.oilProduced + 1
            end
        end
    end
end

function Grinder:draw()
    love.graphics.setColor(0.2,0.8,1)
    love.graphics.rectangle("fill", self.x, self.y, self.w , self.h)
end

return Grinder