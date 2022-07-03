struct Acid_dilution{T} <: Titratable
    stock::Union{Acid,Ion}
    volume::Unitful.Volume
end

concentration(solution::Acid_dilution) = concentration(solution.stock)
concentration(acid::Union{Acid,Ion}) = acid.concentration ## Should go with definition of Acid and Ion

function add_solvent!(x::Acid_dilution)
    ## For mutation to work both Acid and Acid_dilution need to be mutable (update concentration and volume).
    ## First: Test how much making Acid and Ion mutable hurts performance.
end
