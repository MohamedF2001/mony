import { GoogleGenerativeAI } from "@google/generative-ai";

const genAI = new GoogleGenerativeAI(process.env.GOOGLE_API_KEY);

const SYSTEM_PROMPT = `Tu es Mony Assistant, un conseiller expert en finances personnelles.
Tu aides les utilisateurs à mieux gérer leur budget, épargner, réduire leurs dépenses et atteindre leurs objectifs financiers.

Règles strictes :
- Réponds UNIQUEMENT aux questions liées aux finances personnelles, budget, épargne, investissement, dépenses, revenus.
- Si la question n'est pas liée à la finance, réponds poliment que tu es spécialisé uniquement en finance personnelle.
- Tes réponses doivent être courtes, claires, pratiques et pédagogiques.
- Utilise des exemples concrets quand c'est utile.
- Réponds en français.`;

export const askFinancialQuestion = async (message) => {
  const model = genAI.getGenerativeModel({
    model: "gemini-2.0-flash",
    systemInstruction: SYSTEM_PROMPT,
  });

  const result = await model.generateContent(message);
  return result.response.text().trim();
};

export const analyzeTransactions = async (transactions, userProfile) => {
  const model = genAI.getGenerativeModel({
    model: "gemini-2.0-flash",
    systemInstruction: SYSTEM_PROMPT + "\nOn va te fournir une liste de transactions et le profil financier de l'utilisateur pour une analyse personnalisée.",
  });

  const prompt = `Voici mes transactions récentes :
${JSON.stringify(transactions, null, 2)}

Mon profil financier est : ${userProfile ? userProfile.type : "Non défini"}

Analyse mes habitudes de dépenses, identifie des anomalies ou des opportunités d'économie, et donne-moi 3 conseils concrets adaptés à ma situation actuelle.`;

  const result = await model.generateContent(prompt);
  return result.response.text().trim();
};
