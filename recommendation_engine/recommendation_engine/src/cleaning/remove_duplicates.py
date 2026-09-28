"""
MODULE: src\cleaning\remove_duplicates.py

PURPOSE
-------
Remove only duplicates that have been confirmed by configured rules.

IMPLEMENTATION REQUIREMENTS
---------------------------
- Use exact or business-key definitions from configuration.
- Preserve legitimate repeated interactions.
- Make duplicate removal deterministic.
- Record how many rows were removed.
- Record which rule caused removal.
- Never silently remove records.

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
