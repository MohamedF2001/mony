import mongoose from "mongoose";

const financialProfileSchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
      unique: true,
    },
    type: {
      type: String,
      required: true,
      enum: [
        "impulsiveSpender",
        "balancedAware",
        "strategicSaver",
        "overController",
        "financiallyDisorganized",
        "cautiousOptimizer",
      ],
    },
    traitScores: {
      impulsivity: Number,
      discipline: Number,
      savingCapacity: Number,
      emotionalControl: Number,
      organizationLevel: Number,
      riskTolerance: Number,
    },
    confidenceScore: { type: Number, min: 0, max: 100 },
    aiFeedback: String,
    answers: [
      {
        questionId: { type: mongoose.Schema.Types.ObjectId, ref: "FinancialQuestion" },
        selectedChoiceId: String,
        freeText: String,
        answeredAt: { type: Date, default: Date.now },
      },
    ],
  },
  { timestamps: true }
);

const FinancialProfile = mongoose.model("FinancialProfile", financialProfileSchema);
export default FinancialProfile;
