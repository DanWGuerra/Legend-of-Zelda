Pot = Class{__includes = GameObject}

function Pot:init(def, room, x, y)
    GameObject.init(self, def, x, y)

    self.room = room
    self.direction = 'none'
    self.distance = 0
    self.moveSpeed = 0
    self.flashTimer = 0
    self.flashDuration = 0
end

function Pot:initGrab()
    self.state = 'grabbed'
    self.solid = false
end

function Pot:initThrow(direction)
    self.state = 'thrown'
    self.solid = false
    self.moveSpeed = 75
    self.direction = direction
end

function Pot:initDestroy()
    self.state = 'destroyed'
    self.solid = false
    self.moveSpeed = 0
    gSounds['break']:play()
end

function Pot:update(dt)
    if self.state == 'thrown' then
        local velx, vely = 0, 0
        -- check all directions possible
        -- right
        if self.direction == "right" then
            velx = self.moveSpeed
        elseif self.direction == "left" then
            velx = -self.moveSpeed
        elseif self.direction == "up" then
            vely = -self.moveSpeed
        elseif self.direction == "down" then
            vely = self.moveSpeed
        end

        self.x = self.x + velx * dt
        self.y = self.y + vely * dt
        self.distance = self.distance + (math.abs(velx) + math.abs(vely)) * dt

        local w, h = self.width, self.height
        local bx, by, bw, bh = self.room:getBounds()

        local collidedWall = self.x < bx or self.x+w > bx+bw or self.y < by or self.y+h > by+bh

        -- check if it has travele 4 tiles or collided with a wall and destroy if so
        if self.distance >= TILE_SIZE * 4 or collidedWall then
            self:initDestroy()
        end
    elseif self.state == "destroyed" then
        self.flashTimer = self.flashTimer + dt
        self.flashDuration = self.flashDuration + dt

        if self.flashDuration >= 1 then
            self.toRemove = true
        end
    end
end

function Pot:render()
    -- flashing like player
    if self.state == 'destroyed' and self.flashTimer > 0.06 then
        self.flashTimer = 0
        love.graphics.setColor(1, 1, 1, 0.25)
    end

    GameObject.render(self)

    love.graphics.setColor(1, 1, 1, 1)
end

