local component = require("component")
local netprinter = require("netprinter")
local ser = require("serialization")


p = component.nprinter

p.clear()
p.setTitle("test page")
p.writeln("hallo")
p.print()

print("Paper : " .. p.getPaperLevel())
print("Black : " .. p.getBlackInkLevel())
print("Color : " .. p.getColorInkLevel())
