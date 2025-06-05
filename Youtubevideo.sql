drop table youtube;
create table youtube (Slno int,channelId varchar,channelTitle varchar,videoId varchar,publishedAt timestamp,
                      videoTitle varchar,videoDescription varchar,videoCategoryId int,videoCategoryLabel varchar,
					  duration varchar,durationSec int,definition varchar,caption varchar,viewCount int,
					  likeCount int,dislikeCount int,commentCount int);
select *from youtube;
copy youtube (Slno,channelId,	channelTitle,videoId,publishedAt,videoTitle,videoDescription,videoCategoryId,
             videoCategoryLabel,duration,durationSec,definition,caption,viewCount,likeCount,dislikeCount,
			 commentCount)
FROM 'C:\Program Files\PostgreSQL\17\data\file\Data\Trending videos on youtube dataset.csv'
DELIMITER ','csv header encoding  'LATIN1';
select *from youtube;

--DATA CLEANING AND PREPROCESSING
--Convert publishedAt into DATE and TIME using SQL date functions.
select 
publishedAt::date as publisheddate,
publishedAt::time as publishedtime,*
from youtube;
--Replace missing values in likeCount, dislikeCount, and commentCount with 0 or filter them out.
UPDATE youtube
SET likeCount = COALESCE(likeCount, 0),
    dislikeCount = COALESCE(dislikeCount, 0),
    commentCount = COALESCE(commentCount, 0);
select*from youtube;
--Remove videos with null or missing videoId, viewCount, or durationSec.
SELECT * 
FROM youtube
WHERE videoId IS NULL 
   OR viewCount IS NULL 
   OR durationSec IS NULL;
DELETE FROM youtube
WHERE videoId IS NULL 
   OR viewCount IS NULL 
   OR durationSec IS NULL;

--VIDEO ENGAGEMENT AND POPULARITY ANALYSIS
--Top 10 Most Viewed Videos: Based on viewCount.
SELECT *
FROM youtube
ORDER BY viewCount DESC
LIMIT 10;
--Top 5 Most Liked Videos: Based on likeCount.
SELECT *
FROM youtube
ORDER BY likeCount DESC
LIMIT 5;
--Engagement Rate: Calculate likes + dislikes + comments per 1000 views.
SELECT *,
       ROUND(((likeCount + dislikeCount + commentCount) * 1000.0) / viewCount, 2) AS EngagementRate
FROM youtube;
--Average Views By Category: Group by videoCategoryLabel and calculate average viewCount.
SELECT videoCategoryLabel,
    ROUND(AVG(viewCount),2)AS AverageViewCount
FROM youtube
GROUP BY videoCategoryLabel;
--Short VS Long Video Views: Compare average views for:
SELECT 
    ROUND(AVG(CASE WHEN durationSec < 300 THEN viewCount END), 2) AS ShortVideoAverageViews,
    ROUND(AVG(CASE WHEN durationSec > 900 THEN viewCount END), 2) AS LongVideoAverageViews
FROM youtube;

--CONTENT AND CATEGORY TRENDS
--Most Common Video Category: Category with the highest number of videos.
SELECT 
    videoCategoryLabel,
    COUNT(*) AS NumberOfVideos
FROM youtube
GROUP BY videoCategoryLabel
ORDER BY NumberOfVideos DESC
LIMIT 1;
--View Distribution By Definition: Compare views between HD and SD videos.
SELECT definition,
    ROUND(AVG(viewCount),2) AS AverageViews
FROM youtube
GROUP BY 1;
--Top Categories By Total Engagement: Sum of likes + comments grouped by category.
SELECT videoCategoryLabel,
    SUM(likeCount + commentCount) AS TotalEngagement
FROM youtube
GROUP BY videoCategoryLabel
ORDER BY TotalEngagement DESC;
--Daily Uploads Trend: Extract upload day from publishedAt and count uploads per day.
SELECT publishedAt::DATE AS UploadDay,
    COUNT(*) AS UploadCount
FROM youtube
GROUP BY UploadDay
ORDER BY UploadDay ASC;

--ADVANCED SQL QUERIES
--Engagement Leaders: Use window functions (RANK() or DENSE_RANK()) to find the top video per category by engagement.
SELECT 
    videoCategoryLabel,VideoId,TotalEngagement,Rank
FROM	
    (SELECT VideoCategoryLabel,VideoId,likeCount,commentCount,
    (likeCount + commentCount) AS TotalEngagement,
    RANK() OVER (PARTITION BY videoCategoryLabel ORDER BY (likeCount + commentCount) DESC) AS Rank
FROM youtube
ORDER BY videoCategoryLabel, Rank);
--Trending Time Analysis: Extract upload hour and find the peak time range for video uploads.
SELECT 
    EXTRACT(HOUR FROM publishedAt) AS UploadHour,
    COUNT(*) AS UploadCount
FROM youtube
GROUP BY UploadHour
ORDER BY UploadCount DESC;
--Performance Outliers: Find videos with a likeCount significantly higher than the average for their category.
WITH CategoryLikes AS (
    SELECT 
        videoCategoryLabel,
        ROUND(AVG(likeCount),2) AS AverageLikes
    FROM youtube 
    GROUP BY videoCategoryLabel
)
SELECT 
    Y.VideoID,Y.VideoTitle,Y.videoCategoryLabel,Y.likeCount,
    CategoryLikes.AverageLikes
FROM youtube AS Y
JOIN CategoryLikes
ON Y.videoCategoryLabel = CategoryLikes.videoCategoryLabel
WHERE Y.likeCount > (CategoryLikes.AverageLikes * 1.5) 
ORDER BY 4 DESC;
--Boolean Flag: Create a flag for videos where viewCount > 10000 AND likeCount/viewCount > 0.1 → “High Engagement”.
SELECT VideoID,VideoTitle,viewCount,likeCount,
    CASE 
        WHEN viewCount > 10000 AND (likeCount /viewCount) > 0.1 THEN TRUE
        ELSE FALSE
    END AS HighEngagement
FROM youtube
ORDER BY 3 DESC;