import Transaction from "../models/Transaction.js";
import Category from "../models/Category.js";
import mongoose from "mongoose";

export const getTransactions = async (req, res) => {
  try {
    const {
      type,
      category,
      startDate,
      endDate,
      page = 1,
      limit = 10,
    } = req.query;

    const filter = { user: req.user._id };

    if (type) filter.type = type;
    if (category) filter.category = category;
    if (startDate || endDate) {
      filter.transactionDate = {};
      if (startDate) filter.transactionDate.$gte = new Date(startDate);
      if (endDate) filter.transactionDate.$lte = new Date(endDate);
    }

    const skip = (parseInt(page) - 1) * parseInt(limit);
    const total = await Transaction.countDocuments(filter);

    const transactions = await Transaction.find(filter)
      .populate("category", "name color")
      .sort({ transactionDate: -1 })
      .skip(skip)
      .limit(parseInt(limit));

    res.status(200).json({
      success: true,
      count: transactions.length,
      total,
      page: parseInt(page),
      totalPages: Math.ceil(total / parseInt(limit)),
      data: { transactions },
    });
  } catch (error) {
    console.error("❌ Erreur getTransactions :", error.message);
    res.status(500).json({ success: false, message: error.message });
  }
};

export const createTransaction = async (req, res) => {
  try {
    const { title, amount, type, category, description, transactionDate } =
      req.body;

    if (!title || !amount || !type || !category) {
      return res.status(400).json({
        success: false,
        message: "Titre, montant, type et catégorie sont obligatoires.",
      });
    }

    const cat = await Category.findOne({
      _id: category,
      user: req.user._id,
    });

    if (!cat) {
      return res.status(404).json({
        success: false,
        message: "Catégorie introuvable ou non autorisée.",
      });
    }

    const transaction = await Transaction.create({
      title,
      amount,
      type,
      category,
      description: description || "",
      transactionDate: transactionDate || Date.now(),
      user: req.user._id,
    });

    const populated = await transaction.populate("category", "name color");

    console.log(`💰 Transaction créée : ${title} - ${amount}`);

    res.status(201).json({
      success: true,
      message: "Transaction créée avec succès.",
      data: { transaction: populated },
    });
  } catch (error) {
    console.error("❌ Erreur createTransaction :", error.message);
    res.status(500).json({ success: false, message: error.message });
  }
};

export const updateTransaction = async (req, res) => {
  try {
    const { id } = req.params;
    const { title, amount, type, category, description, transactionDate } =
      req.body;

    const transaction = await Transaction.findOne({
      _id: id,
      user: req.user._id,
    });

    if (!transaction) {
      return res.status(404).json({
        success: false,
        message: "Transaction introuvable.",
      });
    }

    if (category) {
      const cat = await Category.findOne({
        _id: category,
        user: req.user._id,
      });
      if (!cat) {
        return res.status(404).json({
          success: false,
          message: "Catégorie introuvable ou non autorisée.",
        });
      }
    }

    const updates = {};
    if (title) updates.title = title;
    if (amount) updates.amount = amount;
    if (type) updates.type = type;
    if (category) updates.category = category;
    if (description !== undefined) updates.description = description;
    if (transactionDate) updates.transactionDate = transactionDate;

    const updated = await Transaction.findByIdAndUpdate(id, updates, {
      new: true,
      runValidators: true,
    }).populate("category", "name color");

    console.log(`✏️ Transaction mise à jour : ${updated.title}`);

    res.status(200).json({
      success: true,
      message: "Transaction mise à jour avec succès.",
      data: { transaction: updated },
    });
  } catch (error) {
    console.error("❌ Erreur updateTransaction :", error.message);
    res.status(500).json({ success: false, message: error.message });
  }
};

export const deleteTransaction = async (req, res) => {
  try {
    const { id } = req.params;

    const transaction = await Transaction.findOne({
      _id: id,
      user: req.user._id,
    });

    if (!transaction) {
      return res.status(404).json({
        success: false,
        message: "Transaction introuvable.",
      });
    }

    await Transaction.findByIdAndDelete(id);

    console.log(`🗑️ Transaction supprimée : ${transaction.title}`);

    res.status(200).json({
      success: true,
      message: "Transaction supprimée avec succès.",
    });
  } catch (error) {
    console.error("❌ Erreur deleteTransaction :", error.message);
    res.status(500).json({ success: false, message: error.message });
  }
};

export const getStats = async (req, res) => {
  try {
    const userId = new mongoose.Types.ObjectId(req.user._id);

    const totals = await Transaction.aggregate([
      { $match: { user: userId } },
      {
        $group: {
          _id: "$type",
          total: { $sum: "$amount" },
        },
      },
    ]);

    let totalIncome = 0;
    let totalExpense = 0;

    totals.forEach((item) => {
      if (item._id === "income") totalIncome = item.total;
      if (item._id === "expense") totalExpense = item.total;
    });

    const expenseByCategory = await Transaction.aggregate([
      { $match: { user: userId, type: "expense" } },
      {
        $group: {
          _id: "$category",
          total: { $sum: "$amount" },
        },
      },
      {
        $lookup: {
          from: "categories",
          localField: "_id",
          foreignField: "_id",
          as: "categoryInfo",
        },
      },
      { $unwind: "$categoryInfo" },
      {
        $project: {
          _id: 0,
          category: "$categoryInfo.name",
          color: "$categoryInfo.color",
          total: 1,
        },
      },
      { $sort: { total: -1 } },
    ]);

    console.log(`📊 Stats calculées pour : ${req.user.email}`);

    res.status(200).json({
      success: true,
      data: {
        totalIncome,
        totalExpense,
        balance: totalIncome - totalExpense,
        expenseByCategory,
      },
    });
  } catch (error) {
    console.error("❌ Erreur getStats :", error.message);
    res.status(500).json({ success: false, message: error.message });
  }
};
