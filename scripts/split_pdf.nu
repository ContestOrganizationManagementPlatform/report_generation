#!/usr/bin/env nu

export def main [
  config_file: string,
  input_pdf: string
] {
  let ids = (open $config_file | get config.targets.ids)
  qpdf --split-pages=5 $input_pdf -- output/%d.pdf
  let padding = ($ids | length | into string | str length)
  $ids | enumerate | par-each {|item|
    let start = ($item.index * 5 + 1 | into string | fill -a right -c '0' -w $padding)
    let end = ($item.index * 5 + 5 | into string | fill -a right -c '0' -w $padding)
    mv $"output/($start)-($end).pdf" $"output/score_report_($item.item).pdf"
  }
}
