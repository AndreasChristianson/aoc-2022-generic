#!/usr/bin/env bash

set -o noglob

input="$1"

declare -A data=()

while IFS="" read -ra line; do
  arrIN=(${line//:/})
  data["${arrIN[0]}"]="${arrIN[@]:1}"
done < "$input"


declare -p data
declare -A stack=()
declare -i top=$((-1))

re='^[0-9]+$'

function isText {
  if [[ $1 =~ $re ]] then
    return 1 #happy exit code is truthy
  else
    return 0 #failed exit code is fasley
  fi
}

function pop() {
  popped="${stack[$top]}"
  unset stack["$top"]
  let top--
}

function push() {
  let top++
  stack[$top]="$1"
}
function topIsText() {
  pop
  push "$popped"
  return $(isText $popped)
}

function swapTop() {
  pop
  argl="$popped"
  pop
  argr="$popped"
  pop 
  push "R$popped"
  push "$argl"
  push "$argr"
}

function stackHasWork() {
  if [[ $top -eq 0 ]]; then
    return $(topIsText)
  fi
  return 0
}

function process {
  while stackHasWork
  do
    if topIsText; then # text on top
      pop
      toBePushed=${data[$popped]}
      asArray=($toBePushed)
      if [[ -z $toBePushed ]] then
        echo "wtf"
        exit -1
      fi
      if [[ ${#asArray[@]} -eq 3 ]] then
        push ${asArray[1]}
        push ${asArray[2]}
        push ${asArray[0]}
       
      else
        push ${asArray[0]}
      fi
      human='^humn$'
      if [[ $popped =~ $human ]] then
        asString="x"
      else
        asString="($toBePushed)"
      fi
      root="${root//$popped/$asString}"
    else # number on top
      swapTop
      if ! topIsText; then # two numbers on top
        pop
        argl="$popped"
        pop
        argr="$popped"
        pop
        op="$popped"
        if [[ $op =~ ^RR.* ]] then
          let result=$(("$argl" "${op:2}" "$argr"))
        elif [[ $op =~ ^R.* ]] then
          let result=$(("$argr" "${op:1}" "$argl"))
        else
          let result=$(("$argl" "$op" "$argr"))
        fi
        push "$result"
      fi
    fi
    # declare -p top
    # declare -p stack
  done
}

push "root"
rootnode="${data[root]}"
root="solve(${rootnode//[+-]/=}; x)"

process
echo $root
declare -p stack

qalc -t "$root"