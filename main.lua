---@diagnostic disable: undefined-global

function love.load()

    ship = love.graphics.newImage("Ship.png")
    love.window.setTitle("Asteroids")

    dx = 0
    dy = 0

    mouse_x = 0
    mouse_y = 0

    player = {}
    player.size = 30
    player.x = (love.graphics.getWidth() - player.size) / 2
    player.y = (love.graphics.getHeight() - player.size) / 2
    player.xv = 0
    player.yv = 0
    player.angle = 0
    player.max_speed = 400
    player.acceleration = 40
    player.friction = 0.975
    player.hp = 3
    
    bullets = {}
    bullets.list = {}
    bullets.size = 15
    bullets.speed = 600
    player.mousedown = false
    bullets.timer = 0
    bullets.reload = 0.125

    astroids = {}
    astroids.list = {}
    astroids.base_size = 35
    astroids.range_size = 10
    astroids.base_speed = 350
    astroids.range_speed = 50
    astroids.timer = 0
    astroids.spawn_time = 1
    astroids.range_time = 0.5
    astroids.hp_range = 3

    explosions = {}

    game = {}
    game.score = 0
    game.time = 0
    game.game_on = false

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
    player.x, player.y = wrap_position(player.x, player.y, player.size)


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

        -- Move asteroid
        a.x = a.x + a.dx * dt
        a.y = a.y + a.dy * dt

        -- Warp before we draw it (fixes flicker)
        a.x, a.y = wrap_position(a.x, a.y, a.size)

        -- Bullet collisions
        for b_i, b in pairs(bullets.list) do
            local dist = get_distance(a.x, a.y, b.x, b.y)
            if dist <= a.size then
                  a.hit_timer = 0.1  
                table.remove(bullets.list, b_i)
                if a.hp <= 1 then
                    table.remove(astroids.list, i)
                    spawn_explosion(a.x, a.y, 25)

                    game.score = game.score + 1
                else
                    a.hp = a.hp - 1
                    a.size = a.size / 1.5
                end
    
            end
        end

        -- Player collision
        local player_radius = player.size / 2
        local dist = get_distance(a.x, a.y, player.x + player_radius, player.y + player_radius)
        if dist <= a.size + player_radius then
            table.remove(astroids.list, i)
            spawn_explosion(a.x, a.y, 15)

            game.score = game.score + 1
            player.hp =  player.hp - 1
        end

         if a.hit_timer > 0 then
           a.hit_timer = a.hit_timer - dt
        end

    end
end

function love.mousepressed(x, y, button, istoudch, pressed)

    if button == 1 then

        player.mousedown = true

    end

end

function love.mousereleased(x, y, button, istouch, pressed)

    if button == 1 then

        player.mousedown = false

    end

end

function love.update(dt)

    player.angle = math.atan2(mouse_y - (player.y + player.size/2), mouse_x - (player.x + player.size/2))
    mouse_x, mouse_y = love.mouse.getPosition()

   if game.game_on then
    
        if player.hp < 1 then
            
            game.game_on = false

        else

            for i = #explosions, 1, -1 do
    local e = explosions[i]
    e.x = e.x + e.dx * dt
    e.y = e.y + e.dy * dt
    e.life = e.life + dt
    if e.life > e.max_life then
        table.remove(explosions, i)
    end
end


            game.time = game.time + (1 * dt)
          
            local dx, dy = get_direction(player.x, player.y, mouse_x, mouse_y)

            player_movement(dt)
            handle_bullets(dt)
            handle_astroids(dt)

            if player.mousedown and bullets.timer <= 0 then
                
                table.insert(bullets.list, {x = player.x + bullets.size / 2, y = player.y + bullets.size / 2, dx = dx * bullets.speed, dy = dy * bullets.speed})
                bullets.timer = bullets.reload

            end
            
            if bullets.timer > 0 then
                
                bullets.timer = bullets.timer - (1 * dt)

            end

            if astroids.timer <= 0 then
                
                local spawn_x, spawn_y
                local hp = math.random(1, astroids.hp_range)
                local size = (astroids.base_size + math.random(-astroids.range_size, astroids.range_size)) * hp

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

                table.insert(astroids.list, {x = spawn_x, y = spawn_y, dx = dx * astroids.base_speed, dy = dy * astroids.base_speed, size = size, hp = hp, hit_timer = 0})
                astroids.timer = astroids.spawn_time + math.random(-astroids.range_time, astroids.range_time)

            end
            
            if astroids.timer > 0 then
                    
                    astroids.timer = astroids.timer - (1 * dt)

            end

        end

    else

        bullets.list = {}
        astroids.list = {}

        game.score = 0
        game.time = 0

        player.hp = 3
        player.x = (love.graphics.getWidth() - player.size) / 2
        player.y = (love.graphics.getHeight() - player.size) / 2
        player.xv = 0
        player.yv = 0

   end
  
end

function love.draw()

    if game.game_on then
        
        
        love.graphics.setColor(1, 1, 1)

        love.graphics.print("score: " .. game.score)
        love.graphics.print("hp: " .. player.hp, 0, 40)
        love.graphics.print("time: " .. math.floor(game.time), 0, 20)

for _, e in ipairs(explosions) do
    local alpha = 1 - (e.life / e.max_life)
    love.graphics.setColor(1, 0.5, 0, alpha)
    love.graphics.circle("fill", e.x, e.y, e.size * alpha)
end


        love.graphics.setColor(0, 0.5, 1)

        --bullets
        for i, b in pairs(bullets.list) do
            love.graphics.circle("fill", b.x + bullets.size / 2, b.y + bullets.size / 2, bullets.size)
        end

        --astroids
        for i, a in pairs(astroids.list) do

            if a.hit_timer > 0 then
                
                love.graphics.setColor(1, 1, 1)
        
            else
                love.graphics.setColor(1, 0.5, 0)

            end

        love.graphics.circle("fill", a.x, a.y, a.size)
        end

        --player

       love.graphics.setColor(0.1, 1, 0.2)
        love.graphics.push()
        love.graphics.translate(player.x + player.size / 2, player.y + player.size / 2) 
        love.graphics.rotate(player.angle)
        love.graphics.rectangle("fill", -player.size / 2, -player.size / 2, player.size, player.size, 4)
        love.graphics.pop()

            
    else

        love.graphics.setColor(1, 1, 1)

        local size_x = 100
        local size_y = 30
        local pos_x = (love.graphics.getWidth() - size_x) / 2
        local pos_y = (love.graphics.getHeight() - size_y) / 2

        love.graphics.rectangle("fill", pos_x, pos_y, size_x, size_y)

        love.graphics.setColor(0, 0, 0)
        love.graphics.print("PLAY", pos_x, pos_y, 0, 3, 2)

        if mouse_x > pos_x and mouse_x < pos_x + size_x and mouse_y > pos_y and mouse_y < pos_y + size_y and player.mousedown then
            
            game.game_on = true

        end

    end

end

function spawn_explosion(x, y, amount)
    for i = 1, amount do
        local angle = math.random() * 2 * math.pi
        local speed = math.random(100, 300)
        local dx = math.cos(angle) * speed
        local dy = math.sin(angle) * speed
        table.insert(explosions, {
            x = x,
            y = y,
            dx = dx,
            dy = dy,
            life = 0,
            max_life = 0.5,
            size = math.random(4, 8)
        })
    end
end


function wrap_position(x, y, size)
    local screen_w = love.graphics.getWidth()
    local screen_h = love.graphics.getHeight()

    local margin = size * 1.1  -- Add a bit of leniency

    if x < -margin then
        x = screen_w + margin
    elseif x > screen_w + margin then
        x = -margin
    end

    if y < -margin then
        y = screen_h + margin
    elseif y > screen_h + margin then
        y = -margin
    end

    return x, y
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