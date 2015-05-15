# Main external function: compiles a metajags model to JAGS code
# 
# Author: Matthew
###############################################################################


## METAJAGS MODEL
metajags_model = function(model) {
    #set up compilation environment
    env = metajags_compile_environment
    env$quoted_model = substitute(model)
    env$eval_env = parent.frame()  #environment used for evaluating R expressions in meta-statements (like if or R())
    #compile
    model = evalq(bare_block(quoted_model, indent="    ", eval_env=eval_env), envir = env)
    model$code = paste0("model {", model$code, "\n}")
    class(model) = c("metajags_model", "model_code")
    model
}
