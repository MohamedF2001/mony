import { askFinancialQuestion, analyzeTransactions } from "../services/geminiService.js";
import ChatHistory from "../models/ChatHistory.js";
import Transaction from "../models/Transaction.js";
import FinancialProfile from "../models/FinancialProfile.js";

export const chat = async (req, res) => {
  try {
    const { message } = req.body;

    if (!message || message.trim() === "") {
      return res.status(400).json({
        success: false,
        message: "Le message ne peut pas être vide.",
      });
    }

    console.log(`🤖 Question IA reçue de ${req.user.email} : ${message}`);

    const answer = await askFinancialQuestion(message.trim());

    await ChatHistory.create({
      user: req.user._id,
      question: message.trim(),
      answer,
    });

    res.status(200).json({
      success: true,
      data: {
        question: message.trim(),
        answer,
      },
    });
  } catch (error) {
    console.error("❌ Erreur chat IA :", error.message);
    res.status(500).json({
      success: false,
      message: "Erreur lors de la communication avec l'IA.",
    });
  }
};

export const getChatHistory = async (req, res) => {
  try {
    const { page = 1, limit = 20 } = req.query;
    const skip = (parseInt(page) - 1) * parseInt(limit);

    const total = await ChatHistory.countDocuments({ user: req.user._id });
    const history = await ChatHistory.find({ user: req.user._id })
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(parseInt(limit));

    res.status(200).json({
      success: true,
      count: history.length,
      total,
      page: parseInt(page),
      totalPages: Math.ceil(total / parseInt(limit)),
      data: { history },
    });
  } catch (error) {
    console.error("❌ Erreur getChatHistory :", error.message);
    res.status(500).json({ success: false, message: error.message });
  }
};

export const getAIAnalysis = async (req, res) => {
  try {
    const transactions = await Transaction.find({ user: req.user._id })
      .sort({ transactionDate: -1 })
      .limit(50)
      .populate("category");

    const profile = await FinancialProfile.findOne({ user: req.user._id });

    const analysis = await analyzeTransactions(transactions, profile);

    res.status(200).json({
      success: true,
      data: { analysis },
    });
  } catch (error) {
    console.error("❌ Erreur analyse IA :", error.message);
    res.status(500).json({ success: false, message: error.message });
  }
};
