using pHcalc
using Documenter

DocMeta.setdocmeta!(pHcalc, :DocTestSetup, :(using pHcalc); recursive=true)

makedocs(;
    modules=[pHcalc],
    authors="Thomas Poulsen <thomas@lha66.dk> and contributors",
    repo="https://github.com/tp2750/pHcalc.jl/blob/{commit}{path}#{line}",
    sitename="pHcalc.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://tp2750.github.io/pHcalc.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/tp2750/pHcalc.jl",
    devbranch="main",
)
