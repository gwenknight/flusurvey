SELECT country AS country,
       year AS year,
       week AS week,
       CASE WHEN a<20 THEN '<20'
       WHEN a>=20 AND a<45 THEN '20..44'
       WHEN a>=45 AND a<65 THEN '45..64'
       WHEN a>=65 THEN '65++'
       END AS agegroup,
       CASE WHEN riskfree='t' THEN 0
       WHEN riskfree='f' THEN 1
       END AS risk,
       CASE WHEN "Q6_0"='t' OR "Q6_1"='t' THEN 1
       ELSE 0
       END AS children,
       CASE WHEN "Q10"=0 THEN 1
       WHEN "Q10"=1 THEN 0
       END AS vaccinated,
       CASE WHEN "Q7b"=0 THEN 1
       WHEN "Q7b"!=0 THEN 0
       END AS transport,
       count(*) AS participants, count(ili) AS ili, count(non_ili)
       AS non_ili
  FROM (
SELECT extract(year from age(to_timestamp(I."Q2",'YYYY-MM'))) AS a,
       "Q11_0" AS riskfree,
       "Q6_0", "Q6_1",
       I."Q7b", I."Q10",
       NULLIF(S.status = 'ILI', false) AS ili,
       NULLIF(S.status != 'ILI', false) AS non_ili,
       extract(week FROM W.timestamp) AS week,
       extract(year FROM date_trunc('week', W.timestamp)) AS year,
       I.country as country
  FROM epidb_results_intake AS I,
       epidb_health_status_fever AS S,
       epidb_results_weekly AS W
 WHERE I."Q10"<2
   AND S.epidb_results_weekly_id = W.id AND (W."Q2" IS NULL OR W."Q2" != 0)
   AND W.global_id = I.global_id AND extract(year from age(to_timestamp(I."Q2",'YYYY-MM'))) > 0
       ) AS statuses
 GROUP BY country,year,week,agegroup,risk,children,vaccinated,transport
 ORDER BY country,week,agegroup,risk,children,vaccinated,transport;
