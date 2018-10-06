# TimeArray to ts conversion by Jay
# conversion methods for DataFrames

function rcopy(::Type{T}, s::Ptr{VecSxp}; sanitize::Bool=true) where T<:TimeArray
    isFrame(s) || error("s is not an R data frame")
    vnames = rcopy(Array{Symbol},getnames(s))
    if sanitize
        vnames = [Symbol(replace(string(v), '.', '_')) for v in vnames]
    end
    DataFrame([rcopy(AbstractArray, c) for c in s], vnames)
end

## DataFrame to sexp conversion.
function sexp(::Type{VecSxp}, ts::TimeArray)
    nr,nc = size(ts)
    nv = names(ts)
    rd = protect(allocArray(VecSxp, nc))
    time_pts = timestamp(ts)
    try
        for i in 1:nc
            rd[i] = sexp(ts[nv[i]])
        end
        setattrib!(rd,Const.NamesSymbol, sexp(nv))

        setattrib!(rd,Const.ClassSymbol, sexp(["mts", "ts", "matrix"] ))
        setattrib!(rv, Const.DimSymbol, collect(size(aa)))

        setattrib!(rd,Const.RowNamesSymbol, sexp(1:nr))
        #=
        r$> attributes(z)
        # $dim
        # [1] 100   3
        $dimnames
        $dimnames[[1]]
        NULL
        $dimnames[[2]]
        [1] "Series 1" "Series 2" "Series 3"
        $tsp
        [1] 1961.00 1969.25   12.00
        # $class
        # [1] "mts"    "ts"     "matrix"
        =#

        ts = OrderedDict(
            k => v.val for (k, v) in zip(axisnames(aa), axes(aa)))
        setattrib!(rv, Const.DimNamesSymbol, ts)
    finally
        unprotect(1)
    end
    rd
end
