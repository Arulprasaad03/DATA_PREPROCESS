# Recommendation Engine - Data Preprocessing Pipeline

## 1. Purpose

This repository defines the production-style data ingestion, validation, cleaning, quarantine, monitoring and reporting layer for a recommendation engine.

The current implementation scope is deliberately limited to data preprocessing.

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

## 3. Explicitly Out of Scope

The following must NOT be implemented in this preprocessing stage:

- Feature engineering
- User embeddings
- Article embeddings
- Candidate generation
- Ranking
- Re-ranking
- Matrix factorization
- Model training
- Model evaluation
- Recommendation serving
- Online recommendation APIs

These belong to later stages.

## 4. Future High-Level Architecture

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
MODEL-READY DATA
   |
   v
MATRIX FACTORIZATION
   |
   v
CANDIDATE GENERATION
   |
   v
RANKING
   |
   v
RE-RANKING
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
- Avoid feature engineering at this stage.
- Avoid model training at this stage.

## 19. Future Recommendation Stage

After preprocessing is stable, the project can progress to:

1. Feature engineering
2. User/item interaction representation
3. Matrix factorization
4. Candidate generation
5. Ranking
6. Re-ranking
7. Evaluation
8. Recommendation serving

Those stages should consume the clean, validated dataset rather than directly consuming raw files.
