I couldn't get this to work. What happens is that the sanity_check fails because it can't 
detect the extension because it doesn't load python itself within the install environment. 
Maybe there is a fix to this but what I did in the end is add the required modules to the 
actual python easyconfig and then use --rebuild --skip to _only_ build the new extensions.
