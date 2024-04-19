#!/bin/bash

nums=()
for i in {1..10}; do
    nums+=( $((1 + RANDOM % 100)) )
done

echo "Original array: ${nums[@]}"

for num in "${nums[@]}"; do
    if (( $num % 2 == 0 )); then
    echo "$num is even"
    else
    echo "$num is odd"
    fi
done

# Sum of all even numbers
# initialize the sum of even number with 0
# Loop trought the array
# Check if element in even or not
# if number is even then add to the sum of even numbers
# print sum of even number


# Sum of all odd numbers
# Similar to above process/logic we will check for the odd condition
# if (( $num % 2 != 0 ));

sum_even_odd_numbers() {
  sumEven=0
  sumOdd=0

  for num in "${nums[@]}"; do
      if (( num % 2 == 0 )); then
          sumEven=$((sumEven + num))
          continue
      fi
      sumOdd=$((sumOdd + num))
  done
  echo "Sum of even numbers: $sumEven"
  echo "Sum of odd numbers: $sumOdd"
}

sum_even_odd_numbers

# Get the max number of a list
# initialize max with the first element of the array
# max = ${nums[0]}
# Loop trough the array
# check condition if (( $max  > num ))
# then max=$num

# Get the min number of a list
# initialize min with the first element of the array
# ${nums[0]}
# Loop trough the array
# check condition if (( $min  < num ))
# then min=$num

find_min_max() {
    max=${nums[0]}
    min=${nums[0]}
    for num in "${nums[@]}"; do
       ((num > max)) && max=$num
       ((num < min)) && min=$num
    done

    echo "Max number: $max"
    echo "Min number: $min"
}

find_min_max
