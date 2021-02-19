wrs = {}

local action = {
    getOutput = "getOutput",
    setOutput = "setOutput",
    getSides = "getSides",
    getInput = "getInput",
    getAnalogInput = "getAnalogInput",
    setAnalogOutput = "setAnalogOutput",
    getAnalogOutput = "getAnalogOutput",
    getBundledInput = "getBundledInput",
    getBundledOutput = "getBundledOutput",
    setBundledOutput = "setBundledOutput",
    testBundledInput = "testBundledInput"
}
local PROTO = "wrs"
local myName = nil
local opened = false

wrs.BORADCAST = nil

local function contains(arr, item)
    for key, value in pairs(arr) do
        if value == item then return key end
    end
    return false
end

local function sendBackById(senderId, message)
    rednet.send(senderId, message, PROTO .. "/id/" .. senderId)
end

local function sendWithCallback(host, message, timeout)
    local id = rednet.lookup(PROTO, host)
    rednet.send(id, message, PROTO)

    local _, message = rednet.receive(PROTO .. "/id/" .. os.getComputerID(), timeout)
    return message
end

local function broadcastOrSend(host, message)
    if host == wrs.BORADCAST then
        return rednet.broadcast(message, PROTO)
    else
        local id = rednet.lookup(PROTO, host)
        return rednet.send(id, message, PROTO)
    end
end

function wrs.isOpen()
    return opened
end

function wrs.getHostname()
    return myName
end

function wrs.open(side, host, group)
    if opened then
        print("Connection is already opened")
        return false
    end

    if not group == nil then
        PROTO = PROTO .. "/" .. group
    end

    rednet.open(side)
    rednet.host(PROTO, host)
    myName = host
    opened = true
end

function wrs.close(side)
    if not opened then
        print("No connection opened")
        return false
    end

    rednet.close(side)
    rednet.unhost(PROTO, myName)

    opened = false
end

function wrs.receive()
    local senderId, message = rednet.receive(PROTO)
    local mAction = message[1]

    if mAction == action.setOutput then
        redstone.setOutput(message[2], message[3])
    elseif mAction == action.getSides then
        sendBackById(senderId, redstone.getSides())
    elseif mAction == action.getInput then
        sendBackById(senderId, redstone.getInput(message[2]))
    elseif mAction == action.getOutput then
        sendBackById(senderId, redstone.getOutput(message[2]))
    elseif mAction == action.getAnalogInput then
        sendBackById(senderId, redstone.getAnalogInput(message[2]))
    elseif mAction == action.setAnalogOutput then
        redstone.setAnalogOutput(message[2], message[3])
    elseif mAction == actiom.getAnalogOutput then
        sendBackById(senderId, redstone.getAnalogInput(message[2]))
    elseif mAction == action.getBundledInput then
        sendBackById(senderId, redstone.getBundledInput(message[2]))
    elseif mAction == action.getBundledOutput then
        sendBackById(senderId, redstone.getBundledOutput(message[2]))
    elseif mAction == action.setBundledOutput then
        redstone.setAnalogOutput(message[2], message[3])
    elseif mAction == action.testBundledInput then
        sendBackById(senderId, redstone.testBundledOutput(message[2], message[3]))
    end
end

function wrs.setOutput(side, value, host)
    return broadcastOrSend(host, { action.setOutput, side, value })
end

function wrs.getSides(host, timeout)
    return sendWithCallback(host, { action.getSides }, timeout)
end

function wrs.getInput(side, host, timeout)
    return sendWithCallback(host, { action.getInput, side }, timeout)
end

function wrs.getOutput(side, host, timeout)
    return sendWithCallback(host, { action.getOutput, side }, timeout)
end

function wrs.getAnalogInput(side, host, timeout)
    return sendWithCallback(host, { action.getAnalogInput, side }, timeout)
end

function setAnalogOutput(side, strength, host)
    return broadcastOrSend(host, { action.setAnalogOutput, side, strength })
end

function getAnalogOutput(side, host, timeout)
    return sendWithCallback(host, { action.getAnalogOutput, side }, timeout)
end

function getBundledInput(side, host, timeout)
    return sendWithCallback(host, { action.getBundledInput, side }, timeout)
end

function getBundledOutput(side, host, timeout)
    return sendWithCallback(host, { action.getBundledOutput, side }, timeout)
end

function setBundledOutput(side, colors, host)
    return broadcastOrSend(host, { action.setBundledOutput, side, colors })
end

function testBundledInput(side, colors, host)
    return broadcastOrSend(host, { action.testBundledInput, side, colors })
end