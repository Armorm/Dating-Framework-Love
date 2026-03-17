
local Textboxbackground = love.graphics.newImage('Sprites/Misc/DokiDokiLitClub.png')
local window = {width = 1920, height = 1080}
local box = {width = Textboxbackground:getWidth(), height = Textboxbackground:getHeight()}
local Scene = require("Scene")

function love.keypressed(key)
    Scene.keypressed(key)
end

function love.load()
    love.window.setMode(window.width, window.height, {x = 0, y = 0})
    love.graphics.setDefaultFilter("nearest", "nearest")
    function drawOutlinedText(text, x, y)
     love.graphics.setColor(0, 0, 0.8, 1)

     for ox = -4, 4 do
         for oy = -4, 4 do
             if not (ox == 0 and oy == 0) then
                 love.graphics.print(text, x + ox, y + oy)
             end
         end
     end

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(text, x, y)
end
end

function love.update(dt)
    Scene.update(dt)
end

function love.draw(dt)

 --background drawing
 if Scene.sceneSetup[Scene.currentScene][Scene.currentInfo].background then
    local sx = window.width / Scene.sceneSetup[Scene.currentScene][Scene.currentInfo].background:getWidth()
    local sy = window.height / Scene.sceneSetup[Scene.currentScene][Scene.currentInfo].background:getHeight()

    love.graphics.draw(Scene.sceneSetup[Scene.currentScene][Scene.currentInfo].background, 0, 0, 0, sx, sy)
 end

 --forgrounddrawing
 if Scene.sceneSetup[Scene.currentScene][Scene.currentInfo].forground then
    local sx = 600 / Scene.sceneSetup[Scene.currentScene][Scene.currentInfo].forground.img:getWidth()
    local sy = 600 / Scene.sceneSetup[Scene.currentScene][Scene.currentInfo].forground.img:getHeight()
    
    love.graphics.draw(Scene.sceneSetup[Scene.currentScene][Scene.currentInfo].forground.img, Scene.sceneSetup[Scene.currentScene][Scene.currentInfo].forground.x, Scene.sceneSetup[Scene.currentScene][Scene.currentInfo].forground.y, 0, sx, sy)
 end
 --Text thing for name
 love.graphics.setLineWidth(4)

 love.graphics.setScissor(400, 750, 400, 74)


 love.graphics.setBlendMode("alpha")
 love.graphics.setColor(1, 1, 1, 0.8)
 love.graphics.rectangle("fill", 400, 750, 400, 100, 20, 20)

 love.graphics.setScissor()


 --Text thing for body text
 love.graphics.setColor(1, 1, 1, 0.9)
 love.graphics.draw(Textboxbackground, 350, window.height - box.height*1.5-40, 0, 1.5, 1.5)
 
 --Actual text
 local font1 = love.graphics.newFont(45)
 love.graphics.setFont(font1)
 love.graphics.printf(Scene.showcaseText.text, 375, 835, 1180)

 -- Name text
 local font2 = love.graphics.newFont(60)
 drawOutlinedText(Scene.sceneSetup[Scene.currentScene][Scene.currentInfo].name, 420, 755)

 
end
