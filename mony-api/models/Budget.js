import mongoose from "mongoose";

const budgetSchema = new mongoose.Schema(
  {
    category: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Category",
      required: [true, "La catégorie est obligatoire"],
    },
    amount: {
      type: Number,
      required: [true, "Le montant est obligatoire"],
      min: [0, "Le montant doit être positif"],
    },
    period: {
      type: String,
      enum: ["monthly", "yearly"],
      required: [true, "La période est obligatoire"],
      default: "monthly",
    },
    startDate: {
      type: Date,
      required: [true, "La date de début est obligatoire"],
      default: Date.now,
    },
    endDate: {
      type: Date,
    },
    isActive: {
      type: Boolean,
      default: true,
    },
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
  },
  { timestamps: true }
);

// Un seul budget actif par catégorie et par période pour un utilisateur
budgetSchema.index({ user: 1, category: 1, period: 1, isActive: 1 });

const Budget = mongoose.model("Budget", budgetSchema);
export default Budget;
