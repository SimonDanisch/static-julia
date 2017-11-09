# Setup

Pkg.add("GLVisualize")
# There weren't that many changes in GLVisualize - just removed some globals
Pkg.checkout("GLVisualize", "sd/makie")

# Some weird issues in GLAbstraction, as you can see in the diff
Pkg.checkout("GLAbstraction", "sd/static")

# Globals again, and predictable names for precompilation
Pkg.checkout("GLFW", "sd/static")

# Mostly globals as well
Pkg.checkout("Reactive", "sd/compile")

# end

# make sure our example runs and is precompiled:
cd(@__DIR__)
include("hello.jl")
using Hello
Hello.julia_main([""])

cd(@__DIR__)
run(`julia juliac.jl -ve hello.jl`)
cd(joinpath(@__DIR__, "builddir"))
run(`./hello`)
#
# using SnoopCompile
# cd(@__DIR__)
# SnoopCompile.@snoop "precompile.csv" begin
#     include("hello.jl")
#     using Hello
#     Hello.julia_main([""])
# end
#
#
# data = SnoopCompile.read("precompile.csv")
# pc = SnoopCompile.parcel(reverse!(data[2]))
#
# open("precompile.jl", "w") do io
#     for (k, v) in pc
#         k == :unknown && continue
#         println(io, "using $k")
#     end
#     println(io, "function _precompile_()")
#     for (k, v) in pc
#         for ln in v
#             println(io, "    ", ln)
#         end
#     end
#     println(io, "end")
# end
