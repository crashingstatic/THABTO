# THABTO

Automatic ghostwriting for AV evasion. Developed and tested on Kali 2020.3
  
## Work in progress. All non-working rules have .rbak extension.
  
To do:
  * Sequence injection randomizer
    * Obfuscation rules to be stored one file per rule in 'rules' subdirectory
  * After adding section header to original assembly, recompile and break this "control" executable into chunks, sha256sum and store the hashes. After recompiling obfuscated payload, repeat the process. If a certain threshold of change isn't met, loop the ghostwriting process and try again.
  * ~Add support for~
    * ~ELFs~
    * ~Mach-o's~
  * Rule files:
    * ~Random NOPs~
      * ~Non-canonical NOPs?~
    * Block shuffling
    * Random reg instructions before reg clearing instructions
    * Load a global constant, do some randomly-generated complex-looking operations on it, then discard it
    * Dynamic Library Calls? (this would probably break stuff)
    * Mixed Booleans?  
    (see https://blog.quarkslab.com/arybo-cleaning-obfuscation-by-playing-with-mixed-boolean-and-arithmetic-operations.html  
    and  
    https://blog.quarkslab.com/phd-defense-of-ninon-eyrolles-obfuscation-with-mixed-boolean-arithmetic-expressions-reconstruction-analysis-and-simplification-tools.html for more info)
    
###### This project is meant to be extensible with minimal effort. Just write a rule file, place it in the rules directory, and re-run the script. All rules may or may not be randomly applied at runtime for maximum confusion. Please do contribute to this project. Two heads are better than one.
