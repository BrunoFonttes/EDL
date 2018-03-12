winWidth = 700
winHeight = 400

jumpAccel = 400
floorHeight = 300
initGravity = 50

counter = 0
obstacles = {}
lastTimeObstacle = 1000

birds = {img =nil}
newBirds = {}
lastTimeBird = 1000

gravity = 50
player = { x = 100, y = floorHeight+100,jumping = false, jumpCont=3000, accel = jumpAccel, img = nil }
jumCont = 2
gameOver = false;
aux= 0
function love.load()

	player.img = love.graphics.newImage("dude.png")
	love.graphics.setBackgroundColor(113,132,146)
	 font = love.graphics.newFont(35)
end

function love.update(dt)

   if love.keyboard.isDown('escape') then
	love.event.push('quit')
   end

	if gameOver == false then
		aux = aux+0.5
		if aux == 5 then
			player.jumpCont= player.jumpCont+10
			aux = 0
		end
		if love.keyboard.isDown('w') then

			if player.y > 150 and player.jumpCont>100 then

				if player.jumpCont -100 <0 then
					player.jumCont = 0
				else
					player.jumpCont = player.jumpCont - 100
				end
				player.accel = jumpAccel
				gravity = initGravity
			end

			if player.jumping == false then
				player.jumping = true

			end
		end

		--Aceleração do pulo
		if player.jumping and player.accel > 0 then
			player.y = player.y - player.accel*dt
			player.accel = player.accel - 1
		end

		--Gravidade
		if player.y < floorHeight then
			player.y = player.y + gravity*dt;
			gravity = gravity + 10;
		end

		--Verifica se o player já chegou ao chão
		if player.y > floorHeight then 
			player.y = floorHeight
		end

		--Seta para as condições iniciais do pulo do player
		if player.y == floorHeight+100 then
			player.jumping = false
			player.accel = jumpAccel
			gravity = initGravity
		end
		

		--Tarefa-07
		--Variáveis: obstacles, birds
		--Escopo: Global(ambas)
		--Tempo de Vida: Por serem globais, o tempo de vida dessas variáveis se extende até o fim
		--da execução do jogo.Os obstáculos são gerados de modo parcialmente randômico (parâmetro 
		--lastTimeObstacle) removidos assim que deixam de estar vísiveis para o usuário,ou seja 
		--assim que a posição .x do obstáculo é inferior a zero.

		--gera Obstaculos 
		--Quando lastTimeObstacle atinge 0 gera um novo obstáculo e a lastTimeObstacle passa
		--a assumir o novo valor gerado aleatoriamente entre 200 e a largura da tela.
				lastTimeObstacle = lastTimeObstacle - 6
				if lastTimeObstacle <= 0 then
					lastTimeObstacle = love.math.random(200,winWidth)

					newObstacle= { x = winWidth , y = floorHeight, width = 20, height = 50, counted = false}
					table.insert(obstacles, newObstacle)
				end
				
				--remove Obstaculos
				for i, obstacle in ipairs(obstacles) do
					obstacle.x = obstacle.x - 10

					if obstacle.x < 0 then
						table.remove(obstacle, i)
					end

					if obstacle.counted == false and obstacle.x < player.x then
						obstacle.counted = true
						counter = counter + 1
					end
				end


				--gera Passaros
				--Equivalente a geração de obstáculos.
				lastTimeBird = lastTimeBird - 3
				if lastTimeBird <= 0 then
					lastTimeBird = love.math.random(200,winHeight)
					newBird= { x = winWidth , y = 150 - love.math.random(0,50), width = 25, height = 25, counted = false}
					table.insert(birds, newBird)	
				end

				--remove Passaro
				--Equivalente a remoção de obstáculos.
				for i, bird in ipairs(birds) do
					bird.x = bird.x - 7

					if bird.x < 0 then
						table.remove(bird,i)
					end
				end

				--Checa Colisao c obstaculo
				for i, obstacle in ipairs(obstacles) do
					if CheckCollision(player.x,player.y,player.img:getWidth(),player.img:getHeight(),obstacle.x,obstacle.y,obstacle.width,obstacle.height) then
						gameOver = true
					end
				end

				--Checa colisao c passaro
				for i, bird in ipairs(birds) do
					if CheckCollision(player.x,player.y,player.img:getWidth(),player.img:getHeight(),bird.x,bird.y,bird.width,bird.height) then
						table.remove(bird,i)
						bird.y=1000
						player.jumpCont = player.jumpCont+300
					end
				end
			end
	--Fim do bloco de comentário da tarefa-07
end
 

 
function love.draw()
	qtdGrad = 5
	grad = 8
	gradHeight = 50/qtdGrad
	--desenha o chao
	for y=0,qtdGrad do
		love.graphics.setColor(71-y*grad, 85-y*grad, 96-y*grad)
		love.graphics.rectangle('fill', 0, floorHeight+50+y*gradHeight , 700, 50-y*gradHeight)
	end
	--desenha o sol
	love.graphics.setColor(255,255,255)
	love.graphics.circle("fill", 550, 70, 40, 100)

    love.graphics.draw(player.img, player.x, player.y)

    --desenha contador de pontos e contador de salto
    love.graphics.setColor(255,255,255)
    love.graphics.setFont(font)
   	love.graphics.print(counter, 650, 10)

   	
   	--desenha o jogador
   	love.graphics.print(player.jumpCont,50,10)

   	--desenha os obstaculos
    for i, obstacle in ipairs(obstacles) do
      love.graphics.setColor(40,47,56)
	  love.graphics.rectangle('fill', obstacle.x, obstacle.y, obstacle.width, obstacle.height);
	  love.graphics.setColor(32,39,47)
	  love.graphics.rectangle('fill',obstacle.x-obstacle.width,obstacle.y-obstacle.height, 3* obstacle.width, obstacle.height)
	end

	--desenha os passaros
	for i, bird in ipairs(birds) do
	  love.graphics.setColor(196,196,196)
	  love.graphics.rectangle('fill', bird.x, bird.y, bird.width, bird.height);
	end

	--desenha o gameover
    if (gameOver) then
   		love.graphics.setColor(255,255,255)
   		love.graphics.print("GAME OVER", 220, 100)	
   	end
end


function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end
