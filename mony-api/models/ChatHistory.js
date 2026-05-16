import mongoose from "mongoose";

const chatHistorySchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    question: {
      type: String,
      required: [true, "La question est obligatoire"],
      trim: true,
    },
    answer: {
      type: String,
      required: [true, "La réponse est obligatoire"],
    },
  },
  { timestamps: true }
);

chatHistorySchema.index({ user: 1, createdAt: -1 });

const ChatHistory = mongoose.model("ChatHistory", chatHistorySchema);
export default ChatHistory;
