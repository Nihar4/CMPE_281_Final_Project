import { getRedisClient } from "../config/redis.js";

export const cacheCourses = async (req, res, next) => {
    try {
        const redisClient = getRedisClient();

        // If Redis is not available, skip caching
        if (!redisClient) {
            return next();
        }

        // Create cache key from query params
        const keyword = req.query.keyword || "";
        const category = req.query.category || "";
        const cacheKey = `courses:${keyword}:${category}`;

        // Check Redis for cached data
        const cachedData = await redisClient.get(cacheKey);

        if (cachedData) {
            console.log("Cached data:", cachedData);
            return res.status(200).json(JSON.parse(cachedData));
        }

        // Store original res.json function
        const originalJson = res.json.bind(res);

        // Override res.json to cache the response
        res.json = async (data) => {
            // Cache the response for 300 seconds
            try {
                await redisClient.setEx(cacheKey, 300, JSON.stringify(data));
            } catch (error) {
                console.error("Error caching data:", error);
            }
            // Call original json function
            return originalJson(data);
        };

        next();
    } catch (error) {
        // If any error occurs, skip caching and continue
        console.error("Cache middleware error:", error);
        next();
    }
};

