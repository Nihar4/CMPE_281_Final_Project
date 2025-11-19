import app from "./app.js";
import { connectDB } from "./config/database.js";
import { connectRedis } from "./config/redis.js";
import cloudinary from "cloudinary";
import RazorPay from "razorpay";
import nodeCron from "node-cron";
import { Stats } from "./models/Stats.js";
import mongoose from "mongoose";
import { getRedisClient } from "./config/redis.js";

import { getSecret } from "./utils/secrets.js";

export let instance;

// Initialize secrets and start server
const startServer = async () => {
    try {
        // Fetch secrets from AWS Secrets Manager
        // In production, these names should match what's in Secrets Manager
        // We use project_name/environment/secret_name convention
        const mongoSecretName = process.env.MONGO_SECRET_NAME || "coursebundler-final/dev/mongo_uri";
        const jwtSecretName = process.env.JWT_SECRET_NAME || "coursebundler-final/dev/jwt_secret";

        const mongoUri = await getSecret(mongoSecretName);
        if (mongoUri) {
            process.env.MONGO_URI = mongoUri;
            console.log("Fetched MONGO_URI from Secrets Manager");
        }

        const jwtSecret = await getSecret(jwtSecretName);
        if (jwtSecret) {
            process.env.JWT_SECRET = jwtSecret;
            console.log("Fetched JWT_SECRET from Secrets Manager");
        }

        // Fetch Cloudinary Secrets
        const cloudinarySecretName = process.env.CLOUDINARY_SECRET_NAME || "coursebundler-final/dev/cloudinary";
        const cloudinarySecret = await getSecret(cloudinarySecretName);
        if (cloudinarySecret) {
            const secrets = JSON.parse(cloudinarySecret);
            process.env.CLOUDINARY_CLIENT_NAME = secrets.CLOUDINARY_CLIENT_NAME;
            process.env.CLOUDINARY_CLIENT_API = secrets.CLOUDINARY_CLIENT_API;
            process.env.CLOUDINARY_CLIENT_SECRET = secrets.CLOUDINARY_CLIENT_SECRET;
            console.log("Fetched Cloudinary secrets from Secrets Manager");
        }

        // Fetch Razorpay Secrets
        const razorpaySecretName = process.env.RAZORPAY_SECRET_NAME || "coursebundler-final/dev/razorpay";
        const razorpaySecret = await getSecret(razorpaySecretName);
        if (razorpaySecret) {
            const secrets = JSON.parse(razorpaySecret);
            process.env.RAZORPAY_API_KEY = secrets.RAZORPAY_API_KEY;
            process.env.RAZORPAY_API_SECRET = secrets.RAZORPAY_API_SECRET;
            console.log("Fetched Razorpay secrets from Secrets Manager");
        }

        // Connect to Databases
        console.log("Connecting to MongoDB...");
        await connectDB();
        console.log("Connected to MongoDB. Connecting to Redis...");
        await connectRedis();
        // Initialize Razorpay instance
        instance = new RazorPay({
            key_id: process.env.RAZORPAY_API_KEY,
            key_secret: process.env.RAZORPAY_API_SECRET,
        });
        console.log("Initialized Razorpay instance");

        console.log("Connected to Redis. Starting server...");

        // Start Server
        const port = process.env.PORT || 5001;
        server = app.listen(port, () => {
            console.log(`Server is working on port: ${port}`);
        });

    } catch (error) {
        console.error("Failed to start server:", error);
        process.exit(1);
    }
};

let server;
startServer();

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
