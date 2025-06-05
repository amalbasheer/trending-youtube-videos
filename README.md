# trending-youtube-videos
SQL  project

SQL-based exploration of video performance, content trends, and audience interaction patterns done in postgresql.

Data Cleaning And Preprocessing
Convert publishedAt into DATE and TIME using SQL date functions.
Replace missing values in likeCount, dislikeCount, and commentCount with 0 or filter them out.
Remove videos with null or missing videoId, viewCount, or durationSec.

Video Engagement And Popularity Analysis
Top 10 Most Viewed Videos: Based on viewCount.
Top 5 Most Liked Videos: Based on likeCount.
Engagement Rate: Calculate likes + dislikes + comments per 1000 views.
Average Views By Category: Group by videoCategoryLabel and calculate average viewCount.
Short VS Long Video Views: Compare average views for:
Short videos (durationSec < 300)
Long videos (durationSec > 900)

Content And Category Trends
Most Common Video Category: Category with the highest number of videos.
View Distribution By Definition: Compare views between HD and SD videos.
Top Categories By Total Engagement: Sum of likes + comments grouped by category.
Daily Uploads Trend: Extract upload day from publishedAt and count uploads per day.

Advanced SQL Queries
Engagement Leaders: Use window functions (RANK() or DENSE_RANK()) to find the top video per category by engagement.
Trending Time Analysis: Extract upload hour and find the peak time range for video uploads.
Performance Outliers: Find videos with a likeCount significantly higher than the average for their category.
Boolean Flag: Create a flag for videos where viewCount > 10000 AND likeCount/viewCount > 0.1 → “High Engagement”.
