local Cutscene = {
    sequence = {},
    current = 1,
    timer = 0,
    active = false
}

function Cutscene.start(seq)
    Cutscene.sequence = seq
    Cutscene.current = 1
    Cutscene.timer = 0
    Cutscene.active = true
end

function Cutscene.update(dt)
    if not Cutscene.active or #Cutscene.sequence == 0 then return end

    Cutscene.timer = Cutscene.timer + dt
    local step = Cutscene.sequence[Cutscene.current]
    local t = math.min(Cutscene.timer / step.duration, 1)

    if step.update then step.update(t) end

    if Cutscene.timer >= step.duration then
        if step.action then step.action() end
        Cutscene.current = Cutscene.current + 1
        Cutscene.timer = 0
        if Cutscene.current > #Cutscene.sequence then
            Cutscene.active = false
        end
    end
end

function Cutscene.draw()
    if not Cutscene.active or #Cutscene.sequence == 0 then return end
    local step = Cutscene.sequence[Cutscene.current]
    if step.draw then step.draw() end
end

function Cutscene.isActive()
    return Cutscene.active
end

return Cutscene
