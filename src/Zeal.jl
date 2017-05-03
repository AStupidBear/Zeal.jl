module Zeal

using Utils

const ZEALDOCS = ENV["ZEALDOCS"]
const DASH = normpath(@__FILE__, "..", "..", "deps",
                is_windows() ? "dashing.exe" : "dashing")


function install(path = homedir())
  @static if is_windows()
    url = "https://bintray.com/artifact/download/zealdocs/windows/zeal-portable-0.3.1-windows-x86.7z"
    fn = joinpath(path, basename(url))
    download(url, fn)
    run(`7z x $fn`)
  elseif is_linux()
    run(`sudo apt-get install zeal`)
  end
end

function documenter(pkg)
  dir = mktempdir()
  cp(Pkg.dir(pkg), dir; remove_destination = true)
  cd(dir); @trys cd("docs") cd("doc")
  run(`julia make.jl`)
  cd("build"); dashing(pkg)
end

function sphinx(pkg)
  dir = mktempdir()
  cp(Pkg.dir(pkg), dir; remove_destination = true)
  cd(dir); @trys cd("docs") cd("doc")
  run(`make html`)
  cd("build/html"); dashing(pkg)
end

function docurl(pkg)
  cd(Pkg.dir(pkg))
  md = @trys readstring("README.md") readstring("README.rst")
  pattern = Regex("http://[\\w\\./]*$pkg[\\w\\./]*(stable|latest)", "i")
  m = match(pattern, md)
  m == nothing ? m : m.match
end

online(pkg) = online(pkg, docurl(pkg))
function online(pkg, url)
  dir = mktempdir(); cd(dir)
  parseweb(url; relative = false)
  for (root, dirs, files) in walkdir(pwd())
    for file in files
      file == "index.html" && (cd(root); break)
    end
  end
  dashing(pkg)
end

function readme(pkg)
  dir = mktempdir()
  cp(Pkg.dir(pkg, "README.md"), joinpath(dir, "README.md"))
  cd(dir)
  run(`pandoc README.md -s -o index.html`)
  Base.rm("README.md")
  dashing(pkg)
end

function dashing(pkg)
  !ispath("index.html") && error("no index.html")
  run(`$DASH create`)
  readstring("dashing.json") |>
  x -> replace(x, "dashing", pkg) |>
  x -> write("dashing.json", x)
  run(`$DASH build`)
  mv("$pkg.docset", joinpath(ZEALDOCS, "$pkg.docset"),
    remove_destination = true)
end

function add(pkg::AbstractString, force::Bool = false)
  warn("adding $pkg")
  ispath(joinpath(ZEALDOCS, "$pkg.docset")) && !force && return
  @trys documenter(pkg) sphinx(pkg) online(pkg) readme(pkg)
end

add(pkgs::Array) = pmap(add, pkgs)
add() = add(Pkg.installed() |> keys |> collect)

update(pkg::AbstractString) = add(pkg, true)
update(pkgs::Array) = pmap(update, pkgs)
update() = update(Pkg.installed() |> keys |> collect)

rm(pkg::AbstractString) = Base.rm(joinpath(ZEALDOCS, "$pkg.docset"), recursive = true)
rm(pkgs::Array) = pmap(rm, pkgs)

end
