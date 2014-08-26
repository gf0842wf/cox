cox
===


A lightly wrapping of Cocos2d-x lua, providing unix style interfaces.

Current Version:
v0.1, support cocos2d-x 3.2.


Example
===

<pre>
local cox = require("cox")

local p = cox.newspr{parent=layer, texf="carrot.png", x=cox.w/2, y=276}
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

Create a animation sprite from frame names
===
<pre>
local block = cox.newspr{animf={"select_%02d.png", {1,2}, 0.2}}
block:play(1) -- play once and remove self
</pre>