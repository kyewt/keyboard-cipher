local process = require("@lune/process")
local stdio = require("@lune/stdio")

local insert = table.insert

local key = {
    [0] = {"p", ";", "/", ")"},
    [1] = {"q", "a", "z", "!"},
    [2] = {"w", "s", "x", "@"},
    [3] = {"e", "d", "c", "#"},
    [4] = {"r", "f", "v", "$"},
    [5] = {"t", "g", "b", "%"},
    [6] = {"y", "h", "n", "^"},
    [7] = {"u", "j", "m", "&"},
    [8] = {"i", "k", ",", "*"},
    [9] = {"o", "l", ".", "("},
}

local encode = function(str: string)
    local oldStr = {}
    str:gsub(".", function(c) insert(oldStr, c) end)
    local newStr = {}
    local isLast3: boolean = false
    local isLastSpace: boolean = false
    local lastKeyIndex: number = 0
    local lastSChar: string = ""
    for strIndex = 1, #oldStr do
        local sChar: string = oldStr[strIndex]
        if sChar == " " then
            for keyIndex = 0, 9 do
                local charSet: table = key[keyIndex]
                for charIndex = 1, 3 do
                    local eChar: string = charSet[charIndex]
                    if lastSChar == eChar then
                        insert(newStr, charSet[4])
                        isLastSpace = true
                        break
                    end
                end
            end
        end
        for keyIndex = 0, 9 do
            local charSet: table = key[keyIndex]
            for charIndex = 1, 3 do
                local eChar: string = charSet[charIndex]
                if sChar == eChar then
                    if (not isLastSpace) and (not isLast3) and keyIndex == lastKeyIndex then
                        insert(newStr, "'")
                    end
                    for i = 1, charIndex do
                        insert(newStr, keyIndex)
                    end
                    if charIndex == 3 then isLast3 = true else isLast3 = false end
                    isLastSpace = false
                    lastKeyIndex = keyIndex
                    lastSChar = sChar
                    break
                end
            end
        end
    end
    return table.concat(newStr)
end

local decode = function(str: string)
    local oldStr = {}
    str:gsub(".", function(c) insert(oldStr, c) end)
    local newStr = {}
    local atIndex atIndex = function(strIndex: number)
        if strIndex > #oldStr then return end
        local char : string = (oldStr[strIndex])
        for keyIndex = 0, 9 do
            local charSet: table = key[keyIndex]
            if char == charSet[4] then
                insert(newStr, " ")
                return atIndex(strIndex + 1)
            end
        end
        local eChar: number  = tonumber(char)
        if not eChar then return atIndex(strIndex + 1) end
        local charLen: number = 1
        if tonumber(oldStr[strIndex + 1]) == eChar then
            charLen = 2
            if tonumber(oldStr[strIndex + 2]) == eChar then
                charLen = 3
            end
        end
        for keyIndex = 0, 9 do
            local charSet: table = key[keyIndex]
            if eChar == keyIndex then
                local dChar = charSet[charLen]
                insert(newStr, dChar)
                atIndex(strIndex + charLen)
                break
            end
        end
    end
    atIndex(1)
    return table.concat(newStr)
end

local main = function()
    local args = process.args
    local opType = args[1]
    local str = args[2]
    if opType ~= "e" and opType ~= "d" then
        stdio.ewrite("no operation specified (e for encode, d for decode)")
        return
    end
    if type(str) ~= "string" then
        stdio.ewrite("no string specified")
        return
    end
    str = string.lower(str)
    if opType == "e" then
        local encoded = encode(str)
        stdio.write(encoded)
    elseif opType == "d" then
        local decoded = decode(str)
        stdio.write(decoded)
    end
end

main()
