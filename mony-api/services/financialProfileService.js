export const calculateTraitScores = (answers, questions) => {
  const scores = {
    impulsivity: 50.0,
    discipline: 50.0,
    savingCapacity: 50.0,
    emotionalControl: 50.0,
    organizationLevel: 50.0,
    riskTolerance: 50.0,
  };

  for (const answer of answers) {
    if (!answer.selectedChoiceId) continue;

    const question = questions.find((q) => q._id.toString() === answer.questionId.toString());
    if (!question) continue;

    const choice = question.choices.find((c) => c.id === answer.selectedChoiceId);
    if (!choice) continue;

    for (const [trait, impact] of Object.entries(choice.scores)) {
      if (scores[trait] !== undefined) {
        scores[trait] = Math.min(100, Math.max(0, scores[trait] + impact * (question.weight || 1.0)));
      }
    }
  }

  return scores;
};

export const determineProfileType = (scores) => {
  const {
    impulsivity,
    discipline,
    savingCapacity,
    emotionalControl,
    organizationLevel,
  } = scores;

  if (impulsivity > 65 && discipline < 45 && savingCapacity < 45) {
    return "impulsiveSpender";
  }

  if (organizationLevel < 35 && discipline < 40) {
    return "financiallyDisorganized";
  }

  if (savingCapacity > 70 && discipline > 65) {
    return "strategicSaver";
  }

  if (discipline > 70 && emotionalControl < 40 && organizationLevel > 70) {
    return "overController";
  }

  if (organizationLevel > 60 && discipline > 55 && savingCapacity > 55) {
    return "cautiousOptimizer";
  }

  return "balancedAware";
};

export const calculateConfidenceScore = (answers, scores) => {
  const answerCompleteness = (answers.length / 20.0) * 40;
  const freeTextBonus = answers.filter((a) => a.freeText && a.freeText.trim().length > 0).length * 3.0;

  const values = Object.values(scores);
  const mean = values.reduce((a, b) => a + b, 0) / values.length;
  const variance = values.reduce((a, b) => a + Math.pow(b - mean, 2), 0) / values.length;
  const coherenceScore = Math.min(30, Math.max(0, 100 - variance));

  return Math.min(100, Math.max(0, answerCompleteness + freeTextBonus + coherenceScore));
};
