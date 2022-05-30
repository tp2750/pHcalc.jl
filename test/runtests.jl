using pHcalc
using Test

@testset "pHcalc.jl" begin
    @test abs(pH(Ion(charge=-1,concentration=0.01)) - 2.00 ) < 1E-6
    @test abs(pH(Ion(charge=-1,concentration=1E-8)) - 6.978294313542888 ) < 1E-22
    @test pHcalc.charge(Ion(charge=-1,concentration=1E-8), 6.978294313542888) < 2E-22
    
end

@testset "Simple API" begin
    @test abs(pH(HCl(0.01)) - 2.00 ) < 1E-6
    @test abs(pH(acid(concentration=1E-8)) - 6.978294313542888 ) < 1E-22
    @test pHcalc.charge(acid(concentration=1E-8, charge=-1), 6.978294313542888) < 2E-22
    
end

@testset "pHcalc examples" begin
    ## pH of 0.01M HCl
    @test abs(pH(HCl(0.01)) - 2.000) < 1E-10
    ## pH of 1E-8M HCl
    @test abs(pH(HCl(1E-8)) -  6.978295898 ) < 2E-6
    ## pH of 0.01M NaOH
    @test abs(pH(NaOH(0.01)) - 12.000) < 1E-10
    ## pH of 0.01M HF
    HF = acid(concentration=0.01, pKa=3.17)
    @test abs(pH(HF) - 2.6413261) < 3E-5
    ## pH af 0.01M HF + 0.01M NaOH = NaF
    @test abs(pH([HF, NaOH(0.01)]) - 7.5992233) < 3E-5
    ## pH of 0.01M H2CO3
    @test abs(pH(acid(pKa = [3.6, 10.32], concentration = 0.01)) -  2.8343772) < 3E-6
    ## pH of 0.01M of alanine zwitterion form
    @test abs(pH(acid(pKa=[2.35, 9.69], concentration = 0.01, charge=1)) -  6.0991569) < 3E-6
    ## pH of 0.01 M (NH4)3PO4
    PO4 = acid(pKa=[2.148, 7.198, 12.319], concentration = 0.01)
    NH4_3 = acid(pKa = 9.25, concentration = 0.03, charge=1)
    @test abs(pH([PO4, NH4_3]) - 8.95915298) < 2E-6
end

@testset "pHcalc exact" begin
    ## pH of 0.01M HCl
    @test abs(pH(HCl(0.01)) - 2.000) < 1E-10
    ## pH of 1E-8M HCl
    @test abs(pH(HCl(1E-8)) - 6.978294313542888) < 1E-10
    ## pH of 0.01M HF
    HF = acid(concentration=0.01, pKa=3.17)
    @test abs(pH(HF) - 2.6413038913220532) < 1E-10
    @test abs(pH([HF, NaOH(0.01)]) - 7.59919839956255) < 1E-10
    ## pH of 0.01M H2CO3
    @test abs(pH(acid(pKa = [3.6, 10.32], concentration = 0.01)) - 2.834379584567423 ) < 1E-10
    ## pH of 0.01M of alanine zwitterion form
    @test abs(pH(acid(pKa=[2.35, 9.69], concentration = 0.01, charge=1)) - 6.099154517095277 ) < 1E-10
    ## pH of 0.01 M (NH4)3PO4
    PO4 = acid(pKa=[2.148, 7.198, 12.319], concentration = 0.01)
    NH4_3 = acid(pKa = 9.25, concentration = 0.03, charge=1)
    @test abs(pH([PO4, NH4_3]) - 8.959151804386952) < 1E-10
end
