using pHcalc

"""
    name: the chemical name of the molecule. In time this should be replaced by a key and properties taken from different databases.
    mw: molecular weight in g/mol
    pKa: vector of pKa values (as in pHcalc.Acid)
    charge: charge of fully protonated form (as in pHcalc)
"""
struct Molecule{T}
    name::String
    mw::T
    # hydration?
    # formula::String
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

DSP7W = Molecule("Sodium Phosphate Dibasic Heptahydrate", 268.07, [2.15, 6.82, 12.35], 0)
MSP1W = Molecule("Sodium Phosphate Monobasic Monohydrate", 137.99, [7.0], 0)
CitricAcid1W = Molecule("Citric Acid monohydrate", 210.14, [3.13, 4.76, 6.39], 0)

#=

### PHOSPHATE–CITRATE BUFFER; PH 2.2–8.0, PKA = 7.20/6.40
https://microscopy.berkeley.edu/buffers-and-buffer-tables/

Add the following to create 100 ml of phosphate/citrate buffer solution. Stock solutions are
0.2 M dibasic sodium phosphate; 0.1 M citric acid (Pearse, 1980).

| 0.2 M Na2HPO4 (ml) | 0.1 M citrate (ml) | pH  |
| 5.4                | 44.6               | 2.6 |
| 7.8                | 42.2               | 2.8 |
| 10.2               | 39.8               | 3.0 |
...
| 36.4 | 13.6 | 6.6 |
| 40.9 | 9.1  | 6.8 |
| 43.6 | 6.5  | 7.0 |

=#

citrate_100mM = acid(0.1, [3.13, 4.76, 6.39], charge=0)
dsp_200mM = acid(0.2, [2.15, 6.82, 12.35], charge=0) # 
dsp_200mM_rizzo = acid(0.2, [2.12, 7.21, 12.67], charge=0) # https://www.vanderbilt.edu/AnS/Chemistry/Rizzo/stuff/Buffers/buffers.html

pH(mix([Acid_aliquod(dsp_200mM, 5.4), Acid_aliquod(citrate_100mM, 44.6)]))
pH(mix([Acid_aliquod(dsp_200mM, 10.2), Acid_aliquod(citrate_100mM, 39.8)]))
pH(mix([Acid_aliquod(dsp_200mM, 36.4), Acid_aliquod(citrate_100mM, 13.6)]))
pH(mix([Acid_aliquod(dsp_200mM, 43.6), Acid_aliquod(citrate_100mM, 6.5)]))


#=
# Titration curve

In pthe documentaiton of the python pH_calc package, a titration curve of 10 mM Phosphate is computed as follows:


=#

tit_pyt = [pH([acid(0.01, [2.16, 7.21, 12.32]), base(x)]) for x in range(1E-8, stop=.05, length=500)];

using Plots

scatter(range(1E-8, stop=.05, length=500), tit_pyt, label="python")


#=
This implies that the concentration of phosphate does not change during the titration.

Now we can do better like this:

=#
phos_10mM = acid(0.01, [2.16, 7.21, 12.32])
naoh_1M = base(1.)
tit_true = [pH(mix([Acid_aliquod(phos_10mM,1000.), Acid_aliquod(naoh_1M,x)])) for x in range(1E-5,stop=5., length=500)]; 

plot(
scatter(range(1E-8, stop=.05, length=500), tit_pyt, label="python"),
scatter(range(1E-5, stop=5., length=500), tit_true, label="true")
)

# Actually, this looks like shit. Looks like something is wrong.
