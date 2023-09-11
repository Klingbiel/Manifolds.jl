include("../utils.jl")

using Quaternions

@testset "Orthogonal Matrices" begin
    M = OrthogonalMatrices(3)
    @test repr(M) == "OrthogonalMatrices(3)"
    @test repr(OrthogonalMatrices(3; parameter=:type)) ==
          "OrthogonalMatrices(3; parameter=:type)"
    @test injectivity_radius(M, PolarRetraction()) == π / sqrt(2.0)
    @test manifold_dimension(M) == 3
    @test injectivity_radius(M) == π * sqrt(2.0)
    @test !is_flat(M)
    p = project(M, ones(3, 3))
    @test is_point(M, p, true)
    @test is_point(M, rand(M), true)
    @test abs(rand(OrthogonalMatrices(1))[]) == 1
    @test is_vector(M, p, rand(M; vector_at=p))
    @test is_point(M, rand(MersenneTwister(), M), true)
    @test abs(rand(MersenneTwister(), OrthogonalMatrices(1))[]) == 1
    @test is_vector(M, p, rand(MersenneTwister(), M; vector_at=p))
end

@testset "Unitary Matrices" begin
    M = UnitaryMatrices(2)
    @test repr(M) == "UnitaryMatrices(2)"
    @test repr(UnitaryMatrices(2; parameter=:type)) == "UnitaryMatrices(2; parameter=:type)"
    @test manifold_dimension(M) == 4
    @test !is_flat(M)
    @test injectivity_radius(M) == π

    # wrong length of size
    @test_throws DomainError is_point(M, zeros(1), true)
    @test_throws DomainError is_point(M, zeros(3, 3), true)
    pF = 1 / 2 .* [1im 1im; -1im 1im]
    @test_throws DomainError is_point(M, pF, true)
    # Determinant not one
    pF2 = [1im 1.0; 0.0 -1im]
    @test_throws DomainError is_point(M, pF2, true)
    p = [1im 0.0; 0.0 1im]
    @test is_point(M, p, true)

    @test_throws DomainError is_vector(M, p, zeros(1), true)
    @test_throws DomainError is_vector(M, p, zeros(3, 3), true)
    # not skew
    @test_throws DomainError is_vector(M, p, ones(2, 2), true)
    X = [0.0 1.0; -1.0 0.0]
    @test is_vector(M, p, X, true)

    q = project(M, ones(2, 2))
    @test is_point(M, q, true)
    q2 = project(M, 1im * ones(2, 2))
    @test is_point(M, q2, true)

    r = exp(M, p, X)
    X2 = log(M, p, r)
    @test isapprox(M, p, X, X2)
    r1 = exp(M, p, X, 1.0)
    @test isapprox(M, r, r1; atol=1e-10)

    @testset "Riemannian Hessian" begin
        p = Matrix{Float64}(I, 2, 2)
        X = [0.0 3.0; -3.0 0.0]
        V = [1.0 0.0; 1.0 0.0]
        @test Weingarten(M, p, X, V) == -1 / 2 * p * (V' * X - X' * V)
        G = [0.0 1.0; 0.0 0.0]
        H = [0.0 0.0; 2.0 0.0]
        @test riemannian_Hessian(M, p, G, H, X) == [0.0 -1.0; 1.0 0.0]
    end
end

@testset "Special unitary matrices" begin
    M = SpecialUnitary(2)
    @test manifold_dimension(M) == 3
    @test injectivity_radius(M) ≈ π * sqrt(2.0)
end

@testset "Quaternionic Unitary Matrices" begin
    M = UnitaryMatrices(1, ℍ; parameter=:type)
    @test repr(M) == "UnitaryMatrices(1, ℍ; parameter=:type)"
    @test repr(UnitaryMatrices(1, ℍ)) == "UnitaryMatrices(1, ℍ)"
    @test manifold_dimension(M) == 3
    @test injectivity_radius(M) == π
    @test !is_flat(M)
    @testset "rand" begin
        p = rand(M)
        @test is_point(M, p)
        X = rand(M; vector_at=p)
        @test is_vector(M, p, X)
        p = rand(MersenneTwister(), M)
        @test is_point(M, p)
        X = rand(MersenneTwister(), M; vector_at=p)
        @test is_vector(M, p, X)
    end

    # wrong length of size
    @test_throws DomainError is_point(M, zeros(2, 2), true)

    # Determinant not one
    pF2 = [quat(0, 1, 0, 0) 1.0; 0.0 -quat(0, 1, 0, 0)]
    @test_throws DomainError is_point(M, pF2, true)
    p = QuaternionF64(
        0.4815296357756736,
        0.6041613272484806,
        -0.2322369798903669,
        0.5909181717450419,
    )

    @test is_point(M, fill(p, 1, 1))
    @test is_point(M, p)

    @test_throws DomainError is_vector(M, p, zeros(2, 2), true)
    # not skew
    @test_throws DomainError is_vector(M, p, Quaternion(1, 0, 0, 0), true)
    X = Quaternion(0.0, 0, 0, 1)
    @test is_vector(M, p, X)

    pu = QuaternionF64(
        -0.2178344173900564,
        -0.4072721993877449,
        -2.2484219560115712,
        -0.4718862793239344,
    )
    q = project(M, pu)
    @test is_point(M, q)
    @test isapprox(q, sign(pu))

    @test get_coordinates(M, p, Quaternion(0, 1, 2, 3), DefaultOrthonormalBasis(ℍ)) ==
          SA[1, 2, 3]
    @test get_vector(M, p, SA[1, 2, 3], DefaultOrthonormalBasis(ℍ)) ==
          Quaternion(0, 1, 2, 3)

    @test get_basis(M, p, DefaultOrthonormalBasis(ℍ)).data == [
        Quaternion(0.0, 1.0, 0.0, 0.0),
        Quaternion(0.0, 0.0, 1.0, 0.0),
        Quaternion(0.0, 0.0, 0.0, 1.0),
    ]
end

@testset "Flatness edge cases" begin
    @test is_flat(SpecialUnitary(1))
end
