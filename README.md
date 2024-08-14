# llpl (lisp like programing language)

## Running Programs
to run llpl files use commmand: \
```lua src\main.lua {file}``` \
but replace "{file}" with relative path to your llpl file.

## Main Idea
llpl is a stack based language. \
Where any token ```(but not thease: ( ) [ ] { } for now)``` is pushed on the stack.
#### Also I need to say one more thing llpl doesn't have grammar. So you can do things like that: ```print ( [ ) ] )``` but it can cause unexpected behaviour.

## Some Examples
More examples can be found in examples directory.
```
/// this is a comment
/// <- is used because // operator is already used as floor division


/// calling functions:
/// ( name    params  )
    ( print   a  b  c )
/// prints out: "a b c"


/// using operators:
/// [ params    operator ]
(print
    [ 1  2  3       +    ] )
/// prints out: "6" (1+2+3 (I think you know why 6))


/// variables:

(set a 2)
/// a = 2

(get a)

(pop) /// pops 1 value from stack (you can also do provide number)

/// one note:
///     function "set" in future will be used for setting variables locally
///     but for setting vars globally "setg" will be used


(print (concat [

            /// This wouldn't be some another random lisp copy without lists
            /// lists can be crated in 2 ways:
(concat             [ blah blah blah ]          (get space) )     /// with square brackets (why are you reading this you can see for yourself)
(concat             ( list yes sir )            (get space) )     /// and a classical lisp clone approach


] (get newline) ))         /// "newline" and "space" vars speak for themself
                           /// but BIG NOTE: they will be only until I am not lazy and implement strings YESSIRRRrr :\/
                           /// instead of writing this


/// ure smart if u understood me
print(concat(list:thumbsup:))) /// turning in to a list to concat without spaces
```

## Some Less Inportant Info
 - state of pl: uncompleate prototype
 - started this project: 11.08.24 (DD/MM/YY) 21:15
