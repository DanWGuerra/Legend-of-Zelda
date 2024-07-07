PlayerPotThrowState = Class{__includes = BaseState}

function PlayerPotThrowState:init(player, dungeon)
    self.player = player
    self.dungeon = dungeon
end

function PlayerPotThrowState:enter(params)
    assert(params, "Missing paramaters")
    local pot = params.pot
    assert(pot, "Missing paramater 'pot'")

    self.player.currentAnimation:refresh()
    self.player:changeAnimation("pot-throw-"..self.player.direction)

    Timer.after(0.15, function()
        pot:initThrow(self.player.direction)
    end)

    Timer.after(0.3, function()
        self.player:changeState("idle")
    end)
end

