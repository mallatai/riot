local button = {}

local Button = {}
Button.__index = Button

function button.create(name, x, y, callback)
    return Button.new(name, x, y, callback)
end

function Button.new(name, x, y, callback)
    local self = setmetatable({}, Button)
    self.name = name
    self.x = x
    self.y = y
    self.callback = callback

    return self
end

function Button:mousepressed(x, y, button, istouch, presses)
    print("Button.mousepressed")
    if self.callback then
        self.callback(x, y, button, istouch, presses)
    end
end

return button