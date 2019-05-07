local painter = {}
painter.__index = painter

setmetatable(painter, {
    __call = function (cls, ...)
        return cls.new(...)
    end
})

local dt_accumulated = 0

function painter.new(color, width, max_particles)
    local self = setmetatable({}, painter)
    self.color = color
    self.width = width
    self.max_particles = max_particles

    self.particles = {}
    for i = 1, max_particles do
        self.particles[i] = { -self.width, -self.width }
    end

    self.current_particle_index = 1
    self.cursor_for_removing_particle = self.current_particle_index + 1

    return self
end

function painter:update(dt)
    local x, y = love.mouse.getPosition()
    if love.mouse.isDown(1) then
        self.particles[self.current_particle_index] = { x, y }
        self.current_particle_index = self.current_particle_index % self.max_particles + 1
    end

    dt_accumulated = dt_accumulated + dt
    if dt_accumulated > 0.5 then
        self.cursor_for_removing_particle = self.current_particle_index % self.max_particles + 1
        -- print("Removing", self.cursor_for_removing_particle)
        self.particles[self.cursor_for_removing_particle] = { -self.width, -self.width }
        -- self.cursor_for_removing_particle = self.cursor_for_removing_particle % self.max_particles + 1

        dt_accumulated = 0
    end
end

function painter:draw()
    love.graphics.setColor(self.color)

    for _, particle in ipairs(self.particles) do
        if particle then
            love.graphics.circle('fill', particle[1], particle[2], self.width)
        end
    end
end

return painter
