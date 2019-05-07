local hp_bar = {}

hp_bar.__index = hp_bar

setmetatable(hp_bar, {
    __call = function (cls, ...)
        return cls.new(...)
    end
})

hp_bar.healthy_color =  { 0,1,0,1 }
hp_bar.wounded_color =  { 1,1,0,1 }
hp_bar.critical_color = { 1,0,0,1 }

function hp_bar.new(x, y, w, h, max_hp, cur_hp)
    local self = setmetatable({}, hp_bar)

    self.pos = { x = x, y = y }
    self.w = w
    self.h = h

    self.max_hp = max_hp
    self.cur_hp = cur_hp
    self.ratio = self.cur_hp / self.max_hp

    self.wounded = 2 / 3 * self.max_hp
    self.critical =  1 / 3 * self.max_hp

    return self
end

function hp_bar:set_hp(hp)
    if hp > self.max_hp then
        hp = self.max_hp
    end
    if hp < 0 then
        hp = 0
    end

    self.cur_hp = hp
    self.ratio = self.cur_hp / self.max_hp
end

function hp_bar:update(dt)

end

function hp_bar:draw()
    if self.cur_hp > self.wounded then
        love.graphics.setColor(hp_bar.healthy_color)
    elseif self.cur_hp > self.critical then
        love.graphics.setColor(hp_bar.wounded_color)
    else
        love.graphics.setColor(hp_bar.critical_color)
    end

    love.graphics.rectangle('fill', self.pos.x, self.pos.y, self.w * self.ratio, self.h)

    love.graphics.setColor(0,0,0)
    love.graphics.rectangle('line', self.pos.x, self.pos.y, self.w, self.h)
end

return hp_bar
