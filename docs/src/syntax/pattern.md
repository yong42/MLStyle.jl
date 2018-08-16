Pattern
=======================

- [ADT destructing](https://github.com/thautwarm/MLStyle.jl/blob/master/docs/src/syntax/pattern.md#adt-destructing)
- [As-Pattern](https://github.com/thautwarm/MLStyle.jl/blob/master/docs/src/syntax/pattern.md#as-pattern)
- [Literal pattern](https://github.com/thautwarm/MLStyle.jl/blob/master/docs/src/syntax/pattern.md#literal-pattern)
- [Capture pattern](https://github.com/thautwarm/MLStyle.jl/blob/master/docs/src/syntax/pattern.md#capture-pattern)
- [Type pattern](https://github.com/thautwarm/MLStyle.jl/blob/master/docs/src/syntax/pattern.md#type-pattern)
- [Guard](https://github.com/thautwarm/MLStyle.jl/blob/master/docs/src/syntax/pattern.md#guard)
- [Custom pattern & dictionary, tuple, array, linked list pattern](https://github.com/thautwarm/MLStyle.jl/blob/master/docs/src/syntax/pattern.md#custom-pattern)
- [Range Pattern](https://github.com/thautwarm/MLStyle.jl/blob/master/docs/src/syntax/pattern.md#range-pattern)
- [Reference Pattern](https://github.com/thautwarm/MLStyle.jl/blob/master/docs/src/syntax/pattern.md#reference-pattern)
- [Fall through cases](https://github.com/thautwarm/MLStyle.jl/blob/master/docs/src/syntax/pattern.md#fall-through-cases)
- [Type level feature](https://github.com/thautwarm/MLStyle.jl/blob/master/docs/src/syntax/pattern.md#type-level-feature)

Patterns provide convenient ways to manipulate data,

ADT destructing
---------------
```julia


@case Natural(dimension :: Float32, climate :: String, altitude :: Int32)
@case Cutural(region :: String,  kind :: String, country :: String, nature :: Natural)


神农架 = Cutural("湖北", "林区", "中国", Natural(31.744, "北亚热带季风气候", 3106))
Yellostone = Cutural("Yellowstone National Park", "Natural", "United States", Natural(44.36, "subarctic", 2357))

function my_data_query(data_lst :: Vector{Cutural})
    filter(data_lst) do data
        @match data begin
            Cutural(_, "林区", "中国", Natural(dim, _, altitude)){
                    dim > 30.0, altitude > 1000
            } => true

            Cutural(_, _, "United States", Natural(_, _, altitude)){altitude > 2000
            } => true

            _ => false

        end
    end
end
my_data_query([神农架, Yellostone])
...
```


Literal pattern
------------------------

```julia

@match 10 {
    1  => "wrong!"
    2  => "wrong!"
    10 => "right!"
}
# => "right"
```
Default supported literal patterns are `Number`and `AbstractString`.


Capture pattern
--------------

```julia

@match 1 begin
    x => x + 1
end
# => 2
```

Type pattern
-----------------

```julia

@match 1 begin
    ::Float  => nothing
    b :: Int => b
    _        => nothing
end
# => 1
```

However, when you use `TypeLevel Feature`, the behavious could change slightly. See [TypeLevel Feature](https://github.com/thautwarm/MLStyle.jl/blob/master/docs/src/syntax/pattern.md#type-level-feature).

As-Pattern
----------

For julia don't have an `as`  keyword and operator `@`(adopted by Haskell and Rust) is invalid for the conflicts against *macro*,
we use `in` keyword to do such stuffs.

The feature is unstable for there might be perspective usage on `in` keyword about making patterns.

```julia
@match (1, 2) begin
    (a, b) in c => c[1] == a && c[2] == b
end
```


Guard
-----

```julia

@match x begin
    x{x > 5} => 5 - x # only succeed when x > 5
    _        => 1
end
```


Range pattern
-------------

```julia

@match num begin
    1..10  in x => "$x in [1, 10]"
    11..20 in x => "$x in [11, 20]"
    21..30 in x => "$x in [21, 30]"
end
```


Reference pattern
-----------------

This feature is from `Elixir` which could slightly extends ML pattern matching.

```julia
c = ...
@match (x, y) begin
    (&c, _)  => "x equals to c!"
    (_,  &c) => "y equals to c!"
    _        => "none of x and y equal to c"
end
```


Custom pattern
--------------

The reason why Julia is a new "best language" might be that you can implement your own static
pattern matching with this feature:-).

Here is a example although it's not robust at all. You can use it to solve multiplication equations.
```julia
uisng MLStyle

# define pattern for application
PatternDef.App(*) do args, guard, tag, mod
         @match (args) begin
            (l::QuoteNode, r :: QuoteNode) => MLStyle.Err.SyntaxError("both sides of (*) are symbols!")
            (l::QuoteNode, r) =>
               quote
                   $(eval(l)) = $tag / ($r)
               end
           (l, r :: QuoteNode) =>
               quote
                   $(eval(r)) = $tag / ($l)
               end
           end
end

@match 10 begin
     5 * :a => a
end
# => 2.0
```

Dictionary pattern, tuple pattern, array pattern and linked list destructing are both implemented by **Custom pattern**.

- Dict pattern(like `Elixir`'s dictionary matching or ML record matching)

```julia
dict = Dict(1 => 2, "3" => 4, 5 => Dict(6 => 7))
@match dict begin
    Dict("3" => four::Int, 
          5  => Dict(6 => sev)){four < sev} => sev
end
# => 7
```

- Tuple pattern 

```julia

@match (1, 2, (3, 4, (5, )))

    (a, b, (c, d, (5, ))) => (a, b, c, d)

end
# => (1, 2, 3, 4)
```

- Array pattern(as efficient as linked list pattern for the usage of array view)

```julia                                                                                                      
julia> it = @match [1, 2, 3, 4] begin                     
         [1, unpack..., a] => (unpack, a)                 
       end                                                
([2, 3], 4)                                               
                                                          
julia> first(it)                                          
2-element view(::Array{Int64,1}, 2:3) with eltype Int64:  
 2                                                        
 3                                                             
julia> it[2]                                              
4                                                                                                            
```

- Linked list pattern

```julia

lst = List.List!(1, 2, 3)

@match lst begin 
    1 ^ a ^ tail => a
end

# => (2, MLStyle.Data.List.Cons{Int64}(3, MLStyle.Data.List.Nil{Int64}()))
```

Fall through cases
-------------------

```julia
test(num) = 
    @match num begin
       ::Float64 |
        0        |
        1        |
        2        => true

        _        => false
    end

test(0)   # true
test(1)   # true
test(2)   # true
test(1.0) # true
test(3)   # false
test("")  # false
```

Type level feature
----------------

By default, type level feature wouldn't be activated.

```julia
@match 1 begin
    ::String => String
    ::Int => Int    
end
# => Int
```

```julia
Feature.@activate TypeLevel

@match 1 begin 
    ::String => String
    ::Int    => Int
end
# => Int64
```

When using type level feature, if you can only perform runtime type checking when matching, and type level variables could be captured as normal variables.

If you do want to check type when type level feature is activated,
do as the following snippet

```julia
@match 1 begin
    ::&String => String
    ::&Int    => Int
end
```
