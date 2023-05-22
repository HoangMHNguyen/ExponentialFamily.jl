module PoissonTest

using Test
using ExponentialFamily
using Random
using Distributions
using ForwardDiff
using StableRNGs

import SpecialFunctions: logfactorial, besseli
import ExponentialFamily: KnownExponentialFamilyDistribution, getnaturalparameters, basemeasure, fisherinformation
import DomainSets: NaturalNumbers

@testset "Poisson" begin
    @testset "Constructors" begin
        @test KnownExponentialFamilyDistribution(Poisson, [10]) == KnownExponentialFamilyDistribution(Poisson, [10])
        @test KnownExponentialFamilyDistribution(Poisson, 10) == KnownExponentialFamilyDistribution(Poisson, 10)
    end

    @testset "convert" begin
        for i in 1:10
            @test convert(Distribution, KnownExponentialFamilyDistribution(Poisson, [log(i)])) ≈ Poisson(i)
            @test Distributions.logpdf(KnownExponentialFamilyDistribution(Poisson, [log(i)]), 10) ≈
                  Distributions.logpdf(Poisson(i), 10)

            @test convert(KnownExponentialFamilyDistribution, Poisson(i)) ==
                  KnownExponentialFamilyDistribution(Poisson, [log(i)])
        end
    end

    @testset "prod" begin
        left = Poisson(1)
        right = Poisson(1)
        prod_dist = prod(ClosedProd(), left, right)
        sample_points = collect(1:5)
        for x in sample_points
            @test prod_dist.basemeasure(x) == (1 / factorial(x)^2)
            @test prod_dist.sufficientstatistics(x) == x
        end
        sample_points = [-5, -2, 0, 2, 5]
        for η in sample_points
            @test prod_dist.logpartition(η) == log(abs(besseli(0, 2 * exp(η / 2))))
        end
        @test prod_dist.naturalparameters == [log(1) + log(1)]
        @test prod_dist.support == NaturalNumbers()

        sample_points = collect(1:5)
        for x in sample_points
            hist_sum(x) =
                prod_dist.basemeasure(x) * exp(
                    prod_dist.sufficientstatistics(x) * prod_dist.naturalparameters[1] -
                    prod_dist.logpartition(prod_dist.naturalparameters[1])
                )
            @test sum(hist_sum(x) for x in 0:20) ≈ 1.0
        end
    end

    @testset "natural parameters related" begin
        @test Distributions.logpdf(Poisson(4), 1) ≈
              Distributions.logpdf(convert(KnownExponentialFamilyDistribution, Poisson(4)), 1)
        @test Distributions.logpdf(Poisson(5), 1) ≈
              Distributions.logpdf(convert(KnownExponentialFamilyDistribution, Poisson(5)), 1)

        for i in 2:10
            @test isproper(KnownExponentialFamilyDistribution(Poisson, [log(i)])) === true
            @test isproper(KnownExponentialFamilyDistribution(Poisson, [NaN])) === false
            @test isproper(KnownExponentialFamilyDistribution(Poisson, [Inf])) === false
        end

        @test basemeasure(Poisson(5), 3) == 1.0 / factorial(3)
    end

    @testset "fisher information" begin
        rng = StableRNG(42)
        n_samples = 10000
        for λ in 1:10
            dist = Poisson(λ)
            ef = convert(KnownExponentialFamilyDistribution, dist)
            η = getnaturalparameters(ef)

            samples = rand(rng, Poisson(λ), n_samples)

            totalHessian = zeros(typeof(λ), 1, 1)
            for sample in samples
                totalHessian -= ForwardDiff.hessian((params) -> logpdf.(Poisson(params[1]), sample), [λ])
            end
            @test fisherinformation(dist) ≈ first(totalHessian) / n_samples atol = 0.1

            f_logpartition = (η) -> logpartition(KnownExponentialFamilyDistribution(Poisson, η))
            autograd_information = (η) -> ForwardDiff.hessian(f_logpartition, η)
            @test fisherinformation(ef) ≈ first(autograd_information(η)) atol = 1e-8
        end
    end
end

end