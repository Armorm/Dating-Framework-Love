local Timer = require("libs.timer")
local timer = Timer.new()

local Scene = {}
local backgroundTweenHandle

local timerText = {value = 0}
Scene.currentScene = "Scene1"
Scene.currentInfo = 1
Scene.selectedChoice = 1

--Assets
--backgrounds
local classroomBackground = love.graphics.newImage('Sprites/backgrounds/GenericClassroom.jpg')

--forgrounds(Characters)
local Rob = love.graphics.newImage('Sprites/characters/Robert.jpg')

local function getExistingDirectory(paths)
    for _, path in ipairs(paths) do
        if love.filesystem.getInfo(path, "directory") then
            return path
        end
    end

    return nil
end

local function toSlug(name)
    local slug = name:lower():gsub("[^%w]+", "_"):gsub("^_+", ""):gsub("_+$", "")
    return slug
end

local function appendUnique(list, seen, value)
    if value ~= "" and not seen[value] then
        list[#list + 1] = value
        seen[value] = true
    end
end

local function registerAudioSource(registry, fileName, source)
    local baseName = fileName:gsub("%.[^%.]+$", "")
    local slug = toSlug(baseName)

    registry[fileName] = source
    registry[fileName:lower()] = source
    registry[baseName] = source
    registry[baseName:lower()] = source

    if slug ~= "" then
        registry[slug] = source
    end
end

local function loadAudioDirectory(candidates, sourceType)
    local registry = {}
    local options = {}
    local seenOptions = {}
    local directory = getExistingDirectory(candidates)

    if not directory then
        return registry, options
    end

    for _, item in ipairs(love.filesystem.getDirectoryItems(directory)) do
        if item:lower():match("%.mp3$") then
            local path = directory .. "/" .. item
            local ok, source = pcall(love.audio.newSource, path, sourceType)

            if ok and source then
                if sourceType == "stream" then
                    source:setLooping(true)
                end
                registerAudioSource(registry, item, source)
                appendUnique(options, seenOptions, toSlug(item:gsub("%.[^%.]+$", "")))
            end
        end
    end

    table.sort(options)
    return registry, options
end

local function getAudioSource(registry, key)
    if type(key) ~= "string" then
        return nil
    end

    return registry[key] or registry[key:lower()]
end

local loadedMusic, loadedMusicOptions = loadAudioDirectory({"sound/music", "Sound/music"}, "stream")
local loadedEffects, loadedEffectOptions = loadAudioDirectory({"sound/effects", "Sound/effects", "Sound/Effects"}, "static")

Scene.audio = {
    music = loadedMusic,
    effects = loadedEffects,
    currentMusic = nil,
    currentMusicKey = nil,
    activeEffects = {}
}

Scene.sceneSetupOptions = {
    backgroundAnimation = {"crossfade"},
    musicChange = {
        "nil (keep current music)",
        "stop (stop current music)",
        "track key from availableMusicKeys"
    },
    effect = "effect key from availableEffectKeys",
    effects = "array of effect keys",
    availableMusicKeys = loadedMusicOptions,
    availableEffectKeys = loadedEffectOptions
}

-- Scene entry options:
-- backgroundAnimation = "crossfade"
-- musicChange = nil (keep), "stop", or a key from Scene.sceneSetupOptions.availableMusicKeys
-- effect = "<effectKey>" or effects = {"<effectKey1>", "<effectKey2>"}
Scene.sceneSetup = {
    Scene1 = {
        {
            text = "adsadsiaji",
            name = "Robert",
            background = classroomBackground,
            backgroundAnimation = "",
            musicChange = "what_is_this_diddy_blud_doing_on_the_calculator_animated_music_video",
            forground = {x = 850, y = 300, img = Rob},
            type = "dialouge"
        }, 
        {
            text = "10000000323132132132132132132132132132132132132132120",
            name = "Marijn",
            forground = {x = 850, y = 300, img = Rob, animation = "jump"},
            background = classroomBackground,
            backgroundAnimation = "",
            effect = "fart_sound_effect",
            musicChange = "stop",
            type = "dialouge"
        },
        {
            text = "choices",
            name = "Marijn",
            choices = {
                {choiceName = "choice 1", outcome = {currentScene = "Scene2"}},
                {choiceName = "choice 2", outcome = {currentScene = "Scene3"}}
            },
            forground = {x = 850, y = 300, img = Rob, animation = "jump"},
            background = classroomBackground,
            backgroundAnimation = "crossfade",
            type = "choice"
        },
    },
    Scene2 = {
        {text = "welcome to scene 2", name = "Robert", background = classroomBackground, backgroundAnimation = "", forground = {x = 850, y = 300, img = Rob}, type = "dialouge" }, 
    },
    Scene3 = {
        {text = "welcome to scene 3", name = "Robert", background = classroomBackground, backgroundAnimation = "", musicChange = "stop", forground = {x = 850, y = 300, img = Rob}, type = "dialouge" }, 
    }
    }

Scene.backgroundState = {
    previous = nil,
    current = Scene.sceneSetup[Scene.currentScene][Scene.currentInfo].background,
    previousOpacity = 0,
    currentOpacity = 1
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

local function playBackgroundAnimation(previousInfo)
    local current = getCurrentInfo()
    if not current then
        return
    end

    if backgroundTweenHandle then
        timer:cancel(backgroundTweenHandle)
        backgroundTweenHandle = nil
    end

    local previousBackground = previousInfo and previousInfo.background or nil
    local currentBackground = current.background

    if current.backgroundAnimation == "crossfade" and previousBackground and currentBackground then
        Scene.backgroundState.previous = previousBackground
        Scene.backgroundState.current = currentBackground
        Scene.backgroundState.previousOpacity = 1
        Scene.backgroundState.currentOpacity = 0

        backgroundTweenHandle = timer:tween(0.45, Scene.backgroundState, {previousOpacity = 0, currentOpacity = 1}, "linear", function()
            Scene.backgroundState.previous = nil
            Scene.backgroundState.previousOpacity = 0
            backgroundTweenHandle = nil
        end)
    else
        Scene.backgroundState.previous = nil
        Scene.backgroundState.current = currentBackground
        Scene.backgroundState.previousOpacity = 0
        Scene.backgroundState.currentOpacity = currentBackground and 1 or 0
    end
end

local function setMusic(change)
    if type(change) == "string" and change:lower() == "stop" then
        if Scene.audio.currentMusic then
            Scene.audio.currentMusic:stop()
        end

        Scene.audio.currentMusic = nil
        Scene.audio.currentMusicKey = nil
        return
    end

    local musicSource = getAudioSource(Scene.audio.music, change)
    if not musicSource then
        return
    end

    if Scene.audio.currentMusic ~= musicSource then
        if Scene.audio.currentMusic then
            Scene.audio.currentMusic:stop()
        end

        musicSource:stop()
        musicSource:setLooping(true)
        musicSource:play()
        Scene.audio.currentMusic = musicSource
        Scene.audio.currentMusicKey = change
        return
    end

    if not musicSource:isPlaying() then
        musicSource:play()
    end
end

local function playEffect(effectName)
    local effectSource = getAudioSource(Scene.audio.effects, effectName)
    if not effectSource then
        return
    end

    local effectInstance = effectSource:clone()
    effectInstance:setLooping(false)
    effectInstance:play()
    Scene.audio.activeEffects[#Scene.audio.activeEffects + 1] = effectInstance
end

local function playCurrentAudio()
    local current = getCurrentInfo()
    if not current then
        return
    end

    if current.musicChange ~= nil then
        if type(current.musicChange) == "table" then
            local requestedMusic = current.musicChange.name or current.musicChange.track or current.musicChange.music
            if requestedMusic then
                setMusic(requestedMusic)
            elseif current.musicChange.action == "stop" then
                setMusic("stop")
            end
        else
            setMusic(current.musicChange)
        end
    end

    local requestedEffect = current.effect or current.effects
    if requestedEffect ~= nil then
        if type(requestedEffect) == "table" then
            if requestedEffect.name then
                playEffect(requestedEffect.name)
            else
                for _, effectName in ipairs(requestedEffect) do
                    playEffect(effectName)
                end
            end
        else
            playEffect(requestedEffect)
        end
    end
end

local function setCurrentInfo(sceneName, infoIndex)
    local previousInfo = getCurrentInfo()
    Scene.currentScene = sceneName
    Scene.currentInfo = infoIndex
    resetShowcaseText()
    playCurrentAnimation()
    playBackgroundAnimation(previousInfo)
    playCurrentAudio()
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
                setCurrentInfo(selected.outcome.currentScene, selected.outcome.currentInfo or 1)
            end
        else
            moveChoiceSelection(key, current.choices)
        end
        return
    end

    if key == "space" and current.type == "dialouge" and textFinished then
        local nextInfo = Scene.currentInfo + 1
        if Scene.sceneSetup[Scene.currentScene][nextInfo] then
            setCurrentInfo(Scene.currentScene, nextInfo)
        end
    end
end

function Scene.update(dt)
    timer:update(dt)

    for i = #Scene.audio.activeEffects, 1, -1 do
        if not Scene.audio.activeEffects[i]:isPlaying() then
            table.remove(Scene.audio.activeEffects, i)
        end
    end

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

playCurrentAudio()


return Scene
