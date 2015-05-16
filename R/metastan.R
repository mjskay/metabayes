# Main external function: compiles a metastan model to Stan code
# 
# Author: Matthew Kay
###############################################################################


## COMPILE METASTAN MODEL
metastan = function(...) {
    #set up compilation environment
    env = metastan_compile_environment
    eval_env = parent.frame()  #environment used for evaluating R expressions in meta-statements (like R())
    metacode_parts = eval(substitute(expression(...)))
    
    #compile
    model = metamodel(metacode_parts, env, eval_env)
    class(model) = c("metastan", "metamodel")
    model
}
