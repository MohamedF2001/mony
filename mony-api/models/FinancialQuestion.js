import mongoose from "mongoose";

const financialQuestionSchema = new mongoose.Schema({
  order: { type: Number, required: true },
  text: { type: String, required: true },
  type: {
    type: String,
    enum: ["multipleChoice", "freeText", "mixed"],
    required: true,
  },
  choices: [
    {
      id: String,
      text: String,
      scores: {
        impulsivity: Number,
        discipline: Number,
        savingCapacity: Number,
        emotionalControl: Number,
        organizationLevel: Number,
        riskTolerance: Number,
      },
    },
  ],
  freeTextPrompt: String,
  weight: { type: Number, default: 1.0 },
  isRequired: { type: Boolean, default: true },
});

const FinancialQuestion = mongoose.model(
  "FinancialQuestion",
  financialQuestionSchema
);
export default FinancialQuestion;
