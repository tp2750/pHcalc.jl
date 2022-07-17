using Unitful

struct Acid_dilution{T} <: Titratable
    stock::Union{Acid,Ion}
    volume::Unitful.Volume
end

concentration(solution::Acid_dilution) = concentration(solution.stock)
concentration(acid::Union{Acid,Ion}) = acid.concentration ## Should go with definition of Acid and Ion

function update(x::Acid; concentration=missing, charge=missing)
    conc = ismissng(concentration) ? x.concentration : concentration
    char = ismissing(charge) ? x.charge : charge
    Acid([x.pKa;], [charge;], x.concentration)
end
function update(x::Ion; concentration=missing, charge=missing)
    conc = ismissng(concentration) ? x.concentration : concentration
    char = ismissing(charge) ? x.charge : charge
    Ion(charge, x.concentration)
end


function add_solvent!(x::Acid_dilution, add_volume::Unitful.Volume)
    ## fixxed mutation: only mutates here and that is not a concrete type.
    new_volume = add_volume + x.volume
    new_concentration = concentration(x)* x.volume / new_volume
    x.stock = update(x; concentration = new_concentration)
    x.volume = new_volume
    (;new_volume)
end

function final_volume!(x::Acid_dilution, final_volume::Unitful.Volume)
    @assert final_volume >= x.volume
    added_volume = final_volume - x.volume
    @info "Volume to add: $(added_volume)"
    x.volume = final_volume
    new_concentration = concentration(x)*x.volume/final_volume
    x.stock = update(x,concentration= new_concentration)
    (;added_volume)
end

function normalize!(x::Acid_dilution, final_concentration)
    ## TODO: communicate how much to adjust volume
end
