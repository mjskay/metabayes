# Building-block object for compiled code
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
model_code = function(code="", symbols=NULL) {
    mc = list(
        code=code,
        symbols=symbols
    )
    class(mc) = "model_code"
    mc
}

c.model_code = function(...) {
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
    mc
}


})