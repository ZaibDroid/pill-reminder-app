---
name: MediAlert Clinical Humanist
colors:
  surface: '#f7f9fb'
  surface-dim: '#d8dadc'
  surface-bright: '#f7f9fb'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f4f6'
  surface-container: '#eceef0'
  surface-container-high: '#e6e8ea'
  surface-container-highest: '#e0e3e5'
  on-surface: '#191c1e'
  on-surface-variant: '#3d4947'
  inverse-surface: '#2d3133'
  inverse-on-surface: '#eff1f3'
  outline: '#6d7a77'
  outline-variant: '#bcc9c6'
  surface-tint: '#006a61'
  primary: '#00685f'
  on-primary: '#ffffff'
  primary-container: '#008378'
  on-primary-container: '#f4fffc'
  inverse-primary: '#6bd8cb'
  secondary: '#006e2f'
  on-secondary: '#ffffff'
  secondary-container: '#6bff8f'
  on-secondary-container: '#007432'
  tertiary: '#b61722'
  on-tertiary: '#ffffff'
  tertiary-container: '#da3437'
  on-tertiary-container: '#fffbff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#89f5e7'
  primary-fixed-dim: '#6bd8cb'
  on-primary-fixed: '#00201d'
  on-primary-fixed-variant: '#005049'
  secondary-fixed: '#6bff8f'
  secondary-fixed-dim: '#4ae176'
  on-secondary-fixed: '#002109'
  on-secondary-fixed-variant: '#005321'
  tertiary-fixed: '#ffdad7'
  tertiary-fixed-dim: '#ffb3ad'
  on-tertiary-fixed: '#410004'
  on-tertiary-fixed-variant: '#930013'
  background: '#f7f9fb'
  on-background: '#191c1e'
  surface-variant: '#e0e3e5'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-sm:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  baseline: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  2xl: 48px
  gutter: 16px
  margin-mobile: 16px
  margin-desktop: 64px
---

## Brand & Style

The design system is built upon a **Corporate Modern** foundation infused with **Humanist** warmth. It prioritizes clarity and accessibility to serve a diverse user base, ranging from chronic care patients to elderly users. 

The aesthetic is characterized by "Clinical Softness"—utilizing the precision of healthcare interfaces but removing the coldness through generous whitespace, soft edges, and supportive color theory. The UI must evoke an emotional response of security, reliability, and calm, ensuring that managing health feels like a supportive partnership rather than a technical chore.

## Colors

The palette is rooted in medical efficacy and psychological safety.

- **Primary (Calm Teal):** Used for primary actions, branding, and active states. It provides a professional, stable anchor for the interface.
- **Success (Green):** Specifically reserved for positive health actions, such as "Medication Taken" or "Course Completed."
- **Warning (Red):** Used sparingly for missed doses, critical alerts, or low-stock notifications.
- **Backgrounds:** Use a tiered neutral system. The base surface is `#FFFFFF`, while the app background is a very soft `#F8FAFC` to reduce eye strain and provide contrast for white cards.

## Typography

This design system utilizes **Inter** exclusively to leverage its exceptional legibility and systematic weights. 

- **Scale:** Font sizes are slightly larger than standard web defaults to accommodate users with visual impairments.
- **Hierarchy:** Medication names should always use `headline-md` or `headline-sm` to ensure they are the first thing a user sees. 
- **Time/Dosage:** Use `label-md` with high-contrast neutral tones for secondary but vital data points.
- **Readability:** Maintain a minimum contrast ratio of 4.5:1 for all body text against its background.

## Layout & Spacing

The layout follows a **Fluid Grid** model with a focus on vertical rhythm.

- **Mobile:** A 4-column grid with 16px margins. Content should be stacked to allow for large, tappable card elements.
- **Tablet/Desktop:** A 12-column grid. On larger screens, the layout should utilize "side-car" panels for dose history or drug information to avoid excessive line lengths.
- **Touch Targets:** All interactive elements (buttons, toggles, checkboxes) must have a minimum hit area of 48x48px. 
- **Rhythm:** Use the 4px baseline for all internal component spacing (padding/margins) to ensure a tight, professional finish.

## Elevation & Depth

Hierarchy is established through **Tonal Layers** and subtle **Ambient Shadows**.

1.  **Level 0 (Background):** `#F8FAFC` - The canvas.
2.  **Level 1 (Cards):** `#FFFFFF` - Used for the primary content containers. These feature a very soft, diffused shadow: `0px 4px 20px rgba(0, 0, 0, 0.05)`.
3.  **Level 2 (Modals/Overlays):** `#FFFFFF` - Used for urgent pill reminders. These use a more pronounced shadow: `0px 10px 30px rgba(0, 0, 0, 0.1)`.

Avoid heavy borders; instead, use 1px strokes in a light neutral (`#E2E8F0`) only when elements need to be differentiated on a white background.

## Shapes

The shape language is defined by **Rounded (2)** settings to emphasize approachability and safety.

- **Standard Elements:** Buttons and input fields use a `0.5rem` (8px) radius.
- **Cards:** Medication cards use `1.5rem` (rounded-xl / 24px) to create a friendly, "holding" feel for health data.
- **Status Indicators:** Small dots or dose markers should be fully circular (pill-shaped) to distinguish them from structural UI components.

## Components

- **Medication Cards:** The hero component. Use `rounded-xl`, white background, and a subtle left-border accent in the Primary color to indicate "Upcoming" or Success color for "Taken."
- **Buttons:** Primary buttons use a solid Teal background with white text. "Take Dose" buttons should be full-width on mobile to maximize the touch target.
- **Chips:** Used for medication categories (e.g., "Supplement," "Prescription"). These should have a light tinted background of the primary color with dark text.
- **Input Fields:** Use large text and 16px internal padding. Labels must always be visible (not floating) for cognitive clarity.
- **Progress Ring:** A custom component to show daily adherence, utilizing the Success Green to provide positive reinforcement.
- **Lists:** High-density lists (like history) should use `1px` dividers in `#F1F5F9` and generous vertical padding (16px) between items.