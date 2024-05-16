select
  tests.id,
  tests.test_name,
  test_problems.problem_number,
  trim(replace(replace(problems.answer_latex, chr(13), ''), chr(10), '')) as answer_latex
from
  public.tests
  left join public.test_problems on tests.id = test_problems.test_id
  left join problems on problems.id = test_problems.problem_id
where
  tests.tournament_id = 1
order by
  tests.id,
  test_problems.problem_number;
