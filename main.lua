--[[
	PuzzleBlock r1
	© 2016 Alfonso Saavedra "Son Link"
	Under the GNU/GPL 3 license
	Source Code -> https://github.com/son-link/PuzzleBlock
	My blog (on Spanish) -> http://son-link.github.io
]]

gameState = 0 -- 0: Main screen, 1: playing, 2: paused, 3: lost live, 4: game over
ifWin = true -- For check if the player complete the puzzle

math.randomseed(os.time())

blocksLines = {}
startX = 0
startY = 0

lostLiveY = 320
moveLostAt = 0.1

playerPos = 5
newLineAt = 5
speed = 1
upSpeedAt = 2000

scoreText = "score"
score = 0
topScore = 0

if love.filesystem.exists('topscore.txt') then
	contents = love.filesystem.read('topscore.txt')
	topScore = tonumber(contents)
end
lives = 4

function love.load()
	-- Window config (only on Löve)
	love.window.setMode(240, 320, {resizable=false, centered=true})
	love.graphics.setBackgroundColor(255,255,255)
	if love.window.setTitle then
		-- Not implementd on LövePotion
		love.window.setTitle("PuzzleBlocks")
		love.window.setIcon(love.image.newImageData('img/block.png'))
	end
	--love.keyboard.setKeyRepeat(true)
	-- set font
	font = love.graphics.newFont("LiquidCrystal-Normal.otf", 16)
	love.graphics.setFont(font)
	
	block = love.graphics.newImage("img/block.png")
	player = love.graphics.newImage("img/player.png")
	lostLive = love.graphics.newImage("img/lost_live.png")
	
	--shuffle(test)
	newLine()
end

function love.update(dt)
	if lives == 0 then
		gameState = 4
	end
	if gameState == 0 then
		if #blocksLines <= 18 then
			if newLineAt < 0 then
				newLine()
				newLineAt = 5 / speed
			else
				newLineAt = newLineAt - dt
			end
		else
			gameState = 3
			newLineAt = 5 / speed
		end
	elseif gameState == 3 then
		if moveLostAt < 0 then
			if lostLiveY > 0 then
				lostLiveY = lostLiveY - 16
			else
				resetGame()
				lives = lives - 1
			end
			moveLostAt = 0.1
		else
			moveLostAt = moveLostAt - dt
		end
	elseif gameState == 4 then
		if score > topScore then
			topScore = score
			love.filesystem.write('topscore.txt', score)
		end
	end
	if score > topScore then
		scoreText = 'hi-score'
	end
	if score == upSpeedAt and speed < 10 then
		speed = speed + 1
		newLineAt = 5 / speed
		upSpeedAt = 1000 * speed
	end
end

function love.draw()
	love.graphics.setColor(255, 255, 255)
	if gameState == 0 or gameState == 2 then
		for i=#blocksLines, 1 ,-1 do
			line = blocksLines[i]
			for n=1,10 do
				if line[n] == 1 then
					love.graphics.draw(block, startX, startY)
				end
				startX = startX + 16
			end
			startY = startY + 16
			startX = 0
		end
		startY = 0
		love.graphics.draw(player, (playerPos * 16) - 32, 288)
	end
		
	--for rigt border
	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle('fill', 160, 0, 2, 320)
	love.graphics.setColor(255, 255, 255)
	love.graphics.rectangle('fill', 162, 0, 76, 320)
	
	-- Score, etc
	love.graphics.setColor(0, 0, 0)
	love.graphics.printf(scoreText, 0, 8, 224, 'right')
	love.graphics.printf(score, 0, 24, 224, 'right')
	
	love.graphics.printf("LIVES", 0, 48, 224, 'right')
	love.graphics.printf(lives, 0, 64, 224, 'right')
	
	love.graphics.printf("SPEED", 0, 96, 224, 'right')
	love.graphics.printf(speed, 0, 112, 224, 'right')
	
	if gameState == 2 then
		love.graphics.setColor(0, 0, 0)
		love.graphics.printf('PAUSE', 0, 144, 224, 'right')
	elseif gameState == 3 then
		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(lostLive ,0, lostLiveY)
	elseif gameState == 4 then
		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(lostLive ,0, 0)
		love.graphics.setColor(0, 0, 0)
		love.graphics.printf('GAME\nOVER', 0, 176, 224, 'right')
	end
end

function love.keypressed(key)
	if key == "p" then
		if gameState == 0 then
			gameState = 2
		elseif gameState == 2 then
			gameState = 0
		end
	elseif key == "escape" then
		love.event.quit()
	elseif gameState == 0 then
		if key == 'left' and playerPos > 1 then
			playerPos = playerPos - 1
		elseif key == 'right' and playerPos < 10 then
			playerPos = playerPos + 1
		elseif key == 'space' then
			if gameState == 0 then
				shot()
			elseif gameState == 4 then
				resetGame()
				lives = 4
				newLineAt = 5
			end
		end
	end
end

function shuffle(t)
	-- Shuflle the table indicated on the parameter
    local rand = math.random 
    assert(t, "table.shuffle() expected a table, got nil")
    local iterations = #t
    local j
    
    for i = iterations, 2, -1 do
        j = rand(i)
        t[i], t[j] = t[j], t[i]
    end
end

function newLine()
	total = math.random(1, 5)
	line = {}
	for i=1,10 do
		if i <= total then
			line[i] = 1;
		else
			line[i] = 0;
		end
	end
	shuffle(line)
	table.insert(blocksLines, line)
end

function shot()
	if #blocksLines > 0 then
		for i=1 , #blocksLines do
			line = blocksLines[i]
			if blocksLines[i+1] == nil and line[playerPos] == 0 then
				line[playerPos] = 1
				break
			elseif line[playerPos] == 0 and blocksLines[i+1][playerPos] == 1 then
				line[playerPos] = 1
				break
			elseif i == 1 and line[playerPos] == 1 or #blocksLines == 0 then
				tempLine = {}
				tempTable = {}
				for i=1,10 do
					if i == playerPos then
						tempLine[i] = 1
					else
						tempLine[i] = 0
					end
				end
				tempTable[1] = tempLine 
				for i=1 , #blocksLines do
					tempTable[i+1] = blocksLines[i]
				end
				blocksLines = tempTable
				break
			end
		end
	else
		tempLine = {}
		tempTable = {}
		for i=1,10 do
			if i == playerPos then
				tempLine[i] = 1
			else
				tempLine[i] = 0
			end
		end
		blocksLines[1] = tempLine
	end 
	score = score + 10
	checkLines()
end

function checkLines()
	for i=1 , #blocksLines do
		cont = 0
		line = blocksLines[i]
		for i,v in ipairs(line) do
			if v == 1 then
				cont = cont +1
			end
		end
		if cont == 10 then
			table.remove(blocksLines, i)
			break
		end
	end
end

function resetGame()
	playerPos = 5
	blocksLines = {}
	gameState = 0
	moveLostAt = 0.1
	lostLiveY = 320
	newLine()
	newLineAt = 5 / speed
end
