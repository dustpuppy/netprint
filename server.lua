local component = require("component")
local event = require("event")

local args = { ... }

local silent = false
if #args > 0 then
  if args[1] == "silent" then
    silent = true
  end
end

if not component.isAvailable("openprinter") then
  io.stderr:write("This program requires openprinter to run.")
  return
end
local printer = component.openprinter

if not component.isAvailable("modem") then
  io.stderr:write("This program requires a modem to run.")
  return
end
local modem = component.modem
local printServerPort = 9100
modem.open(printServerPort)


local function modemCallback(_, _, from, port, distance, ...)
  local message = {...}
  if silent == false then
    if message[2] then
      print(from .. " " .. tostring(port) .. " " .. message[1] .. " " .. message[2])
    else
      print(from .. " " .. tostring(port) .. " " .. message[1])
    end
  end
  if port == printServerPort then
    if message[1] == "GET PRINTER" then
      addr = printer.address
      modem.send(from, printServerPort, addr)
    elseif message[1] == "WRITELN" then
      addr = message[2]
      if addr == printer.address then
	str = message[3]
	col = message[4]
	al = message[5]
	printer.writeln(str, col, al)
      end
    elseif message[1] == "SETTITLE" then
      addr = message[2]
      if addr == printer.address then
	str = message[3]
	printer.setTitle(str)
      end
    elseif message[1] == "GETPAPERLEVEL" then
      addr = message[2]
      if addr == printer.address then
	modem.send(from, printServerPort, printer.getPaperLevel())
      end
    elseif message[1] == "GETCOLORINKLEVEL" then
      addr = message[2]
      if addr == printer.address then
	modem.send(from, printServerPort, printer.getColorInkLevel())
      end
    elseif message[1] == "GETBLACKINKLEVEL" then
      addr = message[2]
      if addr == printer.address then
	modem.send(from, printServerPort, printer.getBlackInkLevel())
      end
    elseif message[1] == "CLEAR" then
      addr = message[2]
      if addr == printer.address then
	printer.clear()
      end
    elseif message[1] == "PRINT" then
      addr = message[2]
      if addr == printer.address then
	printer.print()
      end
    elseif message[1] == "PRINTTAG" then
      addr = message[2]
      if addr == printer.address then
	str = message[3]
	printer.printTag(str)
      end
    end
  end
end


event.listen("modem_message", modemCallback)

if silent == false then
  while true do
    os.sellep(0)
  end
end
