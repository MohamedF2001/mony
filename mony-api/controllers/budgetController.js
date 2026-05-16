import Budget from "../models/Budget.js";

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
    const { category, amount, period, startDate, endDate } = req.body;

    if (!category || !amount) {
      return res.status(400).json({
        success: false,
        message: "La catégorie et le montant sont obligatoires.",
      });
    }

    // Vérifier que la catégorie appartient bien à l'utilisateur
    const categoryExists = await Category.findOne({ _id: category, user: req.user._id });
    if (!categoryExists) {
      return res.status(404).json({
        success: false,
        message: "Catégorie introuvable ou non autorisée.",
      });
    }

    const budget = await Budget.create({
      category,
      amount,
      period: period || "monthly",
      startDate: startDate || Date.now(),
      endDate,
      user: req.user._id,
    });

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
    const updates = req.body;

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
