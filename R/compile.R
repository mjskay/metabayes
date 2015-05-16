# Basic compile function and environment: used to translate quoted R expressions 
# into model_code objects representing code in the base language.
# 
# Author: Matthew Kay
###############################################################################

# We keep all of the "meat" of the compilation code in separate environments.
# See the comment for model_code_environment at the top of model_code.R
compile_environment = copy_environment(model_code_environment)
local({


## compiles metajags code to JAGS
compile = function(x=NULL, ...) UseMethod("compile")

compile.default = function(x=NULL, ...) {
    model_code(as.character(x))
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
        if (function_name %in% operators || substr(function_name, 1, 1) == "%") "operator" else "function_call")
    compile(x, ...)
}

compile.function_call = function(x, in_type_declaration=FALSE, ...) {
    function_code = if(is.name(x[[1]])) {
        #just a plain-old named function
        function_name = deparse(x[[1]])
        model_code(function_name)
    }
    else {
        #function name is an expression
        compile(x[[1]])
    }
    params = as.list(x[-1])
    c(
        function_code,
        if (in_type_declaration) "<" else "(",
        compile(params, ...),
        if (in_type_declaration) ">" else ")"
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
        mc = compile(x[[1]], ...)           #element value
        name = names(x[1])
        if (!is.null(name) && name != "") { #named element
            mc = c(compile(name), "=", mc)
        }  
        if (length(x) > 1) {                #rest of the list
            mc = c(mc, ",", compile(x[-1], ...))
        }
        mc
    }
}

## CODE BLOCKS
statement_list = function(x, indent="", ...) {
    mc = model_code()
    for (statement in x) {
        statement_code = compile(statement, indent=indent, ...)
        mc = c(mc, "\n", indent, statement_code, 
            if (!statement_code$is_statement) ";" #terminate non-statements with ";"
        )
    }
    mc$is_statement = TRUE
    mc
}

`compile.{` = function(x, indent="", ...) {
    c(
        model_code("{"),
        statement_list(as.list(x[-1]), paste0(indent, "    "), ...),
        "\n", indent, "}",
        is_statement = TRUE
    )
}

bare_block = function(x, ...) {
    #if x is a "{...}" block, compiles the statement list without the containing braces
    #otherwise, simply compiles x. This is used primarily for meta-programming constructs
    #because JAGS does not support nested {} blocks, so (e.g.) the meta-if construct
    #must return a sequence of statements without the surrounding {} to be inserted
    #wherever that if statement is.
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
        compile(x[[3]], 
            in_for_seq=TRUE,    #used by metastan to distinguish between sequences and type declarations with `:` 
            ...),
        ") ",
        compile(x[[4]], ...),
        is_statement = TRUE
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
    #evaluate R expression to get the meta code to compile
    quoted_code = eval(x[[2]], envir=eval_env)
    if (is.list(quoted_code)) {
        if (length(quoted_code) == 1) {
            #lists of one language element are treated as just one language element
            #that way a list of one object can be used as an expression
            quoted_code = quoted_code[[1]]
        }
        else {
            #lists can be returned by R expressions here and we
            #treat them as statement blocks
            quoted_code = as.call(c(`{`, quoted_code))
            class(quoted_code) = "{"
        }
    }
    bare_block(quoted_code, eval_env=eval_env, ...)
}

## convenience versions of compile for expressions quoted using ~ or .
compile.formula = function(x, ...) compile(as.list(x)[-1], ...)
compile.quoted = compile.list


}, compile_environment)
