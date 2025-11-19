import express from "express";
import mongoose from "mongoose";

const router = express.Router();

// Health check endpoint
router.get("/health", (req, res) => {
    try {
        // Check if mongoose connection is ready (readyState === 1 means connected)
        if (mongoose.connection.readyState === 1) {
            return res.status(200).json({ status: "healthy" });
        } else {
            return res.status(503).json({ status: "unhealthy" });
        }
    } catch (error) {
        return res.status(503).json({ status: "unhealthy" });
    }
});

export default router;

