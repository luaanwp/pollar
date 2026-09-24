---
version: 1
slug: "anagement-presentation-data-management-screen-dart"
primary_target: "apps/pollar_app/lib/features/data_management/presentation/data_management_screen.dart"
related_targets: []
---

# Dados e backup

- Scope and mode: operational local-data management inside the authenticated app shell; Operate.
- Audience and job: a person protecting private financial records needs to know exactly what will be copied or replaced.
- Primary tasks: create a complete local backup; select and inspect a backup; explicitly confirm a full local replacement.
- Required proof: exact record counts, creation date, schema version, and verified SHA-256 before restoration.
- Constraints: pt-BR, responsive Flutter, 200% text, flat Pollar surfaces, no cloud claims, no encryption claims, no mutation before full validation.
- Direction: a calm device inventory leads to two named actions; warning copy treats the JSON as sensitive plaintext.
- Memorable moment: the destructive sheet turns an opaque file into a concrete, verified inventory before the replacement action.
- Unresolved: encryption and remote sync remain separate future slices.
