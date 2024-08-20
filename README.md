# llpl (lisp like programing language) (not) another lisp clone 😠
### i promise its different plss stay 😃
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(i haven't writen a line of proper lisp) 😎

## Running Programs 😎
#### &nbsp;&nbsp;&nbsp;i am using lua 5.4.2 🔥🔥🔥
to run **llpl** files use commmand: \
```lua src\llpl.lua {file}``` \
but replace "**{file}**" with relative path to your **llpl file**. 😎

## Main Idea
llpl is a **stack based** language. 😠 \
Where **any token** ```(but not thease: ( ) [ ] { } for now)``` is **pushed on the stack**. 😲
#### Also I need to say one more thing llpl doesn't have grammar. So you can do things like that: ```print  ( [ ) ]  )``` but it can cause unexpected behaviour. 😠

## Some Examples
&nbsp;&nbsp;&nbsp;&nbsp;More **examples** can be found in examples directory. 👍
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

/// ONE NOTE:
///     function "set" in future will be used for setting variables locally
///     but for setting vars globally "setg" will be used


(print (concat [

            /// This wouldn't be some another random lisp copy without lists
            /// lists can be crated in 2 ways:
(concat             [ blah blah blah ]          (get SPACE) )     /// with square brackets (why are you reading this you can see for yourself)
(concat             ( list yes sir )            (get SPACE) )     /// and a classical lisp clone approach


] (get NEWLINE) ))         /// "NEWLINE" and "SPACE" vars speak for themself
                           /// but BIG NOTE: they will be only until I am not lazy and implement strings YESSIRRRrr :\/
                           /// instead of writing this


/// blocks:
/// NOTE: blocks work but still there's only one function (as for now) implementing some usebilyty
/// it's "do" which accepts "infinite" paramiers
/// (of any type but will trash any value other then of type block. goes throu provided blocks and evals them synchronously)


/// pseudo functions: (there will be function "func" creating values of type function)

/// pseudo func creation
(set v3_add {
    (set x2 [ (get x0) (get x1) + ])
    (set y2 [ (get y0) (get y1) + ])
    (set z2 [ (get z0) (get z1) + ])
})


/// setting params
(set x0 (rand -10 10)) (set y0 (rand -10 10)) (set z0 (rand -10 10))
(set x1 (rand -10 10)) (set y1 (rand -10 10)) (set z1 (rand -10 10))

/// calling
(do
    (get
        v3_add
    )
)


/// print for debug
(print)
(print
    (concat [
        (concat (list
            (concat (list (get x0) ,))
            (concat (list (get y0) ,))
            (get z0)
            +
        ) (get SPACE))
        (concat (list
            (concat (list (get x1) ,))
            (concat (list (get y1) ,))
            (get z1)
            =
        ) (get SPACE))
        (concat [
            (concat (list (get x2) ,))
            (concat (list (get y2) ,))
            (get z2)
        ] (get SPACE))
    ] (get NEWLINE))
)
(print)


/// ure smart if u understood me
print(concat(list:thumbsup:))) /// turning in to a list to concat without spaces
```
also this prints:
```
a b c
6
blah blah blah
yes sir

```
this part is dynamic ('cuz it uses "rand" (aka random). not used here but also "randseed")
```
number, number, number +
number, number, number =
number, number, number
```
```

:thumbsup:
```
btw (i dont use arch 😎, mom am i cool?)

## What Am I Working On Now ✔️
 - **Adding more functionality to blocks in llpl** 😃 \
    &nbsp;&nbsp;&nbsp;they are very limited (like only one function "do") 😠
 - **Adding useful (or not) functions to llpl** 👍

## Some Later (aka Post-First-Release 😎) Ideas 💻
 - **Exceptions** 🔥🔥🔥 (maybe yeah or nah. idk yet but seems like cool idea 😎)

## Some Less Inportant Info 👀
 - **state of pl**: **uncompleate prototype** 😦
 - **started this project**: **11.08.24 (DD/MM/YY) 21:15** ✔️
