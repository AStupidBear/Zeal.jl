ENV["ZEALDOCS"] = "C:\\PortableSoftware\\Scoop\\apps\\zeal\\0.3.1\\docsets"
reload("Zeal")

Zeal.add("PyCall")
Zeal.update("PyCall")

Zeal.add("Gadfly")
Zeal.update("Gadfly")

Zeal.add(Pkg.available()[1:10])
Zeal.update(Pkg.available()[1:10])

Zeal.update("StatsBase")

Zeal.update("DataStructures")

Zeal.update("Knet")

Zeal.documenter("Knet")
Zeal.sphinx("MLBase")

Zeal.online("PDMats")
Zeal.readme("PDMats")

# pkg = "PDMats"
# dir = mktempdir()
# cp(Pkg.dir(pkg, "README.md"), joinpath(dir, "README.md"))
# cd(dir)
# run(`pandoc README.md -s -o index.html`)
# Base.rm("README.md")
# cd("build"); dashing(pkg)
