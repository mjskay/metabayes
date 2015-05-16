# Building-block object representing compiled code and some metadata (e.g.
# list of variables in the code). The compile functions return one of these.
# 
# Author: Matthew Kay
###############################################################################

code = function(x, ...) UseMethod("code")

code.default = function(x, ...) {
    x$code
}

# we keep all of the "meat" of the compilation code in separate environments so
# that we can:
# 1) build up an environment to compile the code in that is separate from the
#    caller's environment (which is used to evaluate R expressions in if and R()
#    statements)
# 2) Easily build up environments specific to parsing meta-languages for 
#    different modellers (e.g. JAGS or Stan) by re-using the common code needed
#    for compilation.
# You can think of these as poor-mans sub-namespaces within this package.
model_code_environment = new.env()
local({
        

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


}, model_code_environment)

#copy an environment, re-assigning existing functions to use the new
#environment (needed so that new methods can be added which will be
#in the search path of the old methods)
copy_environment = function(env) {
    env2 = list2env(as.list(env, all.names=TRUE), parent=parent.env(env))
    for (i in ls(env, all.names=TRUE)) {
        if (is.function(env2[[i]])) {
            environment(env2[[i]]) = env2
        }
    }
    env2
}
