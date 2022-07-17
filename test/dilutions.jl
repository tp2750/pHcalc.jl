using pHcalc
using Test
using Unitful

HCl_L = pHcalc.Acid_dilution(HCl(0.1), 1u"L")
@testset "dilutions.jl" begin
    @test concentration(HCl_L) == 0.1
end
