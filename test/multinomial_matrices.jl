include("utils.jl")

@testset "MultinomialMatrices manifold" begin
    M = MultinomialMatrices(3, 2)
    @testset "MultinomialMatrices manifold Basics" begin
        @test ProbabilitySimplex(2)^3 === MultinomialMatrices(3, 3)
        @test ProbabilitySimplex(2)^(3,) === PowerManifold(ProbabilitySimplex(2), 3)
        @test ^(ProbabilitySimplex(2), 2) === MultinomialMatrices(3, 2)
        @test typeof(^(ProbabilitySimplex(2), 2)) == MultinomialMatrices{3,2,2}
        @test repr(M) == "MultinomialMatrices(3,2)"
        @test representation_size(M) == (3, 2)
        @test manifold_dimension(M) == 4
        p = [2, 0, 0]
        p2 = [p p]
        @test !is_manifold_point(M, p)
        @test_throws DomainError is_manifold_point(M, p, true)
        @test !is_manifold_point(M, p2)
        @test_throws CompositeException is_manifold_point(M, p2, true)
        @test !is_tangent_vector(M, p2, 0.0)
        @test_throws DomainError is_tangent_vector(M, p2, [-1.0, 0.0, 0.0], true)
        @test !is_tangent_vector(M, p2, [-1.0, 0.0, 0.0])
        @test_throws DomainError is_tangent_vector(M, p, [-1.0, 0.0, 0.0], true)
        @test injectivity_radius(M) ≈ 0
        x = [0.5 0.4 0.1; 0.5 0.4 0.1]'
        y = [0.6 0.3 0.1; 0.4 0.5 0.1]'
        z = [0.3 0.6 0.1; 0.6 0.3 0.1]'
        test_manifold(
            M,
            [x, y, z],
            test_injectivity_radius = false,
            test_forward_diff = false,
            test_reverse_diff = false,
            test_vector_spaces = true,
            test_project_tangent = false,
            test_musical_isomorphisms = true,
            test_default_vector_transport = false,
            is_tangent_atol_multiplier = 5.0,
        )
    end
end
