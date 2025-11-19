import { createClient } from "redis";

let redisClient = null;

export const connectRedis = async () => {
    try {
        const host = process.env.REDIS_HOST || "localhost";
        const port = process.env.REDIS_PORT || 6379;

        redisClient = createClient({
            socket: {
                host: host,
                port: parseInt(port),
            },
        });

        redisClient.on("error", (err) => {
            console.log("Redis Client Error", err);
        });

        await redisClient.connect();
        console.log("Redis connected successfully");
        return redisClient;
    } catch (error) {
        console.log("Redis connection failed:", error.message);
        redisClient = null;
        return null;
    }
};

export const getRedisClient = () => {
    return redisClient;
};

