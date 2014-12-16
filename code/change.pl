## "github.com/docker/docker/utils"
## log "github.com/Sirupsen/logrus"
    open (MYFILE, "deviceset.go") || die ("Could not open file"); 
    open (OUTFILE, ">deviceset_res.go") || die ("Could not open file"); 
    while ($line = <MYFILE>) {
      print OUTFILE $line;
      if ($line =~ /import/){
        print OUTFILE "\"github.com/docker/docker/utils\"\n"
      }
      if ($line =~ /^func /) {
        print OUTFILE  "utils.GetFuncName()\n"
      }
    } 
