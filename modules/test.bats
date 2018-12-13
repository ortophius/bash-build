@test helloworld {
  result="$(echo 2+2 | bc)"
  [ "$result" -eq 3 ]
}
