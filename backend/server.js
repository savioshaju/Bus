require("dotenv").config();
const express = require("express");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const cors = require("cors");
const { createClient } = require("@supabase/supabase-js");


console.log("SUPABASE_URL:", process.env.SUPABASE_URL);
console.log("SUPABASE_ANON_KEY:", process.env.SUPABASE_ANON_KEY);

const app = express();
app.use(express.json());
app.use(cors());

// Initialize Supabase Client
const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_ANON_KEY);

// ✅ General User Token Verification
const verifyUserToken = (req, res, next) => {
    const token = req.headers["authorization"];
    if (!token) return res.status(403).json({ message: "Access denied" });

    jwt.verify(token.split(" ")[1], process.env.JWT_SECRET, (err, decoded) => {
        if (err) return res.status(401).json({ message: "Invalid token" });
        req.user = decoded;
        next();
    });
};

// ✅ Admin Token Verification
const verifyAdminToken = (req, res, next) => {
    const token = req.header("Authorization");
    if (!token) {
        return res.status(401).json({ message: "Access denied. No token provided." });
    }
    try {
        const decoded = jwt.verify(token.replace("Bearer ", ""), process.env.JWT_SECRET);
        console.log("Decoded Admin User:", decoded);

        if (decoded.role.toLowerCase() !== "admin") {
            return res.status(403).json({ message: "Unauthorized access" });
        }

        req.user = decoded;
        next();
    } catch (error) {
        return res.status(400).json({ message: "Invalid token." });
    }
};

// ✅ User Login
app.post("/login", async (req, res) => {
    const { username, password } = req.body;

    if (!username || !password) {
        return res.status(400).json({ message: "Username and password are required" });
    }

    const { data, error } = await supabase
        .from("users")
        .select("id, role, status, password")
        .eq("username", username)
        .single();

    if (error || !data) {
        return res.status(401).json({ message: "Invalid username or password" });
    }

    const user = data;
    const passwordMatch = await bcrypt.compare(password, user.password);

    if (!passwordMatch) {
        return res.status(401).json({ message: "Invalid username or password" });
    }

    if (user.role === "Transit Provider" && user.status === "Pending") {
        return res.status(403).json({ message: "Approval pending by admin" });
    }

    const token = jwt.sign({ id: user.id, role: user.role }, process.env.JWT_SECRET, { expiresIn: "1h" });
    const refreshToken = jwt.sign({ id: user.id }, process.env.JWT_SECRET, { expiresIn: "7d" });

    res.json({ token, refreshToken, role: user.role, status: user.status });
});

// ✅ Fetch Pending Transit Providers (Admin Only)
app.get("/admin/pending-providers", verifyAdminToken, async (req, res) => {
    const { data, error } = await supabase
        .from("users")
        .select("id, first_name, middle_name, last_name, email, phone_number, dob, address")
        .eq("role", "Transit Provider")
        .eq("status", "Pending");

    if (error) {
        return res.status(500).json({ message: "Internal server error", error: error.message });
    }

    res.json(data);
});

// ✅ Approve or Reject a Provider (Admin Only)
app.post("/admin/approve-provider", verifyAdminToken, async (req, res) => {
    const { userId, status } = req.body;

    if (!["Approved", "Rejected"].includes(status)) {
        return res.status(400).json({ message: "Invalid status. Use 'Approved' or 'Rejected'." });
    }

    let updateQuery;
    if (status === "Approved") {
        updateQuery = supabase.from("users").update({ status: "Approved" }).eq("id", userId);
    } else {
        updateQuery = supabase.from("users").delete().eq("id", userId);
    }

    const { error } = await updateQuery;

    if (error) {
        return res.status(500).json({ message: "Internal server error", error: error.message });
    }

    res.json({ message: `Provider ${status.toLowerCase()} successfully` });
});

// ✅ User Signup
app.post("/signup", async (req, res) => {
    const { first_name, middle_name, last_name, username, email, phone_number, password, dob, address, role } = req.body;

    if (!first_name || !last_name || !username || !email || !password) {
        return res.status(400).json({ message: "Please provide all required fields" });
    }

    const { data: existingUser } = await supabase
        .from("users")
        .select("id")
        .or(`username.eq.${username},email.eq.${email},phone_number.eq.${phone_number}`)
        .single();

    if (existingUser) {
        return res.status(400).json({ message: "Username, email, or phone number already exists" });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const { error: insertError } = await supabase
        .from("users")
        .insert([
            {
                first_name,
                middle_name,
                last_name,
                username,
                email,
                phone_number,
                password: hashedPassword,
                dob,
                address,
                role,
                status: "Pending",
            },
        ]);

    if (insertError) {
        return res.status(500).json({ message: "Error registering user" });
    }

    res.json({ message: "User registered successfully" });
});

// ✅ Fetch User Profile
app.get("/user/profile", verifyUserToken, async (req, res) => {
    const { id } = req.user;

    const { data, error } = await supabase
        .from("users")
        .select("first_name, middle_name, last_name, username, email, phone_number, dob, address, role, status")
        .eq("id", id)
        .single();

    if (error || !data) {
        return res.status(404).json({ message: "Profile not found" });
    }

    res.json(data);
});

// ✅ Update User Profile
app.put("/user/update-profile", verifyUserToken, async (req, res) => {
    const { id } = req.user;
    const { first_name, middle_name, last_name, phone_number, dob, address } = req.body;

    if (!first_name || !last_name || !phone_number || !dob || !address) {
        return res.status(400).json({ message: "All fields are required" });
    }

    const { data, error } = await supabase
        .from("users")
        .update({ first_name, middle_name, last_name, phone_number, dob, address })
        .eq("id", id)
        .select();

    if (error) {
        return res.status(500).json({ message: "Error updating profile", error: error.message });
    }

    res.json({ message: "Profile updated successfully", updatedUser: data });
});

// ✅ Delete User Account
app.delete("/user/delete-account", verifyUserToken, async (req, res) => {
    const { id } = req.user;

    const { error } = await supabase.from("users").delete().eq("id", id);

    if (error) {
        return res.status(500).json({ message: "Error deleting account", error: error.message });
    }

    res.json({ message: "Account deleted successfully" });
});
// JWT Authentication Middleware
const authenticateUser = (req, res, next) => {
    const token = req.headers.authorization?.split(" ")[1];
    if (!token) return res.status(401).json({ error: "Unauthorized" });

    jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
        if (err) return res.status(403).json({ error: "Invalid token" });

        req.user = user;
        next();
    });
};

// ✅ **1. Fetch User Details**
app.get("/user/details", authenticateUser, async (req, res) => {
    const { id } = req.user;
    const { data, error } = await supabase
        .from("users")
        .select("email, phone_number, password")
        .eq("id", id)
        .single();

    if (error || !data) return res.status(404).json({ error: "User not found" });

    res.json(data);
});

// ✅ **2. Change Password**
app.post("/user/change-password", authenticateUser, async (req, res) => {
    const { old_password, new_password } = req.body;
    const { id } = req.user;

    // Fetch existing hashed password
    const { data, error } = await supabase
        .from("users")
        .select("password")
        .eq("id", id)
        .single();

    if (error || !data) return res.status(404).json({ error: "User not found" });

    const isMatch = await bcrypt.compare(old_password, data.password);
    if (!isMatch) return res.status(400).json({ error: "Incorrect old password" });

    // Hash new password and update
    const newHashedPassword = await bcrypt.hash(new_password, 10);
    const { error: updateError } = await supabase
        .from("users")
        .update({ password: newHashedPassword })
        .eq("id", id);

    if (updateError) return res.status(500).json({ error: "Error updating password" });

    res.json({ message: "Password changed successfully" });
});
// ✅ Start Server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
    console.log(`🚀 Server is running on port ${PORT}`);
});
