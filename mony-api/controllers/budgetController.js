import Budget from "../models/Budget.js";
import Category from "../models/Category.js";

export const getBudgets = async (req, res) => {
  try {
    const budgets = await Budget.find({ user: req.user._id })
      .populate("category")
      .sort({ createdAt: -1 });

    res.status(200).json({
      success: true,
      count: budgets.length,
      data: { budgets },
    });
  } catch (error) {
    console.error("❌ Erreur getBudgets :", error.message);
    res.status(500).json({ success: false, message: error.message });
  }
};

export const createBudget = async (req, res) => {
  try {
    const { category, categoryName, amount, period, startDate, endDate, isActive } = req.body;

    if ((!category && !categoryName) || !amount) {
      return res.status(400).json({
        success: false,
        message: "La catégorie et le montant sont obligatoires.",
      });
    }

    // Vérifier que la catégorie appartient bien à l'utilisateur
    let categoryExists = null;
    if (category) {
      categoryExists = await Category.findOne({ _id: category, user: req.user._id });
    } else {
      categoryExists = await Category.findOneAndUpdate(
        { name: categoryName.trim(), user: req.user._id },
        {
          $setOnInsert: {
            name: categoryName.trim(),
            type: "expense",
            color: "#ef4444",
            user: req.user._id,
          },
        },
        { upsert: true, new: true, runValidators: true }
      );
    }
    if (!categoryExists) {
      return res.status(404).json({
        success: false,
        message: "Catégorie introuvable ou non autorisée.",
      });
    }

    const budget = await Budget.create({
      category: categoryExists._id,
      amount,
      period: period || "monthly",
      startDate: startDate || Date.now(),
      endDate,
      isActive: isActive ?? true,
      user: req.user._id,
    });

    await budget.populate("category");

    res.status(201).json({
      success: true,
      message: "Budget créé avec succès.",
      data: { budget },
    });
  } catch (error) {
    console.error("❌ Erreur createBudget :", error.message);
    res.status(500).json({ success: false, message: error.message });
  }
};

export const updateBudget = async (req, res) => {
  try {
    const { id } = req.params;
    const { category, categoryName, ...updates } = req.body;

    if (categoryName) {
      const categoryDoc = await Category.findOneAndUpdate(
        { name: categoryName.trim(), user: req.user._id },
        {
          $setOnInsert: {
            name: categoryName.trim(),
            type: "expense",
            color: "#ef4444",
            user: req.user._id,
          },
        },
        { upsert: true, new: true, runValidators: true }
      );
      updates.category = categoryDoc._id;
    } else if (category) {
      updates.category = category;
    }

    const budget = await Budget.findOneAndUpdate(
      { _id: id, user: req.user._id },
      updates,
      { new: true, runValidators: true }
    ).populate("category");

    if (!budget) {
      return res.status(404).json({
        success: false,
        message: "Budget introuvable.",
      });
    }

    res.status(200).json({
      success: true,
      message: "Budget mis à jour avec succès.",
      data: { budget },
    });
  } catch (error) {
    console.error("❌ Erreur updateBudget :", error.message);
    res.status(500).json({ success: false, message: error.message });
  }
};

export const deleteBudget = async (req, res) => {
  try {
    const { id } = req.params;

    const budget = await Budget.findOneAndDelete({ _id: id, user: req.user._id });

    if (!budget) {
      return res.status(404).json({
        success: false,
        message: "Budget introuvable.",
      });
    }

    res.status(200).json({
      success: true,
      message: "Budget supprimé avec succès.",
    });
  } catch (error) {
    console.error("❌ Erreur deleteBudget :", error.message);
    res.status(500).json({ success: false, message: error.message });
  }
};
