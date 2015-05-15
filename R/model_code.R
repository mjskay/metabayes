# Building-block object representing compiled code and some metadata (e.g.
# list of variables in the code). The compile functions return one of these.
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
model_code_environment = within(list(), {
        

## MODEL CODE
## Represents model code that results from compiled meta code
## Can be concatenated with other code (and characters) using c().
model_code = function(code="", 
        symbols=NULL, 
        #true if this code represents a terminated statement or list of statements
        #used to identify statement blocks so that semi-colons can be properly inserted when needed
        is_statement=FALSE
    ) {
    mc = list(
        code=code,
        symbols=symbols,
        is_statement=is_statement
    )
    class(mc) = "model_code"
    mc
}

c.model_code = function(..., is_statement=FALSE) {
    code_fragments = list(...)
    mc = code_fragments[[1]]
    for (f in code_fragments[-1]) {
        if (is.character(f)) {
            mc$code = paste0(mc$code, f)
        }
        else {
            mc = model_code(paste0(mc$code, f$code), union(mc$symbols, f$symbols))
        }
    }
    mc$is_statement = is_statement
    mc
}


})