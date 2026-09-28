"""
MODULE: src\ingestion\load_article_metadata.py

PURPOSE
-------
Load article/research metadata into the staging layer.

IMPLEMENTATION REQUIREMENTS
---------------------------
- Read the configured article metadata source.
- Preserve docid as the primary article reference.
- Attach ingestion and source metadata.
- Record source row counts and loading errors.
- Do not create embeddings.
- Do not create recommendation features.
- Do not train or score any model.
- Keep the staged representation traceable to the original metadata file.

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
