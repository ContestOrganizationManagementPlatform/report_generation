# Usage

Put grades data in `data` folder.
Expected structure: 
```
- data
  - algebra.csv
    - Rank,ID,Score,Name,HM,grades (looks like "true, false, true, ...")
  - answers.csv (generate with scripts/query_solutions.sql)
    - "id","test_name","problem_number","answer_latex"
  - calculus.csv
    - Rank,ID,Score,Name,HM,grades
  - discrete.csv
    - Rank,ID,Score,Name,HM,grades
  - general.csv
    - Rank,ID,Score,Name,HM,grades
  - geometry.csv
    - Rank,ID,Score,Name,HM,grades
  - guts.csv
    - Rank,ID,Score,Name,Organization,HM,grades (looks like "10,0,0,11,0,11,...")
  - overall.csv
    - Rank,ID,Score,Name,Organization,HM
  - power.csv
    - Rank,ID,Score,Name,Organization,HM
  - team.csv
    - Rank,ID,Score,Name,Organization,HM,grades
```

Then, run `typst compile report.typ`.
To split the pdf into individual reports, run the contents of `scripts/split_pdf.nu` 
(which uses nushell but can be translated to bash).

# Notes

Uses [statastic](https://github.com/Sett17/typst-statastic).
Depends on [typst](https://typst.app/home/) for typesetting, 
[xsv](https://github.com/BurntSushi/xsv) for csv joining,
and [qpdf](https://qpdf.sourceforge.io/) for pdf splitting.
