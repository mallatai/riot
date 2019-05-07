painter = require("painter")
boids = require("libs/boids")
water_cannon = require("libs/water_cannon")

function love.load()
    window_width, window_heigth = love.graphics.getDimensions()

    love.graphics.setNewFont(12)
    love.graphics.setBackgroundColor(255, 255, 255)

    painter_cursor = painter({1,0,0}, 10, 100)

    boids.createRandomBoids({x=400,y=300}, {x=50,y=50}, 100)
    boids.set_direction( { x = window_width / 2, y = window_heigth / 2 } )

    wc = water_cannon.new(200, 200)

    update_time = 0
end

function love.mousepressed(x, y, button, istouch, presses)
    print(x, y)
    if button == 1 then
        boids.set_direction( {x = x, y = y} )
        -- boids.kill( {x = x, y = y} )
    end

    if button == 2 then
        boids.set_threat( {x = x, y = y} )
    end
end

function love.keypressed(key, scancode, isrepeat)
    if key == "escape" then
       love.event.quit()
    end
end

local updates_count = 0
local total_update_time = 0

function love.update(dt)
    -- painter_cursor:update(dt)

    local start = love.timer.getTime()
    boids.update(dt)
    total_update_time = total_update_time + love.timer.getTime() - start
    updates_count = updates_count + 1

    if updates_count > 60 then
        update_time = total_update_time * 1000 / 60
        print("Boids update time", update_time)
        total_update_time = 0
        updates_count = 0
    end
end

function love.draw()
    painter_cursor:draw()
    boids.draw()
    wc:draw()

    love.graphics.setColor(0, 0, 0.2)
    love.graphics.print("FPS: "..tostring(love.timer.getFPS( )), 10, 10)
    love.graphics.print(string.format( "%.5f", update_time ), 10, 30)

end
