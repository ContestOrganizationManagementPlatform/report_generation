#!/usr/bin/env nu

# Usage: ./scripts/join.nu data/contest_dojo_grades raw_data/scores_and_ranks data/joined -f
# where contest_dojo_grades is populated by cd_to_grades.
export def main [
  grades_directory: string,
  scores_and_ranks_directory: string,
  output_directory: string,
  --force (-f),
] {
  for f in ["geometry", "general", "discrete", "calculus", "algebra", "team", "guts"] {
    let grades_path = ([[parent stem extension]; [$grades_directory, $f, "csv"]] | path join).0
    let scores_path = ([[parent stem extension]; [$scores_and_ranks_directory, $f, "csv"]] | path join).0
    let out_path = ([[parent stem extension]; [$output_directory, $f, "csv"]] | path join).0
    xsv join ID $grades_path ID $scores_path | xsv select 'Rank,ID,Score,Name,Organization,HM,grades' 
    | if $force { save $out_path -f } else {save $out_path }
  }
}

