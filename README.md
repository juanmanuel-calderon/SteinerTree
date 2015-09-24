# SteinerTree
Attempts to give a solution to the Steiner Tree Problem in Lua.
The starting point of the program is the main.lua file. Its usage is
  > lua main.lua "inputFile" "outputFile"

The main file creates the structure from the input file, calls the best algorithm available and then exports the solution
to the output file.

PointStructure.lua contains the functions relative to the point structure (see head of the file for a better explanation).

Utility.lua contains a couple of useful functions used in the whole program.

Algorithm.lua contains the algorithms used to give a solution to the problem.
