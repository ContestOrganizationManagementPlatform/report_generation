#!/usr/bin/env nu

# Usage: ./scripts/stats.nu raw_data/scores_and_ranks data/stats -f
# Calculates statistics on each test and outputs to the specificed directory as json.
export def main [
  scores_and_ranks_directory: string,
  output_directory: string,
  --force (-f),
] {
  for f in ["geometry", "general", "discrete", "calculus", "algebra", "team", "guts", "overall", "power"] {
    let scores_path = ([[parent stem extension]; [$scores_and_ranks_directory, $f, "csv"]] | path join).0
    let out_path = ([[parent stem extension]; [$output_directory, $"($f)", "json"]] | path join).0
    let scores = (open $scores_path | get "Score" | sort)
    let output = {
      first_quartile: (calculate_fraction $scores 0.25),
      median: (calculate_fraction $scores 0.5),
      third_quartile: (calculate_fraction $scores 0.75),
      stddev: ($scores | math stddev -s),
      top_10_percent: (calculate_fraction $scores 0.9),
    }

    $output | to json | if $force { save $out_path -f } else {save $out_path }
  }
}

def calculate_fraction [
  sorted_values: list,
  fraction: float,
] {
  let pos = (($sorted_values | length) - 1) * $fraction
  if ($pos | describe) == "int" {
    $sorted_values | get $pos
  } else {
    lerp $sorted_values $pos
  }
}

def lerp [
  values: list,
  position: float,
] {
  let min = $values | get ($position | math floor)
  let max = $values | get ($position | math ceil)
  let fractional = ($position - ($position | math floor))
  $min * (1 - $fractional) + $max * $fractional
}

