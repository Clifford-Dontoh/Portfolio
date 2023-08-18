/* THIS ANALYSIS WAS DONE ON DATA CONTAINING TOP 10000 SONGS WITH THE HIGHEST NUMBER OF STREAMS ON SPOTIFY

   QUESTIONS TO BE ANSWERED ARE AS FOLLOWS:
   - HOW MANY ARTISTES HAVE SONGS ON SPOTIFY?
   - WHO ARE THE TOP 10 ARTISTES WITH THE HIGHEST NUMBER OF SONGS ON THIS LIST?
   - WHO ARE THE TOP 10 ARTISTES WITH THE HIGHEST NUMBER OF SONGS IN THE TOP 10 CHARTS AND HOW MANY TIMES HAS EACH SONG BEEN ON THE TOP 10?
   - WHO ARE THE TOP 10 ARTISTES WITH THE HIGHEST NUMBER OF SONGS RANKING NO.1 ON THE CHARTS?
   - WHICH SONG HAS THE LONGEST STREAK ON THE NO1 SPOT ON THE CHARTS?
   - WHO ARE THE TOP 10 ARTISTES WITH THE HIGHEST NUMBER OF STREAMS FOR EACH SONG FOR EACH DAY*/



SELECT *
FROM [Spotify].[dbo].[Spotify_final_dataset]       --TO VIEW THE FULL DATA


SELECT COUNT(DISTINCT([Artist Name]))
FROM [dbo].[Spotify_final_dataset]                 --1608 ARTISTES HAVE THEIR SONGS ON SPOTIFY


SELECT TOP (10) [Artist Name], 
       COUNT([Song Name]) AS No_of_songs
FROM [dbo].[Spotify_final_dataset]
GROUP BY [Artist Name]
ORDER BY No_of_songs DESC                          --DRAKE TOPS THE CHART WITH 208 SONGS AND YOUNBOY NEVER BROKE AGAIN COMES 10TH WITH 89 SONGS


SELECT TOP (10) [Artist Name],
       COUNT([Song Name]) AS Songs_in_top10, 
	   SUM([Top 10 (xTimes)])/COUNT([Song Name]) AS No_of_top10_per_song
FROM [dbo].[Spotify_final_dataset]
WHERE [Top 10 (xTimes)] > 0
GROUP BY [Artist Name]
ORDER BY Songs_in_top10 DESC,
         No_of_top10_per_song DESC                 /* DRAKE TOPS THE CHART AGAIN WITH 88 DIFFERENT SONGS BEING IN THE TOP 10 AND EACH SONG 
		                                             HAS BEEN IN THE TOP 10 AN AVERAGE OF 26 TIMES 
													 LIL UZI VERT COMES 10TH WITH 27 SONGS BEING IN THE TOP 10 WITH EACH SONG BEING IN THE TOP 10 AN AVERAGE OF 15 TIMES*/




SELECT TOP(10) [Artist Name],
       COUNT([Artist Name]) AS NO_OF_SONGS_ON_NO1, 
	   ROUND(AVG([Peak Position Times]),0) AS AVG_NO_OF_TIMES_ON_NO1
FROM [dbo].[Spotify_final_dataset]
GROUP BY [Artist Name],
         [Peak Position]
HAVING MIN([Peak Position]) = 1
ORDER BY  NO_OF_SONGS_ON_NO1 DESC                   /*AMAZING DRAKE TOPS THE CHART AGAIN WITH 18 SONGS RANKING N01 WITH 
                                                      EACH SONG TOPPING THE CHART AN AVERAGE OF 22 TIME
													  KANYE WEST COMES 10TH WITH 5 SONGS HAVING EACH SONG TOPPING AN AVERAGE OF 5 TIMES
													  
													  HAS DRAKE ALWAYS BEEN THE BEST? HOW HAS HIS SONGS GROWN FROM THE FIRST SONG POSTED TO THE LATEST*/



SELECT [Song Name],
       [Days],
	   MIN([Peak Position]) AS BEST_RANK,
	   [Total Streams]
FROM [dbo].[Spotify_final_dataset]
WHERE [Artist Name] = 'Drake'
GROUP BY [Song Name],
         [Days],
		 [Total Streams]
ORDER BY Days DESC                                 --A TREND OF THE PERFORMANCE OF DRAKE'S  SONGS WOULD BE BEST SEEN WHEN VISUALIZED 


SELECT TOP (10) [Song Name],
       [Artist Name],
       MIN([Peak Position]), 
	   SUM([Peak Position Times]) NO1_STREAK
FROM [dbo].[Spotify_final_dataset]
GROUP BY [Song Name],
         [Artist Name]
HAVING MIN([Peak Position]) = 1
ORDER BY SUM([Peak Position Times]) DESC             /*POST MALONE WITH THE LONGEST STREAK AS NO1 WITH HIS SONG "ROCKSTAR"
                                                       RIHANNA COMES 10TH WITH WORK TOPPING 62 TIMES
													   CAN SOMEBODY SEE DRAKE?? LOL */



SELECT [Artist Name],
       ROUND(SUM([Days])/COUNT([Song Name]),0) AS DAYS_PER_SONG, 
	   SUM([Total Streams]) AS TOTAL_STREAMS, 
	   ROUND((SUM([Total Streams])/SUM([Days])/COUNT([Song Name])),0) AS STREAMS_PER_DAY_PER_SONG

FROM [dbo].[Spotify_final_dataset]
GROUP BY [Artist Name]
ORDER BY  STREAMS_PER_DAY_PER_SONG DESC             --KATE BUSH HAS AN AVERAGE OF 895,OOO PLUS STREAMS ON EACH OF HER SONGS EVERY DAY



/*NOW THAT ALL QUESTIONS HAVE BEEN ANSWERED, LET'S HEAD INTO TABLEAU TO CREATE OUR VISUALIZATIONS*/






