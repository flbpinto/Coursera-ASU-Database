-- Cousera - ASU - Data in Database
-- Assignment 2: SQL Query for Movie Recommendation
-- Fernando L B Pinto

-- Drop TABLE

DROP TABLE query1 cascade;
DROP TABLE query2 cascade;
DROP TABLE query3 cascade;
DROP TABLE query4 cascade;
DROP TABLE query5 cascade;
DROP TABLE query6 cascade;
DROP TABLE query7 cascade;
DROP TABLE query8 cascade;
DROP TABLE query9 cascade;
DROP TABLE similarities cascade;
DROP TABLE recommendation cascade;
DROP TABLE prediction cascade;


-- #1
select * from query1 where name = 'Romance';
-- #2
select * from query2 where name = 'Drama';
-- #3
select * from query3 where title like '%Sleepy%'
-- #4
select * from query4 where title like '%Guide to the Galaxy%'
-- #5
select * from query5 where title like '%Where the Heart Is%';
-- #6
select * from query6;
-- #7 
select * from query7; 
-- #8
select * from query8; 
-- #9
select * from query9;
-- #10
select sum(sxr) / sum(sim) as P from (
	select movieid1, movieid2, rating, sim, (sim * rating) as sxr  from similarities 
	LEFT JOIN ratings ON ratings.movieid = similarities.movieid1 and ratings.userid = 2 
	where movieid1 IN (select movieid from ratings where ratings.userid = 2 )
	and movieid2 IN (select movieid from ratings where ratings.userid = 2 )
) as base ;

select * from prediction;
-- 11
SELECT * from recommendation;
-- #12
select * from similarities where movieid1 = 110
-- #13
select * from similarities where movieid1 = 3565 and movieid2 = 2026;

















