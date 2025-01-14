@doc raw"""
    LorentzMetric <: AbstractMetric

Abstract type for Lorentz metrics, which have a single time dimension. These
metrics assume the spacelike convention with the time dimension being last,
giving the signature $(++...+-)$.
"""
abstract type LorentzMetric <: AbstractMetric end

@doc raw"""
    MinkowskiMetric <: LorentzMetric

As a special metric of signature  $(++...+-)$, i.e. a [`LorentzMetric`](@ref),
see [`minkowski_metric`](@ref) for the formula.
"""
struct MinkowskiMetric <: LorentzMetric end

@doc raw"""
    Lorentz{N} = MetricManifold{Euclidean{N,ℝ},LorentzMetric}

The Lorentz manifold (or Lorentzian) is a pseudo-Riemannian manifold.

# Constructor

    Lorentz(n[, metric=MinkowskiMetric()])

Generate the Lorentz manifold of dimension `n` with the [`LorentzMetric`](@ref) `m`,
which is by default set to the [`MinkowskiMetric`](@ref).
"""
const Lorentz = MetricManifold{ℝ,Euclidean{Tuple{N},ℝ},<:LorentzMetric} where {N}

function Lorentz(n, m::MT=MinkowskiMetric()) where {MT<:LorentzMetric}
    return Lorentz{n,typeof(m)}(Euclidean(n), m)
end

function local_metric(
    ::MetricManifold{ℝ,Euclidean{Tuple{N},ℝ},MinkowskiMetric},
    p,
) where {N}
    return Diagonal([ones(N - 1)..., -1])
end

function inner(::MetricManifold{ℝ,Euclidean{Tuple{N},ℝ},MinkowskiMetric}, p, X, Y) where {N}
    return minkowski_metric(X, Y)
end
@doc raw"""
    minkowski_metric(a,b)

Compute the minkowski metric on $\mathbb R^n$ is given by
````math
⟨a,b⟩_{\mathrm{M}} = -a_{n}b_{n} +
\displaystyle\sum_{k=1}^{n-1} a_kb_k.
````
"""
function minkowski_metric(a, b)
    a_part = @view a[1:(end - 1)]
    b_part = @view b[1:(end - 1)]
    return -a[end] * b[end] + dot(a_part, b_part)
end
function minkowski_metric(a::StaticVector{N}, b::StaticVector{N}) where {N}
    return -a[N] * b[N] + dot(a[SOneTo(N - 1)], b[SOneTo(N - 1)])
end
