# compile function and environment for metajags: used to translate quoted R 
# expression into model_code objects that represent JAGS code.
# 
# Author: Matthew Kay
###############################################################################

# We keep all of the "meat" of the compilation code in separate environments.
# See the comment for model_code_environment at the top of model_code.R
metajags_compile_environment = copy_environment(compile_environment)
local({


## CODE CONCATENATION OPERATOR (WORK AROUND FOR USE WITH TRUNCATION)
`compile.%c%` = function(x, ...) {
    c(
        compile(x[[2]], ...),
        " ",
        compile(x[[3]], ...)
    )
}

## META-PROGRAMMING CONSTRUCTS
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


}, metajags_compile_environment)
