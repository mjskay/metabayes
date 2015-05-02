# Building-block object for compiled code
# 
# Author: Matthew Kay
###############################################################################

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
