---@diagnostic disable: undefined-global

function love.load()

    ship = love.graphics.newImage("Ship.png")
    love.window.setTitle("Asteroids")

    player = {}
    player.size = 0.05
    player.x = 0
    player.y = 0
    player.xv = 0
    player.yv = 0
    player.max_speed = 20
    player.acceleration = 3
    player.friction = 0.95
    
    bullets = {}
    bullets.list = {}
    bullets.size = 15
    bullets.speed = 35
    bullets.mosuedown = false
    bullets.timer = 0
    bullets.reload = 0.25

    astroids = {}

end

function player_movement(dt)

    if love.keyboard.isDown("a") then

        player.xv = player.xv - player.acceleration

    end
    if love.keyboard.isDown("d") then

        player.xv = player.xv + player.acceleration

    end
    if love.keyboard.isDown("s") then

        player.yv = player.yv + player.acceleration
 
    end
    if love.keyboard.isDown("w") then

        player.yv = player.yv - player.acceleration

    end

    --cap speed

    if player.xv > player.max_speed then
        player.xv = player.max_speed  
    elseif player.xv < -player.max_speed then
        player.xv = -player.max_speed
    end

    if player.yv > player.max_speed then
        player.yv = player.max_speed 
    elseif player.yv < -player.max_speed then
        player.yv = -player.max_speed
    end

    player.xv = player.xv * player.friction
    player.yv = player.yv * player.friction

    player.x = player.x + player.xv * dt
    player.y = player.y + player.yv * dt

    --boundries

    if player.x < 0 then

        player.x = 0

    end 
    if player.x > love.graphics.getWidth() - player.size then

        player.x = love.graphics.getWidth() - player.size

    end
    if player.y < 0 then

        player.y = 0

    end
    if player.y > love.graphics.getHeight() - player.size then

        player.y = love.graphics.getHeight() - player.size

    end


end

function handle_bullets(dt)
    
    for i = #bullets.list, 1, -1 do
        local b = bullets.list[i]
        b.x = b.x + b.dx * dt
        b.y = b.y + b.dy * dt
        -- Remove bullets off-screen
        if b.x < -bullets.size or b.x > love.graphics.getWidth() or b.y < -bullets.size or b.y > love.graphics.getHeight() then
            table.remove(bullets.list, i)
        end
    end

end

function love.mousepressed(x, y, button, istouch, pressed)

    if button == 1 then

        bullets.mosuedown = true

    end

end

function love.mousereleased(x, y, button, istouch, pressed)

    if button == 1 then

        bullets.mosuedown = false

    end

end

function love.update(dt)

    player_movement(dt)
    handle_bullets(dt)

    local mouse_x, mouse_y = love.mouse.getPosition()
    
    if bullets.mosuedown and bullets.timer <= 0 then
        
        local dx, dy = get_direction(player.x, player.y, mouse_x, mouse_y)
        table.insert(bullets.list, {x = player.x, y = player.y, dx = dx * bullets.speed, dy = dy * bullets.speed})
        bullets.timer = bullets.reload

    end

    if bullets.timer > 0 then
        
        bullets.timer = bullets.timer - (1 * dt)

    end

end

function love.draw()
    --bullets
    for i, b in pairs(bullets.list) do
        love.graphics.rectangle("fill", b.x + bullets.size / 2, b.y + bullets.size / 2, bullets.size, bullets.size, 4)
    end
    --player
    love.graphics.draw(ship, player.x, player.y, 0, player.size, player.size)
    
end

function get_direction(x1, y1, x2 ,y2)

    local dx = x2 - x1
    local dy = y2 - y1
    local len = math.sqrt(dx * dx + dy * dy)
    if len == 0 then return 0, 0 end
    return dx / len, dy / len

end