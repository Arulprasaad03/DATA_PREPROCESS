"""
MODULE: src\ingestion\load_interactions.py

PURPOSE
-------
Load raw user-interaction files into the staging layer.

IMPLEMENTATION REQUIREMENTS
---------------------------
- Read raw interaction files without silently changing their contents.
- Attach source filename, source path, ingestion run ID and ingestion timestamp.
- Preserve the original source row identity where practical.
- Record source row counts and load failures.
- Write staged data using the configured intermediate format.
- Do not perform feature engineering.
- Do not train models.
- Do not silently drop malformed records; failures must be reported for validation or quarantine.

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
