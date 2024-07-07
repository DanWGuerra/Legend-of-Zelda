--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

PlayState = Class{__includes = BaseState}

function PlayState:init()
    self.dungeon = Dungeon(MAP_WIDTH, MAP_HEIGHT)

    local x, y, w, h = self.dungeon.currentRoom:getBounds()
    self.player = Player {
        animations = ENTITY_DEFS['player'].animations,
        walkSpeed = ENTITY_DEFS['player'].walkSpeed,

        x = x+w/2,-- VIRTUAL_WIDTH / 2 - 8,
        y = y+h/2,-- VIRTUAL_HEIGHT / 2 - 11,

        width = 16,
        height = 22,

        -- one heart == 2 health
        health = 6,
        maxHealth = 6,

        -- rendering and collision offset for spaced sprites
        offsetY = 5,

        dungeon = self.dungeon
    }

    self.dungeon:setPlayer(self.player)
end

function PlayState:enter(params)
end

function PlayState:update(dt)
    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end

    self.dungeon:update(dt)
end

function PlayState:renderHearts()
    local healthLeft = self.player.health
    local heartFrame = 1

    for i = 1, math.ceil(self.player.maxHealth/2) do
        if healthLeft > 1 then
            heartFrame = 5
        elseif healthLeft == 1 then
            heartFrame = 3
        else
            heartFrame = 1
        end

        love.graphics.draw(gTextures['hearts'], gFrames['hearts'][heartFrame], (i - 1) * (TILE_SIZE + 1), 2)

        healthLeft = healthLeft - 2
    end
end

function PlayState:render()
    -- render dungeon and all entities separate from hearts GUI
    self.dungeon:render()

    -- draw player hearts, top of screen
    self:renderHearts()
end
