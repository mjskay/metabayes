# Main external function: compiles a metajags model to JAGS code
# 
# Author: Matthew
###############################################################################


## METAJAGS MODEL
metajags_model = function(model) {
    model = bare_block(substitute(model), indent="    ")
    model$code = paste0("model {", model$code, "\n}")
    class(model) = c("metajags_model", "model_code")
    model
}
