xsv join ID data/team.csv Name `~/Downloads/smt_score_csvs/Team.csv` | xsv select 'Rank,ID,Score,Name,Organization,HM,Grades'
xsv join ID data/guts.csv Name `~/Downloads/smt_score_csvs/Guts.csv` | xsv select 'Rank,ID,Score,Name,Organization,HM,19-'
xsv join ID data/general.csv Name `~/Downloads/smt_score_csvs/General.csv` | xsv select 'Rank,ID,Score,Name,HM,Grades'
