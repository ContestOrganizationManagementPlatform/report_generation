#import "@preview/mitex:0.2.2": *
#import "./statastic.typ": *

#let check_csvs = (csvs) => {
  // TODO: check if csvs have correct fields.
}

#let config = toml("config.toml").config
#let csvs_path = config.csvs_path
#let create_dict = (k, v) => {
  let dict = (:)
  dict.insert(k, v)
  dict
}
#let answers = csv(csvs_path + "/answers.csv")
#let answers_map = (:)
#for row in answers.slice(1) {
  let answers = answers_map.at(lower(row.at(1)), default: ())
  answers.push(row.at(3))
  answers_map.insert(lower(row.at(1)), answers)
}
#let csvs = ("overall", "algebra", "calculus", "discrete", "general", "geometry", "guts", "power", "team").map(key => {
  create_dict(key, csv(csvs_path + "/" + key + ".csv"))
}).sum()
#let id_map = (:)
#for (test, id_data) in csvs.pairs().map(((test, csv_data)) => {
	let keys = csv_data.at(0)
  let id_index = keys.position(k => k =="ID")
  (test, csv_data.slice(1).map(row => {
    create_dict(row.at(id_index), keys.zip(row).map(((k, v)) => {
      create_dict(k, v)
    }).sum())
  }).sum())
}) {
  for (id, data) in id_data {
    let entry = id_map.at(id, default: (:))
    entry.insert(test, data)
    id_map.insert(id, entry)
  }
}

#set page(height: 11in, width: 8.5in)
#let dark_red = rgb(119, 24, 14).lighten(10%)

#let get_message = (id) => {
  let name = id_map.at(id).values().first().Name

  [
    Dear #name,

    Thank you again for your participation in SMT 2024! We loved seeing you at our competition, and we hope to see you again at SMT 2025! Before we get to your score report, we have a few notes.

  	First, our answer for Team \#1 was incorrect. We had marked the answer as 729, but the correct answer was 728. We apologize for the error, and we have notified any teams whose final placements were affected.

  	Second, for the winners of the special awards, as well as the top scorers, check out our Closing Ceremony Slides.

  	Finally, if you have any questions—either about the score report or the tournament in general—please contact us at #link("stanford.math.tournament@gmail.com").

  	Please enjoy your score report for SMT 2024!
  ]
}

#let get_team_test = (team_id) => {
  let data = id_map.at(team_id)

  align(center, [
    #set text(size: 15pt, fill: dark_red)
    *Team Tests Summary*
  ])
  figure(table(columns: (1fr, 1fr, 1fr), inset: 10pt,
    "", [*Score*], [*Rank*], 
    "SMT Index", [#calc.round(float(data.overall.Score), digits: 2)], data.overall.Rank,
    "Power", data.power.Score, data.power.Rank,
    "Guts", data.guts.Score, data.guts.Rank,
    "Team", data.team.Score, data.team.Rank,
  ))
}

#let capitalize = (string) => {
  if string.len() > 0 {
    upper(string.slice(0, 1)) + string.slice(1)
  } else {
    string
  }
}

#let get_individual_tests = (id) => {
  align(center, [
    #set text(size: 15pt, fill: dark_red)
    *Individual Tests Summary*
  ])

  figure(table(columns: (1fr, 1fr), inset: 10pt,
    "", [*Score*], 
    ..id_map.at(id).pairs().map(((test, data)) => {
      (capitalize(test), data.Score)
    }).flatten()
  ))
}

#let get_overall_statistics = () => {
  align(center, [
    #set text(size: 15pt, fill: dark_red)
    *Overall Statistics*
  ])

  set text(size: 9pt)
 
  figure(table(columns: (1fr,) * 7, inset: 10pt,
    "", [*1st Quartile*], [*Median*], [*3rd Quartile*], [*Standard Deviation*], [*HM (top 25%) Cutoff*], [*DHM (top 10%) cutoff*], 
    ..csvs.pairs().map(((test, data)) => {
      let parse_data = data.slice(1).map(d => float(d.at(2)))
      let stats = arrayStats(parse_data)
      if test == "overall" {
        test = "SMT Index"
      }
      (
        capitalize(test), 
        stats.at("25percentile"), 
        stats.at("median"), 
        stats.at("75percentile"), 
        stats.std, 
        stats.at("75percentile"), 
        arrayPercentile(parse_data, 0.9)
      ).map(v => {
        if type(v) == float {
          v = calc.round(v, digits: 2)
        }
        [#v]
      })
  }).flatten()))
}

#let get_team_breakdown = (team_id) => {
  align(center, [
    #set text(size: 15pt, fill: dark_red)
    *Team Breakdown*
  ])

  figure(table(columns: (1fr, 1fr, 1fr), inset: 10pt,
    [*Problem Number*], [*Correct Answer*], [*Correct?*],
    ..id_map.at(team_id).team.Grades.split(",").zip(answers_map.at("team")).enumerate().map(((i, (correct, answer))) => {
      (str(i + 1), mi(answer), capitalize(str(correct)))
    }).flatten()
  ))
}

#let split_at = (arr, i) => {
  (arr.slice(0, i), arr.slice(i))
}
#let intersperse = (a1, a2, default) => {
  range(calc.max(a1.len(), a2.len())).map((i) => {
    (a1.at(i, default: default), a2.at(i, default: default))
  }).flatten()
}

#let get_guts_breakdown = (team_id) => {
  align(center, [
    #set text(size: 15pt, fill: dark_red)
    *Guts Breakdown*
  ])
  
  let (t1, t2) = split_at(id_map.at(team_id).guts.pairs().filter(((k, _)) => {k.starts-with("Problem")}).map(((_, v)) => v).zip(answers_map.at("guts")).enumerate().map(((i, (score, answer))) => {
    (str(i + 1), mi(answer), score)
  }), calc.ceil(answers_map.at("guts").len() / 2))
  table(columns: (1fr, 1fr, 1fr) * 2, inset: 10pt,
    table.vline(x: 3, stroke: 2pt),
    table.header(repeat: true, ..(([*Problem Number*], [*Correct Answer*], [*Score*]) * 2)),
    ..(intersperse(t1, t2, ("", "", "")).flatten()),
  )
}

#let get_individual_breakdown = (id) => {
  let (title, test_names, t1, t2) = if id_map.at(id).at("general", default: none) != none {
    let (t1, t2) = split_at(id_map.at(id).general.Grades.split(",").zip(answers_map.at("general")).enumerate().map(((i, (correct, answer))) => {
      (str(i + 1), mi(answer), capitalize(str(correct)))
    }), calc.ceil(answers_map.at("general").len() / 2))
    ("Individual Test Breakdown", ("General Test", ), t1, t2)
  } else {
    let tests = id_map.at(id).keys()
    ("Individual Tests Breakdown", tests.map(t => capitalize(t) + " Test"), ..id_map.at(id).keys().map((test) => {
      id_map.at(id).at(test).Grades.split(",").zip(answers_map.at(test)).enumerate().map(((i, (correct, answer))) => {
        (str(i + 1), mi(answer), capitalize(str(correct)))
      })
    }))
  }
  align(center, [
    #set text(size: 15pt, fill: dark_red)
    *#title*
  ])

  table(columns: (1fr, 1fr, 1fr) * 2, inset: 10pt,
    ..if test_names.len() == 1 {
      (table.cell(colspan: 6, align(center, [*#test_names.first()*])),)
    } else {
      test_names.map(t => table.cell(colspan: 3, align(center, [*#t*])))
    },
    table.vline(x: 3, stroke: 2pt),
    ..(([*Problem Number*], [*Correct Answer*], [*Correct?*]) * 2),
    ..(intersperse(t1, t2, ("", "", "")).flatten()),
  )
}

#let layout_student = (id) => {
  let team_id = id.slice(0, 3)
  let team_name = id_map.at(team_id).team.Name
  let name = id_map.at(id).values().first().Name

  figure(image(config.logo_path, width: 50%))
  align(center, [
    #set text(size: 16pt)
    *#team_name* \
    *#name* \
    *SMT 2024 Score Report* \
    April 13, 2024
  ])

  get_message(id)
  pagebreak(weak: true)

  get_team_test(team_id)
  get_individual_tests(id)
  get_overall_statistics()
  pagebreak(weak: true)

  get_team_breakdown(team_id)
  pagebreak(weak: true)

  get_guts_breakdown(team_id)
  pagebreak(weak: true)

  get_individual_breakdown(id)
  pagebreak(weak: true)
}

#for id in config.targets.slice(0, 10) {
// #for id in config.targets {
  layout_student(id)
}



#check_csvs(csvs)
