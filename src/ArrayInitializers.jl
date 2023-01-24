module ArrayInitializers

using Random

export init, undeftype, zeroinit, oneinit, randinit, geninit

const NArray{N} = Array{T,N} where T
const NAbstractArray{N} = AbstractArray{T,N} where T

abstract type AbstractArrayInitializer{T} end

"""
    FillArrayInitializer{T}(value::T)

When passed to an `AbstractArray` constructor as the first argument,
the constructed array will be filled with value via `fill!`.
"""
struct FillArrayInitializer{T} <: AbstractArrayInitializer{T}
    value::T
end

"""
    init(value::T)

Create a `FillArrayInitializer{T}`.  When passed to an `AbstractArray` 
constructor as the first argument, the constructed array will be filled
with `value` via `fill!`.

Also the result can be called with an array argument. It will `fill!`
the array.

```julia
julia> const threes = init(3)
ArrayInitializers.FillArrayInitializer{Int64}(3)

julia> Array(threes, 5)
5-element Vector{Int64}:
 3
 3
 3
 3
 3

julia> const fives! = init(5)
ArrayInitializers.FillArrayInitializer{Int64}(5)

julia> fives!(ones(3))
3-element Vector{Float64}:
 5.0
 5.0
 5.0
```
"""
init(value::T) where T = FillArrayInitializer{T}(value)
@inline (fai::FillArrayInitializer)(array) = Base.fill!(array, fai.value)
@inline (fai::FillArrayInitializer{T})(dims::Dims{N}) where {T,N} = Base.fill!(Array{T,N}(undef, dims), fai.value)
@inline (fai::FillArrayInitializer{T})(dims::Vararg{<: Integer}) where {T} = Base.fill!(Array{T}(undef, dims), fai.value)

# Does not override Base.fill!, no type piracy
"""
    ArrayInitializers.fill!(value)

Alias for [`ArrayInitializers.init`](@ref).

```julia
julia> import ArrayInitializers: fill!

julia> const fives = fill!(5)
ArrayInitializers.FillArrayInitializer{Int64}(5)

julia> Matrix(fives, 5, 9)
5×9 Matrix{Int64}:
 5  5  5  5  5  5  5  5  5
 5  5  5  5  5  5  5  5  5
 5  5  5  5  5  5  5  5  5
 5  5  5  5  5  5  5  5  5
 5  5  5  5  5  5  5  5  5
```
"""
@inline fill!(value) = init(value)
@inline fill!(array, args...) = Base.fill!(array, args...)

"""
    ZeroInitializer{T}

When passed as the first argument of an `AbstractArray` constructor,
fill the constructed array with zeros. This will also add a type to
an untyped array.
"""
struct ZeroInitializer{T} <: AbstractArrayInitializer{T} end
ZeroInitializer(::Type{T}) where T = ZeroInitializer{T}()

"""
    zeroinit
    zeroinit(::Type{T})

Singleton instance of `ZeroInitializer{Any}`. The instance can be
called with a type argument to create a typed zero initializer.

```julia
julia> Vector{Int}(zeroinit, 5)
5-element Vector{Int64}:
 0
 0
 0
 0
 0

julia> Matrix(zeroinit(Rational), 4, 2)
4×2 Matrix{Rational}:
 0//1  0//1
 0//1  0//1
 0//1  0//1
 0//1  0//1
```
"""
const zeroinit = ZeroInitializer{Any}()
(::ZeroInitializer{Any})(::Type{T}) where T = ZeroInitializer{T}()

"""
    OneInitializer{T}

When passed as the first argument of an `AbstractArray` constructor,
fill the constructed array with ones. This will also add a type to
an untyped array.
"""
struct OneInitializer{T} <: AbstractArrayInitializer{T} end
OneInitializer(::Type{T}) where T = OneInitializer{T}()

"""
    oneinit
    oneinit(::Type{T})

Singleton instance of `oneInitializer{Any}`. The instance can be
called with a type argument to create a typed one initializer.

```julia
julia> Matrix(oneinit(Rational), 3, 6)
3×6 Matrix{Rational}:
 1//1  1//1  1//1  1//1  1//1  1//1
 1//1  1//1  1//1  1//1  1//1  1//1
 1//1  1//1  1//1  1//1  1//1  1//1

julia> Matrix{Number}(oneinit, 3, 6)
3×6 Matrix{Number}:
 1  1  1  1  1  1
 1  1  1  1  1  1
 1  1  1  1  1  1
```
"""
const oneinit = OneInitializer{Any}()
(::OneInitializer{Any})(::Type{T}) where T = OneInitializer{T}()

"""
    UndefTypeArrayInitializer{T}

When passed as the first argument of an `AbstractArray` constructor,
confer the type `T` if the `AbstractArray` is not typed. The array
is not initialized.

See [`undeftype`](@ref)
"""
struct UndefTypeArrayInitializer{T} <: AbstractArrayInitializer{T} end

"""
    undeftype(::Type{T})

When passed as the first argument of an `AbstractArray` constructor,
confer the type `T` if the `AbstractArray` is not typed. The array
is not initialized.

```
julia> Matrix(undeftype(Float64), 3, 6)
3×6 Matrix{Float64}:
 1.5e-323      2.0e-323      7.0e-323      2.5e-323      3.5e-323      3.0e-323
 1.0e-323      1.5e-323      2.0e-323      2.0e-323      2.5e-323      2.5e-323
 1.13396e-311  6.95272e-310  6.95272e-310  1.13394e-311  6.95272e-310  6.95272e-310

julia> Matrix(undeftype(Number), 3, 6)
3×6 Matrix{Number}:
 #undef  #undef  #undef  #undef  #undef  #undef
 #undef  #undef  #undef  #undef  #undef  #undef
 #undef  #undef  #undef  #undef  #undef  #undef
```
"""
undeftype(::Type{T}) where T = UndefTypeArrayInitializer{T}()

# Array(init(2), (3,))
@inline (::Type{A})(fai::FillArrayInitializer{T}, dims::Dims{N}) where {T, N, A <: AbstractArray} =  Base.fill!(A{T,N}(undef, dims...), fai.value)
# Array(init(2), 1, 2)
@inline (::Type{A})(fai::FillArrayInitializer{T}, dims...) where {T, A <: AbstractArray} =  Base.fill!(A{T,length(dims)}(undef, dims...), fai.value)
# e.g. Array{Float64}(fai, 1, 2)
@inline (::Type{A})(fai::FillArrayInitializer{T}, dims...) where {T, T2, A <: AbstractArray{T2}} =  Base.fill!(A{length(dims)}(undef, dims...), fai.value)
# e.g. Vector(fai, 1)
@inline (::Type{A})(fai::FillArrayInitializer{T}, dims...) where {T, N, A <: NAbstractArray{N}} =  Base.fill!(A{T}(undef, dims...), fai.value)
# e.g. Vector{T}(fai::FillArrayInitializer{T}, 1)
@inline (::Type{A})(fai::FillArrayInitializer, dims...) where {T, N, A <: AbstractArray{T,N}} =  Base.fill!(A(undef, dims...), fai.value)

@inline (::Type{A})(oi::ZeroInitializer{T}, dims::Dims{N}) where {T, N, A <: AbstractArray} =  Base.fill!(A{T,N}(undef, dims...), zero(T))
@inline (::Type{A})(oi::ZeroInitializer{T}, dims...) where {T, A <: AbstractArray} =  Base.fill!(A{T,length(dims)}(undef, dims...), zero(T))
@inline (::Type{A})(oi::ZeroInitializer{T}, dims...) where {T, N, A <: NAbstractArray{N}} =  Base.fill!(A{T}(undef, dims...), zero(T))

@inline (::Type{A})(oi::ZeroInitializer, dims...) where {T, A <: AbstractArray{T}} =  Base.fill!(A{length(dims)}(undef, dims...), zero(T))
@inline (::Type{A})(oi::ZeroInitializer, dims...) where {T, N, A <: AbstractArray{T,N}} =  Base.fill!(A(undef, dims...), zero(T))


@inline (::Type{A})(oi::OneInitializer{T}, dims::Dims{N}) where {T, N, A <: AbstractArray} =  Base.fill!(A{T,N}(undef, dims...), oneunit(T))
@inline (::Type{A})(oi::OneInitializer{T}, dims...) where {T, A <: AbstractArray} =  Base.fill!(A{T,length(dims)}(undef, dims...), oneunit(T))
@inline (::Type{A})(oi::OneInitializer{T}, dims...) where {T, N, A <: NAbstractArray{N}} =  Base.fill!(A{T}(undef, dims...), oneunit(T))

@inline (::Type{A})(oi::OneInitializer, dims...) where {T, A <: AbstractArray{T}} =  Base.fill!(A{length(dims)}(undef, dims...), oneunit(T))
@inline (::Type{A})(oi::OneInitializer, dims...) where {T, N, A <: AbstractArray{T,N}} =  Base.fill!(A(undef, dims...), oneunit(T))

@inline (::Type{A})(::UndefTypeArrayInitializer{T}, dims::Dims{N}) where {T, N, A <: AbstractArray} =  A{T,N}(undef, dims...)
@inline (::Type{A})(::UndefTypeArrayInitializer{T}, dims...) where {T, A <: AbstractArray} =  A{T,length(dims)}(undef, dims...)
@inline (::Type{A})(::UndefTypeArrayInitializer{T}, dims...) where {T, T2, A <: AbstractArray{T2}} = throw(ArgumentError("Tried to initialize $A with a $(UndefTypeArrayInitializer{T})")) 
@inline (::Type{A})(::UndefTypeArrayInitializer{T}, dims...) where {T, N, A <: NAbstractArray{N} where T2} =  A{T}(undef, dims...)

abstract type AbstractRandomArrayInitializer{T} <: AbstractArrayInitializer{T} end

struct RandomTypeInitializer{T} <: AbstractArrayInitializer{T} end
"""
    randinit

Initialize array with random values.

```julia
julia> Array{UInt8}(randinit, 5)
5-element Vector{UInt8}:
 0x91
 0xcb
 0xf0
 0xa5
 0x9e

julia> Array(randinit(1:3), 5)
5-element Vector{Int64}:
 3
 3
 2
 2
 3

julia> ri = randinit(MersenneTwister(1234), Int8)
ArrayInitializers.RNGArrayInitializer{Int8, Type{Int8}, MersenneTwister}(Int8, MersenneTwister(1234))

julia> Matrix(ri, 2, 3)
2×3 Matrix{Int8}:
  -20   75  126
 -105  115  -42
```
"""
const randinit = RandomTypeInitializer{Any}()
(::RandomTypeInitializer{Any})(::Type{T}) where T = RandomTypeInitializer{T}()

@inline (::Type{A})(ri::RandomTypeInitializer{T}, dims::Dims{N}) where {T, N, A <: Array} = rand(T, dims...)
@inline (::Type{A})(ri::RandomTypeInitializer{T}, dims...) where {T, A <: Array} = rand(T, dims...)
@inline (::Type{A})(ri::RandomTypeInitializer{T}, dims...) where {T, N, A <: NArray{N}} = rand(T, dims...)

@inline (::Type{A})(ri::RandomTypeInitializer, dims...) where {T, A <: Array{T}} = rand(T, dims...)
@inline (::Type{A})(ri::RandomTypeInitializer, dims...) where {T, N, A <: Array{T,N}} = rand(T, dims...)

@inline (::Type{A})(ri::RandomTypeInitializer{T}, dims::Dims{N}) where {T, N, A <: AbstractArray} = rand!(A{T,N}(undef, dims))
@inline (::Type{A})(ri::RandomTypeInitializer{T}, dims...) where {T, A <: AbstractArray} = rand!(A{T,length(dims)}(undef, dims...))
@inline (::Type{A})(ri::RandomTypeInitializer{T}, dims...) where {T, N, A <: NAbstractArray{N}} = rand!(A{T}(undef, dims...))

@inline (::Type{A})(ri::RandomTypeInitializer, dims...) where {T, A <: AbstractArray{T}} = rand!(A{length(dims)}(undef, dims...))
@inline (::Type{A})(ri::RandomTypeInitializer, dims...) where {T, N, A <: AbstractArray{T,N}} = rand!(A(undef, dims...))

struct RandomCollectionInitializer{T,C} <: AbstractArrayInitializer{T}
    S::C
end
(::RandomTypeInitializer{Any})(S::C) where C = RandomCollectionInitializer{eltype(C), C}(S)

@inline (::Type{A})(ri::RandomCollectionInitializer{T}, dims::Dims{N}) where {T, N, A <: Array} = Base.rand(ri.S, dims...)
@inline (::Type{A})(ri::RandomCollectionInitializer{T}, dims...) where {T, A <: Array} = Base.rand(ri.S, dims...)
@inline (::Type{A})(ri::RandomCollectionInitializer{T}, dims...) where {T, N, A <: NArray{N}} = Base.rand(ri.S, dims...)

@inline (::Type{A})(ri::RandomCollectionInitializer, dims...) where {T, A <: Array{T}} = Base.rand(ri.S, dims...)
@inline (::Type{A})(ri::RandomCollectionInitializer, dims...) where {T, N, A <: Array{T,N}} = Base.rand(ri.S, dims...)

@inline (::Type{A})(ri::RandomCollectionInitializer{T}, dims::Dims{N}) where {T, N, A <: AbstractArray} = Random.rand!(A{T,N}(undef, dims), ri.S)
@inline (::Type{A})(ri::RandomCollectionInitializer{T}, dims...) where {T, A <: AbstractArray} = Random.rand!(A{T,length(dims)}(undef, dims...), ri.S)
@inline (::Type{A})(ri::RandomCollectionInitializer{T}, dims...) where {T, N, A <: NAbstractArray{N}} = Random.rand!(A{T}(undef, dims...), ri.S)

@inline (::Type{A})(ri::RandomCollectionInitializer, dims...) where {T, A <: AbstractArray{T}} = Random.rand!(A{length(dims)}(undef, dims...), ri.S)
@inline (::Type{A})(ri::RandomCollectionInitializer, dims...) where {T, N, A <: AbstractArray{T,N}} = Random.rand!(A(undef, dims...), ri.S)

struct RNGArrayInitializer{T, C, RNG} <: AbstractArrayInitializer{T}
    S::C
    rng::RNG
end
(::RandomTypeInitializer{Any})(rng::RNG, S::C) where {RNG, C} = RNGArrayInitializer{eltype(C), C, RNG}(S, rng)
(::RandomTypeInitializer{Any})(rng::RNG, T::Type{TY}) where {RNG, TY} = RNGArrayInitializer{T, Type{TY}, RNG}(T, rng)

@inline (::Type{A})(ri::RNGArrayInitializer{T}, dims::Dims{N}) where {T, N, A <: Array} = Base.rand(ri.rng, ri.S, dims...)
@inline (::Type{A})(ri::RNGArrayInitializer{T}, dims...) where {T, A <: Array} = Base.rand(ri.rng, ri.S, dims...)
@inline (::Type{A})(ri::RNGArrayInitializer{T}, dims...) where {T, N, A <: NArray{N}} = Base.rand(ri.rng, ri.S, dims...)

@inline (::Type{A})(ri::RNGArrayInitializer, dims...) where {T, A <: Array{T}} = Base.rand(ri.rng, ri.S, dims...)
@inline (::Type{A})(ri::RNGArrayInitializer, dims...) where {T, N, A <: Array{T,N}} = Base.rand(ri.rng, ri.S, dims...)

@inline (::Type{A})(ri::RNGArrayInitializer{T}, dims::Dims{N}) where {T, N, A <: AbstractArray} = Random.rand!(ri.rng, A{T,N}(undef, dims), ri.S)
@inline (::Type{A})(ri::RNGArrayInitializer{T}, dims...) where {T, A <: AbstractArray} = Random.rand!(ri.rng, A{T,length(dims)}(undef, dims...), ri.S)
@inline (::Type{A})(ri::RNGArrayInitializer{T}, dims...) where {T, N, A <: NAbstractArray{N}} = Random.rand!(ri.rng, A{T}(undef, dims...), ri.S)

@inline (::Type{A})(ri::RNGArrayInitializer, dims...) where {T, A <: AbstractArray{T}} = Random.rand!(ri.rng, A{length(dims)}(undef, dims...), ri.S)
@inline (::Type{A})(ri::RNGArrayInitializer, dims...) where {T, N, A <: AbstractArray{T,N}} = Random.rand!(ri.rng, A(undef, dims...), ri.S)


"""
    SizedArrayInitializer(initializer, dims)

`Array` initializer with dimensions. Construct using `Base.reshape`

```julia
julia> twos = init(2)
ArrayInitializers.FillArrayInitializer{Int64}(2)

julia> twos_3x5 = reshape(twos, 3, 5)
ArrayInitializers.SizedArrayInitializer{Int64, ArrayInitializers.FillArrayInitializer{Int64}, Tuple{Int64, Int64}}(ArrayInitializers.FillArrayInitializer{Int64}(2), (3, 5))

julia> Array(twos_3x5)
3×5 Matrix{Int64}:
 2  2  2  2  2
 2  2  2  2  2
 2  2  2  2  2
```
"""
struct SizedArrayInitializer{T, I <: AbstractArrayInitializer{T}, D} <: AbstractArrayInitializer{T}
    initializer::I
    dims::D
end
Base.reshape(aai::AbstractArrayInitializer{T}, dims) where T = SizedArrayInitializer(aai, dims)
Base.reshape(aai::AbstractArrayInitializer{T}, dims...) where T = SizedArrayInitializer(aai, dims)

@inline (::Type{A})(si::SizedArrayInitializer) where {A <: AbstractArray} = A(si.initializer, si.dims...)
@inline (::Type{A})(si::SizedArrayInitializer, dims...) where {A <: AbstractArray} = A(si.initializer, dims...)

struct GeneratorInitializer{T, G <: Base.Generator} <: AbstractArrayInitializer{T}
    gen::G
end

function geninit(gen::Base.Generator)
    gi = GeneratorInitializer{eltype(first(gen)), typeof(gen)}(gen)
    if applicable(size, gi.gen.iter)
        gi = SizedArrayInitializer(gi, size(gi.gen))
    end
    return gi
end

function (::Type{Array})(gi::GeneratorInitializer{T}, dims...) where T
    reshape(collect(T, gi.gen), dims)
end
function (::Type{Array{T}})(gi::GeneratorInitializer, dims...) where T
    reshape(collect(T, gi.gen), dims)
end
function (::Type{A})(gi::GeneratorInitializer{T}, dims...) where {T, A <: AbstractArray}
    A(collect(T, gi.gen), dims)
end
function (::Type{A})(gi::GeneratorInitializer, dims...) where {T, A <: AbstractArray{T}}
    A(collect(T, gi.gen), dims)
end


end