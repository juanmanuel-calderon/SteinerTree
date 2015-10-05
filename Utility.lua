--[[
	This file contains a couple of useful functions used in the rest of the program.
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
	local result = {}
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

-- Shifts an array by one to the left
-- in: input = the array to shift
-- pos: the initial position to shift
local function shift1Left (input, pos)
	local length = tlength(input)
	for i = pos, length do
		input[i] = input[i+1]
	end
end
Utility.shift1Left = shift1Left

-- Shifts an array by one to the right
-- in: input = the array to shift
-- pos: the initial position to shift
local function shift1Right (input, pos)
	local length = tlength(input)
	for i = length, pos, -1 do
		input[i+1] = input[i]
	end
	input[pos] = nil
end
Utility.shift1Right = shift1Right

-- Merges two tables
-- in: tab1 = the destination
-- in: tab2 = the other table
-- out: tab1 has the elements of tab2
local function merge (tab1, tab2)
	for k,v in pairs(tab2) do
		table.insert(tab1, v)
	end
end
Utility.merge = merge

return Utility
