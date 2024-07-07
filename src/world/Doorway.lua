--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

Doorway = Class{}


-- Ids are listed in this order
--  1|2
--  ---
--  3|4
local directionIds = {
    left = {
        open = {181, 182, 200, 201},
        closed = {219, 220, 238, 239}
    },
    right = {
        open = {172, 173, 191, 192},
        closed = {174, 175, 193, 194}
    },
    up = {
        open = {98, 99, 117, 118},
        closed = {134, 135, 153, 154}
    },
    down = {
        open = {141, 142, 160, 161},
        closed = {216, 217, 235, 236}
    }
}

function Doorway:init(direction, x, y)
    self.open = false
    self.direction = direction
    self.x = x or 0
    self.y = y or 0
    self.width = TILE_SIZE * 2
    self.height = TILE_SIZE * 2
end

function Doorway:render()
    local texture = gTextures['tiles']
    local quads = gFrames['tiles']

    local ids
    if self.open then
        ids = directionIds[self.direction].open
    else
        ids = directionIds[self.direction].closed
    end

    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    love.graphics.draw(texture, quads[ids[1]], 0, 0)
    love.graphics.draw(texture, quads[ids[2]], TILE_SIZE, 0)
    love.graphics.draw(texture, quads[ids[3]], 0, TILE_SIZE)
    love.graphics.draw(texture, quads[ids[4]], TILE_SIZE, TILE_SIZE)
    love.graphics.pop()
end

