# Recommendation Engine

## 1. Purpose

This repository defines the production-style data ingestion, validation, cleaning, quarantine, monitoring and reporting layer for a recommendation engine.

The existing preprocessing architecture remains responsible for producing clean data. Recommendation-stage directories and module specifications prepare the next stages; they do not claim that recommendation behavior has been implemented or evaluated.

The project is designed for a system where historical interaction data already exists and new data will arrive regularly, potentially every day.

The repository is intentionally structured so that an AI coding agent can inspect the architecture and implement each Python module according to its module-level docstring.

## 2. Current Scope

The current stage covers:

- Raw data ingestion
- Incremental file discovery
- File manifests
- Staging
- Schema validation
- Missing-value validation
- Duplicate validation
- Identifier validation
- Datatype validation
- Timestamp validation
- Range validation
- Business-rule validation
- Referential-integrity validation
- Distribution monitoring
- Cleaning
- Quarantine
- Row-count tracking
- Data-quality reporting
- Data-drift monitoring
- Daily processing
- Historical backfill
- Full rebuild
- Automated tests

## 3. Stage Boundaries

Preprocessing ends at CLEAN DATA. Feature engineering and recommendation reasoning consume clean outputs in separate modules; they must not be mixed into cleaning.

- Feature engineering must not be performed by preprocessing modules.
- Raw data remains immutable; invalid data remains traceable through quarantine.
- Recommendation-stage specifications are architectural preparation, not validated algorithms.

## 4. Recommendation Architecture

`	ext
RAW DATA
   |
   v
INGESTION
   |
   v
STAGING
   |
   v
VALIDATION
   |
   +---- invalid ----> QUARANTINE
   |
   v
CLEANING
   |
   v
CLEAN DATA
   |
   v
FEATURE ENGINEERING
   |
   v
USER INTELLIGENCE
   |
   v
USER BEHAVIORAL PROFILE
   |
   v
AFFINITY MODEL
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

## 5. Data Sources

The project currently expects two conceptual datasets:

### Interaction Data

Historical user-interaction files are expected to arrive in:

`data/raw/interactions/`

The known core identifiers are:

- user_id
- wireid
- docid
- timestamp

The actual dataset must be inspected before implementation. Additional fields must not be invented.

### Article Metadata

Article/research metadata is expected in:

`data/raw/article_metadata/`

docid is the primary relationship key between article metadata and interaction records.

## 6. Directory Structure

`	ext
recommendation_engine/
|
+-- config/
|   +-- pipeline_config.yaml
|   +-- schema_config.yaml
|   +-- business_rules.yaml
|   +-- feature_config.yaml
|
+-- data/
|   +-- raw/
|   |   +-- interactions/
|   |   +-- article_metadata/
|   |
|   +-- staging/
|   |   +-- interactions/
|   |   +-- article_metadata/
|   |
|   +-- clean/
|   |   +-- interactions/
|   |   +-- article_metadata/
|   |
|   +-- features/
|       +-- user/
|       +-- article/
|       +-- interaction/
|       +-- behavioral/
|       +-- model_ready/
|
|   +-- quarantine/
|   |   +-- interactions/
|   |   +-- article_metadata/
|   |
|   +-- manifests/
|
+-- src/
|   +-- ingestion/
|   +-- validation/
|   +-- cleaning/
|   +-- features/
|   +-- user_intelligence/
|   +-- modeling/affinity/
|   +-- modeling/rules/
|   +-- monitoring/
|   +-- pipeline/
|   +-- utils/
|
+-- tests/
+-- reports/
|   +-- data_quality/
|   +-- schema/
|   +-- run_history/
|   +-- drift/
+-- logs/
+-- models/
+-- notebooks/
+-- docs/
+-- README.md
+-- requirements.txt
+-- .gitignore
```

## 7. Data Layer Principles

### Raw

Raw files are immutable source-of-truth inputs.

No cleaning or transformation should overwrite raw data.

### Staging

Staging contains data loaded from raw files with source traceability.

### Clean

Clean data contains records that have passed configured preprocessing rules.

### Quarantine

Quarantine contains records that cannot safely enter the clean dataset.

Records must not simply disappear.

### Manifest

The manifest tracks what happened to each source file.

## 8. Idempotency

Running the same daily pipeline twice should not duplicate successfully processed data.

The manifest and file identity information are used to determine whether a source file has already been processed.

A rerun should either:

1. Skip an already completed file, or
2. Explicitly reprocess it as a new controlled run.

The behavior must never accidentally append the same source data repeatedly.

## 9. Validation

Validation answers:

> Is the incoming data acceptable?

Validation must detect problems without silently modifying the data.

Examples include:

- Missing columns
- Unexpected columns
- Invalid datatypes
- Missing identifiers
- Duplicate records
- Invalid timestamps
- Invalid ranges
- Missing article references
- Unexpected categories
- Abnormal distributions

## 10. Cleaning

Cleaning answers:

> How should known data-quality problems be safely handled?

Cleaning rules must be configuration-driven where possible.

Examples include:

- Standardizing column names
- Trimming harmless whitespace
- Standardizing datatypes
- Normalizing timestamps
- Applying approved category mappings
- Removing confirmed duplicates
- Applying explicit business rules

## 11. Quarantine

Quarantine is mandatory for records that cannot safely be converted into valid clean records.

Each quarantined record should retain:

- Original record information
- Source file
- Run ID
- Rule or issue ID
- Severity
- Reason

This makes rejection auditable and allows later investigation.

## 12. Referential Integrity

Interaction records reference articles through docid.

The preprocessing pipeline must check whether interaction docids exist in the article metadata dataset.

Missing references must be reported explicitly.

The pipeline must not fabricate article metadata.

## 13. Daily Processing

The intended daily flow is:

`	ext
Discover files
      |
      v
Check manifest
      |
      v
Load new files
      |
      v
Pre-validation
      |
      v
Quarantine invalid records
      |
      v
Clean valid data
      |
      v
Post-clean validation
      |
      v
Write clean data
      |
      v
Update manifest
      |
      v
Generate reports
      |
      v
Update monitoring
```

## 14. Backfill

Backfill is used when historical files must be processed again.

The backfill pipeline must reuse the same validation and cleaning modules used by daily processing.

There should not be one set of rules for daily processing and another unrelated set for historical data.

## 15. Full Rebuild

A full rebuild is appropriate when:

- A cleaning rule changes
- A schema interpretation changes
- A serious implementation bug is discovered
- Historical data must be regenerated

The raw layer remains unchanged.

A new run ID should distinguish the rebuild from previous runs.

## 16. Monitoring

Important operational metrics include:

- Input rows
- Clean rows
- Quarantined rows
- Rejected percentage
- Unique users
- Unique articles
- Event distribution
- Missingness
- Referential-integrity coverage
- Daily volume
- Distribution changes

The purpose is to make data problems visible before they reach later recommendation stages.

## 17. Configuration

Business-specific values should not be scattered throughout Python code.

Configuration belongs primarily in:

- `pipeline_config.yaml`
- `schema_config.yaml`
- `business_rules.yaml`

The implementation should read these files rather than hard-code thresholds unnecessarily.

eature_config.yaml contains architecture defaults and experimental parameters, not validated model weights or assumed source fields.

## 18. AI Coding Agent Instructions

Before implementing anything, the coding agent must:

1. Read this README.
2. Read docs/data_pipeline_design.md.
3. Inspect every Python module docstring.
4. Inspect the configuration files.
5. Inspect the actual source data.
6. Confirm the real schema before implementing assumptions.

The coding agent must:

- Preserve the existing architecture.
- Implement the requested module responsibilities.
- Reuse utilities.
- Add tests.
- Add logging.
- Maintain idempotency.
- Maintain raw-data immutability.
- Preserve quarantine traceability.
- Avoid silent row deletion.
- Avoid invented business rules.
- Keep feature engineering outside preprocessing and consume clean data only.
- Do not claim recommendation algorithms are validated until evaluated on real data.

## 19. User Intelligence and Affinity

The core reasoning layer models why observed behavior may form a pattern, rather than only matching an article's surface similarity.

Profiles keep OBSERVED interactions, DERIVED behavioral patterns and INFERRED candidate interests separate, with evidence, confidence and time context.

Intent is inferred, not observed; it must never be presented as a confirmed personal or psychological fact. Configurable behavioral relationships may connect non-identical behaviors, but no relationship mapping is assumed until supported by inspected data and configuration.

Affinity combines interpretable configured components and preserves their contributions. The rule engine separately decides candidate eligibility and records each decision. Candidate generation, ranking and re-ranking are later stages after affinity and eligibility.

Daily profile updates should consume newly cleaned interactions using a recorded as-of cutoff, update evidence deterministically, and prevent future interactions from leaking into historical features or evaluations.

Matrix factorization is an optional future experiment, disabled by default. It may be activated only after evaluation of real data demonstrates sufficient collaborative signal and measurable value.

No recommendation quality or performance claim is made by this architecture scaffold.
