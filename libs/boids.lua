vector = require("../libs/vector")

-- http://www.vergenet.net/~conrad/boids/pseudocode.html
-- http://www.red3d.com/cwr/boids/

-- TODO
-- * iterate only over the nearby boids when implementing rules
-- * collisions

-- local bump = require("../libs/bump")
-- local world = bump.newWorld(50)
-- local box = { x = 200, y = 200, w = 100, h = 100 }
-- world:add(box, box.x, box.y, box.w, box.h)


local win_width, win_height = love.graphics.getDimensions()
local normal_to_y = vector.new(1,0)
local normal_to_x = vector.new(0,1)


local boids = {}
boids.__index = boids

boids.entities = {}
boids.entity_size = 7
boids.num = 1
boids.direction = vector.new(300, 300)

boids.threat = vector.new(-1000,-1000)
boids.threat_duration = 10
boids.running_away_time = 0

boids.distance_min = boids.entity_size -- boids.entity_size?
boids.distance_max = 30
boids.randomized_distance = 5
boids.velocity_limit = 100


local entity = {}
entity.__index = entity
setmetatable(entity, {
    __call = function (cls, ...)
        return cls.new(...)
    end
})

function entity.new(x, y, vel, i)
    local self = setmetatable({}, entity)
    self.pos = vector.new(x, y)
    self.velocity = vel
    self.i = i

    return self
end

function entity:combined_rules()
    -- Rule 1: towards center
    local perceived_center = vector.new()

    -- Rule 2: keep distance
    local keep_distance_vec = vector.new()

    -- Rule 3: common heading
    local perceived_velocity = vector.new()

    for i,e in ipairs(boids.entities) do
        -- if i ~= self.i and self.pos:dist(e.pos) < 30 then
        if i ~= self.i then
            -- Rule 1: towards center
            perceived_center = perceived_center + e.pos

            -- Rule 2: keep distance
            if self.pos:dist(e.pos) < boids.randomized_distance then
                keep_distance_vec = keep_distance_vec - (e.pos - self.pos)
            end

            -- Rule 3: common heading
            perceived_velocity = perceived_velocity + e.velocity
        end
    end

    -- Rule 1: towards center
    perceived_center = perceived_center / (boids.num - 1)
    local towards_center_vec = (perceived_center - self.pos) * 0.01

    -- Rule 2: keep distance
    -- local v2 = keep_distance_vec

    -- Rule 3: common heading
    perceived_velocity = perceived_velocity / (boids.num - 1)
    local common_heading_vec = (perceived_velocity - self.velocity) * 0.1

    return towards_center_vec + keep_distance_vec + common_heading_vec
end

function entity:towards_center()
    local perceived_center = vector.new()
    for i,e in ipairs(boids.entities) do
        if i ~= self.i then
            perceived_center = perceived_center + e.pos
        end
    end

    perceived_center = perceived_center / (boids.num - 1)

    return (perceived_center - self.pos) * 0.01
end

function entity:keep_distance()
    local v = vector.new()
    local dist = 0
    for i,e in ipairs(boids.entities) do
        if i ~= self.i then
            dist = e.pos.dist(e.pos, self.pos)
            if dist < boids.randomized_distance then
                v = v - (e.pos - self.pos)
            end
        end
    end

    return v
end

function entity:common_heading()
    local perceived_velocity = vector.new()

    for i,e in ipairs(boids.entities) do
        if i ~= self.i then
            perceived_velocity = perceived_velocity + e.velocity
        end
    end

    perceived_velocity = perceived_velocity / (boids.num - 1)

    return (perceived_velocity - self.velocity) * 0.1
end

function entity:change_direction()
    return (boids.direction - self.pos) * 0.1
end

function entity:run_from_threat(dt)
    if boids.running_away_time > boids.threat_duration then
        boids.threat = vector.new(-1000, -1000)
        boids.running_away_time = 0
        return vector.new(0,0)
    end

    if boids.threat.x < 0 or boids.threat.y < 0 then
        return vector.new()
    end

    boids.running_away_time = boids.running_away_time + dt

    return -(boids.threat - self.pos) * 0.2
end

function entity:update(dt)
    -- local v1 = self:towards_center() * 1
    -- local v2 = self:keep_distance() * 1
    -- local v3 = self:common_heading() * 1

    local v4 = self:change_direction() * 0.5
    local v5 = self:run_from_threat(dt) * 1

    self.velocity = self.velocity + self:combined_rules() + v4 + v5

    local wander = 100
    self.velocity = self.velocity
                    + vector.new(love.math.random(self.velocity.x - wander,
                                                    self.velocity.x + wander),
                                love.math.random(self.velocity.y - wander,
                                                    self.velocity.y + wander))

    self.velocity = self.velocity:limit(boids.velocity_limit)

    local projected_pos = self.pos + self.velocity * dt
    if projected_pos.x > win_width or projected_pos.x < 0 then
        self.velocity = self.velocity - 2 * self.velocity:dot(normal_to_y) * normal_to_y
        self.pos = self.pos + self.velocity * dt
        return
    end
    if projected_pos.y > win_height or projected_pos.y < 0 then
        self.velocity = self.velocity - 2 * self.velocity:dot(normal_to_x) * normal_to_x
        self.pos = self.pos + self.velocity * dt
        return
    end

    -- local actual_x, actual_y, cols, len = world:move(self, projected_pos.x, projected_pos.y)
    -- print(actual_x, actual_y, cols, len)
    -- self.pos = vector.new(actual_x, actual_y)

    self.pos = projected_pos
end

function boids.createRandomBoids(start_pos, bounds, num)
    boids.num = num

    local entity_x = 0
    local entity_y = 0

    local min_x_bound = start_pos.x - bounds.x
    local max_x_bound = start_pos.x + bounds.x
    local min_y_bound = start_pos.y - bounds.y
    local max_y_bound = start_pos.y + bounds.y
    for i = 1, boids.num do
        entity_x = love.math.random(min_x_bound, max_x_bound)
        entity_y = love.math.random(min_y_bound, max_y_bound)
        boids.entities[i] = entity.new(entity_x, entity_y, vector.new(-10,-10), i)

        -- world:add(boids.entities[i], entity_x, entity_y, boids.entity_size, boids.entity_size)
    end

    return boids.entities
end

function boids.kill(pos)
    local j = 1
    for i = 1, boids.num do
        if vector.dist(pos, boids.entities[i].pos) < boids.entity_size then
            print("Killing", pos.x, pos.y)
            boids.entities[i] = nil
            boids.num = boids.num - 1
        else
            if i ~= j then
                boids.entities[j] = boids.entities[i]
                boids.entities[j].i = j
                boids.entities[i] = nil
            end
            j = j + 1
        end
    end
end

function boids.set_direction(vec)
    print("Updating boids direction to", vec.x, vec.y)

    boids.direction = vector.new(vec.x, vec.y)
end

function boids.set_threat(vec)
    print("Threat appeared at", vec.x, vec.y)
    boids.threat = vector.new(vec.x, vec.y)
end

function boids.update(dt)
    boids.randomized_distance = love.math.random(boids.distance_min, boids.distance_max)
    for _,e in ipairs(boids.entities) do
        e:update(dt)
    end
end

function boids.draw()

    -- love.graphics.setColor(1,0,0)
    -- love.graphics.rectangle('line', box.x, box.y, box.w, box.h)

    love.graphics.setColor(0,1,0)
    for _,e in ipairs(boids.entities) do
        love.graphics.circle('fill', e.pos.x, e.pos.y, boids.entity_size)
    end
end


return boids
