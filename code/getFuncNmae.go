package utils

import (
  "github.com/docker/docker/pkg/log"
  "runtime"
)

func GetFuncName(){
  log.Debugf("GetFuncName: ")
  for i := 1; i < 10; i++ {
	funcName, file, line, ok := runtime.Caller(i)
	if ok {
        log.Debugf("  frame %v:[func:%v,file:%v,line:%v]\n", i, runtime.FuncForPC(funcName).Name(), file, line)
	}
   }

}
