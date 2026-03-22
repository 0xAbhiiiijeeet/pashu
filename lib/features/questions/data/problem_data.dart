import '../domain/models/problem_models.dart';

// Static seed data for the Animal Problems screen.
// Replace / extend as the backend drives this dynamically.

/// Quick-access chips shown at the top of the screen ("Talk to Pashu Bhai").
const List<ProblemItem> talkToBrotherItems = [
  ProblemItem(label: 'Prevent Loss'),
  ProblemItem(label: 'Increase Earnings'),
  ProblemItem(label: 'Heat Not Coming'),
  ProblemItem(label: 'Repeat Heat'),
  ProblemItem(label: 'AI Failure'),
  ProblemItem(label: 'Weak Pregnancy'),
  ProblemItem(label: 'Watery Milk'),
  ProblemItem(label: 'Udder Injury'),
  ProblemItem(label: 'Weak Calf'),
  ProblemItem(label: 'Not Eating Fodder'),
  ProblemItem(label: 'Hoof Blisters'),
  ProblemItem(label: 'Fever'),
  ProblemItem(label: 'Lack of Milk'),
  ProblemItem(label: 'Increase Rate'),
];

/// Full categorised problem data — all sections and items in English.
const ProblemCategory animalProblemsData = ProblemCategory(
  categoryTitle: 'Animal Problems',
  sections: [
    // ── Earnings ──────────────────────────────────────────────────────────────
    ProblemSection(
      title: 'Earning from Animals',
      items: [
        ProblemItem(label: 'Increase Animal Rate'),
        ProblemItem(label: 'Avoid Harm'),
        ProblemItem(label: 'Increase Earnings'),
        ProblemItem(label: 'Dairy Development'),
      ],
    ),

    // ── Mastitis (Thanela) ────────────────────────────────────────────────────
    ProblemSection(
      title: 'Mastitis',
      items: [
        ProblemItem(label: 'Udder Heat'),
        ProblemItem(label: 'Udder Hardness'),
        ProblemItem(label: 'Udder Swelling'),
        ProblemItem(label: 'Pain While Milking'),
        ProblemItem(label: 'Milk Drop Suddenly'),
        ProblemItem(label: 'Blood in Milk'),
        ProblemItem(label: 'Clots in Milk'),
        ProblemItem(label: 'Pus in Milk'),
        ProblemItem(label: 'Stringy Milk'),
        ProblemItem(label: 'Watery Milk'),
        ProblemItem(label: 'Redness'),
      ],
    ),

    // ── Low Milk ──────────────────────────────────────────────────────────────
    ProblemSection(
      title: 'Low Milk',
      items: [
        ProblemItem(label: 'Sudden Milk Drop'),
        ProblemItem(label: 'Fodder Related'),
        ProblemItem(label: 'Stress Related'),
        ProblemItem(label: 'Gradual Milk Drop'),
        ProblemItem(label: 'Low After Calving'),
      ],
    ),

    // ── Udder Problems ────────────────────────────────────────────────────────
    ProblemSection(
      title: 'Udder Problems',
      items: [
        ProblemItem(label: 'Blocked Teat'),
        ProblemItem(label: 'Teat Cut'),
        ProblemItem(label: 'Teat Cracks'),
        ProblemItem(label: 'Thick Milk in Teat'),
        ProblemItem(label: 'Wound on Teat'),
        ProblemItem(label: 'Teat Injury'),
        ProblemItem(label: 'Teat Swelling'),
        ProblemItem(label: 'Teat Hernia'),
      ],
    ),

    // ── Heat Problems ─────────────────────────────────────────────────────────
    ProblemSection(
      title: 'Heat Problems',
      items: [
        ProblemItem(label: 'Early Heat'),
        ProblemItem(label: 'Repeat Heat'),
        ProblemItem(label: 'Silent Heat'),
        ProblemItem(label: 'Heat Symptoms'),
        ProblemItem(label: 'No Heat'),
      ],
    ),

    // ── Conception Problems ───────────────────────────────────────────────────
    ProblemSection(
      title: 'Conception Problems',
      items: [
        ProblemItem(label: 'AI Failure'),
        ProblemItem(label: 'Pregnancy Not Holding'),
        ProblemItem(label: 'Short Heat'),
        ProblemItem(label: 'Repeat Breeding'),
        ProblemItem(label: 'Long Heat'),
      ],
    ),

    // ── Pregnancy ─────────────────────────────────────────────────────────────
    ProblemSection(
      title: 'Pregnancy',
      items: [
        ProblemItem(label: 'Weak Fetus'),
        ProblemItem(label: 'Pregnancy Check'),
        ProblemItem(label: 'Twin Pregnancy'),
        ProblemItem(label: 'High-Risk Pregnancy'),
      ],
    ),

    // ── Pre-Calving ───────────────────────────────────────────────────────────
    ProblemSection(
      title: 'Before Calving',
      items: [
        ProblemItem(label: 'Udder Filling Early'),
        ProblemItem(label: 'Belly Dropping'),
        ProblemItem(label: 'Vulva Swelling'),
        ProblemItem(label: 'White Discharge'),
      ],
    ),

    // ── Post-Calving ──────────────────────────────────────────────────────────
    ProblemSection(
      title: 'After Calving',
      items: [
        ProblemItem(label: 'Uterus Prolapse'),
        ProblemItem(label: 'Uterine Infection'),
        ProblemItem(label: 'Uterine Swelling'),
        ProblemItem(label: 'Thick Discharge'),
        ProblemItem(label: 'Injury'),
        ProblemItem(label: 'Placenta Not Passing'),
        ProblemItem(label: 'No Milk After Calving'),
        ProblemItem(label: 'Watery Discharge'),
        ProblemItem(label: 'Yellow Discharge'),
        ProblemItem(label: 'Vaginal Prolapse'),
        ProblemItem(label: 'White Discharge'),
      ],
    ),

    // ── Milk Fever ────────────────────────────────────────────────────────────
    ProblemSection(
      title: 'Milk Fever',
      items: [
        ProblemItem(label: 'Cold Ears'),
        ProblemItem(label: 'Crooked Neck (Stage 1)'),
        ProblemItem(label: 'Crooked Neck'),
        ProblemItem(label: 'Cow Unable to Stand'),
      ],
    ),

    // ── Ketosis ───────────────────────────────────────────────────────────────
    ProblemSection(
      title: 'Ketosis',
      items: [
        ProblemItem(label: 'Not Eating Fodder'),
        ProblemItem(label: 'Low Milk'),
        ProblemItem(label: 'Sweet Breath Smell'),
      ],
    ),

    // ── Weakness ──────────────────────────────────────────────────────────────
    ProblemSection(
      title: 'Weakness',
      items: [
        ProblemItem(label: 'Unable to Stand'),
        ProblemItem(label: 'Trembling'),
        ProblemItem(label: 'Sitting for Long'),
      ],
    ),

    // ── Mineral Deficiency ────────────────────────────────────────────────────
    ProblemSection(
      title: 'Mineral Deficiency',
      items: [
        ProblemItem(label: 'Licking Walls'),
        ProblemItem(label: 'Eating Stones'),
        ProblemItem(label: 'Pica'),
        ProblemItem(label: 'Eating Mud'),
      ],
    ),

    // ── Breathing Problems ────────────────────────────────────────────────────
    ProblemSection(
      title: 'Breathing Problems',
      items: [
        ProblemItem(label: 'Cough'),
        ProblemItem(label: 'Thick Nasal Discharge'),
        ProblemItem(label: 'Rapid Breathing'),
        ProblemItem(label: 'Runny Nose'),
        ProblemItem(label: 'Pneumonia'),
        ProblemItem(label: 'Fever + Cough'),
        ProblemItem(label: 'Breathing Sound'),
      ],
    ),

    // ── Lumpy Disease ─────────────────────────────────────────────────────────
    ProblemSection(
      title: 'Lumpy Disease',
      items: [
        ProblemItem(label: 'Lumps / Knots'),
        ProblemItem(label: 'Low Milk'),
        ProblemItem(label: 'Leg Swelling'),
        ProblemItem(label: 'Fever'),
      ],
    ),

    // ── FMD ───────────────────────────────────────────────────────────────────
    ProblemSection(
      title: 'FMD',
      items: [
        ProblemItem(label: 'Blisters on Hooves'),
        ProblemItem(label: 'Mouth Sores'),
        ProblemItem(label: 'Limping'),
        ProblemItem(label: 'Drooling'),
      ],
    ),

    // ── Haemorrhagic Septicaemia ──────────────────────────────────────────────
    ProblemSection(
      title: 'Haemorrhagic Septicaemia',
      items: [
        ProblemItem(label: 'Sudden Death'),
        ProblemItem(label: 'Swelling Under Jaw'),
        ProblemItem(label: 'Very High Fever'),
      ],
    ),

    // ── Internal Worms ────────────────────────────────────────────────────────
    ProblemSection(
      title: 'Internal Worms',
      items: [
        ProblemItem(label: 'Worms Visible'),
        ProblemItem(label: 'Weight Loss'),
        ProblemItem(label: 'White Dung'),
      ],
    ),

    // ── Lameness ──────────────────────────────────────────────────────────────
    ProblemSection(
      title: 'Lameness',
      items: [
        ProblemItem(label: 'Hoof Cracks'),
        ProblemItem(label: 'Hoof Rotting'),
        ProblemItem(label: 'Unable to Walk'),
        ProblemItem(label: 'Joint Pain'),
        ProblemItem(label: 'Leg Swelling'),
        ProblemItem(label: 'Fracture'),
        ProblemItem(label: 'Limping'),
      ],
    ),

    // ── Skin Problems ─────────────────────────────────────────────────────────
    ProblemSection(
      title: 'Skin Problems',
      items: [
        ProblemItem(label: 'Wound'),
        ProblemItem(label: 'Lice or Tick'),
        ProblemItem(label: 'Abscess / Boil'),
        ProblemItem(label: 'Hair Loss'),
        ProblemItem(label: 'Fly Infestation'),
        ProblemItem(label: 'Itching'),
        ProblemItem(label: 'Swelling'),
      ],
    ),

    // ── Fodder Problems ───────────────────────────────────────────────────────
    ProblemSection(
      title: 'Fodder Problems',
      items: [
        ProblemItem(label: 'Not Eating Fodder'),
        ProblemItem(label: 'Problem Changing Feed'),
        ProblemItem(label: 'Feed Toxicity'),
        ProblemItem(label: 'Diet Imbalance'),
        ProblemItem(label: 'Drinking Less Water'),
      ],
    ),

    // ── Calf Health ───────────────────────────────────────────────────────────
    ProblemSection(
      title: 'Calf Health',
      items: [
        ProblemItem(label: 'Weak Calf'),
        ProblemItem(label: 'Joint Infection'),
        ProblemItem(label: 'Not Drinking Milk'),
        ProblemItem(label: 'Navel Infection'),
        ProblemItem(label: 'Calf Diarrhea'),
        ProblemItem(label: 'Calf Pneumonia'),
      ],
    ),

    // ── General ───────────────────────────────────────────────────────────────
    ProblemSection(
      title: 'General',
      items: [
        ProblemItem(label: 'Sudden Inactivity'),
        ProblemItem(label: 'Fever'),
        ProblemItem(label: 'Body Pain'),
        ProblemItem(label: 'General Weakness'),
        ProblemItem(label: 'Lethargy'),
      ],
    ),
  ],
);
