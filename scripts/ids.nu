open raw_data/contest_dojo/*.csv | get "#" | filter {|i| ($i | into string | str length) > 3} | uniq | sort | each {|i| $"\"($i)\","} | str join "\n" | pbcopy
