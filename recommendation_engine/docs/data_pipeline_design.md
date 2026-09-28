# Data Pipeline Design

## 1. Objective

Build a reliable preprocessing layer for a recommendation engine that receives historical data and continuing daily data.

The preprocessing system must make data quality visible, preserve source traceability and produce a clean dataset suitable for future feature engineering and recommendation modeling.

## 2. Architectural Philosophy

The architecture follows these principles:

1. Raw data is immutable.
2. Every source file is traceable.
3. Validation happens before cleaning.
4. Cleaning rules are explicit.
5. Invalid records are quarantined rather than silently dropped.
6. Every run has an identifier.
7. Daily processing is idempotent.
8. Historical backfill reuses production logic.
9. Configuration controls business-specific rules.
10. Monitoring exposes unexpected data changes.

## 3. Data Layers

### Raw

Exact source files.

### Staging

Loaded representation with source metadata.

### Clean

Validated and cleaned records suitable for later modeling.

### Quarantine

Records rejected by explicit rules, retained for investigation.

### Manifest

Operational record of source-file processing state.

## 4. Validation Architecture

Validation modules are intentionally separated so that each type of quality issue can be tested independently.

Validation categories:

- Schema
- Missing values
- Duplicates
- IDs
- Datatypes
- Timestamps
- Ranges
- Business rules
- Referential integrity
- Distribution

The validation runner combines these results.

## 5. Severity

Validation issues should have a severity such as:

- INFO
- WARNING
- ERROR
- BLOCKING

Severity determines whether processing can continue and whether a record must be quarantined.

The exact behavior should be configuration-driven.

## 6. Cleaning Architecture

Cleaning should be composed from small deterministic modules.

Recommended interaction cleaning order:

`	ext
Column standardization
        |
        v
ID standardization
        |
        v
Datatype standardization
        |
        v
Timestamp standardization
        |
        v
Missing-value handling
        |
        v
Duplicate removal
        |
        v
Category/event standardization
        |
        v
Business rules
        |
        v
Quarantine invalid records
```

The order may be adjusted if actual dataset characteristics require it, but any change should be deliberate and documented.

## 7. Auditability

Important transformations should produce audit information.

Examples:

- Number of rows before transformation
- Number of rows after transformation
- Number of rows quarantined
- Rule responsible
- Source file
- Run ID

This allows engineers to explain where rows went.

## 8. Daily Processing

Daily processing should be deterministic.

A successful file should not be processed repeatedly simply because the pipeline is run again.

The manifest provides the operational state required to support this.

## 9. Late Arriving Data

A file may arrive later than its logical data date.

The system should distinguish:

- File arrival date
- Data/event date

Late data should be processed according to the configured policy rather than silently ignored.

## 10. Failed Processing

A failed file should remain identifiable in the manifest.

The system should record:

- Failure status
- Error message
- Run ID
- Timestamp

Retry behavior should be deterministic.

## 11. Row Retention

Every major stage should provide row counts.

Example:

`	ext
Raw              1,000,000
Staging          1,000,000
Validated          998,000
Quarantine           2,000
Clean              998,000
```

The numbers above are illustrative only and must not be treated as expected results.

## 12. Data Drift

Data drift monitoring at this stage means monitoring changes in the incoming data distribution.

It does not mean model drift.

Examples include:

- Sudden interaction-volume changes
- Sudden changes in event proportions
- Sudden changes in missingness
- Sudden changes in unique-user counts
- Sudden changes in unique-article counts
- Sudden changes in referential-integrity coverage

## 13. Recommendation Architecture

Preprocessing remains unchanged and ends at CLEAN DATA. Separate recommendation stages consume clean outputs:

`	ext
CLEAN DATA
    |
    v
FEATURE ENGINEERING
    |
    v
USER INTELLIGENCE
    +-- History Analysis
    +-- Behavior Analysis
    +-- Intent Discovery
    +-- Preference Profiling
    +-- Behavioral Relationships
    |
    v
USER BEHAVIORAL PROFILE
    |
    v
AFFINITY ENGINE
    |
    v
CANDIDATE GENERATION
    |
    v
RULE ENGINE
    |
    v
RANKING / RE-RANKING
    |
    v
RECOMMENDATIONS
```

Feature engineering uses only actual inspected clean-data columns and metadata. It preserves user_id/docid/timestamp keys, repeated interaction evidence and an explicit as-of cutoff. Article features may use only real metadata fields; no embeddings or invented columns are assumed.

## 14. User Intelligence and Inference

User intelligence is the core reasoning layer: it analyzes chronological history and recurring patterns, then builds an interpretable profile that can explain affinities beyond exact article similarity.

The profile distinguishes:

- OBSERVED: source interactions and their timestamps/identifiers.
- DERIVED: recurring behavior patterns calculated from observations.
- INFERRED: candidate preferences or intents that may explain patterns.
- MODEL SIGNAL: configured affinity contribution from supported evidence.
- RULE: an auditable eligibility decision independent of affinity.

Intent is inferred rather than directly observed. Every candidate intent must carry evidence, confidence, supporting interaction references and time context. It is never a confirmed psychological, demographic or personal fact; multiple candidates and changing strength are allowed.

## 15. Behavioral Relationships and Preferences

Relationship logic supports direct similarity and higher-level connections between non-identical behaviors. It must be configuration-driven and auditable; empty configuration means no asserted domain relationships. Example topics are illustrative, not hard-coded rules.

Preference profiles distinguish persistent, emerging, recent and weak/uncertain signals, preserve evidence, and avoid one opaque preference score.

## 16. Affinity and Rules

Affinity combines configurable, interpretable components such as direct preference, behavioral relationship, recency, interaction strength, persistence and supported intent relevance. Component contributions, weight version and evidence are retained. Initial weights are experimental placeholders, not scientifically validated parameters, and must not be silently tuned.

The rule engine remains separate: it determines candidate eligibility, returns passed/failed status, rule ID, reason and affected candidate, and preserves priority/configuration audit details. No consumed-item, freshness or business policy is assumed unless explicitly configured.

Candidate generation follows user profile and affinity. Ranking and re-ranking are later stages and are not implemented by the intelligence pipeline.

## 17. Daily Profile Updates and Temporal Safety

Daily updates consume newly cleaned records, preserve prior evidence/profile versions, and record an as-of timestamp. Rebuilds from the same clean snapshot and configuration must be deterministic.

Features, profile evidence and evaluation snapshots may use only events at or before their as-of cutoff. Future interactions must never contribute to historical aggregates, labels or recommendation evaluation. Temporal association alone does not prove intent.

## 18. Optional Matrix-Factorization Experiment

Matrix factorization is not the primary architecture and is disabled by default. It remains an optional experiment that may be activated only if evaluation on real data demonstrates sufficient collaborative signal and measurable value. No matrix-factorization code or fabricated evaluation metrics are included in this scaffold.

## 19. Data and Evaluation Boundaries

The actual dataset is authoritative. The inspected scaffold currently documents interaction identifiers user_id, wireid, docid and timestamp, and article key docid; no raw or clean data files were present during scaffold design. Any additional columns, event semantics, metadata, intent mappings and business rules require inspection and explicit configuration.

Architecture specifications do not demonstrate that an algorithm works. Recommendation quality claims require real-data evaluation and documented methodology.

## 20. AI Implementation Instruction

An AI coding agent implementing this repository must first inspect:

- README.md
- docs/data_pipeline_design.md
- All Python module docstrings
- YAML configuration
- Actual data files

The agent should implement the requested responsibilities without redesigning the architecture.

If an actual data column contradicts an assumed placeholder, the real data should be treated as authoritative and the configuration/documentation should be updated explicitly.

The agent must not invent business semantics.

The agent must not move feature engineering into preprocessing or implement assumptions unsupported by actual data.
