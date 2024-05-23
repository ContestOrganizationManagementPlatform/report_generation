#!/usr/bin/env nu

# Usage: ./scripts/cd_to_grades.nu raw_data data/contest_dojo_grades/ -f
# where raw_data contains the downloaded files from Contest Dojo (per tournament per test).

let points = [10, 11, 12, 13, 14, 16, 18, 21, 25]
let guts_scores = 1..=27 | each {|problem_number| $points | get ((($problem_number - 1) / 3) | math floor)}

export def main [
  input_directory: string,
  output_directory: string,
  --force (-f),
] {
  for f in ["geometry", "general", "discrete", "calculus", "algebra"] {
    let in_path = ([[parent stem extension]; [$input_directory, $f, "csv"]] | path join).0
    let out_path = ([[parent stem extension]; [$output_directory, $f, "csv"]] | path join).0
    (process_individual $in_path) | if $force { save $out_path -f } else {save $out_path }
  }

  for f in ["team", "guts"] {
    let in_path = ([[parent stem extension]; [$input_directory, $f, "csv"]] | path join).0
    let out_path = ([[parent stem extension]; [$output_directory, $f, "csv"]] | path join).0
    (process_team $in_path)  | if $force { save $out_path -f } else {save $out_path }
  }
}

def process_individual [
  input_file: string
] {
  let data = open $input_file
  $data 
  | reject " Student ID" "Start Time" "Score" ...($data | columns | where {|col| ($col | str starts-with "A") or ($col | str starts-with "T")}) 
  | rename -c {" Student Name": "Student Name", "#": "ID"} 
  | par-each {|it| 
    let correct_columns = ($it | columns | where {|c| $c | str starts-with "C"})
    let grades = $correct_columns | each {|c| $it | get $c} | each {|v| (if $v == 1 {true} else {false}) | into string} | str join ','
    $it | reject ...$correct_columns | insert grades $grades 
  } | to csv
}

def process_team [
  input_file: string
] {
  let data = open $input_file
  $data 
  | update "#" {|it| $it."#" | into string | fill -a right -c '0' -w 3}
  | reject "ID" "Score" "Start Time" ...($data | columns | where {|col| ($col | parse -r '^[TA](\d+)$' | length) > 0}) 
  | rename -c {"#": "ID"} 
  | par-each {|it| 
    let correct_columns = ($it | columns | where {|c| $c | str starts-with "C"})
    let grades = $correct_columns | each {|c| 
      if ($input_file | str contains "guts") {
        let index = ($c | parse -r 'C(\d+)' | get "capture0".0 | into int) - 1
        echo $index
        (if ($it | get $c) == 1 {$guts_scores | get $index} else {0}) | into string
      } else {
        (if ($it | get $c) == 1 {true} else {false}) | into string
      }
    } | str join ','
    $it | reject ...$correct_columns | insert grades $grades 
  }
  | to csv
}

