# ArrayInitializers.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://mkitti.github.io/ArrayInitializers.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://mkitti.github.io/ArrayInitializers.jl/dev/)
[![Build Status](https://github.com/mkitti/ArrayInitializers.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/mkitti/ArrayInitializers.jl/actions/workflows/CI.yml?query=branch%3Amain)

Create array initializers and allocate arrays without curly braces in Julia.
The initializer instances can be passed as the first argument of an `AbstractArray` constructor to initialize the array.
If the initializer is typed, the element type of the `AbstractArray` constructor is optional.

Compatible with `OffsetArrays` and other subtypes of Julia arrays that implement `Base.fill!`.

```julia
julia> using ArrayInitializers

julia> fives = init(5)
ArrayInitializers.FillArrayInitializer{Int64}(5)

julia> Array(fives, 3)
3-element Vector{Int64}:
 5
 5
 5

julia> Vector(fives, 3)
3-element Vector{Any}:
 5
 5
 5

julia> Array{Float64}(fives, 3)
3-element Vector{Float64}:
 5.0
 5.0
 5.0

julia> Array(oneinit(Int), 5)
5-element Vector{Int64}:
 1
 1
 1
 1
 1

julia> Array(zeroinit(Float64), 5)
5-element Vector{Float64}:
 0.0
 0.0
 0.0
 0.0
 0.0

julia> Array(undeftype(Rational), 3, 2)
3×2 Matrix{Rational}:
 #undef  #undef
 #undef  #undef
 #undef  #undef

julia> fives(3, 2)
3×2 Matrix{Int64}:
 5  5
 5  5
 5  5

julia> fives((3, 2))
3×2 Matrix{Int64}:
 5  5
 5  5
 5  5

julia> Array(geninit(x^2 for x in 1:5))
5-element Vector{Int64}:
  1
  4
  9
 16
 25

julia> Array{Float64}(geninit(x^2 for x in 1:5))
5-element Vector{Float64}:
  1.0
  4.0
  9.0
 16.0
 25.0
```