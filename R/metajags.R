# Main external function: compiles a metajags model to JAGS code
# 
# Author: Matthew Kay
###############################################################################


## COMPILE METAJAGS MODEL
metajags = function(model, data=NULL, ...) {
    #set up compilation environment
    env = metajags_compile_environment
    eval_env = parent.frame()  #environment used for evaluating R expressions in meta-statements (like if or R())
    metacode_parts = eval(substitute(expression(data=data, model=model, ...)))
    
    #compile
    model = metamodel(metacode_parts, env, eval_env)
    class(model) = c("metajags", "metamodel")
    model
}
