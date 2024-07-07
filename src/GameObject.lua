--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

GameObject = Class{}

function GameObject:init(def, x, y)
    -- string identifying this object type
    self.type = def.type

    self.texture = def.texture
    self.frame = def.frame or 1

    -- whether it acts as an obstacle or not
    self.solid = def.solid

    self.defaultState = def.defaultState
    self.state = self.defaultState
    self.states = def.states

    -- dimensions
    self.x = x or 0
    self.y = y or 0
    self.width = def.width
    self.height = def.height

    self.consumable = def.consumable or false

    -- default empty collision callback
    self.onCollide = function() end
    self.consumed = function() end
end

function GameObject:collides(t)
    return not (self.x + self.width < t.x or self.x > t.x + t.width or
                self.y + self.height < t.y or self.y > t.y + t.height)
end

function GameObject:update(dt)
end

function GameObject:render()
    local frame
    if self.states == nil then
        frame = self.frame
    else
        frame = self.states[self.state].frame
    end

    love.graphics.draw(gTextures[self.texture], gFrames[self.texture][frame], self.x, self.y)
end

