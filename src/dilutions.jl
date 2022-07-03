struct Acid_dilution{T} <: Titratable
    stock::Union{Acid,Ion}
    volume::Unitful.Volume
end

concentration(solution::Acid_dilution) = concentration(solution.stock)
concentration(acid::Union{Acid,Ion}) = acid.concentration ## Should go with definition of Acid and Ion

function add_solvent!(x::Acid_dilution, add_volume::Unitful.Volume)
    ## For mutation to work both Acid and Acid_dilution need to be mutable (update concentration and volume).
    ## First: Test how much making Acid and Ion mutable hurts performance.
    new_volume = add_volume + x.volume
    new_concentration = concentration(x)* x.volume / new_volume
    x.stock.concentration = new_concentration
    x.volume = new_volume
    new_volume
end

function final_volume!(x::Acid_dilution, final_volume::Unitful.Volume)
    @assert final_volume >= x.volume
    added_volume = final_volume - x.volume
    @info "Volume to add: $(added_volume)"
    x.volume = final_volume
    x.concentration = concentration(x)*x.volume/final_volume
    added_volume
end

function normalize!(x::Acid_dilution, final_concentration)
    ## TODO: communicate how much to adjust volume
end
