-- Cousera - ASU - Data in Database
-- Assignment 2: SQL Query for Movie Recommendation
-- Fernando L B Pinto


--psql -U postgres –f "c:\Coursera-ASU-Database\solution.sql" -v v1=2



/*
1. Write a SQL query to return the total number of movies for each genre. Your query result should be saved in a table called “query1” 
which has two attributes: “name” attribute is a list of genres, and “moviecount” list of movie counts for each genre.
*/

DROP TABLE query1 cascade;

CREATE TABLE query1 as (
SELECT name, count(*) as moviecount from movies
JOIN hasagenre ON movies.movieid = hasagenre.movieid 
JOIN genres ON genres.genreid = hasagenre.genreid
group by name);

select * from query1 where name = 'Romance';


/*
2. Write a SQL query to return the average rating per genre. 
Your query result should be saved in a table called “query2” 
which has two attributes: “name” attribute is a list of all genres, and “rating” attribute is a list of average rating per genre.
*/

DROP TABLE query2 cascade;

CREATE TABLE query2 AS (
SELECT genres.name as name, avg(ratings.rating) as rating from movies
JOIN hasagenre ON movies.movieid = hasagenre.movieid 
JOIN genres ON genres.genreid = hasagenre.genreid
JOIN ratings ON ratings.movieid = movies.movieid
group by genres.name ) ;

select * from query2 where name = 'Drama';


/*
3. Write a SQL query to return the movies which have at least 10 ratings. 
Your query result should be saved in a table called “query3” 
which has two attributes: “title” is a list of movie titles, and “CountOfRatings” is a list of ratings.
*/

DROP TABLE query3 cascade;

CREATE TABLE query3 AS
select * from ( SELECT title, count(rating) as CountOfRatings from movies
	LEFT JOIN ratings ON ratings.movieid = movies.movieid
	where ratings.timestamp is not null
	group by title ) AS total
where CountOfRatings >= 10;

select * from query3 where title like '%Sleepy%';


/*
4. Write a SQL query to return all “Comedy” movies, including movieid and title. 
Your query result should be saved in a table called “query4” 
which has two attributes: “movieid” is a list of movie ids, and “title” is a list of movie titles.
*/

DROP TABLE query4 cascade;
CREATE TABLE query4 (movieid int, title text);

INSERT INTO query4 (movieid, title)
SELECT movies.movieid , movies.title from movies
LEFT JOIN hasagenre ON movies.movieid = hasagenre.movieid 
LEFT JOIN genres ON genres.genreid = hasagenre.genreid
where genres.name = 'Comedy';

select * from query4 where title like '%Guide to the Galaxy%';

/*
5. Write a SQL query to return the average rating per movie. 
Your query result should be saved in a table called “query5” 
which has two attributes: “title” is a list of movie titles, and “average” is a list of the average rating per movie.
*/

DROP TABLE query5 cascade;

CREATE TABLE query5 AS (
SELECT movies.title as title , avg(ratings.rating) as average from movies
JOIN hasagenre ON movies.movieid = hasagenre.movieid 
JOIN ratings ON ratings.movieid = movies.movieid
where ratings.rating is not null
group by movies.title ) ;

select * from query5 where title like '%Where the Heart Is%';

/*
6. Write a SQL query to return the average rating for all “Comedy” movies. 
Your query result should be saved in a table called “query6” which has one attribute: “average”.
*/

DROP TABLE query6 cascade;
CREATE TABLE query6 AS (
select average 
from (	SELECT genres.name as name, avg(ratings.rating) as average from movies
	LEFT JOIN hasagenre ON movies.movieid = hasagenre.movieid 
	LEFT JOIN genres ON genres.genreid = hasagenre.genreid
	LEFT JOIN ratings ON ratings.movieid = movies.movieid
	group by genres.name ) AUX
where name = 'Comedy' ) ;

select average from query6;


/*
7. Write a SQL query to return the average rating for all movies and each of these movies is both “Comedy” and “Romance”. 
Your query result should be saved in a table called “query7” which has one attribute: “average”.
*/

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



/*
8. Write a SQL query to return the average rating for all movies and each of these movies is “Romance” but not “Comedy”. 
Your query result should be saved in a table called “query8” which has one attribute: “average”.
*/

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

select average from query8; 


/*
9. Find all movies that are rated by a user such that the userId is equal to v1. 
The v1 will be an integer parameter passed to the SQL query. 
Your query result should be saved in a table called “query9” 
which has two attributes: “movieid” is a list of movieid’s rated by userId v1, 
and “rating” is a list of ratings given by userId v1 for corresponding movieid.
*/

DROP TABLE query9 cascade;

CREATE TABLE query9 as ( select movieid, rating from ratings where ratings.userid =:v1);

select * from query9;

/*
10. Write an SQL query to create a recommendation table* for a given user. 
Given a userID v1, you need to recommend the movies according to the movies he has rated before. 
In particular, you need to predict the rating P of a movie “i” that the user “Ua” didn’t rate. 
In the following recommendation model, P(Ua, i) is the predicted rating of movie i for User Ua. 
L contains all movies that have been rated by Ua. Sim(i,l) is the similarity between i and l. r is the rating that Ua gave to l.
*/

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
	LEFT JOIN ratings ON ratings.movieid = similarities.movieid1 and ratings.userid = 2 
	where movieid1 IN (select movieid from ratings where ratings.userid = 2 )
	and movieid2 IN (select movieid from ratings where ratings.userid = 2 )
) as base ;

-- Create table Prediction
DROP TABLE prediction cascade;
CREATE TABLE prediction (movieid int, p numeric);

INSERT INTO prediction (movieid, p)
select  movieid1, sum(sxr) / sum(sim) as P from (
	select movieid1, movieid2, rating, sim, (sim * rating) as sxr , userid from similarities 
	JOIN ratings ON ratings.movieid = similarities.movieid1 and ratings.userid <> 2 
) as base 
group by movieid1;

select * from prediction where movieid = 110;

select movieid1, movieid2, rating, sim, (sim * rating) as sxr , userid from similarities 
	JOIN ratings ON ratings.movieid = similarities.movieid1 and ratings.userid <> 2 




/*
11. Your SQL query should return predicted ratings from all movies that the given user hasn’t rated yet. 
You only return the movies whose predicted ratings are >3.9. 
Your query result should be saved in a table called “recommendation” which has one attribute: “title”.
*/

DROP TABLE recommendation cascade;
CREATE TABLE recommendation (title text);

INSERT INTO recommendation (title)
select title from prediction 
LEFT JOIN movies ON movies.movieid = prediction.movieid
where title NOT IN (SELECT DISTINCT title FROM movies 
				LEFT JOIN ratings ON ratings.movieid = movies.movieid 
				where ratings.userid =2)
and p > 3.9;

SELECT * from recommendation;


/*
12. In order to produce the recommendation table, you first need to calculate the similarities between every pair of two movies. 
The similarity is equal to the similarity of the average ratings of two movies (average rating over all users, the average ratings in Query 5). 
That means, if the average ratings of two movies are more close, the two movies are more similar. 
The similarity score is a fractional value E [0, 1]. 0 means not similar at all, 1 means very similar. 
To summarize, the similarity between two movies, i and l, is calculated using the equation below. Abs() is to take the absolute value.
*/

select * from similarities where movieid1 = 110;


/*
13. The result of similarity table should look like as follows:
*/

select * from similarities where movieid1 = 3565 and movieid2 = 2026;
select * from similarities where movieid1 = 2026 and movieid2 = 3565;

--- End Of Script ---















