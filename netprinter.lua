local component = require("component")
local ser = require("serialization")
local vcomp = require("vcomponent")
local modem = component.modem
local event = require("event")

local printServerPort = 9100

modem.open(printServerPort)
local netprinter = {}

local printerList = {}

function getPrinterAddress(addr)
  for i = 1, #printerList do
    if printerList[i].server == addr then
--      print(printerList[i].server .. "->" .. printerList[i].printerAddress)
      return printerList[i].printerAddress
    end
  end
end

local netprinterproxy = {}
local netprinterdocs = {}


function netprinter.register(addr)
  netprinterproxy.printerAddress = function() return getPrinterAddress(addr) end
  netprinterproxy.writeln = function(str, col, al) modem.send(addr, printServerPort, "WRITELN", getPrinterAddress(addr), str, col, al) end
  netprinterproxy.setTitle = function(str) modem.send(addr, printServerPort, "SETTITLE", getPrinterAddress(addr), str) end
  netprinterproxy.print = function(str) modem.send(addr, printServerPort, "PRINT", getPrinterAddress(addr)) end
  netprinterproxy.clear = function(str) modem.send(addr, printServerPort, "CLEAR", getPrinterAddress(addr)) end
  netprinterproxy.getPaperLevel = function()
    modem.send(addr, printServerPort, "GETPAPERLEVEL", getPrinterAddress(addr))
    local ev, _, from, port, distance, message = event.pull(0.5,"modem_message")
    if ev then
      if message then
	return message
      end
    end
  end
  netprinterproxy.getColorInkLevel = function()
    modem.send(addr, printServerPort, "GETCOLORINKLEVEL", getPrinterAddress(addr))
    local ev, _, from, port, distance, message = event.pull(0.5,"modem_message")
    if ev then
      if message then
	return message
      end
    end
  end
  netprinterproxy.getBlackInkLevel = function()
    modem.send(addr, printServerPort, "GETBLACKINKLEVEL", getPrinterAddress(addr))
    local ev, _, from, port, distance, message = event.pull(0.5,"modem_message")
    if ev then
      if message then
	return message
      end
    end
  end
  netprinterproxy.printTag = function(str) modem.send(addr, printServerPort, "PRINTTAG", getPrinterAddress(addr)) end
  vcomp.register(addr, "nprinter", netprinterproxy, netprinterdocs)
end


function netprinter.getPrinterList()
  printerList = {}
  modem.broadcast(printServerPort, "GET PRINTER")
  for i = 1, 20 do
    local ev, _, from, port, distance, message = event.pull(0,"modem_message")
    if ev then
      local tmpTable = {}
      tmpTable.server = from
      if message then
	tmpTable.printerAddress = message
	table.insert(printerList, tmpTable)
	netprinter.register(from)
      end
    end
  end
  return printerList
end

netprinter.getPrinterList()

return netprinter

