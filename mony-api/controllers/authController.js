import jwt from "jsonwebtoken";
import User from "../models/User.js";

const generateToken = (userId, email) => {
  return jwt.sign({ userId, email }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN,
  });
};

export const register = async (req, res) => {
  try {
    const { firstName, lastName, username, email, password, avatar } = req.body;

    if (!firstName || !lastName || !username || !email || !password) {
      return res.status(400).json({
        success: false,
        message: "Tous les champs obligatoires doivent être renseignés.",
      });
    }

    const existingUser = await User.findOne({ $or: [{ email }, { username }] });
    if (existingUser) {
      return res.status(409).json({
        success: false,
        message:
          existingUser.email === email
            ? "Cet email est déjà utilisé."
            : "Ce nom d'utilisateur est déjà pris.",
      });
    }

    const user = await User.create({
      firstName,
      lastName,
      username,
      email,
      password,
      avatar: avatar || "",
    });

    const token = generateToken(user._id, user.email);

    console.log(`✅ Nouvel utilisateur inscrit : ${user.email}`);

    res.status(201).json({
      success: true,
      message: "Inscription réussie.",
      data: { user, token },
    });
  } catch (error) {
    console.error("❌ Erreur register :", error.message);
    res.status(500).json({ success: false, message: error.message });
  }
};

export const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: "Email et mot de passe requis.",
      });
    }

    const user = await User.findOne({ email });
    if (!user) {
      return res.status(401).json({
        success: false,
        message: "Email ou mot de passe incorrect.",
      });
    }

    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: "Email ou mot de passe incorrect.",
      });
    }

    const token = generateToken(user._id, user.email);

    console.log(`🔐 Connexion : ${user.email}`);

    res.status(200).json({
      success: true,
      message: "Connexion réussie.",
      data: { user, token },
    });
  } catch (error) {
    console.error("❌ Erreur login :", error.message);
    res.status(500).json({ success: false, message: error.message });
  }
};

export const getProfile = async (req, res) => {
  try {
    res.status(200).json({
      success: true,
      data: { user: req.user },
    });
  } catch (error) {
    console.error("❌ Erreur getProfile :", error.message);
    res.status(500).json({ success: false, message: error.message });
  }
};

export const updateProfile = async (req, res) => {
  try {
    const { firstName, lastName, username, avatar } = req.body;

    const updates = {};
    if (firstName) updates.firstName = firstName;
    if (lastName) updates.lastName = lastName;
    if (avatar !== undefined) updates.avatar = avatar;

    if (username && username !== req.user.username) {
      const taken = await User.findOne({ username });
      if (taken) {
        return res.status(409).json({
          success: false,
          message: "Ce nom d'utilisateur est déjà pris.",
        });
      }
      updates.username = username;
    }

    const user = await User.findByIdAndUpdate(req.user._id, updates, {
      new: true,
      runValidators: true,
    }).select("-password");

    console.log(`✏️ Profil mis à jour : ${user.email}`);

    res.status(200).json({
      success: true,
      message: "Profil mis à jour avec succès.",
      data: { user },
    });
  } catch (error) {
    console.error("❌ Erreur updateProfile :", error.message);
    res.status(500).json({ success: false, message: error.message });
  }
};
