#!/usr/bin/env nu

# Some emails were already sent out, so remove those.
let finished_winners = (cat ../raw_data/autocrat_certificates.csv
  | from csv --no-infer
  | where {|it| $it."Document Merge Status - Email Achievement Certificates" | str contains "Emails Sent"}
)

^echo "Not including" ($finished_winners | length) "already sent out certificates."

let finished = $finished_winners
  | each {|it| $it.email + $it.subject}

# data={"email": "banana@gmail.com", "name": "NAME", "achievements": [{"award": "PARTICIPATION", "test": ""}, {"award": "HONOURABLE MENTION", "test": "Algebra"}]}
let achievement_winners = (cat ../data/certificates.csv
  | from csv --no-infer
  | group-by {|it| $it.email + $it.subject}
  | reject ...$finished 
  | values 
  | each {|it| $it | get 0} 
  | group-by {|it| $it.email}
 )

^echo "There are" ($achievement_winners | columns | length) "other certificate winners."

# Some people didn't capitalize their names in title case (all upper, typos, etc).
def title_case_name [data] {
  mut d = $data
  $d.name = ($d.name | str title-case)
  $d
}

def render_pdf [data] {
    if ($data.email | str contains "/") {
      panic $"Email '($data.email)' contains '/' and will break paths."
    }
    # typst compile --font-path Oswald/ --input $"data=((title_case_name $data) | to json)" certificate.typ $"output/($data.email).pdf"
}

$achievement_winners
  | transpose key value 
  | each {|kv| 
    {email: $kv.key, name: ($kv.value | get 0 | get name), achievements: ($kv.value | each {|it| {award: $it."achievement", test: $it.subject}})} 
  } 
  | par-each {|data| render_pdf $data }

# Ignore the already sent out achievements and just send participation if they didn't get a new achievement.
let all_achievement_winners = ($achievement_winners | columns) | group-by {|it| $it}
# let all_achievement_winners = ($finished_winners | get email) | append ($achievement_winners | columns) | group-by {|it| $it}

let participation_winners = (cat ../raw_data/online_individual.csv 
  | from csv --no-infer 
  | where {|it| (($all_achievement_winners | get -i ($it | get email)) == null)})


^echo "There are" ($participation_winners | length) "participation obtainers."
  
$participation_winners
  | each {|it| {email: $it.Email, name: ($it."First Name" + " " + $it."Last Name"), achievements: [{"award": "PARTICIPATION", test: ""}]}}
  | par-each {|data| render_pdf $data }
  | null

