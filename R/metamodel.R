# Basic metamodel compilation function: used to translate quoted R expressions 
# into metamodel objects representing code in the base language. Does the setup
# grunt work and then calls into the compile() functions in that environment to
# do the actual work
# 
# Author: Matthew Kay
###############################################################################

metamodel = function(model_parts, env, eval_env) {
    env = new.env(parent=env)
    env$eval_env = eval_env
    
    #compile each sub-part of the model
    model_parts = model_parts[!sapply(model_parts, is.null)]
    model = lapply(model_parts, function(model_part_metacode) {
            env$metacode = model_part_metacode
            #compile
            model_part = evalq(bare_block(metacode, indent="    ", eval_env=eval_env), envir = env)
            model_part$code = paste0("{", model_part$code, "\n}")
            model_part
        })
    class(model) = c("metamodel")
    model
}

code.metamodel = function(x, ...) {
    paste(names(x), lapply(x, code), collapse="\n\n")
}

as.character.metamodel = code.metamodel 

print.metamodel = function(x, ...) {
    cat(class(x)[[1]], "code:\n\n")
    cat(code(x))
    cat("\n")
}
