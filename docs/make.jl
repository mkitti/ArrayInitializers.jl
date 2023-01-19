using ArrayInitializers
using Documenter

DocMeta.setdocmeta!(ArrayInitializers, :DocTestSetup, :(using ArrayInitializers); recursive=true)

makedocs(;
    modules=[ArrayInitializers],
    authors="Mark Kittisopikul <kittisopikulm@janelia.hhmi.org> and contributors",
    repo="https://github.com/mkitti/ArrayInitializers.jl/blob/{commit}{path}#{line}",
    sitename="ArrayInitializers.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://mkitti.github.io/ArrayInitializers.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/mkitti/ArrayInitializers.jl",
    devbranch="main",
)
