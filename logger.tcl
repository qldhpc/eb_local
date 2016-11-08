if { [ module-info mode load ] }  {
   set name [module-info name]
   if [info exists env(PBS_JOBID)] {
     set message "$name - $env(USER) - $env(PBS_JOBID) - $ModulesCurrentModulefile"
   } else {
     set message "$name - $env(USER) - - $ModulesCurrentModulefile"
   }
   system logger -t hpcsoftware -p user.notice $message
}

