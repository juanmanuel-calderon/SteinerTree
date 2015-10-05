--[[
	Main file of the script.
	Reads the input file, calculates a solution and exports it.
--]]

local Utility = require("Utility")
local PointStructure = require("PointStructure")
local Algorithm = require("Algorithm")

if(Utility.tlength(arg) ~= 4) then
	print("Usage = inputfile outputfile")
else
	INPUT_FILE = arg[1]
	OUTPUT_FILE = arg[2]

	local file = Utility.readFile(INPUT_FILE)

	local points = PointStructure.create(file)
	local start = Algorithm.TSP_Solution(points)
	PointStructure.export(points, start, OUTPUT_FILE)
end

print("Done.")
