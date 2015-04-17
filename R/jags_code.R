# Building-block object for compiled code
# 
# Author: Matthew Kay
###############################################################################

## JAGS CODE
## Represents JAGS code that results from compiled metajags code
## Can be concatenated with other code (and characters) using c().
jags_code = function(code="", symbols=NULL) {
    jc = list(
        code=code,
        symbols=symbols 
    )
    class(jc) = "jags_code"
    jc
}

c.jags_code = function(...) {
    code_fragments = list(...)
    jc = code_fragments[[1]]
    for (f in code_fragments[-1]) {
        if (is.character(f)) {
            jc$code = paste0(jc$code, f)
        }
        else {
            jc = jags_code(paste0(jc$code, f$code), union(jc$symbols, f$symbols))
        }
    } 
    jc
}
