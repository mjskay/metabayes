# compile function and environment for metastan: used to translate quoted R 
# expression into model_code objects that represent Stan code.
# 
# Author: Matthew Kay
###############################################################################

# We keep all of the "meat" of the compilation code in separate environments.
# See the comment for model_code_environment at the top of model_code.R
metastan_compile_environment = copy_environment(compile_environment)
local({


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
                #used by compile.function_call to change bracket type from 
                #( ... ) to < ... >
                in_type_declaration=TRUE, 
                ...),
            " ",
            compile(x[[2]], ...)
        )
    }
}


}, metastan_compile_environment)
