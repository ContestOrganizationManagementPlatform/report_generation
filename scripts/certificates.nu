#!/usr/bin/env nu

use std assert

# Usage: ./scripts/certificates.nu raw_data/online_individual.csv raw_data/scores_and_ranks data/stats data/certificates.csv - f
# Uses the calculated stats to determine who gets which certificate.
export def main [
  individual_registrations: path,
  scores_and_ranks_directory: path,
  stats_directory: path,
  output_file: path,
  --force (-f),
] {
  let students = (load_students $individual_registrations)
  # Add a newline.
  ^echo ""
  # let output = ["geometry", "general", "discrete", "calculus", "algebra", "team", "guts", "overall", "power"] 
  let output = ["geometry", "general", "discrete", "calculus", "algebra"] 
  | each {|f|
    let stats = open ([[parent stem extension]; [$stats_directory, $"($f)", "json"]] | path join).0
    let scores_path = ([[parent stem extension]; [$scores_and_ranks_directory, $f, "csv"]] | path join).0
    let out = cat $scores_path 
      | from csv --no-infer
      | filter {|result| ($result.Score | into float) >= $stats.third_quartile} 
      | each {|result| 
        let achievement = if ($result.Score | into float) >= $stats.top_10_percent {
          "Distinguished Honorable Mention"
        } else {
          "Honorable Mention"
        }
        assert ((($result.ID | str length) == 3) or (($result.ID | str length) == 4)) "Expected all ID's to be of length 3 or 4"
        let target_students = if ($result.ID | str length) == 4 {
          [($students | get ($result.ID | str substring 0..3) | get ($result.ID | str substring 3..4))]
        } else if ($result.ID | str length) == 3 {
          $students | get $result.ID | values
        }
        $target_students | each {|target| 
          [[name, achievement, subject, email]; [$target.name, $achievement, ($f | str title-case), $target.email]]
        }
      } | flatten;
      ^echo $f "accounts for" ($out | length) "certificates"
      $out
    }
  | flatten 
  | reduce {|value, acc| $acc | append $value }

  ^echo ""
  ^echo $"Total: ($output | length) certificates"

  $output
  | to csv 
  | if $force { save $output_file -f } else { save $output_file }
}

def get_name [student] {
  (if ($student | get -i "First Name") == null { "" } else {
    ($student | get "First Name" | into string) + " "
  }) + ($student | default "" "Last Name" | get "Last Name")
}

def load_students [
  individual_registrations: path,
] {
  open $individual_registrations | compact "Number" --empty | reduce --fold {} {|student, output| 
    let id = $student."Number"
    let team_id = $id | str substring 0..3
    let subteam_id = $id | str substring 3..4
    let name = (get_name $student | str title-case)
    let email = $student.Email
    
    # Sometimes contest dojo front id's are not unique! Log for later inspection.
    if ($output | default {} $team_id | get $team_id -i) != null {
      if ($output | default {} $team_id | get $team_id | get $subteam_id -i ) != null {
        ^echo $id $name "replacing" ($output | get $team_id | get $subteam_id | get "name")
      }
    }

    let updated_team = $output 
      | default {} $team_id 
      | get $team_id 
      | upsert $subteam_id {name: $name, email: $email}
    
    $output | upsert $team_id $updated_team
  }
}
