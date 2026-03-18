local Timer = require("libs.timer")
local timer = Timer.new()

local Scene = {}

local timerText = {value = 0}
Scene.currentScene = "Scene1"
Scene.currentInfo = 1
Scene.selectedChoice = 1

--Assets
--backgrounds
local classroomBackground = love.graphics.newImage('Sprites/backgrounds/GenericClassroom.jpg')

--forgrounds(Characters)
local Rob = love.graphics.newImage('Sprites/characters/Robert.jpg')



Scene.sceneSetup = {
    Scene1 = {
        {text = "adsadsiaji", name = "Robert", background = classroomBackground, forground = {x = 850, y = 300, img = Rob}, type = "dialouge" }, 
        {text = "10000000323132132132132132132132132132132132132132120", name = "Marijn", forground = {x = 850, y = 300, img = Rob, animation = "jump"}, background = classroomBackground, type = "dialouge"},
        {
            text = "choices",
            name = "Marijn",
            choices = {
                {choiceName = "choice 1", outcome = {currentScene = "Scene2"}},
                {choiceName = "choice 2", outcome = {currentScene = "Scene3"}}
            },
            forground = {x = 850, y = 300, img = Rob, animation = "jump"},
            background = classroomBackground,
            type = "choice"
        },
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

local function getCurrentInfo()
    return Scene.sceneSetup[Scene.currentScene][Scene.currentInfo]
end

local function resetShowcaseText()
    local current = getCurrentInfo()
    local currentText = current and current.text or ""
    Scene.showcaseText = {text = "", total = #currentText, amountShown = 0}
    Scene.selectedChoice = 1
end

local function playCurrentAnimation()
    local current = getCurrentInfo()
    if not current then
        return
    end

    if current.forground and current.forground.animation and animations[current.forground.animation] and current.type == "dialouge" then
        animations[current.forground.animation](current.forground)
    end
end

local function moveChoiceSelection(key, choices)
    local totalChoices = #choices
    local colCount = 2
    local selected = Scene.selectedChoice

    if key == "left" then
        if selected > 1 and (selected - 1) % colCount ~= 0 then
            Scene.selectedChoice = selected - 1
        end
    elseif key == "right" then
        if selected < totalChoices and selected % colCount ~= 0 then
            Scene.selectedChoice = selected + 1
        end
    elseif key == "up" then
        local target = selected - colCount
        if target >= 1 then
            Scene.selectedChoice = target
        end
    elseif key == "down" then
        local target = selected + colCount
        if target <= totalChoices then
            Scene.selectedChoice = target
        end
    end
end

function Scene.keypressed(key)
    local current = getCurrentInfo()
    if not current then
        return
    end

    local textFinished = Scene.showcaseText.total == Scene.showcaseText.amountShown

    if key == "space" and not textFinished then
        Scene.showcaseText.amountShown = Scene.showcaseText.total
        return
    end

    if current.type == "choice" and current.choices and textFinished then
        if key == "space" then
            local selected = current.choices[Scene.selectedChoice]
            if selected and selected.outcome and selected.outcome.currentScene and Scene.sceneSetup[selected.outcome.currentScene] then
                Scene.currentScene = selected.outcome.currentScene
                Scene.currentInfo = selected.outcome.currentInfo or 1
                resetShowcaseText()
                playCurrentAnimation()
            end
        else
            moveChoiceSelection(key, current.choices)
        end
        return
    end

    if key == "space" and current.type == "dialouge" and textFinished then
        local nextInfo = Scene.currentInfo + 1
        if Scene.sceneSetup[Scene.currentScene][nextInfo] then
            Scene.currentInfo = nextInfo
            resetShowcaseText()
            playCurrentAnimation()
        end
    end
end

function Scene.update(dt)
    timer:update(dt)
    local info = Scene.sceneSetup[Scene.currentScene][Scene.currentInfo] 
        if info and Scene.showcaseText.amountShown ~= Scene.showcaseText.total and timerText.value <= 0 then
        Scene.showcaseText.amountShown = Scene.showcaseText.amountShown + 1
        timerText.value = 1
        timer:tween(0.02, timerText, {value = -0.1}, "linear")
    end
    if info then
        Scene.showcaseText.text = string.sub(info.text, 1, Scene.showcaseText.amountShown)
    else
        Scene.showcaseText.text = ""
    end

    
end



return Scene
