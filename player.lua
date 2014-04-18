require 'input'
require 'entity'
require 'bbox'

Player = {}
Player.__index = Player
setmetatable(Player, {__index = Entity})

function Player:new(game, config)
    local config = config or {}

    local newPlayer = Entity:new(game)
    newPlayer.type = "player"
    newPlayer.x = config.x or 400
    newPlayer.y = config.y or 300
    newPlayer.min_y = config.min_y or 0
    newPlayer.max_y = config.max_y or 600
    newPlayer.min_x = config.min_x or 0
    newPlayer.max_x = config.max_x or 600
    newPlayer.score = config.score or 0
    newPlayer.size = config.size or {
        x = 150,
        y = 120
    }

    newPlayer.speed = config.speed or 5

    newPlayer.keys = config.keys or {
        up = "up",
        down = "down",
        left = "left",
        right = "right",
        shoot = "z"
    }

    newPlayer.graphics = config.graphics or {
        source = "assets/images/SpaceCowboy.png",
        facing = "right"
    }

    newPlayer.sound = config.sound or {
        moving = {
            source = "assets/sounds/move.wav"
        }
    }

    newPlayer.lastPosition = {
        x = nil,
        y = nil
    }

    if game.audio ~= nil then
        newPlayer.sound.moving.sample = game.audio.newSource(newPlayer.sound.moving.source)
        newPlayer.sound.moving.sample:setLooping(true)
    end

    if game.graphics ~= nil and game.animation ~= nil then
        newPlayer.graphics.sprites = game.graphics.newImage(newPlayer.graphics.source)
        newPlayer.sx = newPlayer.size.x / newPlayer.graphics.sprites:getWidth()
        newPlayer.sy = newPlayer.size.y / newPlayer.graphics.sprites:getHeight()
        newPlayer.graphics.grid = game.animation.newGrid(
            newPlayer.size.x, newPlayer.size.y,
            newPlayer.graphics.sprites:getWidth(),
            newPlayer.graphics.sprites:getHeight()
        )
        newPlayer.graphics.animation = game.animation.newAnimation(
            newPlayer.graphics.grid("1-6", 1),
            0.05
        )

        newPlayer.bboxes = BoundingBoxes:new(newPlayer, {
            {
                left = 549 * newPlayer.sx,
                right = 1350 * newPlayer.sx,
                top = 435 * newPlayer.sy,
                bottom = 693 * newPlayer.sy
            },
            {
                left = 15 * newPlayer.sx,
                right = 1890 * newPlayer.sx,
                top = 693 * newPlayer.sy,
                bottom = 1239 * newPlayer.sy
            }
        })
    end

    newPlayer.type = 'player'

    return setmetatable(newPlayer, self)
end

function Player:updatescore(points)
    self.score = self.score + points
end

function Player:collide(other)
    if other.type == 'asteroid' then
        Runner:gameover()
    end
end

function Player:update(dt)
    local dy = 0
    local dx = 0

    local canMoveUp = function()
      return self.y >= self.min_y + self.speed
    end

    local canMoveDown = function()
      return self.y <= self.max_y - self.size.y - self.speed
    end

    local canMoveLeft = function()
      return self.x >= self.min_x + self.speed
    end

    local canMoveRight = function()
      return self.x <= self.max_x - self.size.x - self.speed
    end

    if self.game.input.pressed(self.keys.up) then
        if (canMoveUp()) then
          dy = dy - self.speed
        end
    end

    if self.game.input.pressed(self.keys.down) then
        if (canMoveDown()) then
          dy = dy + self.speed
        end
    end

    if self.game.input.pressed(self.keys.shoot) then
        self.shoot()
    end

    self.lastPosition = {
        x = self.x,
        y = self.y
    }

    self.y = self.y + dy
    self.x = self.x + dx

    if self.bboxes ~= nil then
        self.bboxes:update()
    end

    if self.graphics.animation ~= nil then
        if dy ~= 0 or dx ~= 0  then
            self.graphics.animation:update(dt)
        else
            self.graphics.animation:gotoFrame(1)
        end
    end

    if self.sound.moving.sample ~= nil then
        if dy ~= 0 or dx ~= 0  then
            self.sound.moving.sample:play()
        else
            self.sound.moving.sample:stop()
        end
    end

end

function Player:shoot()
end

function Player:draw()
  self.game.graphics.draw(self.graphics.sprites, self.x, self.y, self.angle, self.sx, self.sy)
  if DEBUG_MODE then
      for i = 1, #self.bboxes.boxes do
          local box = self.bboxes.boxes[i]
          self.game.graphics.rectangle('line', box.x, box.y, box.size.x, box.size.y)
      end
  end
  love.graphics.printf("Score: " .. self.score, love.window.getWidth() * 0.80, love.window.getHeight() * 0.015, 400, "left", 0, 1, 1.5)
end
