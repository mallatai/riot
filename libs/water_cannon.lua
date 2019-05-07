hp_bar = require("../libs/hp_bar")

local water_cannon = {}

water_cannon.__index = water_cannon

setmetatable(water_cannon, {
    __call = function (cls, ...)
        return cls.new(...)
    end
})

function water_cannon.new(x, y)
    local self = setmetatable({}, water_cannon)
    self.pos = { x = x, y = y }
    self.size = 30

    self.hp = 30
    self.hp_bar = hp_bar.new(
        x - self.size,
        y - self.size - 10,
        self.size * 2,
        5,
        self.hp,
        15
    )

    return self
end

function water_cannon:update(dt)

end

function water_cannon:draw()
    -- love.graphics.setColor(0.7,0.9,0, 1)
    love.graphics.setColor(1,0,0, 0.5)
    love.graphics.circle('fill', self.pos.x, self.pos.y, self.size)

    -- love.graphics.setColor(0.5,0,0,0.8)
    -- love.graphics.rectangle('fill', self.hp_bar.x, self.hp_bar.y, self.hp_bar.w, self.hp_bar.h)

    self.hp_bar:draw()
end

return water_cannon
