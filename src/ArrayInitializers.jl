module ArrayInitializers

export init, undeftype, zeroinit, oneinit

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

end
