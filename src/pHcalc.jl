module pHcalc

import Optim

export Acid, Ion, pH, pH_res
export acid, base, NaOH, HCl
export Acid_aliquod, mix, concentration, dilute, sample

acid(concentration) = Ion(;charge=-1, concentration=concentration)
base(concentration) = Ion(;charge= 1, concentration=concentration)
acid(concentration, pKa; charge = 0) = Acid(;pKa=pKa, concentration=concentration, charge=charge)
base(concentration, pKb; charge = 0) = Acid(;pKa = 14 .- pKb, concentration=concentration, charge=charge)

NaOH(concentration) = base(concentration)
HCl(concentration) = acid(concentration)

function acid(;concentration, pKa=missing, charge=0)
    if ismissing(pKa)
        return(acid(concentration))
    end
    acid(concentration, pKa, charge=charge)
end

abstract type Titratable end

struct Ion{T} <: Titratable
    charge::T
    concentration::T
end
Ion(;charge , concentration) = Ion(promote(charge, concentration)...)

struct Acid{T} <: Titratable
    pKa::Vector{T}
    charge::Vector{T}
    concentration::T
    function Acid(pKa::Vector{T}, charge::Vector{T}, concentration::T) where T
        @assert length(charge) == (length(pKa) +1)
        @assert all(diff(charge) .== -1)
        new{T}(pKa, charge, concentration)
    end
end
function Acid(;pKa, charge, concentration)
    T = typeof(promote(pKa...,charge, concentration)[1])    
    Acid(convert(Vector{T},[pKa;]),
         collect(range(start = convert(T,charge), step = -1, length= length(pKa)+1)),
         convert(T,concentration),
         )
end


alpha(ion::Ion,pH) =  one(ion.charge)

function charge(ion::Ion,pH)
    h3o, oh = water(pH)
    h3o - oh + alpha(ion,pH) * ion.charge * ion.concentration
end

Ka(x) = 10. ^(-x)
Ka(a::Acid) = Ka(-a.pKa)

function alpha(a::Acid, pH)
    h3o, oh = water(pH)
    ka = Ka.(a.pKa)
    Ka_t = [one(ka[1]); ka] ## [1., Ka...]
    power = collect(range(0, step = 1, length=length(Ka_t))) ## [0, 1, 2, ..]
    h3o_pow = h3o .^ reverse(power) 
    Ka_prod = cumprod(Ka_t)
    h3o_Ka = h3o_pow .* Ka_prod
    h3o_Ka ./ sum(h3o_Ka)
end

function charge(a::Acid, pH)
    h3o, oh = water(pH)
    h3o - oh + sum( a.concentration .* a.charge .* alpha(a, pH))    
end

function water(pH)
    h3o = 10. ^-pH
    oh = (10. ^(-14))/h3o
    (h3o, oh)
end

function charge(system::Vector{<:Titratable},pH)
    h3o, oh = water(pH)
    x = h3o - oh
    for (i,s) in enumerate(system)
        ## @info s
        x += sum( s.concentration .* s.charge .* alpha(s, pH))
    end
    x
end


# function pH(buffer::Vector{<:Titratable})
#     curry_charge(x,p) = abs(charge(buffer, x[1]))
#     prob = OptimizationProblem(curry_charge, [7.])
#     solve(prob, NelderMead())## [1]
# end


function pH_res(buffer::Vector{<:Titratable})
    curry_charge(x) = abs(charge(buffer, x[1]))
    Optim.optimize(curry_charge, [7.], g_tol=1E-32)
end


pH(buffer::Vector{<:Titratable}) = Optim.minimizer(pH_res(buffer))[1]
pH(buffer) = pH([buffer;])

function titration_curve(pKa, charge, concentration; volume = 1., base =  range(1E-8, stop=5E-3, length=500), title="Titration curve")
    acid = Acid(pKa = pKa, charge=charge, concentration = concentration)
    tit_curve = [first(pH([acid, Ion(charge=1, concentration=x/volume)])) for x in base];
    p1 = plot(base, tit_curve, xlabel="NaOH moles", ylabel = "pH", label="", title=title)
    hline!(pKa, label="")
    display(p1)
end

struct Acid_aliquod{S <: Titratable,T}
    stock::S
    volume::T
end

sample(stock,vol) = Acid_aliquod(stock,vol)
concentration(x::T) where T <:Titratable  = x.concentration
concentration(x::Acid_aliquod)  = x.stock.concentration
stock(x::Acid_aliquod)  = x.stock
dilute(x::Acid,factor) = Acid(x.pKa, x.charge, x.concentration/factor)
dilute(x::Ion,factor) = Ion(x.charge, x.concentration/factor)

function mix(v) ## return Vector{<:Titratable} with updated concentrations
    total_volume = sum([x.volume for x in v])
    [dilute(x.stock, total_volume/x.volume) for x in v]
end


#=
Usage:
citrate_100mM = acid(0.1, [3.13, 4.76, 6.39], charge=0)
dsp_200mM = acid(0.2, [2.15, 6.82, 12.35], charge=3)

pH(mix([Acid_aliquod(dsp_200mM, 5.4), Acid_aliquod(citrate_100mM, 44.6)]))

This models a mix of 5.4 mL 200 mM DSP and 44.6 mL 100 mM Citric acid

See https://microscopy.berkeley.edu/buffers-and-buffer-tables/

Compare to: https://www.egr.msu.edu/~scb-group-web/buffers/buffers.html

citrate: originalpKa = [3.13,4.79,6.39]; Activities at 0.1M : [3.047, 4.3971, 5.5797]
phosphate:  originalpKa = [	2.148, 7.198, 12.375];;  Activities at 0.1M : [2.06486, 6.80506, 11.564674]


This works:
pH([acid(0.001226/1000, [3.047, 4.3971, 5.5797], charge=0), acid(0.09877/1000, [3.047, 4.3971, 5.5797], charge=3)])
6.999999208472769

pH([acid(38.96/1000, [2.06486, 6.80506, 11.564674], charge=1), acid(61.04/1000, [2.06486, 6.80506, 11.564674], charge=2)])
7.000026671703892

Titration curve:
plot([pH(mix([sample(acid(0.2, [2.15, 6.82, 12.35], charge=0), 100), sample(base(.1),x)])) for x in 1:1000])

buffer = [acid(38.96/1000, [2.06486, 6.80506, 11.564674], charge=1), acid(61.04/1000, [2.06486, 6.80506, 11.564674], charge=2)]
plot([pH(mix([sample(buffer, 100), sample(base(.1),x)])) for x in 1:1000])

TODO: sample vector of Titratables

=#


## TODO: titrate_NaOH, titrate_HCl

## include("dilutions.jl")

end
