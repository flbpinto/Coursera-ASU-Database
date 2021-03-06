﻿-- Cousera - ASU - Data in Database
-- Assignment 2: SQL Query for Movie Recommendation
-- Fernando L B Pinto
--
-- psql -U postgres –f solution.sql -v v1=2

-- #1

DROP TABLE query1 cascade;

CREATE TABLE query1 as (
SELECT name, count(*) as moviecount from movies
JOIN hasagenre ON movies.movieid = hasagenre.movieid 
JOIN genres ON genres.genreid = hasagenre.genreid
group by name);

select * from query1 where name = 'Romance';

-- #2

DROP TABLE query2 cascade;

CREATE TABLE query2 AS (
SELECT genres.name as name, avg(ratings.rating) as rating from movies
JOIN hasagenre ON movies.movieid = hasagenre.movieid 
JOIN genres ON genres.genreid = hasagenre.genreid
JOIN ratings ON ratings.movieid = movies.movieid
group by genres.name ) ;

select * from query2 where name = 'Drama';


-- #3

DROP TABLE query3 cascade;

CREATE TABLE query3 AS
select * from ( SELECT title, count(rating) as CountOfRatings from movies
	LEFT JOIN ratings ON ratings.movieid = movies.movieid
	where ratings.timestamp is not null
	group by title ) AS total
where CountOfRatings >= 10;

select * from query3 where title like '%Sleepy%';


-- #4

DROP TABLE query4 cascade;
CREATE TABLE query4 (movieid int, title text);

INSERT INTO query4 (movieid, title)
SELECT movies.movieid , movies.title from movies
LEFT JOIN hasagenre ON movies.movieid = hasagenre.movieid 
LEFT JOIN genres ON genres.genreid = hasagenre.genreid
where genres.name = 'Comedy';

select * from query4 where title like '%Guide to the Galaxy%';

-- #5

DROP TABLE query5 cascade;

CREATE TABLE query5 AS (
SELECT movies.title as title , avg(ratings.rating) as average from movies
LEFT JOIN hasagenre ON movies.movieid = hasagenre.movieid 
LEFT JOIN ratings ON ratings.movieid = movies.movieid
where ratings.rating is not null
group by movies.title ) ;

select * from query5 where title like '%Where the Heart Is%';

-- #6

DROP TABLE query6 cascade;
CREATE TABLE query6 AS (
select average 
from (	SELECT genres.name as name, avg(ratings.rating) as average from movies
	LEFT JOIN hasagenre ON movies.movieid = hasagenre.movieid 
	LEFT JOIN genres ON genres.genreid = hasagenre.genreid
	LEFT JOIN ratings ON ratings.movieid = movies.movieid
	group by genres.name ) AUX
where name = 'Comedy' ) ;

select * from query6;


-- #7

DROP TABLE query7 cascade;

CREATE TABLE query7 AS (
select avg(SUB.rating) as average
from (	select movies.title as title, genres.name, ratings.rating from movies
	LEFT JOIN hasagenre ON movies.movieid = hasagenre.movieid 
	LEFT JOIN genres ON genres.genreid = hasagenre.genreid
	LEFT JOIN ratings ON ratings.movieid = movies.movieid
	where name = 'Comedy'
	and title in ( select title from movies
		LEFT JOIN hasagenre ON movies.movieid = hasagenre.movieid 
		LEFT JOIN genres ON genres.genreid = hasagenre.genreid
		where name = 'Romance')
	UNION
	select movies.title as title, genres.name, ratings.rating from movies
	LEFT JOIN hasagenre ON movies.movieid = hasagenre.movieid 
	LEFT JOIN genres ON genres.genreid = hasagenre.genreid
	LEFT JOIN ratings ON ratings.movieid = movies.movieid
	where name = 'Romance'
	and title in ( select title from movies
		LEFT JOIN hasagenre ON movies.movieid = hasagenre.movieid 
		LEFT JOIN genres ON genres.genreid = hasagenre.genreid
		where name = 'Comedy')
) as SUB ) ;

select * from query7;

-- #8

DROP TABLE query8 cascade;

CREATE TABLE query8 AS (
select avg(SUB.rating) as average
from (	select movies.title, genres.name, ratings.rating from movies
	LEFT JOIN hasagenre ON movies.movieid = hasagenre.movieid 
	LEFT JOIN genres ON genres.genreid = hasagenre.genreid
	LEFT JOIN ratings ON ratings.movieid = movies.movieid
	where name = 'Romance' and rating is not null
	and title not in ( select title from movies
		LEFT JOIN hasagenre ON movies.movieid = hasagenre.movieid 
		LEFT JOIN genres ON genres.genreid = hasagenre.genreid
		where name = 'Comedy')
) as SUB ) ;

select * from query8; 


-- #9

DROP TABLE query9 cascade;

CREATE TABLE query9 as ( select movieid, rating from ratings where ratings.userid =:v1 );

select * from query9;

-- #10


-- Create table Similarities
DROP TABLE similarities cascade;
CREATE TABLE similarities (movieid1 int, movieid2 int, sim numeric);

INSERT INTO similarities (movieid1, movieid2, sim)
SELECT r1.movieid as movieid1, r2.movieid as movieid2, (1 - (ABS( r1.avg - r2.avg)/5)) as sim
FROM (SELECT movieid, avg(rating) as avg from ratings
	where rating is not null 
	group by movieid ) AS r1 
	JOIN (SELECT movieid, avg(rating)as avg from ratings
		where rating is not null 
		group by movieid ) AS r2 ON r1.movieid <> r2.movieid 
;
-- Calculate Prediction
select sum(sxr) / sum(sim) as P from (
	select movieid1, movieid2, rating, sim, (sim * rating) as sxr  from similarities 
	LEFT JOIN ratings ON ratings.movieid = similarities.movieid1 and ratings.userid =:v1 
	where movieid1 IN (select movieid from ratings where ratings.userid =:v1 )
	and movieid2 IN (select movieid from ratings where ratings.userid =:v1 )
) as base ;

-- Create table Prediction
DROP TABLE prediction cascade;
CREATE TABLE prediction (movieid int, p numeric);

INSERT INTO prediction (movieid, p)
select  movieid1, sum(sxr) / sum(sim) as P from (
	select movieid1, movieid2, rating, sim, (sim * rating) as sxr , userid from similarities 
	LEFT JOIN ratings ON ratings.movieid = similarities.movieid1 and ratings.userid <> 2 
) as base 
group by movieid1;

select * from prediction where movieid = 110;

-- #11

DROP TABLE recommendation cascade;
CREATE TABLE recommendation (title text);

INSERT INTO recommendation (title)
select title from prediction 
LEFT JOIN movies ON movies.movieid = prediction.movieid
where title NOT IN (SELECT DISTINCT title FROM movies 
				LEFT JOIN ratings ON ratings.movieid = movies.movieid 
				where ratings.userid =:v1)
and p > 3.9;

SELECT * from recommendation;


-- #12 # 13

SELECT * from similarities where movieid1 = 3565 and movieid2 = 2026;

--- End Of Script ---















