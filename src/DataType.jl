module DataType
using MLStyle
using MLStyle.toolz: isCapitalized, ($)

isSymCap = isCapitalized ∘ string

"""
eg.
@data DataName{T} begin
    Cons1{A}(A)
    Cons2(A, B)
    Cons3{a :: A, b :: B)
    Cons3
    Cons4
end
"""

macro data(typ, def_variants)
    (abstract_typ, tvars) =
        @match typ begin
            :($typename{$(tvars...)}) => (typename, tvars)
            :($typename)              => (typename, [])
        end
    variants =
        @match def_variants begin
            quote
                $(variants...)
            end => variants
        end
    elems = []
    ctors = []
    for each in variants
        @match each begin
            ::LineNumberNode => continue
            :($(name && PushTo(extra_vars) || :($name{$(extra_tvars...)}))($(args...))) =>
                begin
                  cons_args = []
                  for (i, arg) in enumerate(args)
                      cons_arg = @match arg begin
                          a :: Symbol where isSymCap(a) => (Symbol("_$i"), a)
                          a :: Symbol                   => (a, Any)
                          :($field :: $typ)             => (field, typ)
                      end
                      push!(cons_args, cons_arg)
                  end
                  all_tvars = append(extra_tvars, tvars)
                  push!(ctors, (name, all_tvars, cons_args))
                end

            name :: Symbol   => push!(elems, (name, tvars))
            :($name{$(extra_tvars...)}) =>
                push!(elems, (name, append(extra_tvars, tvars)))
        end
    end
    for each_elem in elems
        # TODO: make singleton structs and matching patterns
    end
    for each_ctor in ctors
        # TODO: ...
    end

end



end # module
