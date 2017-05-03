if !isdir(Pkg.dir("Utils"))
  Pkg.clone("https://github.com/AStupidBear/Utils.jl.git")
  Pkg.build("Utils")
end

using Utils

@static if is_linux()
  download("https://github.com/technosophos/dashing/releases/download/0.3.0/dashing", "dashing")
elseif is_windows()
  psdownload("https://sourceforge.net/projects/bearapps/files/dashing.exe", "dashing.exe")
end

run(`pip install -U sphinx`)
run(`pip install mkdocs`)
run(`pip install mkdocs-material`)
