using Distributions, BenchmarkTools, FillArrays
using ExponentialFamily
import ExponentialFamily:Contingency, MatrixDirichlet, KnownExponentialFamilyDistribution,getnaturalparameters,pack_naturalparameters,unpack_naturalparameters,logpartition,basemeasure,sufficientstatistics,fisherinformation, Unsafe,support
dist = Contingency(ones(3,3)/9)
ef = convert(KnownExponentialFamilyDistribution, dist)
@btime pack_naturalparameters($dist)
@btime unpack_naturalparameters($ef)
# @btime unpack_naturalparameters($ef)
@code_warntype logpartition(ef)
@code_lowered logpartition(ef)
@btime logpartition($ef)

ExponentialFamily.support(ef)

@btime basemeasure($ef2, $2)
@btime sufficientstatistics($dist,$[1,3])
@btime pdf($ef,$[1,3])
@btime pdf($dist, $[1,3])
using StaticArrays
dot([1], SA[1])
@btime log(logistic(η))
using SparseArrays
@btime Vector{Int64}(undef,10)
@btime convert(Distribution,ef)

ef1 = KnownExponentialFamilyDistribution(Categorical, log.([1.0,  1.0]))

dist1 = convert(Distribution,ef1)
getnaturalparameters(ef1)
@btime logpdf($ef1,$2)
@btime fisherinformation($ef1)
logpdf(dist1,2)
pack_naturalparameters(dist)
using FillArrays


OneElement(1,10)
using BlockArrays

BlockArray{Int64}(zeros(4,4), [2,2],[2,2])

@btime fisherinformation($ef)
@btime fisherinformation($dist)
@btime unpack_naturalparameters($ef) + Ones{Float64}(2,2) 

using LogExpFunctions

A = [1 0; 0 1]
logsumexp.(A)