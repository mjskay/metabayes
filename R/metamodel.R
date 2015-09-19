# Basic metamodel compilation function: used to translate quoted R expressions 
# into metamodel objects representing code in the base language. Does the setup
# grunt work and then calls into the compile() functions in that environment to
# do the actual work
# 
# Author: Matthew Kay
###############################################################################

# Names that should be suppressed from global variable check by codetools
# Names used broadly should be put in global_variables.R
globalVariables(c("bare_block", "metacode"))


metamodel = function(model_parts, env, eval_env) {
    env = new.env(parent=env)
    env$eval_env = eval_env
    
    #compile each sub-part of the model
    model_parts = model_parts[!sapply(model_parts, is.null)]
    model = lapply(model_parts, function(model_part_metacode) {
            env$metacode = model_part_metacode
            #compile
            model_part = evalq(bare_block(metacode, indent="    ", eval_env=eval_env), envir = env)
            if (!model_part$is_statement) {
                #returned code is not a terminated statement, so terminate it
                model_part$code = paste0("\n    ", model_part$code, ";")
            }
            model_part$code = paste0("{", model_part$code, "\n}")
            model_part
        })
    names(model) = gsub("[\\._]", " ", names(model))    #translate _ and . into spaces (for metastan)
    class(model) = c("metamodel")
    model
}

code.metamodel = function(x, ...) {
    paste(names(x), lapply(x, code), collapse="\n\n")
}

as.character.metamodel = code.metamodel 

print.metamodel = function(x, ...) {
    cat(class(x)[[1]], "code:\n\n")
    lines = strsplit(code(x), "\n", fixed=TRUE)[[1]]
    cat(paste(seq_along(lines), "\t", lines, collapse="\n"))
    cat("\n")
}

variables = function(m) {
    vars = unlist(sapply(m, function(.) as.vector(.$symbols)))
    names(vars) = NULL
    vars
}
