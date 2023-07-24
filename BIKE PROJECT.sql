--WELCOME TO MY FIRST SQL PORTFOLIO PROJECT. IN THIS PROJECT, WE LOOK INTO MOTORBIKE PURCHASES AND FACTORS THAT AFFECT SUCH PURCHASES.
--DATA WAS OBTAINED FROM ALEX FREIBURG
--THIS PROJECT WAS COMPLETED IN GOOGLE SHEET SO I DECIDED TO PERFORM THE SAME ANALYSIS USING SQL


--VIEW FULL DATA
Select *
From  [dbo].[Data$]


--REMOVE DUPLICATE ROWS

WITH row_count AS  
     (SELECT *,
             ROW_NUMBER () OVER (PARTITION BY Age,
                                              Occupation,
                                              Children,
                                              Region,
                                              ID
                                    ORDER BY  ID) AS row_num
      FROM [dbo].[Data$])                  

DELETE
FROM row_count
WHERE row_num >1                      --TO CREATE A CTE TO IDENTIFY DUPLICATE ROWS AND DELETE THEM


-- CHANGE GENDER VALUES FROM SINGLE LETTERS TO FULL WORDS

SELECT DISTINCT(Gender)
FROM [dbo].[Data$]                     --TO VIEW UNIQUE GENDER VALUES

SELECT *,
       CASE WHEN Gender = 'F' THEN 'Female'
            WHEN Gender = 'M' THEN 'Male'
       ELSE Gender END AS New_Gender
FROM  [dbo].[Data$]                     --TO CREATE NEW COLUMN WITH GENDER VALUES IN FULL

UPDATE [dbo].[Data$]
SET Gender =
    CASE WHEN Gender = 'F' THEN 'Female'
         WHEN Gender = 'M' THEN 'Male'
    ELSE Gender END                -- TO REPLACE OLD VALUES IN COLUMN WITH NEW ONES


 --CHANGE MARITAL STATUS VALUES FROM SINGLE LETTERS TO FULL WORDS

SELECT *,
       CASE WHEN [Marital Status] = 'M' THEN 'Married'
            WHEN [Marital Status] = 'S' THEN 'Single'
       ELSE [Marital Status] END AS New_Marital_Status
FROM [dbo].[Data$]                       --TO CREATE NEW COLUMN WITH MARITAL STATUS VALUES IN FULL WORDS

UPDATE [dbo].[Data$]
SET [Marital Status] =
    CASE WHEN [Marital Status] = 'M' THEN 'Married'
         WHEN [Marital Status] = 'S' THEN 'Single'
    ELSE [Marital Status] END       -- TO REPLACE OLD VALUES WITH NEW ONES



--GROUP COMMUTE DISTANCE

SELECT DISTINCT [Commute Distance]
FROM [dbo].[Data$]                         --TO SELECT UNIQUE COMMUTE DISTANCE VALUES

SELECT CASE WHEN [Commute Distance] = '0-1 Miles' THEN 'Very Close'
            WHEN [Commute Distance] = '1-2 Miles' THEN 'Close'
            WHEN [Commute Distance] = '2-5 Miles' THEN 'Moderate'
            WHEN [Commute Distance] = '5-10 Miles' THEN 'Far'
       ELSE 'Very Far' END
FROM [dbo].[Data$]                          --TO GROUP COMMUTE DISTANCE

UPDATE [dbo].[Data$]
SET [Commute Distance] =
    CASE WHEN [Commute Distance] = '0-1 Miles' THEN 'Very Close'
         WHEN [Commute Distance] = '1-2 Miles' THEN 'Close'
         WHEN [Commute Distance] = '2-5 Miles' THEN 'Moderate'
         WHEN [Commute Distance] = '5-10 Miles' THEN 'Far'
    ELSE 'Very Far' END              --TO UPDATE THE COLUMN WITH GROUPED VALUES


-- GROUP AGE

ALTER TABLE [dbo].[Data$]
ADD new_age VARCHAR(20);                     --ADD A NEW COLUMN TO THE TABE WITH VARCHAR DATA TYPE

UPDATE [dbo].[Data$]
SET new_age =
    CASE WHEN age < 40 THEN 'Adult'
         WHEN age BETWEEN 40 AND 55 THEN 'Middle_age'
    ELSE 'Old' END;            --FILL THE NEW COLUMN WITH AGE GROUPING



--WE BEGIN OUR DATA EXPLORATION FOR INSIGHTS


--WE FIRST COMPARE INCOME BETWEEN GENDER AND ITS IMPACT ON BIKE PURCHASES

WITH yes_gender AS
    (SELECT DISTINCT ([Gender]),
            AVG([Income]) OVER(PARTITION BY [Gender], [Purchased Bike]) AS yes_avg_income
     FROM [dbo].[Data$]
     WHERE [Purchased Bike] = 'Yes')           --  CREATES A CTE WITH GENDER AND AVERAGE INCOME OF PARTICIPANTS WHO MADE A BIKE PURCHASE

SELECT [yes_gender].[Gender],
       ROUND(yes_avg_income,2) AS yes,
       ROUND(no_avg_income,2) AS no
FROM yes_gender

INNER JOIN

(SELECT DISTINCT ([Gender]),
        AVG([Income]) OVER(PARTITION BY [Gender], [Purchased Bike]) AS no_avg_income
FROM [dbo].[Data$]
WHERE [Purchased Bike] = 'No') AS no_gender --JOIN IT TO A SUBQUERY THAT CONTAINS GENDER AND AVERAGE INCOME OF PARTICIPANT WHO DID NOT MAKE A BIKE PURCHASE

ON yes_gender.Gender = no_gender.Gender
ORDER BY yes_gender.Gender DESC               --FROM THE RESULT WE MAKE TWO CONCLUSIONS
                                              --GENERALLY, MEN HAVE A HIGHER AVERAGE INCOME THAN WOMEN
                                              --PARTICIPANTS WHO MADE A BIKE PURCHASE RECEIVE A HIGHER AVERAGE INCOME THAN PARTICIPANTS WHO DID NOT


----WE GO ON TO COMPARE AGE GROUP AND ITS IMPACT ON BIKE PURCHASES

WITH CTE AS (SELECT [new_age],
                    SUM(CASE WHEN  [Purchased Bike]= 'Yes' THEN 1 ELSE 0 END) AS purchased,
                    SUM(CASE WHEN  [Purchased Bike]= 'No' THEN 1 ELSE 0 END) AS not_purchased,
                    COUNT(*) AS total
             FROM  [dbo].[Data$]
             GROUP BY [new_age])
  
SELECT CTE.new_age,
       ROUND((100 * purchased) / total, 2) AS percentage_purchased,
       ROUND((100 * not_purchased) / total, 2) AS percentage_not_purchased
FROM CTE

INNER JOIN

(SELECT DISTINCT ([new_age]) AS age_group,
        COUNT([new_age]) OVER(PARTITION BY [new_age],[Purchased Bike]) AS no_age
 FROM [dbo].[Data$]
 WHERE [Purchased Bike] = 'No') AS D

 ON D.age_group=CTE.new_age                       --FROM THIS, THE PERCENTAGE OF PARTICIPANTS WHO MAKE BIKE PURCHASES REDUCES AS THEY GET INTO OLDER AGE GROUPS


--WE COMPARE COMMUTE DISTANCE TO BIKE PURCHASES

 WITH yes_commute_distance AS
    (SELECT DISTINCT ([Commute Distance])AS commute,
            COUNT([Commute Distance]) OVER(PARTITION BY [Commute Distance], [Purchased Bike]) AS yes_commute
     FROM [dbo].[Data$]
     WHERE [Purchased Bike] = 'Yes')           --  CREATES A CTE WITH COMMUTE DISTANCE AND NUMBER OF PARTICIPANTS WHO MADE BIKE PURCHASES

SELECT yes_commute_distance.commute,
	   ROUND((100*yes_commute/C.total),2) AS percent_commute_purchase,
       ROUND((100*no_commute/C.total),2) AS percent_commute_not_purchase
FROM yes_commute_distance

FULL JOIN

(SELECT DISTINCT ([Commute Distance])AS commute,
        count([Commute Distance]) OVER(PARTITION BY [Commute Distance], [Purchased Bike]) AS no_commute
 FROM [dbo].[Data$]
 WHERE [Purchased Bike] = 'No') AS no_commute_distance   --JOIN IT TO A SUBQUERY THAT CONTAINS COMMUTE DISTANCE AND NUMBER OF PARTICIPANT WHO DID NOT MAKE A BIKE PURCHASE

ON yes_commute_distance.commute = no_commute_distance.commute

INNER JOIN (SELECT  DISTINCT ([Commute Distance]) AS commute,
                    count([Purchased Bike]) OVER(PARTITION BY[Commute Distance])  AS total  
            FROM [dbo].[Data$]) AS C

ON C.commute=no_commute_distance.commute                  --JOIN AGAIN TO A SUBQUERY THAT CONTAINS THE TOTAL NUMBER OF PARTICIPANTS IN EACH COMMUTE GROUP

INNER JOIN

(SELECT [Commute Distance],
        SUM(CASE WHEN  [Purchased Bike]= 'Yes' THEN 1 ELSE 0 END) AS purchased,
        SUM(CASE WHEN  [Purchased Bike]= 'No' THEN 1 ELSE 0 END) AS not_purchased,
        COUNT(*) AS total
 FROM [dbo].[Data$]
 GROUP BY [Commute Distance]) AS E

  ON no_commute_distance.commute = E.[Commute Distance]   --WE INFER THAT THE PERCENTAGE OF PARTICIPANTS THAT MADE PURCHASES AND THAT OF THOSE THAT DID NOT MAKE ANY PURCHASE ARE SYMETRIC ABOUT 50% 



--WE TAKE A CLOSER LOOK INTO PARTICIPANTS WHO COMMUTE THE SHORTEST DISTANCE TO WORK

WITH yes_cars AS
    (SELECT DISTINCT[Cars] AS num_cars,
            COUNT([Purchased Bike])OVER(PARTITION BY CARS,[Purchased Bike])AS purchased

     FROM[dbo].[Data$]
     WHERE [Commute Distance] = 'Very Close' AND [Purchased Bike]='Yes')

SELECT yes_cars.num_cars,
       yes_cars.purchased,
       not_purchased
FROM yes_cars

INNER JOIN

(SELECT DISTINCT[Cars] AS num_cars,
        COUNT([Purchased Bike])OVER(PARTITION BY CARS,[Purchased Bike])AS not_purchased

 FROM[dbo].[Data$]
 WHERE [Commute Distance] = 'Very Close' AND [Purchased Bike]='No') AS no_cars

ON yes_cars.num_cars=no_cars.num_cars         --BIKE PURCHASE DECREASE SIGNIFICANTLY WITH NUMBER OF CARS AVAILABLE AMONG PARTICIPANTS WHO COMMUTE AT MOST 1 MILE



--WE LOOK AT GENERAL CAR OWNERSHIP AND ITS IMPACT ON BIKE PURCHASES

WITH yes_cars AS
     (SELECT DISTINCT[Cars] AS num_cars,
             COUNT([Purchased Bike])OVER(PARTITION BY CARS,[Purchased Bike])AS purchased

      FROM[dbo].[Data$]
      WHERE  [Purchased Bike]='Yes')

SELECT yes_cars.num_cars,
       yes_cars.purchased,
       not_purchased
FROM yes_cars

INNER JOIN

(SELECT DISTINCT[Cars] AS num_cars,
        COUNT([Purchased Bike])OVER(PARTITION BY CARS,[Purchased Bike])AS not_purchased

 FROM[dbo].[Data$]
 WHERE  [Purchased Bike]='No') AS no_cars

 ON yes_cars.num_cars=no_cars.num_cars           --GENERALLY THE MORE CARS OWNED BY PARTICIPANTS, THE LESS NUMBER OF BIKE PURCHASES MADE








