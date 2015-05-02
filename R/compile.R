# Basic compilation function: translate quoted R expressions into model_code objects
# 
# Author: Matthew Kay
###############################################################################

# we keep all of the "meat" of the compilation code in separate environments so
# that we can:
# 1) build up an environment to compile the code in that is separate from the
#    caller's environment (which is used to evaluate R expressions in if and R()
#    statements)
# 2) Easily build up environments specific to parsing meta-languages for 
#    different modellers (e.g. JAGS or Stan) by re-using the common code needed
#    for compilation.
# You can think of these as poor-mans sub-namespaces within this package.
compile_environment = within(model_code_environment, {


## compiles metajags code to JAGS
compile = function(x=NULL, ...) UseMethod("compile")

compile.default = function(x=NULL, ...) {
    model_code(deparse(x))    
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
        model_code(function_name), 
        "(",
        compile(params, ...),
        ")"
    )
}

compile.operator = function(x, ...) {
    if (length(x) == 2) {   #unary operator
        c(
            model_code(deparse(x[[1]])),
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
        model_code()
    }
    else {
        mc = compile(x[[1]], ...)
        if (length(x) > 1) {
            mc = c(mc, ",", compile(x[-1], ...))
        }
        mc
    }
}

## CODE BLOCKS
statement_list = function(x, indent="", ...) {
    mc = model_code()
    for (param in x) {
        mc = c(mc, 
            "\n", indent, compile(param, indent=indent, ...))
    }
    mc
}

`compile.{` = function(x, indent="", ...) {
    c(
        model_code("{"),
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
        model_code("("),
        compile(x[[2]], ...),
        ")"
    )
}

## FOR LOOPS
compile.for = function(x, ...) {
    c(
        model_code("for ("),
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
    model_code(
        symbol_name,
        if (symbol_name == "") NULL else symbol_name
    )
}

## META-PROGRAMMING CONSTRUCTS
compile.R = function(x, eval_env=list(), ...) {
    bare_block(eval(x[[2]], envir=eval_env), eval_env=eval_env, ...)
}

compile.if = function(x, eval_env=list(), ...) {
    if (eval(x[[2]], envir=eval_env)) {
        bare_block(x[[3]], eval_env=eval_env, ...)
    }
    else if (length(x) == 4) {  #else clause
        bare_block(x[[4]], eval_env=eval_env, ...)
    }
    else {      #no else clause given
        model_code()
    }
}

## convenience versions of compile for expressions quoted using ~ or .
compile.formula = function(x, ...) compile(as.list(x)[-1], ...)
compile.quoted = compile.list


})
