# Basic compilation function: translate quoted R expressions into jags_code objects
# 
# Author: Matthew Kay
###############################################################################

## compiles metajags code to JAGS
compile = function(x=NULL, ...) UseMethod("compile")

compile.default = function(x=NULL, ...) {
    jags_code(deparse(x))    
}

## GENERIC FUNCTIONS AND OPERATORS
operators=c(
    "||","&&","!",
    ">",">=","<","<=","==","!=",
    "+","-","*","/",
    "^","**",
    ":","[","~","<-")

compile.call = function(x, ...) {
    function_name = deparse(x[[1]])
    class(x) = c(function_name, 
        if (function_name %in% operators || substr(function_name, 1, 1) == "%") "operator" else "function")
    compile(x, ...)
}

compile.function = function(x, ...) {
    function_name = deparse(x[[1]])
    params = as.list(x[-1])
    c(
        jags_code(function_name), 
        "(",
        compile(params, ...),
        ")"
    )
}

compile.operator = function(x, ...) {
    if (length(x) == 2) {   #unary operator
        c(
            jags_code(deparse(x[[1]])),
            compile(x[[2]], ...)
        )
    }
    else {                  #binary operator
        c(
            compile(x[[2]], ...),
            " ", deparse(x[[1]]), " ",
            compile(x[[3]], ...)
        )
    }
}

## LISTS
compile.list = function(x, ...) {
    if (length(x) == 0) {
        jags_code()
    }
    else {
        jc = compile(x[[1]], ...)
        if (length(x) > 1) {
            jc = c(jc, ",", compile(x[-1], ...))
        }
        jc
    }
}

## CODE BLOCKS
statement_list = function(x, indent="", ...) {
    jc = jags_code()
    for (param in x) {
        jc = c(jc, 
            "\n", indent, compile(param, indent=indent, ...))
    }
    jc
}

`compile.{` = function(x, indent="", ...) {
    c(
        jags_code("{"),
        statement_list(as.list(x[-1]), paste0(indent, "    "), ...),
        "\n", indent, "}"
    )
}

bare_block = function(x, ...) {
    #if x is a "{...}" block, compiles the statement list without the containing braces
    #otherwise, simply compiles x
    if (class(x) == "{") {
        statement_list(as.list(x[-1]), ...)
    }
    else {
        compile(x, ...)
    }
}

## INDEXING
`compile.[` = function(x, ...) {
    c(
        compile(x[[2]], ...),
        "[",
        compile.list(as.list(x[-1:-2]), ...),
        "]"
    )
}

## PARAMETER LISTS
`compile.(` = function(x, ...) {
    c(
        jags_code("("),
        compile(x[[2]], ...),
        ")"
    )
}

## FOR LOOPS
compile.for = function(x, ...) {
    c(
        jags_code("for ("),
        compile(x[[2]], ...),
        " in ",
        compile(x[[3]], ...),
        ") ",
        compile(x[[4]], ...)
    )
}

## OPERATOR ALIASES
`compile.**` = function(x, ...) {
    x[[1]] = quote(`^`)
    compile.operator(x, ...)
}
`compile.=` = function(x, ...) {
    x[[1]] = quote(`<-`)
    compile.operator(x, ...)
}
`compile.<-` = function(x, ...) {
    compile.operator(x, ...)
}

## CODE CONCATENATION OPERATOR (WORK AROUND FOR USE WITH TRUNCATION)
`compile.%c%` = function(x, ...) {
    c(
        compile(x[[2]], ...),
        " ",
        compile(x[[3]], ...)
    )
}

## LONE SYMBOLS (NAMES)
compile.name = function(x, ...) {
    symbol_name = deparse(x)
    jags_code(
        symbol_name,
        if (symbol_name == "") NULL else symbol_name
    )
}

## META-PROGRAMMING CONSTRUCTS
compile.R = function(x, ...) {
    bare_block(eval(x[[2]]), ...)
}

compile.if = function(x, ...) {
    if (eval(x[[2]])) {
        bare_block(x[[3]], ...)
    }
    else if (length(x) == 4) {  #else clause
        bare_block(x[[4]], ...)
    }
    else {      #no else clause given
        jags_code()
    }
}

## convenience versions of compile for expressions quoted using ~ or .
compile.formula = function(x, ...) compile(as.list(x)[-1], ...)
compile.quoted = compile.list
