/// Developmental screening scale sourced from scale.docx.
class DevelopmentalQuestion {
  final String section;
  final String text;

  const DevelopmentalQuestion({
    required this.section,
    required this.text,
  });
}

/// Likert scale: 0 = Never … 4 = Very Often
const developmentalScaleOptions = [
  'Never',
  'Rarely',
  'Sometimes',
  'Often',
  'Very Often',
];

const developmentalQuestions = [
  DevelopmentalQuestion(
    section: 'Social Communication',
    text: 'My child avoids or has limited eye contact during interaction.',
  ),
  DevelopmentalQuestion(
    section: 'Social Communication',
    text: 'My child does not consistently respond when their name is called.',
  ),
  DevelopmentalQuestion(
    section: 'Social Communication',
    text:
        'My child rarely shares enjoyment (e.g., showing toys, smiling back).',
  ),
  DevelopmentalQuestion(
    section: 'Social Communication',
    text: 'My child prefers to play alone rather than with other children.',
  ),
  DevelopmentalQuestion(
    section: 'Social Communication',
    text: 'My child does not point to show interest in objects or events.',
  ),
  DevelopmentalQuestion(
    section: 'Social Communication',
    text: 'My child does not follow when someone points at something.',
  ),
  DevelopmentalQuestion(
    section: 'Social Communication',
    text: 'My child has difficulty understanding others\' facial expressions.',
  ),
  DevelopmentalQuestion(
    section: 'Social Communication',
    text: 'My child rarely initiates social interaction.',
  ),
  DevelopmentalQuestion(
    section: 'Social Communication',
    text:
        'My child does not engage in back-and-forth conversation appropriate for age.',
  ),
  DevelopmentalQuestion(
    section: 'Social Communication',
    text: 'My child does not imitate actions (e.g., clapping, waving).',
  ),
  DevelopmentalQuestion(
    section: 'Communication',
    text: 'My child had delayed speech development.',
  ),
  DevelopmentalQuestion(
    section: 'Communication',
    text: 'My child repeats words or phrases over and over (echolalia).',
  ),
  DevelopmentalQuestion(
    section: 'Communication',
    text: 'My child uses unusual tone, pitch, or rhythm when speaking.',
  ),
  DevelopmentalQuestion(
    section: 'Communication',
    text:
        'My child struggles to use gestures like waving, nodding, or pointing.',
  ),
  DevelopmentalQuestion(
    section: 'Communication',
    text:
        'My child talks mainly about one topic and struggles to shift topics.',
  ),
  DevelopmentalQuestion(
    section: 'Communication',
    text:
        'My child interprets language very literally (e.g., struggles with jokes or sarcasm).',
  ),
  DevelopmentalQuestion(
    section: 'Restricted & Repetitive Behaviors',
    text: 'My child flaps hands, rocks, spins, or shows repetitive movements.',
  ),
  DevelopmentalQuestion(
    section: 'Restricted & Repetitive Behaviors',
    text: 'My child becomes very upset with small changes in routine.',
  ),
  DevelopmentalQuestion(
    section: 'Restricted & Repetitive Behaviors',
    text: 'My child insists on doing things in a specific order.',
  ),
  DevelopmentalQuestion(
    section: 'Restricted & Repetitive Behaviors',
    text: 'My child has intense, highly focused interests.',
  ),
  DevelopmentalQuestion(
    section: 'Restricted & Repetitive Behaviors',
    text:
        'My child repeatedly lines up or arranges objects in specific patterns.',
  ),
  DevelopmentalQuestion(
    section: 'Restricted & Repetitive Behaviors',
    text:
        'My child becomes distressed if interrupted during a preferred activity.',
  ),
  DevelopmentalQuestion(
    section: 'Sensory Processing',
    text: 'My child is overly sensitive to loud sounds.',
  ),
  DevelopmentalQuestion(
    section: 'Sensory Processing',
    text: 'My child covers ears or avoids noisy environments.',
  ),
  DevelopmentalQuestion(
    section: 'Sensory Processing',
    text: 'My child is very sensitive to clothing textures or touch.',
  ),
  DevelopmentalQuestion(
    section: 'Sensory Processing',
    text:
        'My child seeks strong sensory input (e.g., spinning, crashing into things).',
  ),
  DevelopmentalQuestion(
    section: 'Sensory Processing',
    text: 'My child has unusually high or low reaction to pain.',
  ),
  DevelopmentalQuestion(
    section: 'Emotional & Behavioral Regulation',
    text: 'My child has intense emotional reactions (meltdowns).',
  ),
  DevelopmentalQuestion(
    section: 'Emotional & Behavioral Regulation',
    text: 'My child struggles to calm down once upset.',
  ),
  DevelopmentalQuestion(
    section: 'Emotional & Behavioral Regulation',
    text:
        'My child shows unusual levels of hyperactivity or extreme passivity.',
  ),
];

/// Total score thresholds (max 120): 0–30 Low · 31–70 Moderate · 71+ High.
/// The backend model is the source of truth; this mirrors those bands as a
/// local fallback / reference.
String riskLevelFromScore(int totalScore) {
  if (totalScore <= 30) return 'low';
  if (totalScore <= 70) return 'moderate';
  return 'high';
}

String summaryForRiskLevel(String riskLevel) {
  switch (riskLevel) {
    case 'low':
      return 'Developmental milestones appear on track. Continue monitoring and follow-up in 3 months.';
    case 'high':
      return 'Screening result indicates high risk. Clinical review recommended.';
    default:
      return 'Some areas may benefit from additional support. Clinical review recommended.';
  }
}

int totalScoreFromAnswers(List<int?> answers) {
  return answers.fold<int>(0, (sum, v) => sum + (v ?? 0));
}

/// Maximum possible screening total (30 questions × 4).
const screeningMaxScore = 120;

/// Concern % shown on result screens: totalScore / 120 × 100.
int concernPercentFromScore(int totalScore) {
  return ((totalScore / screeningMaxScore) * 100).round();
}
