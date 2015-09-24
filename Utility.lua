--[[
	This file contains a couple of useful functions used in the rest of the program.
	Currently it contains:
		1. readFile (filename)
		2. split (input, sep)
		3. tlength (input)
		4. distance (a, b)
]]--
local Utility = {}

-- Reads the content of a text file
-- in: filename = the name of the file to read
-- out: the content of the file in a string
local function readFile (filename)
	local f = assert(io.open(filename, "r"))
	local file = f:read("*all")
	f:close()
	return file
end
Utility.readFile = readFile

-- Splits a string into a list of tokens using a separator
-- For example: split("Hello World", " ") -> {"Hello", "World"}
-- in: input = the string to split
-- in: sep = the separator (can be a string)
-- out: a list containing the tokens
local function splitString (input, sep)
	local result={}
        for match in string.gmatch(input, "([^"..sep.."]+)") do
                table.insert(result, match)
        end
        return result
end
Utility.splitString = splitString

-- Returns the length of a table
-- in: input = a table
-- out: its length
local function tlength (input)
	local count = 0
	for _ in pairs(input) do
		count = count + 1
	end
	return count
end
Utility.tlength = tlength

-- Gives the distance between two points
-- The distance is defined by sqrt( (bx-ax)^2 + (by-ay)^2 )
-- in: a = the first point
-- in: b = the second point
-- out: the distance between a and b
local function distance (a, b)
	local dx = b.x - a.x
	local dy = b.y - a.x
	return math.sqrt(dx*dx + dy*dy)
end
Utility.distance = distance

return Utility
