# THABTO

Automatic ghostwriting for AV evasion.
  
## Work in progress. Not ready yet!
  
To do:
  * Sequence injection randomizer
    * Obfuscation rules to be stored one file per rule in 'rules' subdirectory
  * Break original executable into chunks, md5sum and store the hashes. After recompiling, repeat the process. If a certain threshold of change isn't met, loop the ghostwriting process and try again.
  * Add support for
    * ELFs
    * Mach-o's
  * Rule files:
    * Random NOPs
    * Block shuffling
    * Random reg instructions before reg clearing instructions
    * Load a global constant, do some randomly-generated complex-looking operations on it, then discard it
    * Dynamic Library Calls? (this would probably break stuff)
    * Mixed Booleans? (https://blog.quarkslab.com/arybo-cleaning-obfuscation-by-playing-with-mixed-boolean-and-arithmetic-operations.html https://blog.quarkslab.com/phd-defense-of-ninon-eyrolles-obfuscation-with-mixed-boolean-arithmetic-expressions-reconstruction-analysis-and-simplification-tools.html)
    
###### This project is meant to be extensible with minimal effort. Just write a rule file, place it in the rules directory, and re-run the script. Please do contribute to this project. Two heads are better than one.
