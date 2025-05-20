require("dotenv").config();
const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");

const app = express();
app.use(cors());
app.use(express.json());

// 📌 MongoDB Connection (Using Atlas URI)
const DB_URI = process.env.MONGO_URI;
mongoose.connect(DB_URI, {
    useNewUrlParser: true,
    useUnifiedTopology: true
}).then(() => console.log("✅ Connected to MongoDB Atlas"))
.catch(err => console.error("❌ MongoDB Atlas connection error:", err));

// Student Schema
const studentSchema = new mongoose.Schema({
    name: { type: String, required: true },
    age: { type: Number, required: true, min: 16 },
    department: { type: String, required: true }
});

const Student = mongoose.model("Student", studentSchema);

// CRUD Endpoints
app.get("/students", async (req, res) => {
    try {
        const students = await Student.find();
        res.json(students);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.post("/students", async (req, res) => {
    try {
        const { name, age, department } = req.body;
        if (!name || !age || !department) {
            return res.status(400).json({ error: "All fields are required" });
        }

        const newStudent = new Student({ name, age, department });
        await newStudent.save();
        res.status(201).json({ message: "✅ Student added successfully", student: newStudent });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.put("/students/:id", async (req, res) => {
    try {
        const { id } = req.params;
        const { name, age, department } = req.body;

        if (!mongoose.Types.ObjectId.isValid(id)) {
            return res.status(400).json({ error: "Invalid student ID" });
        }

        const updatedStudent = await Student.findByIdAndUpdate(
            id, { name, age, department },
            { new: true, runValidators: true }
        );

        if (!updatedStudent) {
            return res.status(404).json({ error: "Student not found" });
        }

        res.json({ message: "✅ Student updated successfully", student: updatedStudent });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.delete("/students/:id", async (req, res) => {
    try {
        const { id } = req.params;

        if (!mongoose.Types.ObjectId.isValid(id)) {
            return res.status(400).json({ error: "Invalid student ID" });
        }

        const deletedStudent = await Student.findByIdAndDelete(id);

        if (!deletedStudent) {
            return res.status(404).json({ error: "Student not found" });
        }

        res.json({ message: "✅ Student deleted successfully" });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`🚀 Server running on port ${PORT}`));
