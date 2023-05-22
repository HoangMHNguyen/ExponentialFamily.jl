module ChisqTest

using Test
using ExponentialFamily
using Random
using Distributions
using ForwardDiff
using StableRNGs
using ForwardDiff

import SpecialFunctions: logfactorial, loggamma
import ExponentialFamily:
    xtlog, KnownExponentialFamilyDistribution, getnaturalparameters, basemeasure, ExponentialFamilyDistribution,
    fisherinformation

@testset "Chisq" begin
    @testset "naturalparameters" begin
        for i in 3:10
            @test convert(Distribution, KnownExponentialFamilyDistribution(Chisq, [i])) ≈ Chisq(2 * (i + 1))
            @test Distributions.logpdf(KnownExponentialFamilyDistribution(Chisq, [i]), 10) ≈
                  Distributions.logpdf(Chisq(2 * (i + 1)), 10)
            @test isproper(KnownExponentialFamilyDistribution(Chisq, [i])) === true
            @test isproper(KnownExponentialFamilyDistribution(Chisq, [-2 * i])) === false

            @test convert(KnownExponentialFamilyDistribution, Chisq(i)) ==
                  KnownExponentialFamilyDistribution(Chisq, [i / 2 - 1])

            @test Distributions.logpdf(Chisq(10), 1.0) ≈
                  Distributions.logpdf(convert(KnownExponentialFamilyDistribution, Chisq(10)), 1.0)
            @test Distributions.logpdf(Chisq(5), 1.0) ≈
                  Distributions.logpdf(convert(KnownExponentialFamilyDistribution, Chisq(5)), 1.0)
        end

        @test basemeasure(Chisq(5), 3) == exp(-3 / 2)
    end

    @testset "fisherinformation KnownExponentialFamilyDistribution{Chisq}" begin
        f_logpartion = (η) -> logpartition(KnownExponentialFamilyDistribution(Chisq, η))
        autograd_inforamation_matrix = (η) -> ForwardDiff.hessian(f_logpartion, η)
        for i in 3:10
            @test fisherinformation(KnownExponentialFamilyDistribution(Chisq, [i])) ≈
                  autograd_inforamation_matrix([i])[1, 1]
        end
    end

    @testset "fisherinformation (Chisq)" begin
        rng = StableRNG(42)
        n_samples = 1000
        for ν in 1:10
            samples = rand(rng, Chisq(ν), n_samples)
            hessian_at_sample = (sample) -> ForwardDiff.hessian((params) -> logpdf(Chisq(params[1]), sample), [ν])
            expected_hessian = -mean(hessian_at_sample, samples)
            chisq_fisher = fisherinformation(Chisq(ν))
            @test fisherinformation(Chisq(ν)) ≈ expected_hessian[1, 1] atol = 0.01
        end
    end

    @testset "prod" begin
        for i in 3:10
            left = Chisq(i + 1)
            right = Chisq(i)
            prod_dist = prod(ClosedProd(), left, right)

            η_left = first(getnaturalparameters(convert(KnownExponentialFamilyDistribution, left)))
            η_right = first(getnaturalparameters(convert(KnownExponentialFamilyDistribution, right)))
            naturalparameters = [η_left + η_right]

            @test prod_dist.naturalparameters == naturalparameters
            @test prod_dist.basemeasure(i) ≈ exp(-i)
            @test prod_dist.sufficientstatistics(i) ≈ log(i)
            @test prod_dist.logpartition(η_left + η_right) ≈ loggamma(η_left + η_right + 1)
            @test prod_dist.support === support(left)
        end
    end
end

end