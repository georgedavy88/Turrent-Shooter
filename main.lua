-- =====================================================================================
--|CS 4849 GAME PROGRAMMING ASSIGNMENT													|
--|-------------------------------------------------------------------------------------
--|AUTHOR 						: GEORGE DAVY											|
--|GAME							: TURRENT SHOOTER										|
--|NETID						: py3424												|
--|DATE							: 16-04-2014											|
-- =====================================================================================

display.setStatusBar( display.HiddenStatusBar )
-- ========
--| SCREEN |
-- ========
	local CW 					= display.contentWidth /2;
	local CH 					= display.contentHeight /2;
-- =========
--| PHYSICS |
-- =========
	local gravity 				= 0.0
	local physics 				= require("physics")
	physics.start()
-- ==========
--|  LAYERS  |
-- ==========
	local titleScreenGroup 		= display.newGroup()
	local skyLayer    			= display.newGroup()
	local shootLayer 			= display.newGroup()
	local BoxfallLayer	 		= display.newGroup()
	local missileLayer			= display.newGroup()
	local gun 					= display.newGroup()
-- ==================
--|  GAME VARIABLES  |
-- ==================
	local gameOn 				= true
	local score 				= 0
	local boxMiss				= 0
	local timeLastbox 			= 0, 0
	local toRemove 				= {}
	local textureCache 			= {}
	textureCache[1] 			= display.newImage("images/box.png");
	textureCache[1].isVisible 	= false;
	boxWidth 					= textureCache[1].contentWidth
-- =======
--| SOUND |
-- =======
	local sounds
	-- Adjust the volume
	audio.setMaxVolume( 0.090, { channel=2 } )
	sounds ={
			pew 				= audio.loadSound("sound/pew.wav"),
			boom 				= audio.loadSound("sound/boom.wav"),
			gameOver 			= audio.loadSound("sound/gameover.mp3")
			}
-- ================
--| GAME FUNCTIONS |
-- ================
function main()
	score 					= 0
	boxMiss					= 0
    showTitleScreen();
end

function showTitleScreen()


	--background
			menuBackground 	 	= display.newImageRect( "images/menu.png",display.contentWidth,display.contentHeight)
			menuBackground.x 	= CW
			menuBackground.y 	= CH

	--play button
			playBtn 			= display.newImage("images/playButton.png")
			playBtn.x 			= CW;
			playBtn.y 			= CH + 80
			playBtn.name 		= "loadGame"

	--inserting
			titleScreenGroup:insert(menuBackground)
			titleScreenGroup:insert(playBtn)
	--press button
			playBtn:addEventListener("tap", loadGame)
end


function loadGame(event)
    if event.target.name == "loadGame"  then
			gameOn = true
			transition.to(titleScreenGroup,{time = 0, alpha=0, onComplete =	startGame});
			playBtn:removeEventListener("tap", loadGame)
	end
end

local function destroyObj(obj)
		display.remove(obj)
		obj=nil
end


local function onCollision(self, event)
		if self.name == "bullet" and event.other.name == "box" and gameOn then
			-- Increase score
				score 			= score + 1
				scoreText.text 	= score
			-- Play Sound
				audio.play(sounds.boom)
				table.insert(toRemove, event.other)
				table.insert(toRemove, self)
				explode 		= display.newImage("images/explode.png")
				explode.x 		= laser.x
				explode.y 		= laser.y
				BoxfallLayer:insert(explode)
				timer.performWithDelay(150,function()
											destroyObj(explode)
											end, 1)
		elseif self.name == "bullet" and event.other.name == "missile" and gameOn then
			-- Increase score
				score 			= score + 5
				scoreText.text 	= score
			-- Play Sound
				audio.play(sounds.boom)
				table.insert(toRemove, event.other)
				table.insert(toRemove, self)
				explode 		= display.newImage("images/explode.png")
				explode.x 		= laser.x
				explode.y 		= laser.y
				BoxfallLayer:insert(explode)
				timer.performWithDelay(150,function()
											destroyObj(explode)
											end, 1)
		elseif self.name == "ground" and event.other.name == "box" and gameOn then
			-- Increase boxMiss
				boxMiss 			= boxMiss + 1
				boxMissText.text 	= boxMiss
				table.insert(toRemove, event.other)
				timer.performWithDelay(150,function()
											destroyObj(explode)
											end, 1)
				if boxMiss >= 5 then
					gameOn 			= false
					boxMiss 		= 0
					audio.play(sounds.gameOver)
					gameoverText 	= display.newText("GAME OVER !!!", 0, 0, native.systemFontBold, 35)
					gameoverText:setFillColor(40, 0, 0)
					gameoverText.x 	= display.contentCenterX
					gameoverText.y 	= display.contentCenterY - 20
					skyLayer:insert(gameoverText)

					gameScore 	= display.newText(score, 0, 0, native.systemFontBold, 50)
					gameScore:setFillColor(0, 0, 0)
					gameScore.x 	= display.contentCenterX
					gameScore.y 	= display.contentCenterY + 40
					gameScore.name 	= "gameScore"
					skyLayer:insert(gameScore)
				end
		elseif self.name == "ground" and event.other.name == "missile" and gameOn then
				table.insert(toRemove, event.other)
				explode 			= display.newImage("images/explode.png")
				explode.x 			= gun.x
				explode.y 			= gun.y - 50
				BoxfallLayer:insert(explode)
				--timer.performWithDelay(150,function()
				--							destroyObj(explode)
				--							end, 1)
				gameOn 				= false
				audio.play(sounds.gameOver)
				gameoverText 		= display.newText("GAME OVER !!!", 0, 0, native.systemFontBold, 35)
				gameoverText:setFillColor(40, 0, 0)
				gameoverText.x 		= display.contentCenterX
				gameoverText.y 		= display.contentCenterY - 20
				skyLayer:insert(gameoverText)

				gameScore 	= display.newText(score, 0, 0, native.systemFontBold, 50)
				gameScore:setFillColor(0, 0, 0)
				gameScore.x 		= display.contentCenterX
				gameScore.y 		= display.contentCenterY + 40
				gameScore.name 		= "gameScore"
				skyLayer:insert(gameScore)
		end
end


local function rotateObj(event)
	local t = event.target
	local phase = event.phase
	if (phase == "began") then
			display.getCurrentStage():setFocus( t )
			t.isFocus 			= true
			t.x1 				= event.x
			t.y1 				= event.y

	elseif t.isFocus then
		if (phase == "moved") then
				t.x2 			= event.x
				t.y2 			= event.y
				angle1 			= 180/math.pi * math.atan2(t.y1 - t.y, t.x1 - t.x)
				angle2 			= 180/math.pi * math.atan2(t.y2 - t.y, t.x2 - t.x)
				rotationAmt 	= angle1 - angle2
				t.rotation 		= t.rotation - rotationAmt
				t.x1 			= t.x2
				t.y1 			= t.y2
		elseif (phase == "ended") then
				display.getCurrentStage():setFocus( nil )
				t.isFocus 		= false
		end
	end
	return true
end


local function pointAtDistance(angle, distance)
	-- Convert angle to radians as lua math functions expect radians
		local r 				= math.rad(angle)
		local x 				= math.cos(r) * distance
		local y 				= math.sin(r) * distance
		return x, y
end


local function shootfunc(event)
	if  gameOn then
			laser = display.newRect(0, 0,10, 35)
			laser:setFillColor(255, 255, 255)
			physics.addBody(laser, "kinematic", {bounce = 0})
			local tipX, tipY 	= pointAtDistance(gun.rotation - 90, gun.height + (laser.height/3))
			laser.x 			= gun.x + tipX
			laser.y 			= gun.y + tipY
			-- distance to shoot bullet (anywhere offscreen is sufficient)
			local distance 		= 1000
			-- Make bullet match angle of gun
			laser.rotation 		= gun.rotation
			-- We actually want to shoot perpendicular to our angle
			local shootAngle 	= laser.rotation - 90
			-- Plot x, y target for bullet based on rotation
			local x, y 			= pointAtDistance(shootAngle, distance)
			local targetX 		= laser.x + x
			local targetY 		= laser.y + y
			laser.name 			= "bullet"
			laser.collision 	= onCollision
			laser:addEventListener("collision", laser)
			shootLayer:insert(laser)
			-- firing sound!
			audio.play(sounds.pew)
			transition.to(laser,{
									time = 1500,
									x = targetX,
									y = targetY
								})
	end
end


local function gameLoop(event)
-- ===========
--| Game loop |
-- ===========

		-- Remove collided box
	for i = 1, #toRemove do
				toRemove[i].parent:remove(toRemove[i])
				toRemove[i] = nil
	end
	if gameOn then
		-- box planes
		if event.time - timeLastbox >= math.random(1000, 1100+math.floor(gravity)*2) then
		-- Randomly position it on the top of the screen
				box 			= display.newImage("images/box.png")
				boxPos = math.random(boxWidth, display.contentWidth - boxWidth)
				if boxPos >= lastStartPos and boxPos <= lastEndPos then
					box.x 		= boxPos - boxWidth - 20
				else
					box.x 		= boxPos
				end
				box.x 			= boxPos
				box.y 			= -box.contentHeight
				lastStartPos 	= boxPos
				lastEndPos 		= boxPos + boxWidth
				-- fall to the bottom of the screen.
				physics.addBody(box, "dynamic", {bounce = 0})
				box.name 		= "box"
				BoxfallLayer:insert(box)
				timeLastbox 	= event.time
				-- Increase Level by increasing gravity
				gravity     	= (score / 50) + 1
				physics.setGravity(0, gravity)
				gameLevelText	= display.newText(math.floor(gravity), 0, 0, native.systemFont, 12)
				gameLevelText:setFillColor(0, 0, 0)
				gameLevelText.x = display.contentWidth - 35
				gameLevelText.y = 70
				skyLayer:insert(gameLevelText)
				timer.performWithDelay(500,function()
											destroyObj(gameLevelText)
											end, 1)
		end
		if event.time - timeLastbox >= math.random(1000,2000) then
				missile 		= display.newImage("images/missile.png")
				missile.x 		= math.random(missile.contentWidth, display.contentWidth - missile.contentWidth)
				missile.y 		= -missile.contentHeight
				physics.addBody( missile, "dynamic",{bounce = 0} )
				missile.name 	= "missile"
				missileLayer:insert(missile)
				transition.to(missile,{
									time = 3000,
									x = gun.x,
									y = gun.y
								})
		end
	end
end


function startGame()
-- ==============
--| MAIN PROGRAM |
-- ==============

	-- Hide status bar, so it won't keep covering our game objects
	display.setStatusBar(display.HiddenStatusBar)
	gun.x 						= display.contentCenterX
	gun.y 						= display.contentHeight + 30

	-- Background Layer(Layer 1)
	background 					= display.newImageRect( "images/sky.png",display.contentWidth,display.contentHeight)
	background.y 				= display.contentHeight/2
	background.x 				= display.contentWidth/2
	skyLayer:insert(background)
	lastStartPos 				= display.contentWidth/2
	lastEndPos   				= lastStartPos + boxWidth

	-- Box Layer(Layer 2)
	-- The shape of the gun
	gunBody 				= display.newRect(-5, -50, 45, 120)
	gunBody:setFillColor(0, 0, 0)
	gun:insert(gunBody)

	-- A site on the gun so we can tell where it's pointed
	site 					= display.newRect(-5, -55, 10, 20)
	site:setFillColor(100, 200, 50)
	gun:insert(site)
	gun:addEventListener("touch", rotateObj)
	gun:addEventListener("tap", shootfunc)

		skyLayer:insert(gun)

	-- Bullet Layer(Layer 3)
	skyLayer:insert(shootLayer)


	-- Missile Layer(Layer 5)
	skyLayer:insert(missileLayer)

	-- Box Layer(Layer 4)
	skyLayer:insert(BoxfallLayer)

	ground 						= display.newRect(0, display.contentHeight + 20 , display.contentWidth*2, 50)
	ground:setFillColor(0, 0, 0)
	physics.addBody(ground, "static", {bounce = 0})
	ground.name 				= "ground"
	ground.collision 			= onCollision
	ground:addEventListener("collision", ground)
	skyLayer:insert(ground)

	-- Score Layer(Layer 5)
	scoreTextTitle 				= display.newText("SCORE", 0, 0, native.systemFont, 12)
	scoreTextTitle:setFillColor(0, 0, 0)
	scoreTextTitle.x 			= 30
	scoreTextTitle.y 			= 20
	skyLayer:insert(scoreTextTitle)

	scoreText 					= display.newText(score, 0, 0, native.systemFont, 12)
	scoreText:setFillColor(0, 0, 0)
	scoreText.x 				= 30
	scoreText.y 				= 35
	skyLayer:insert(scoreText)

	boxMissTitle 				= display.newText("BOX MISSED", 0, 0, native.systemFont, 12)
	boxMissTitle:setFillColor(0, 0, 0)
	boxMissTitle.x 				= display.contentWidth - 50
	boxMissTitle.y 				= 20
	skyLayer:insert(boxMissTitle)

	boxMissText					= display.newText(boxMiss, 0, 0, native.systemFont, 12)
	boxMissText:setFillColor(0, 0, 0)
	boxMissText.x 				= display.contentWidth - 35
	boxMissText.y 				= 35
	skyLayer:insert(boxMissText)

	gameLevelTitle 				= display.newText("LEVEL", 0, 0, native.systemFont, 12)
	gameLevelTitle:setFillColor(0, 0, 0)
	gameLevelTitle.x 			= display.contentWidth - 40
	gameLevelTitle.y 			= 55
	skyLayer:insert(gameLevelTitle)

	Runtime:addEventListener("enterFrame", gameLoop)

end

-- ==================
--| RUN MAIN PROGRAM |
-- ==================
main()
-- =============
--| END OF FILE |
-- =============
