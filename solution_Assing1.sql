-- Cousera - ASU - Data in Database
-- Assignment 1: Create Movie Recommendation Database
-- Fernando L B Pinto

-- clearing the database
drop table users     cascade ; drop table movies    cascade ; drop table taginfo   cascade ; drop table genres    cascade ;
drop table ratings   cascade ; drop table tags      cascade ; drop table hasagenre cascade ;

-- Creating tables

CREATE TABLE users ( userid int, name varchar(256)
	, PRIMARY KEY(userid));
CREATE TABLE movies (movieid int, title text
	, PRIMARY KEY(movieid));
CREATE TABLE taginfo (tagid int, content varchar(256)
	, PRIMARY KEY(tagid));
CREATE TABLE genres (genreid int, name varchar(30)
	, PRIMARY KEY(genreid));
CREATE TABLE ratings (userid int, movieid int, rating numeric , timestamp bigint not null   
	, FOREIGN KEY (userid) REFERENCES users (userid));
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


-- Testing Import Data
COPY users(userid,name) FROM 'C:\Coursera-ASU-Database\users.dat' DELIMITER '%';
COPY movies(movieid,title) FROM 'C:\Coursera-ASU-Database\movies.dat' DELIMITER '%';
COPY taginfo(tagid,content) FROM 'C:\Coursera-ASU-Database\taginfo.dat' DELIMITER '%';
COPY genres(genreid,name) FROM 'C:\Coursera-ASU-Database\genres.dat' DELIMITER '%';
COPY ratings(userid,movieid,rating,timestamp) FROM 'C:\Coursera-ASU-Database\ratings.dat' DELIMITER '%';
COPY tags(userid,movieid,tagid,timestamp) FROM 'C:\Coursera-ASU-Database\tags.dat' DELIMITER '%';
COPY hasagenre(movieid,genreid) FROM 'C:\Coursera-ASU-Database\hasagenre.dat' DELIMITER '%';

