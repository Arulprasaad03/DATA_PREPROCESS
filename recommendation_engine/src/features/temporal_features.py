"""
MODULE: src\features\temporal_features.py

PURPOSE
-------
Derive reproducible time-window, recency and sequence features.

IMPLEMENTATION REQUIREMENTS
---------------------------
- Use a configured as-of time and configured recent, medium and long-term windows.
- Prevent future events from contributing to historical snapshots.
- Represent sequences in chronological order with deterministic tie handling.
- Do not claim temporal correlation proves intent.

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
