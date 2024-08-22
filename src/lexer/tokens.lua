-- enum of different token types
tok = {
    number = "number",
    operator = "operator",
    name = "name",
    -- string = "string",        -- not implemented (yet i promise i will implement strings)

    unknown = "unknown",
}

-- list of different operators
operators = {
    '!', '@', '#', '$', '%', '^', '&', "&&", '*', '-', "--", '+', "++", '=',
    ':', ';', '|', "||", '\\',
    '<', '>', ',', '.', '?', '/', "//",

    "<<", ">>",
    "<=", ">=", "!=", "==",
    "-=", "+=", "/=", "*=",

    "..", "..=",

    '(', ')',
    '[', ']',
    '{', '}',
}