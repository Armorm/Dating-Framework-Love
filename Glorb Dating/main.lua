
local Textboxbackground = love.graphics.newImage('Sprites/Misc/DokiDokiLitClub.png')
local window = {width = 1920, height = 1080}
local box = {width = Textboxbackground:getWidth(), height = Textboxbackground:getHeight()}
local Scene = require("Scene")

local function drawBackgroundImage(image, window, alpha)
    if not image or alpha <= 0 then
        return
    end

    local sx = window.width / image:getWidth()
    local sy = window.height / image:getHeight()

    love.graphics.setColor(1, 1, 1, alpha)
    love.graphics.draw(image, 0, 0, 0, sx, sy)
end

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
 local current = Scene.sceneSetup[Scene.currentScene][Scene.currentInfo]
 if not current then
    return
 end

 --background drawing
 if Scene.backgroundState then
    drawBackgroundImage(Scene.backgroundState.previous, window, Scene.backgroundState.previousOpacity)
    drawBackgroundImage(Scene.backgroundState.current, window, Scene.backgroundState.currentOpacity)
 elseif current.background then
    drawBackgroundImage(current.background, window, 1)
 end
 love.graphics.setColor(1, 1, 1, 1)

 --forgrounddrawing
 if current.forground then
    local sx = 600 / current.forground.img:getWidth()
    local sy = 600 / current.forground.img:getHeight()
    
    love.graphics.draw(current.forground.img, current.forground.x, current.forground.y, 0, sx, sy)
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
 drawOutlinedText(current.name, 420, 755)

if current.type == "choice" and current.choices and Scene.showcaseText.amountShown == Scene.showcaseText.total then
    local startX = 400
    local startY = 890
    local colSpacing = 500  -- distance between left/right choices
    local rowSpacing = 70   -- distance between rows

    love.graphics.setColor(1, 1, 1, 1)
    for i, choice in ipairs(current.choices) do
        local col = (i - 1) % 2
        local row = math.floor((i - 1) / 2)

        local x = startX + col * colSpacing
        local y = startY + row * rowSpacing

        if i == Scene.selectedChoice then
            love.graphics.circle("fill", x - 22, y + 23, 8)
        end

        love.graphics.printf(choice.choiceName, x, y, 450)
    end
 end
end
 
