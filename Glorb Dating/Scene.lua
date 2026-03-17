local Timer = require("libs.timer")
local timer = Timer.new()

local Scene = {}

local timerText = {value = 0}
Scene.currentScene = "Scene1"
Scene.currentInfo = 1

--Assets
--backgrounds
local classroomBackground = love.graphics.newImage('Sprites/backgrounds/GenericClassroom.jpg')

--forgrounds(Characters)
local Rob = love.graphics.newImage('Sprites/characters/Robert.jpg')



Scene.sceneSetup = {
    Scene1 = {
        {text = "adsadsiaji", name = "Robert", background = classroomBackground, forground = {x = 850, y = 300, img = Rob}, type = "dialouge" }, 
        {text = "10000000323132132132132132132132132132132132132132120", name = "Marijn", forground = {x = 850, y = 300, img = Rob, animation = "jump"}, background = classroomBackground, type = "dialouge"},
        {text = "choices", choices = {{choiceName = "choice 1", outcome = {currentScene = "Scene 2"}}, {choiceName = "choice 2", outcome = {currentScene = "Scene 3"}}, name = "Marijn", forground = {x = 850, y = 300, img = Rob, animation = "jump"}, background = classroomBackground, type = "choice"}},
    },
    Scene2 = {
        {text = "welcome to scene 2", name = "Robert", background = classroomBackground, forground = {x = 850, y = 300, img = Rob}, type = "dialouge" }, 
    },
    Scene3 = {
        {text = "welcome to scene 3", name = "Robert", background = classroomBackground, forground = {x = 850, y = 300, img = Rob}, type = "dialouge" }, 
    }
    }


local animations = {
    jump = function (fg)
        timer:tween(0.1, fg, {y = fg.y -20}, "out-quad", function ()
            timer:tween(0.1, fg, {y = fg.y+20}, "in-quad")
        end)
    end
}
    


Scene.showcaseText = {text = "", total = #Scene.sceneSetup[Scene.currentScene][Scene.currentInfo].text, amountShown = 0}

function Scene.keypressed(key)
    
    if key == "space" and Scene.showcaseText.total == Scene.showcaseText.amountShown and Scene.sceneSetup[Scene.currentScene][Scene.currentInfo].type == "dialouge" then
         Scene.showcaseText.amountShown = 0
         Scene.currentInfo = Scene.currentInfo + 1
         Scene.showcaseText = {text = "", total = #Scene.sceneSetup[Scene.currentScene][Scene.currentInfo].text, amountShown = 0}
         local current = Scene.sceneSetup[Scene.currentScene][Scene.currentInfo]
         if current.forground and current.forground.animation and animations[current.forground.animation] and Scene.sceneSetup[Scene.currentScene][Scene.currentInfo].type == "dialouge" then
             animations[current.forground.animation](current.forground)
         end

     elseif key == "space" and Scene.showcaseText.total ~= Scene.showcaseText.amountShown and Scene.sceneSetup[Scene.currentScene][Scene.currentInfo].type == "dialouge" then
         Scene.showcaseText.amountShown = Scene.showcaseText.total
     else
        Scene.showcaseText.text = ""
        Scene.showcaseText.total = 0 
     end
end

function Scene.update(dt)
    timer:update(dt)
    local info = Scene.sceneSetup[Scene.currentScene][Scene.currentInfo] 
        if Scene.showcaseText.amountShown ~= Scene.showcaseText.total and timerText.value <= 0 then
        Scene.showcaseText.amountShown = Scene.showcaseText.amountShown + 1
        timerText.value = 1
        timer:tween(0.02, timerText, {value = -0.1}, "linear")
    end
    Scene.showcaseText.text = string.sub(Scene.sceneSetup[Scene.currentScene][Scene.currentInfo].text, 1, Scene.showcaseText.amountShown)

    
end



return Scene