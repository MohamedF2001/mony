import FinancialQuestion from "../models/FinancialQuestion.js";
import FinancialProfile from "../models/FinancialProfile.js";
import {
  calculateTraitScores,
  determineProfileType,
  calculateConfidenceScore,
} from "../services/financialProfileService.js";

export const getQuestions = async (req, res) => {
  try {
    const questions = await FinancialQuestion.find().sort({ order: 1 });
    res.status(200).json({ success: true, data: { questions } });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

export const calculateAndSaveProfile = async (req, res) => {
  try {
    const { answers } = req.body;

    if (!answers || !Array.isArray(answers) || answers.length === 0) {
      return res.status(400).json({ success: false, message: "Réponses manquantes" });
    }

    const questions = await FinancialQuestion.find();
    const traitScores = calculateTraitScores(answers, questions);
    const profileType = determineProfileType(traitScores);
    const confidenceScore = calculateConfidenceScore(answers, traitScores);

    const profileData = {
      user: req.user._id,
      type: profileType,
      traitScores,
      confidenceScore,
      answers,
    };

    const profile = await FinancialProfile.findOneAndUpdate(
      { user: req.user._id },
      profileData,
      { upsert: true, new: true }
    );

    res.status(200).json({
      success: true,
      data: { profile },
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

export const getMyProfile = async (req, res) => {
  try {
    const profile = await FinancialProfile.findOne({ user: req.user._id });
    if (!profile) {
      return res.status(404).json({ success: false, message: "Profil non trouvé" });
    }
    res.status(200).json({ success: true, data: { profile } });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};
