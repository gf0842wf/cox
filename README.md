cox
===
A lightweight unix style wrapping of Cocos2d-x-lua.

Current Version:
v0.1.1, support cocos2d-x 3.2.


How to use
===
put cox.lua under your src direcotry, and require it.

Simple test
===
<pre>
local cox = require("cox")
local carrot = cox.newspr{on=layer, tex="icon.png"}
carrot:runact{"moveb", 2, 200, 0}
</pre>

Sprite and Action
===
<pre>
local cox = require("cox")

local p = cox.newspr{on=layer, texf="carrot.png", x=cox.w/2, y=276}
p:set{name="carrot"}
p:runact{
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
}
</pre>

Animate sprite
===
<pre>
local block = cox.newspr{on=layer, animf={"select_%02d.png", {1,2}, 0.2}}
block:play(1) -- play once and remove self
</pre>
