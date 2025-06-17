---@diagnostic disable: undefined-global

function love.load()

    ship = love.graphics.newImage("Ship.png")
    love.window.setTitle("Asteroids")

    dx = 0
    dy = 0

    mouse_x = 0
    mouse_y = 0

    player = {}
    player.size = 25
    player.x = 0
    player.y = 0
    player.xv = 0
    player.yv = 0
    player.angle = 0
    player.max_speed = 400
    player.acceleration = 40
    player.friction = 0.975
    
    bullets = {}
    bullets.list = {}
    bullets.size = 15
    bullets.speed = 600
    bullets.mosuedown = false
    bullets.timer = 0
    bullets.reload = 0.25

    astroids = {}
    astroids.list = {}
    astroids.base_size = 35
    astroids.range_size = 10
    astroids.base_speed = 350
    astroids.range_speed = 50
    astroids.timer = 0
    astroids.spawn_time = 0.5
    astroids.range_time = 0.25

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
       
        if b.x < -bullets.size or b.x > love.graphics.getWidth() or b.y < -bullets.size or b.y > love.graphics.getHeight() then
            table.remove(bullets.list, i)
        end
    end

end

function handle_astroids(dt)

    for i = #astroids.list, 1, -1 do
        local a = astroids.list[i]
        a.x = a.x + a.dx * dt
        a.y = a.y + a.dy * dt

        if a.x < -a.size or a.x > love.graphics.getWidth() + 10 or a.y < -a.size or a.y > love.graphics.getHeight() + 10 then
            table.remove(astroids.list, i)
        end

        for b_i, b in pairs(bullets.list) do
            
            local dist = get_distance(a.x, a.y, b.x, b.y)

            if dist <= a.size then
                
                table.remove(bullets.list, b_i)
                table.remove(astroids.list, i)

            end

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

    local mouse_x, mouse_y = love.mouse.getPosition()
    local dx, dy = get_direction(player.x, player.y, mouse_x, mouse_y)

    player_movement(dt)
    handle_bullets(dt)
    handle_astroids(dt)

    if bullets.mosuedown and bullets.timer <= 0 then
        
        table.insert(bullets.list, {x = player.x, y = player.y, dx = dx * bullets.speed, dy = dy * bullets.speed})
        bullets.timer = bullets.reload

    end
    
    if bullets.timer > 0 then
        
        bullets.timer = bullets.timer - (1 * dt)

    end

    if astroids.timer <= 0 then
        
        local spawn_x, spawn_y
        local size = astroids.base_size + math.random(-astroids.range_size, astroids.range_size)

        if math.random(0, 1) == 1 then
            
            spawn_x = math.random(0, love.graphics.getWidth())

             if math.random(0, 1) == 1 then

                spawn_y = -size

             else

                spawn_y = love.graphics.getHeight() + size
                
             end

        else

            spawn_y = math.random(0, love.graphics.getHeight())

             if math.random(0, 1) == 1 then

                spawn_x = -size

             else

                spawn_x = love.graphics.getWidth() + size
                
             end

        end

        local dx, dy = get_direction(spawn_x, spawn_y, player.x, player.y)

        table.insert(astroids.list, {x = spawn_x, y = spawn_y, dx = dx * astroids.base_speed, dy = dy * astroids.base_speed, size = size})
        astroids.timer = astroids.spawn_time + math.random(-astroids.range_time, astroids.range_time)

    end
    
    if astroids.timer > 0 then
        
        astroids.timer = astroids.timer - (1 * dt)

    end

    player.angle = math.atan(dy, dx)
end

function love.draw()

    love.graphics.setColor(0, 0.5, 1)

    --bullets
    for i, b in pairs(bullets.list) do
        love.graphics.circle("fill", b.x + bullets.size / 2, b.y + bullets.size / 2, bullets.size)
    end
     love.graphics.setColor(1, 0.5, 0)

    --astroids
    for i, a in pairs(astroids.list) do
        love.graphics.circle("fill", a.x + a.size / 2, a.y + a.size / 2, a.size)
    end

    --player

    love.graphics.setColor(0.1, 1, 0.2)

    love.graphics.push()
    love.graphics.translate(player.x, player.y)
    love.graphics.rotate(player.angle)
    love.graphics.rectangle("fill", -player.size / 2, -player.size / 2, player.size, player.size, 4)
    love.graphics.pop()
end

function get_direction(x1, y1, x2 ,y2)

    local dx = x2 - x1
    local dy = y2 - y1
    local len = math.sqrt(dx * dx + dy * dy)
    if len == 0 then return 0, 0 end
    return dx / len, dy / len
end

function get_distance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end