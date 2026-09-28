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

## 13. Future Recommendation System

The clean dataset will later become the input to a separate modeling layer.

That later layer may contain:

`	ext
Clean data
    |
    v
Feature engineering
    |
    v
Model-ready interactions
    |
    v
Matrix factorization
    |
    v
Candidate generation
    |
    v
Ranking
    |
    v
Re-ranking
```

This repository deliberately stops before that stage.

## 14. AI Implementation Instruction

An AI coding agent implementing this repository must first inspect:

- README.md
- docs/data_pipeline_design.md
- All Python module docstrings
- YAML configuration
- Actual data files

The agent should implement the requested responsibilities without redesigning the architecture.

If an actual data column contradicts an assumed placeholder, the real data should be treated as authoritative and the configuration/documentation should be updated explicitly.

The agent must not invent business semantics.

The agent must not implement feature engineering, recommendation models or recommendation serving in this preprocessing repository.
