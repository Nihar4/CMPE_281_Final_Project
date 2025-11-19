import app from "./app.js";
import { connectDB } from "./config/database.js";
import { connectRedis } from "./config/redis.js";
import cloudinary from "cloudinary";
import RazorPay from "razorpay";
import nodeCron from "node-cron";
import { Stats } from "./models/Stats.js";
import mongoose from "mongoose";
import { getRedisClient } from "./config/redis.js";

connectDB();
connectRedis();

cloudinary.v2.config({
    cloud_name: process.env.CLOUDINARY_CLIENT_NAME,
    api_key: process.env.CLOUDINARY_CLIENT_API,
    api_secret: process.env.CLOUDINARY_CLIENT_SECRET,
});

export const instance = new RazorPay({
    key_id: process.env.RAZORPAY_API_KEY,
    key_secret: process.env.RAZORPAY_API_SECRET,
});

nodeCron.schedule("0 0 0 5 * *", async () => {
    try {
        await Stats.create({});
    } catch (error) {
        console.log(error);
    }
});


const server = app.listen(process.env.PORT, () => {
    console.log(`Server is working on port: ${process.env.PORT}`);
});

// Graceful shutdown handlers
const gracefulShutdown = async (signal) => {
    console.log(`${signal} received. Starting graceful shutdown...`);
    
    // Close HTTP server
    server.close(() => {
        console.log("HTTP server closed");
    });
    
    // Close mongoose connection
    try {
        await mongoose.connection.close();
        console.log("MongoDB connection closed");
    } catch (error) {
        console.error("Error closing MongoDB connection:", error);
    }
    
    // Close Redis connection
    try {
        const redisClient = getRedisClient();
        if (redisClient) {
            await redisClient.quit();
            console.log("Redis connection closed");
        }
    } catch (error) {
        console.error("Error closing Redis connection:", error);
    }
    
    process.exit(0);
};

process.on("SIGTERM", () => gracefulShutdown("SIGTERM"));
process.on("SIGINT", () => gracefulShutdown("SIGINT"));
