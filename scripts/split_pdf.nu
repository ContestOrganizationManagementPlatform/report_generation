pdfseparate report.pdf output/recombined/%d.pdf
0..(1935 / 5) | par-each {|i| pdfunite $"output/split/($i * 5 + 1).pdf" $"output/split/($i * 5 + 2).pdf" $"output/split/($i * 5 + 3).pdf" $"output/split/($i * 5 + 4).pdf" $"output/split/($i * 5 + 5).pdf" $"output/recombined/($i).pdf"}

let ids = (open config.toml | get config.targets)
for i in 0..(1935 / 5) {mv $"output/recombined/($i).pdf" $"output/recombined/score_report_($ids | get $i).pdf"}
