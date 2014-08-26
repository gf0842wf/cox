-- A lightly wrapping of Cocos2d-x lua, providing unix style interfaces.
-- v0.1, support cocos2d-x 3.2.

require "Cocos2d"

local cox = {}

local D = cc.Director:getInstance()
local TC = D:getTextureCache()
local FC = cc.SpriteFrameCache:getInstance()
local SIZE = D:getWinSize()
local UD = cc.UserDefault:getInstance()
local SA = cc.SimpleAudioEngine:getInstance()
local FU = cc.FileUtils:getInstance()

cox.d = D
cox.tc = TC
cox.fc = FC
cox.w = SIZE.width
cox.h = SIZE.height
cox.ud = UD
cox.sa = SA
cox.fu = FU

-- remove by element
function table.del(t, elem)
    for i, v in ipairs(t) do
        if v == elem then
            table.remove(t, i)
        end
    end
end

-- set resolution
function cox.setrs(w, h, type)
    D:getOpenGLView():setDesignResolutionSize(w, h, type)
    SIZE = D:getWinSize()
    cox.w = SIZE.width
    cox.h = SIZE.height
end

-- run or replace scene
function cox.switch(nextscene)
    if D:getRunningScene() then
        D:replaceScene(nextscene)
    else
        D:runWithScene(nextscene)
    end
end

--[[ bind key event
eg.
local function onrelease(code, event)
    if code == cc.KeyCode.KEY_BACK then
        D:endToLua()
end
cox.bindkey(layer, onrelease)
]]
function cox.bindk(node, cb)
    local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(cb, cc.Handler.EVENT_KEYBOARD_RELEASED)

    local eventDispatcher = node:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, node)
end

-- bind KEY_BACK event
function cox.bindkb(node, cb)
    local function onpress(code, event)
        if code == cc.KeyCode.KEY_BACK then
            cb()
        end
    end
    cox.bindk(node, onpress)
end

function cox.loadef(filename)
    SA:preloadEffect(filename)
end

function cox.playef(filename)
    SA:playEffect(filename)
end

function cox.playms(filename, loop)
    SA:playMusic(filename, loop)
end

function cox.stopms()
    SA:stopMusic()
end

-- create a cc.Sprite and add to parent node.
-- eg.
-- cox.newspr{parent=layer, texf="carrot.png", x=cox.w/2, y=276}
function cox.newspr(arg)
    local spr = nil
    if arg.texf then
        spr = cc.Sprite:createWithSpriteFrameName(arg.texf)
    elseif arg.tex then
        spr = cc.Sprite:create(arg.tex)
    elseif arg.animf then
        spr = cox._animspr(arg.animf[1], arg.animf[2], arg.animf[3])
    else
        spr = cc.Sprite:create()
    end
    cox.setspr(spr, arg)
    spr.set = cox.setspr
    spr.runact = cox.runact
    return spr
end

-- set sprite's attributes
-- eg.
-- tip:set{parent=self, name="uptip", x=0, y=60}
function cox.setspr(spr, arg)
    if arg.x then
        spr:setPositionX(arg.x)
    end
    if arg.y then
        spr:setPositionY(arg.y)
    end
    if arg.z then
        spr:setLocalZOrder(arg.z)
    end
    -- normalized position
    if arg.np then
        spr:setNormalizedPosition(cc.p(arg.np[1], arg.np[2]) )
    end
    -- anchor point
    if arg.ac then
        spr:setAnchorPoint(arg.ac[1], arg.ac[2])
    end
    if arg.name then
        spr:setName(arg.name)
    end
    if arg.rot then
        spr:setRotation(arg.rot)
    end
    if arg.scale then
        spr:setScale(arg.scale)
    end
    if arg.parent then
        arg.parent:addChild(spr)
        -- default in middle
        local size = arg.parent:getContentSize()
        if not arg.x then
            spr:setPositionX(size.width/2)
        end
        if not arg.y then
            spr:setPositionY(size.height/2)
        end
    end
end

--[[
Create a cc.Animate action with frame names.
eg.
cox.animf("air%02d.png", {1,2,3,4,5}, 0.06)
]]
function cox.animf(format, numbers, dt)
    local frames = {}
    for i, num in ipairs(numbers) do
        local f = FC:getSpriteFrame(string.format(format, num))
        table.insert(frames, f)
    end
    local animation = cc.Animation:createWithSpriteFrames(frames,dt)
    local animate = cc.Animate:create(animation)
    return animate
end

function cox._animspr(format, numbers, dt)
    local ani = cox.animf(format, numbers, dt)
    local spr = cc.Sprite:createWithSpriteFrameName(string.format(format, numbers[1]))
    spr.play = function(self, times)
        if times == nil or times <= 0 then
            spr:runAction(cc.RepeatForever:create(ani))
        else
            spr:runAction(cc.Sequence:create(
                cc.Repeat:create(ani, times), 
                cc.RemoveSelf:create() 
            ))
        end
    end
    return spr
end

--[[
Create a cc.Action with a simple lua table.
eg.
luobo:runAction(cox.act{
{"delay", 3},
{
    {"animf", "hlb%d.png", {21,22,23,10}, 0.05},
    {"repeat", 2}
},
{"delay", 3},
{
    {"rotb", 0.2, 20},
    {"rotb", 0.4, -40},
    {"rotb", 0.2, 20},
    {"repeat", 4}
},
{"delay", 3},
{"repeat", -1}
})
]]
function cox.act(cfg)
    local tok = cfg[1]
    local act = nil
    if type(tok) == "string" then
        local act = nil
        local v = cfg
        if tok == "move" then
            act = cc.MoveTo:create(v[2], cc.p(v[3], v[4]))   
        elseif tok == "moveb" then
            act = cc.MoveBy:create(v[2], cc.p(v[3], v[4]))
        elseif tok == "obj" then
            act = v[2]
        elseif tok == "call" then
            if v[3] == nil then
                act = cc.CallFunc:create(v[2])
            else
                act = cc.CallFunc:create(v[2], v[3])
            end
        elseif tok == "delay" then
            act = cc.DelayTime:create(v[2])
        elseif tok == "rot" then
            act = cc.RotateTo:create(v[2], v[3])
        elseif tok == "rotb" then
            act = cc.RotateBy:create(v[2], v[3])
        elseif tok == "scale" then
            act = cc.ScaleTo:create(v[2], v[3])
        elseif tok == "scaleb" then
            act = cc.ScaleBy:create(v[2], v[3])
        elseif tok == "remove" then
            act = cc.RemoveSelf:create()
        elseif tok == "fadein" then
            act = cc.FadeIn:create(v[2])
        elseif tok == "fadeout" then
            act = cc.FadeOut:create(v[2])
        elseif tok == "animf" then
            act = cox.animf(v[2], v[3], v[4])
        elseif tok == "flipx" then
            act = cc.FlipX:create(v[2])
        elseif tok == "flipy" then
            act = cc.FlipY:create(v[2])
        end
        return act
    elseif type(tok) == "table" then
        local n = 1
        local speed = nil
        local seq = {}
        local spawn = false
        for _, v in ipairs(cfg) do
            local op = v[1]
            if op == "repeat" then
                n = v[2]
            elseif op == "speed" then
                speed = v[2]
            elseif op == "spawn" then
                spawn = true
            else
                local a = cox.act(v)
                if a then table.insert(seq, a) end
            end
        end
        local act = nil
        if #seq > 1 then
            act = spawn and cc.Spawn:create(seq) or cc.Sequence:create(seq)
        elseif #seq == 1 then
            act = seq[1]
        else
            return
        end
        if n < 0 then
            act = cc.RepeatForever:create(act)
        elseif n ~= 1 then
            act = cc.Repeat:create(act, n)
        end
        if speed ~= nil then
            act = cc.Speed:create(act, speed) 
        end

        return act
    end
end

function cox.runact(node, cfg)
    local act = cox.act(cfg)
    node:runAction(act)
    return act
end

return cox
