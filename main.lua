--[[
	Main file of the script.
	Reads the input file, calculates a solution and exports it.
--]]

local Utility = require("Utility")
local PointStructure = require("PointStructure")
local SteinerBudget = require("SteinerBudget")
local Steiner = require("Steiner")
local Kruskal = require("Kruskal")

if(arg[1] == nil) then
	print("Must specify an input file.")
end

math.randomseed(os.time())
INPUT_FILE = arg[1]
local file = Utility.readFile(INPUT_FILE)

local points = PointStructure.create(file)

OUTPUT_FILE = "OUTPUTKRUSKAL.txt"
local kruskal = Kruskal.kruskal(PointStructure.clone(points))
Steiner.optimization3Point(kruskal)
print("Kruskal", PointStructure.score(kruskal))
PointStructure.export(kruskal, 1, OUTPUT_FILE)

OUTPUT_FILE = "OUTPUTINCREMENTAL.txt"
start = math.random(Utility.tlength(points))
local steiner = Steiner.steiner(PointStructure.clone(points), start)
print("Steiner", PointStructure.score(steiner))
PointStructure.export(steiner, 1, OUTPUT_FILE)

if(arg[2] ~= nil and arg[3] ~= nil) then
BUDGET = tonumber(arg[2])
START = tonumber(arg[3])

local budget
print("")
print("Budget:")
OUTPUT_FILE = "OUTPUTBUDGET1.txt"
budget = SteinerBudget.steinerBudget(points, BUDGET, START)
Steiner.optimization3Point(budget)
print("Algorithm TSP", PointStructure.score(budget))
PointStructure.export(budget, START, OUTPUT_FILE)
OUTPUT_FILE = "OUTPUTBUDGET1bis.txt"
budget = SteinerBudget.steinerBudgetOptimized(points, BUDGET, START)
Steiner.optimization3Point(budget)
print("Algorithm TSP Optimized", PointStructure.score(budget))
PointStructure.export(budget, START, OUTPUT_FILE)
OUTPUT_FILE = "OUTPUTBUDGET2.txt"
local budget = SteinerBudget.steinerBudgetDoubleSearch(points, BUDGET, START)
Steiner.optimization3Point(budget)
print("Algorithm Double Search", PointStructure.score(budget))
PointStructure.export(budget, START, OUTPUT_FILE)
OUTPUT_FILE = "OUTPUTBUDGET2bis.txt"
local budget = SteinerBudget.steinerBudgetDoubleSearchWithPoints(points, BUDGET, START)
Steiner.optimization3Point(budget)
print("Algorithm Double Search with points", PointStructure.score(budget))
PointStructure.export(budget, START, OUTPUT_FILE)
OUTPUT_FILE = "OUTPUTBUDGET3.txt"
local budget = SteinerBudget.steinerBudgetReorganizing(points, BUDGET, START)
Steiner.optimization3Point(budget)
print("Algorithm Reorganizing", PointStructure.score(budget))
PointStructure.export(budget, START, OUTPUT_FILE)
OUTPUT_FILE = "OUTPUTBUDGET3bis.txt"
local budget = SteinerBudget.steinerBudgetReorganizingWithPoints(points, BUDGET, START)
Steiner.optimization3Point(budget)
print("Algorithm Reorganizing with points", PointStructure.score(budget))
PointStructure.export(budget, START, OUTPUT_FILE)

end

print("Done.")

