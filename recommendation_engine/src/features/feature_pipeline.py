"""
MODULE: src\features\feature_pipeline.py

PURPOSE
-------
Orchestrate feature generation from clean data into data/features.

IMPLEMENTATION REQUIREMENTS
---------------------------
- Consume data/clean only and never read raw data as a feature source.
- Coordinate user, article, interaction, temporal and aggregate feature modules.
- Write configured outputs below data/features/user, article, interaction, behavioral and model_ready.
- Support deterministic daily updates and preserve run/as-of metadata.
- Do not modify preprocessing outputs or raw data.

ARCHITECTURAL CONSTRAINTS
------------------------
- Raw data must remain immutable.
- Validation and cleaning must remain separate responsibilities.
- Invalid records must be traceable through quarantine.
- Configuration should contain business-specific rules.
- Processing should be deterministic and idempotent.
- Every important transformation must be auditable.
- Do not silently discard records.
- Do not invent business rules.
- Do not perform feature engineering in preprocessing modules.
- Do not train recommendation models in preprocessing modules.

EXPECTED AI CODING AGENT BEHAVIOR
--------------------------------
- Inspect the repository before implementing.
- Inspect actual input data before assuming column names or types.
- Read configuration before hard-coding thresholds.
- Reuse existing utilities instead of duplicating logic.
- Add tests for important behavior.
- Preserve the directory architecture.
"""

# Implementation intentionally left for the coding phase.
