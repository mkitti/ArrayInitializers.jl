using ArrayInitializers
using ArrayInitializers: fill!
using OffsetArrays
using Test

@testset "ArrayInitializers.jl" begin
    # FillArrayInitializer
    fives = init(5)
    @test Array(fives, 3) == Base.fill!(Vector{Int}(undef, 3), 5)
    @test Array(fives, 3) |> typeof == Vector{Int}
    @test Array{Float64}(fives, 3) == Base.fill!(Vector{Float64}(undef, 3), 5.0)
    @test typeof(Array{Float64}(fives, 3)) == Vector{Float64}
    @test Array{Any}(fives, 3) == Base.fill!(Vector{Float64}(undef, 3), 5.0)
    @test typeof(Array{Any}(fives, 3)) == Vector{Any}
    @test Vector(fives, 9) == Base.fill!(Vector{Int}(undef, 9), 5)
    @test typeof(Vector(fives, 9)) == Vector{Int}
    @test Matrix(fives, 3, 6) == Base.fill!(Matrix{Int}(undef, 3, 6), 5)
    @test typeof(Matrix(fives, 3, 6)) == Matrix{Int}

    @test OffsetArray(fives, 5:9, 2:3) == Base.fill!(OffsetArray{Int}(undef, 5:9, 2:3), 5)
    @test OffsetArray(fives, 5:9, 2:3) |> typeof == OffsetMatrix{Int, Matrix{Int}}
    @test OffsetMatrix(fives, 5:9, 2:3) == Base.fill!(OffsetArray{Int}(undef, 5:9, 2:3), 5)
    @test OffsetMatrix(fives, 5:9, 2:3) |> typeof == OffsetMatrix{Int, Matrix{Int}}
    @test OffsetMatrix{Float64}(fives, 5:9, 2:3) == Base.fill!(OffsetArray{Float64}(undef, 5:9, 2:3), 5)
    @test OffsetVector(fives, 5:9) |> typeof == OffsetVector{Int, Vector{Int}}

    # fill! alias
    @test Array(fill!(3), 5) == Base.fill!(Vector{Int}(undef, 5), 3)
    @test Array(fill!(3.5), 5) == Base.fill!(Vector{Float64}(undef, 5), 3.5)

    # ZeroInitializer
    @test Array{Int}(zeroinit, 5) == zeros(Int, 5)
    @test Array(zeroinit(Int), 5) == zeros(Int, 5)
    @test Matrix(zeroinit(Int), 5, 3) == zeros(Int, 5, 3)
    @test Matrix{Float64}(zeroinit(Int), 5, 3) == zeros(Float64, 5, 3)
    @test Matrix{Float64}(zeroinit(Int), 5, 3) |> typeof == Matrix{Float64}
    @test Array{Float64}(zeroinit(Int), 3, 2, 1) == zeros(Float64, 3, 2, 1)
    @test Array{Float64}(zeroinit(Int), 3, 2, 1) |> typeof == Array{Float64, 3}

    @test OffsetVector{Rational}(zeroinit, 2:5) == Base.fill!(OffsetVector{Rational}(undef, 2:5), 0)
    @test OffsetVector{Rational}(zeroinit, 2:5) |> typeof == OffsetVector{Rational, Vector{Rational}}

    # OneInitializer
    @test Array{Int}(oneinit, 5) == ones(Int, 5)
    @test Array(oneinit(Int), 5) == ones(Int, 5)
    @test Matrix(oneinit(Int), 5, 3) == ones(Int, 5, 3)
    @test Matrix{Float64}(oneinit(Int), 5, 3) == ones(Float64, 5, 3)
    @test Matrix{Float64}(oneinit(Int), 5, 3) |> typeof == Matrix{Float64}
    @test Array{Float64}(oneinit(Int), 3, 2, 1) == ones(Float64, 3, 2, 1)
    @test Array{Float64}(oneinit(Int), 3, 2, 1) |> typeof == Array{Float64, 3}

    @test OffsetVector{Number}(oneinit, 2:5) == Base.fill!(OffsetVector{Number}(undef, 2:5), 1)
    @test OffsetVector{Number}(oneinit, 2:5) |> typeof == OffsetVector{Number, Vector{Number}}

    # UndefTypeArrayInitializer
    A = Array(undeftype(Int), 5)
    @test typeof(A) == Vector{Int}
    @test size(A) == (5,)

    B = Vector(undeftype(Float64), 9)
    @test typeof(B) == Vector{Float64}
    @test size(B) == (9,)

    C = Matrix(undeftype(Float64), 9, 6)
    @test typeof(C) == Matrix{Float64}
    @test size(C) == (9,6)

    @test_throws ArgumentError Array{Int}(undeftype(Float64), 3, 6)
    @test_throws MethodError Matrix{Int}(undeftype(Float64), 3, 6)

    D = OffsetMatrix(undeftype(Int), 1:3, 2:5)
    @test size(D) == (3,4)
    @test typeof(D) == OffsetMatrix{Int, Matrix{Int}}
end
