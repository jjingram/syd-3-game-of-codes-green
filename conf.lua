-- Set DEBUG_MODE to true to enable useful debugging output
-- such as drawing the bounding box
DEBUG_MODE = false

-- See https://love2d.org/wiki/Config_Files for the full list of configuration
-- options and defaults.

function love.conf(config)
    config.title = "SpaceCowBoy to the rescue"
    config.modules.joystick = false
    config.modules.mouse = false
    config.modules.physics = false
    love.filesystem.setIdentity("space_cow")
end
