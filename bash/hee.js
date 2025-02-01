data = [] // it is initialized and awk'd and stuff

i=1
checksum=0
done_idx=0
block=0
check_start = data.length % 2 == 0? data.length-1: data.length-2

for(j =0;j < data[done_idx]; j++){
  checksum += done_idx*block
  block +=1
}

while( done_idx < check_start){
  for(j = check_start; j >done_idx; j-=2){
    if(data[done_idx+1] >= data[j]){
      for(k = 0; k < data[j]; j++){
        block+=1
        checksum += (j/2)*block // this should be floor_div just in case but j should be even always
      }
      if(data[done_idx+1] - data[j] == 0){
        block += data[done_idx+1]
        done_idx +=2
        i +=2
      }
      else{
        data[done_idx+1] -= data[j]
      }
      check_start = check_start == j? check_start -2 : check_start
      break;
    }
  }
}
