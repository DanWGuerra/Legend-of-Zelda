--[[
    GD50
    Legend of Zelda

    -- Animation Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

Animation = Class{}

function Animation:init(def)
    self.frames = def.frames
    self.interval = def.interval
    self.texture = def.texture
    self.looping = def.looping
    if type(self.looping) == "nil" then
        self.looping = true
    end

    self.timer = 0
    self.currentFrame = 1

    self.ox = def.offsetX or 0
    self.oy = def.offsetY or 0

    -- used to see if we've seen a whole loop of the animation
    self.timesPlayed = 0
end

function Animation:refresh()
    self.timer = 0
    self.currentFrame = 1
    self.timesPlayed = 0
end

function Animation:update(dt)
    -- if not a looping animation and we've played at least once, exit
    if not self.looping and self.timesPlayed > 0 then
        return
    end

    -- no need to update if animation is only one frame
    if #self.frames <= 1 then return end
    self.timer = self.timer + dt

    -- Use 'while' instead of 'if', because if interval is really small, allow
    -- animation to skip multiple frames in a single update step
    while self.timer > self.interval do
        self.timer = self.timer - self.interval

        self.currentFrame = math.max(1, (self.currentFrame + 1) % (#self.frames + 1))

        -- if we've looped to the back, record
        if self.currentFrame == #self.frames then
            self.timesPlayed = self.timesPlayed + 1
        end
    end
end

function Animation:getCurrentFrame()
    return self.frames[self.currentFrame]
end

function Animation:render(x, y)
    local texture = gTextures[self.texture]
    local frame = gFrames[self.texture][self:getCurrentFrame()]
    love.graphics.draw(texture, frame, x, y, 0, 1, 1, self.ox, self.oy)
end

