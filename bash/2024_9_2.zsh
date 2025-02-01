#!/usr/bin/env bash

# Read all standard input into the 'data' variable
IFS=$'\n' read -r -d '' data

# Split the input into an array of individual characters
disk=($(awk '{for(i=1;i<=length();i++) print substr($0,i,1)}' <<< "$data"))

# Initialize variables
i=1
checksum=0
done_idx=0
block=0
# set check_start, if the length of the array is even then the last item's index will be the length - 1, else it is length -2.
if (( (${#disk[@]} % 2) == 0 )); then
  check_start=$(( ${#disk[@]} - 1 ))
else
  check_start=$(( ${#disk[@]} - 2 ))
fi

# loop through indexes
for ((j=0; j < ${disk[done_idx]}; j++)); do
  checksum=$(( checksum + done_idx * block ))
  block=$(( block + 1 ))
done


while (( done_idx < check_start )); do
  ini=$(:q

  for (( j=check_start; j > done_idx; j-=2 )); do
     if (( ${disk[done_idx+1]} >= ${disk[j]} )); then
        for ((k=0; k < ${disk[j]}; k++)); do
          block=$(( block + 1 ))
          checksum=$(( checksum + (j / 2) * block ))
        done

       if (( ${disk[done_idx+1]} - ${disk[j]} == 0 )); then
         block=$(( block + ${disk[done_idx+1]} ))  # Added block update
         done_idx=$(( done_idx + 2 ))
         i=$((i+2))
       else
          disk[$((done_idx+1))]=$(( ${disk[done_idx+1]} - ${disk[j]} ))
       fi
        if (( check_start == j )); then
          check_start=$(( check_start - 2 ))
        fi
        break
     fi
  done
  echo "done_idx: $done_idx"
  echo "block: $block"
  echo "current_available: $i"
  echo "Checksum: $checksum"
done

# Output the final checksum
echo "Checksum: $checksum"
