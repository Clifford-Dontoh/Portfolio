/*  IN THIS PROJECT WE ANALYZE DATA FOR SOCIAL BUZZ, A GROWING SOCIAL MEDIA PLATFORM. 
    THE DATA CONSISTS OF THREE TABLE WHICH WE ARE GOING TO CLEAN, MODEL AND ANALYZE*/


--VIEW CONTENT TABLE

SELECT *
FROM [dbo].[Content]

--TAKE OUT THE COLUMNS THAT WE DO NOT NEED FOR OUR ANALYSIS, IN THIS CASE, THE URL COLUMN

ALTER TABLE [dbo].[Content]
DROP COLUMN [URL]      


--CHECK FOR NULL VALUES

SELECT *
FROM [dbo].[Content]
WHERE [Content ID] IS NULL OR [User ID] IS NULL OR [Type] IS NULL OR  [Category] IS NULL


--RENAME THE "TYPE" COLUMN TO CONTENT_TYPE FOR PRECISION, THIS IS DONE IN THE OBJECT EXPLORER PANE

--VIEW DISTINCT VALUES IN CATEGORY COLUMN

SELECT DISTINCT Category
FROM Content                   -- THERE ARE VALUES IN CATEGORY THAT ARE IN QUOTATION 


SELECT RIGHT(Category,LEN(Category)-1)
FROM Content
WHERE Category LIKE'"%"'        --THIS TAKE OFF THE LEFT QUOTATION 


UPDATE Content
SET Category =
   RIGHT(Category,LEN(Category)-1)
WHERE Category LIKE'"%"'        --EFFECT THE CHANGE IN THE ORIGINAL TABLE


SELECT LEFT(Category,LEN(Category)-1)
FROM Content
WHERE Category LIKE'%"'         --THIS TAKES OFF THE RIGHT QUOTATION MARK


UPDATE Content
SET Category =
   LEFT(Category,LEN(Category)-1)
WHERE Category LIKE'%"'         --EFFECT THE CHANGE IN THE ORIGINAL TABLE




--CLEANING  THE REACTION TABLE


--SELECT THE FULL TABLE

SELECT *
FROM [dbo].[Reactions]



--CHECK FOR NULL VALUES

SELECT *
FROM [Reactions]
WHERE [Content_ID] IS NULL OR [User ID] IS NULL OR [Reaction_type] IS NULL


--ROWS WITH NULL VALUES ARE DELETED

DELETE 
FROM [Reactions]
WHERE [Content_ID] IS NULL OR [User ID] IS NULL OR [Reaction_type] IS NULL


--CLEANING REACTION TYPE TABLE

 SELECT *
 FROM [dbo].[ReactionTypes]      --THERE ARE NO NULL VALUES


 --MERGE ALL THREE TABLES AND SELECT DISTICT COLUMNS

SELECT      Content.[Content_ID], 
             Content.[User ID] AS Poster_ID,  
			 Content.Content_type, 
			 Content.Category, 
			 Reactions.[User ID] AS Reactor_ID, 
			 Reactions.Reaction_type, 
			 ReactionTypes.Sentiment, 
			 ReactionTypes.Score

FROM [dbo].[Content]

JOIN [dbo].[Reactions]
 ON Content.[Content_ID]=Reactions.[Content_ID]

 JOIN [dbo].[ReactionTypes]
 ON [Reactions].Reaction_type=[ReactionTypes].Reaction_type


 --CREATE A TEMP TABLE TO PROCEED WITH NEWLY MERGED TABLE

 CREATE TABLE #temp_usage
              (Content_ID nvarchar(255), 
               Poster_ID nvarchar(255), 
               Content_type nvarchar(255), 
               Category nvarchar(255), 
               Reactor_ID nvarchar(255),
               Reaction_type nvarchar(255), 
               Sentiment nvarchar(255), 
               Score int,
               Datetime datetime)


  SELECT *
  FROM #temp_usage    --TO VIEW THE TEMP TABLE


  --FILL THE TEMP TABLE WITH OUR NEWLY MERGED TABLE

INSERT INTO #temp_usage

 SELECT      Content.[Content_ID], 
             Content.[User ID] AS Poster_ID,  
			 Content.Content_type, 
			 Content.Category, 
			 Reactions.[User ID] AS Reactor_ID, 
			 Reactions.Reaction_type, 
			 ReactionTypes.Sentiment, 
			 ReactionTypes.Score,
			 Datetime

 FROM [dbo].[Content]

 JOIN [dbo].[Reactions]
 ON Content.[Content_ID]=Reactions.[Content_ID]

 JOIN [dbo].[ReactionTypes]
 ON [Reactions].Reaction_type=[ReactionTypes].Reaction_type



 --DATA EXPLORATION


 --HOW MANY INDIVIDUAL USERS DO WE HAVE ON SOCIAL BUZZ

 SELECT COUNT (DISTINCT Poster_ID) AS num_posters
 FROM #temp_usage               --THERE IS A TOTAL OF 438 USERS ON SOCIAL BUZZ WHO HAVE MADE AT LEAST ONE POST


 --HOW MANY POSTS ARE MADE BY EACH USER

 SELECT DISTINCT Poster_ID, 
        COUNT(Poster_ID)  OVER(PARTITION BY Poster_ID) AS num_posts
 FROM #temp_usage
 ORDER BY num_posts DESC        --THE HIGHEST NUMBER OF POSTS MADE BY A USER IS 200 (72d2587e-8fae-4626-a73d-352e6465ba0f)


 --WHAT ARE THE SCORES BY EACH USER

 SELECT DISTINCT Poster_ID, 
        SUM(Score)  OVER(PARTITION BY Poster_ID) AS total_score
 FROM #temp_usage
 ORDER BY total_score DESC      --HIGHEST SCORE BY A USER IS 7,964 (72d2587e-8fae-4626-a73d-352e6465ba0f)


 --WHAT CONTENT TYPE HAS THE HIGHEST SCORE

 SELECT DISTINCT Content_type, 
        SUM(Score) OVER(PARTITION BY Content_type) AS popularity
 FROM #temp_usage
 ORDER BY popularity DESC       --PHOTO HAS THE HIGHEST POPULARITY


 --WHAT CATEGORY OF CONTENT IS MOST POPULAR

 SELECT DISTINCT Category, SUM(Score) OVER(PARTITION BY Category) AS category_popularity
 FROM #temp_usage
 ORDER BY category_popularity DESC  --MOST POPULAR CATEGORY OF CONTENT IS ANIMALS


 --WHAT SENTIMENT DO WE GET THE MOST OF

 SELECT DISTINCT Sentiment, 
        COUNT(Sentiment) OVER(PARTITION BY Sentiment) num_reaction, 
		SUM(Score) OVER(PARTITION BY Sentiment) AS sum_score
 FROM #temp_usage_data2
 ORDER BY sum_score DESC           --GENERALLY SOCIAL BUZZ IS PROVIDES A POSITIVE ENVIRONMENT FOR USERS


 /* IN SUMMARY 
 -SOCIAL BUZZ PROVIDES A  POSITIVE ENVIRONMENT FOR 400 USERS
 - USER (72d2587e-8fae-4626-a73d-352e6465ba0f) HAS THE HIGHEST NUMBER OF POSTS AND THE HIGHEST SCORE. 
   HE CAN BE CONSIDERED FOR FUTURE SOCIAL MEDIA CAMPAIGNS
 - CONTENTS ABOUT ANIMALS HAVE THE HIGHEST POPULARITY AND ARE IN THE FORM OF PICTURES, 
   HENCE ANY CAMPAIGN OR ADVERTISEMENT CAN BE BUILT AROUND IMAGES OF ANIMALS*/





   





