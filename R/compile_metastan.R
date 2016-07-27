# compile function and environment for metastan: used to translate quoted R 
# expression into model_code objects that represent Stan code.
# 
# Author: Matthew Kay
###############################################################################

# We keep all of the "meat" of the compilation code in separate environments.
# See the comment for model_code_environment at the top of model_code.R
metastan_compile_environment = copy_environment(compile_environment)
local({

#<- is deprecated in Stan, convert to =
`compile.=` = function(x, ...) {
    compile.operator(x, ...)
}
`compile.<-` = function(x, ...) {
    x[[1]] = quote(`=`)
    compile.operator(x, ...)
}
    
    
`compile.:` = function(x, in_for_seq=FALSE, ...) {
    if (in_for_seq) {
        #when used to specify sequences in a for loop, this acts
        #as a normal binary operator: the sequence operator
        compile.operator(x, in_for_seq=TRUE, ...)
    }
    else {
        #when used elsewhere, this acts as a type declaration operator
        c(
            compile(x[[3]], 
                #used by compile.function_call to change compiled bracket type from 
                #( ... ) to < ... >, because type declarations in Stan use < ... >
                #to parameterize types
                in_type_declaration=TRUE, 
                ...),
            " ",
            compile(x[[2]], ...)
        )
    }
}

compile.if = function(x, ...) {
    cond_code = compile(x[[2]], ...)
    true_code = compile(x[[3]], ...)
    mc = c(
        model_code("if ("),
        cond_code,
        ") ",
        true_code)
    if ((length(x) == 4)) {
        false_code = compile(x[[4]], ...)
        mc = c(mc,
            model_code(" else "), 
            false_code,
            #is_statement must be set by the last clause in the
            #if statement (here, the false clause because an else
            #clause was present)
            is_statement = false_code$is_statement
            )
    } 
    else {
        #is_statement must be set by the last clause in the
        #if statement (here, the true clause because no else
        #clause was present)
        mc$is_statement = true_code$is_statement
    }
    mc
}


}, metastan_compile_environment)
