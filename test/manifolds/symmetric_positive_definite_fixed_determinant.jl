include("../utils.jl")

@testset "Symmetric Positive Definite Matrices fixed determinant" begin
    M = SymmetricPositiveDefiniteFixedDeterminant(2, 1.0)
    @test repr(M) == "SymmetricPositiveDefiniteFixedDeterminant(2, 1.0)"
    p = [1.0 0.0; 0.0 1.0]
    @test is_point(M, p)
    # Determinant is 4
    @test !is_point(M, 2.0 .* p)
    @test_throws DomainError is_point(M, 2.0 .* p, true)
    #
    X = [0.0 0.1; 0.1 0.0]
    @test is_vector(M, p, X)
    Y = [1.0 0.1; 0.1 1.0]
    @test !is_vector(M, p, Y)
    @test_throws DomainError is_vector(M, p, Y, true)

    @test project(M, 2.0 .* p) == p
    @test project(M, p, Y) == X

    @test manifold_dimension(M) == 2

    q = exp(M, p, X)
    @test det(q) ≈ 1
    @test distance(M, q, exp(get_embedding(M), p, X)) ≈ 0 atol = 6e-16
    @test norm(M, p, log(M, p, q) - X) ≈ 0 atol = 3e-16
    @test norm(M, p, log(get_embedding(M), p, q) - X) ≈ 0 atol = 3e-16
end