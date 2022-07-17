using pHcalc

"""
    name: the chemical name of the molecule. In time this should be replaced by a key and properties taken from different databases.
    mw: moleculat weight in g/mol
    pKa: vector of pKa values (as in pHcalc.Acid)
    charge: charge of fully protonated form (as in pHcalc)
"""
struct Molecule{T}
    name::String
    mw::T
    pKa::Vector{T} 
    charge::T      
end

name(x::Molecule) = x.name
mw(x::Molecule) = x.mw
pKa(x::Molecule) = x.pKa
charge(x::Molecule) = x.charge

"""
    molecule: a Molecule struct
    amount: amount i grams
"""
struct Sample{T}
    molecule::Molecule
    mass::T
end

mass(x::Sample) x.mass

"""
    sample: a Sample struct
    volume: amount i Liter
    A solution has a concentration
    A solution has a pH
"""
struct Solution{T}
    sample::Sample
    volume::T
end

volume(x::Solution) = x.volume
concentration(x::Solution) = mass(x.sample)/volume(x)
_titratable(x::Solution) = pHcalc.acid(concentration(x), pKa(x); charge=charge(x))
pH(x::Solution) = pH(_titratable(x))

"""
    solution: Solution struct
    volume: amount of solution in L
    concentration of an aliquot is the same as the concentation of the solution.
    This is a sample of a solution.
    An alequot has a pH
"""
struct Aliquot{T}
    solution::Solution
    volume::T
end

volume(x::Aliquot) = x.volume
concentration(x::Aliquod) = concentration(x.solution)
pH(x::Aliquod) = pH(x.solution)

"""
    aliquots: vector of aliquots
    This represents a mix of different amounts of solutions of molecules.
    A mix has a pH
    A mix has a vector of concentrations
"""
struct Mix{T}
    aliqouts::Vector{Aliquot}
end

pH(x::Mix) = pH([_titratable(y) for y in x.aliqouts])

############## Examples ################

DSP6W = Molecule("Sodium Phosphate Dibasic Heptahydrate", 268.07, [2.15, 6.82, 12.35], 0)
