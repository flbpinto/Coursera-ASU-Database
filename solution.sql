-- Cousera - ASU - Data in Database
-- Assignment 1: Create Movie Recommendation Database
-- Fernando L B Pinto

drop table users     cascade ; drop table movies    cascade ; drop table taginfo   cascade ; drop table genres    cascade ;
drop table ratings   cascade ; drop table tags      cascade ; drop table hasagenre cascade ;

CREATE TABLE users ( userid int, name varchar(256)
	, PRIMARY KEY(userid));
CREATE TABLE movies (movieid int, title varchar(256)
	, PRIMARY KEY(movieid));
CREATE TABLE taginfo (tagid int, content varchar(256)
	, PRIMARY KEY(tagid));
CREATE TABLE genres (genreid int, name varchar(30)
	, PRIMARY KEY(genreid));
CREATE TABLE ratings (userid int, movieid int, rating float , timestamp bigint not null   
	, FOREIGN KEY (userid ) REFERENCES users (userid));
ALTER TABLE ratings 
	ADD CONSTRAINT ratings_movieid FOREIGN KEY (movieid) REFERENCES movies (movieid);
CREATE TABLE tags (userid int, movieid int, tagid int, timestamp bigint not null    
	, FOREIGN KEY (userid) REFERENCES users (userid));
ALTER TABLE tags 
	ADD CONSTRAINT tags_movieid FOREIGN KEY (movieid) REFERENCES movies (movieid);
ALTER TABLE tags 
	ADD CONSTRAINT tags_taginfo FOREIGN KEY (tagid) REFERENCES taginfo (tagid);
CREATE TABLE hasagenre (movieid int, genreid int
	, FOREIGN KEY (genreid) REFERENCES genres (genreid));
ALTER TABLE hasagenre 
	ADD CONSTRAINT hasagenre_genreid FOREIGN KEY (genreid) REFERENCES genres (genreid);
/*

CHECK(RATING>=0 AND RATING<=5)

COPY users(userid,name)
FROM 'https://github.com/jiayuasu/Coursera-ASU-Database/blob/master/course1/assignment1/exampleinput/users.dat'
--BUNARY DELIMITER '%'
   ;
*/
