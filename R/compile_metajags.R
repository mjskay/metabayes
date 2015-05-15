# compile function and environment for metajags: used to translate quoted R 
# expression into model_code objects that represent JAGS code.
# 
# Author: Matthew Kay
###############################################################################

# We keep all of the "meat" of the compilation code in separate environments.
# See the comment for model_code_environment at the top of model_code.R
metajags_compile_environment = within(compile_environment, {

    })
