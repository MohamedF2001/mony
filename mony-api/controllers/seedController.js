import FinancialQuestion from "../models/FinancialQuestion.js";

const questions = [
  {
    order: 1,
    text: "Comment réagissez-vous face à une promotion imprévue sur un objet qui vous plaît ?",
    type: "multipleChoice",
    choices: [
      { id: "1a", text: "Je l'achète immédiatement, c'est une trop bonne affaire.", scores: { impulsivity: 15, discipline: -5 } },
      { id: "1b", text: "Je réfléchis 24h avant de me décider.", scores: { discipline: 5, emotionalControl: 5 } },
      { id: "1c", text: "Je vérifie si j'en ai vraiment besoin et si c'est dans mon budget.", scores: { discipline: 10, organizationLevel: 10 } },
      { id: "1d", text: "Je n'achète rien qui n'était pas prévu.", scores: { discipline: 15, savingCapacity: 5 } }
    ],
    weight: 1.2
  },
  {
    order: 2,
    text: "Quelle proportion de vos revenus mensuels arrivez-vous à épargner ?",
    type: "multipleChoice",
    choices: [
      { id: "2a", text: "Rien du tout, je finis souvent dans le rouge.", scores: { savingCapacity: -15, organizationLevel: -10 } },
      { id: "2b", text: "Moins de 10%.", scores: { savingCapacity: 5 } },
      { id: "2c", text: "Entre 10% et 30%.", scores: { savingCapacity: 15, discipline: 5 } },
      { id: "2d", text: "Plus de 30%.", scores: { savingCapacity: 20, discipline: 15 } }
    ],
    weight: 1.5
  }
];

export const seedQuestions = async (req, res) => {
  try {
    await FinancialQuestion.deleteMany({});
    await FinancialQuestion.insertMany(questions);
    res.status(200).json({ success: true, message: "Questions initialisées avec succès" });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};
