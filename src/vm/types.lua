-- enum of vm inside types
vm.types = {
    number = "number",
    operator = "operator",
    name = "name",
    string = "string",                                                                          -- not fully implemented (still no lexer support for strings. im lazy :) )

    block = "block",             -- { v = tokenValues: table, t = tokenTypes: table }
    list = "list",               -- { v = values: table, t = types: table, s? = size: number }

    func = "func",               -- { p = paramList: table, b = block: vm.types.block }         -- not implemented (just still workin' on it)

    unknown = "unknown",
}