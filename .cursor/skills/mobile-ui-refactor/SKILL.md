---
name: mobile-ui-refactor
description: >-
  Refactors and overhauls mobile app UI for clarity, delight, and usability.
  Use when redesigning screens, improving layouts, Material 3 / Flutter UI
  polish, dark-mode-first design, motion, or when the user asks for a major
  visual refresh, UI refactor, or "make it look better" on mobile.
---

# Mobile UI refactor

## Mindset

- **Favor the greater good**: If a full restructure (navigation, information architecture, component breakdown) serves users better than tweaks, propose and implement it.
- **Layout Changes** are normally better and more impactful then colors. Suggest significant UI refactors that can benefit the user experience and feel of the app.
- **Mobile-first**: Thumb zones, 48dp minimum touch targets, scroll affordances, safe areas, one-hand use where possible.
- **Dark-mode-native**: Contrast, elevation without harsh borders, readable secondary text, no "light theme pasted onto dark."

## Workflow

1. **Audit** — Note primary user goals on this screen, pain points (density, hierarchy, discoverability), and what must stay (data, actions).
2. **Redesign intent** — State the visual/UX direction in one short paragraph before coding (e.g. "card-based scores, hero current player, bottom actions").
3. **Implement** — Theme tokens, reusable widgets, consistent spacing (8px grid), semantic structure.
4. **Motion** — Meaningful transitions (page/sheet, list updates, emphasis); avoid gratuitous animation.
5. **Verify** — Large text, TalkBack/Semantics labels where needed, tap targets, no overflow on small widths.

## Flutter / Material 3 (this project)

- Use **Theme.of(context)** / **ColorScheme** / **TextTheme**; avoid hardcoded colors except intentional brand accents.
- Align with project rules: **Material 3 Expressive**, **playful** tone, **dark mode**, **Pooker** context; animations where they add fun without hurting clarity.
- Prefer **composition** over giant build methods; extract sections into private widgets or files when refactoring heavily.
- Use **const** where possible; avoid unnecessary rebuilds after large UI changes.

## Checklist (major refactors)

- [ ] Clear visual hierarchy (one focal point per screen where it makes sense)
- [ ] Spacing and typography scale consistent with theme
- [ ] Primary actions obvious; destructive/secondary de-emphasized
- [ ] Loading / empty / error states considered if applicable
- [ ] Accessibility: contrast, semantics, touch size

## Output style

When doing large UI changes: briefly summarize **what changed and why** for the user, then deliver code. Offer optional follow-ups (e.g. micro-interactions, illustration hooks) only if they fit scope.
