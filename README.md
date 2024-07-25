# Usage

Put downloaded grades from contest dojo, answer csv from supabase, team registration csv,
and scores and ranks csv into `raw_data` folder.

Expected structure: 
```
- raw_data
  - scores_and_ranks
    - algebra.csv
      - Rank,ID,Score,Name,...
    - discrete.csv
      - similar ...
    - ...
  - contest_dojo
    - team.csv
      - ID,#,Team Name,Score,C1,C2, ...
    - algebra.csv
      - " Student ID",#," Student Name",C1,C2, ...
    - ...
  - team_registration.csv
    - id,number,name,org_id, ...
  - answers.csv
    - id,test_name,problem_number,answer_latex
- data
  - joined (directory)
  - stats (directory)
  - contest_dojo_grades (directory)
```

If you have nushell and xsv installed, run the scripts with the below.
```
scripts/cd_to_grades.nu raw_data/contest_dojo/ data/contest_dojo_grades/
scripts/stats.nu raw_data/scores_and_ranks/ data/stats
scripts/join.nu data/contest_dojo_grades/ raw_data/scores_and_ranks/ data/joined/
```

Select which students for which to generate a report in config.toml.

Then, run `typst compile report.typ`.
To split the pdf into individual reports, run the contents of `scripts/split_pdf.nu` 
(which uses nushell but can be translated to bash).

# Notes

Uses [statastic](https://github.com/Sett17/typst-statastic).
Depends on [typst](https://typst.app/home/) for typesetting, 
[xsv](https://github.com/BurntSushi/xsv) for csv joining,
and [qpdf](https://qpdf.sourceforge.io/) for pdf splitting.
