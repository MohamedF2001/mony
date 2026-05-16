import mongoose from "mongoose";

const transactionSchema = new mongoose.Schema(
  {
    title: {
      type: String,
      required: [true, "Le titre est obligatoire"],
      trim: true,
    },
    amount: {
      type: Number,
      required: [true, "Le montant est obligatoire"],
      min: [0.01, "Le montant doit être supérieur à 0"],
    },
    type: {
      type: String,
      enum: {
        values: ["income", "expense"],
        message: 'Le type doit être "income" ou "expense"',
      },
      required: [true, "Le type est obligatoire"],
    },
    category: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Category",
      required: [true, "La catégorie est obligatoire"],
    },
    description: {
      type: String,
      trim: true,
      default: "",
    },
    transactionDate: {
      type: Date,
      required: [true, "La date de transaction est obligatoire"],
      default: Date.now,
    },
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
  },
  { timestamps: true }
);

transactionSchema.index({ user: 1, transactionDate: -1 });
transactionSchema.index({ user: 1, type: 1 });
transactionSchema.index({ user: 1, category: 1 });

const Transaction = mongoose.model("Transaction", transactionSchema);
export default Transaction;
