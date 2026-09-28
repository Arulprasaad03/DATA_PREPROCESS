# ============================================================
# RECOMMENDATION ENGINE - PROJECT SCAFFOLD GENERATOR
# ============================================================
# Purpose:
#   Creates the complete preprocessing/data-pipeline repository.
#
# IMPORTANT:
#   This script creates ARCHITECTURE + DOCUMENTATION only.
#   It does NOT implement the actual data-processing logic.
#
#   The Python files contain detailed module docstrings.
#   An AI coding agent can later inspect:
#       README.md
#       docs/data_pipeline_design.md
#       config/*.yaml
#       src/**/*.py
#       tests/**/*.py
#
#   and implement the repository without redesigning the architecture.
# ============================================================

$ErrorActionPreference = "Stop"

# ------------------------------------------------------------
# PROJECT ROOT
# ------------------------------------------------------------

$root = Join-Path (Get-Location) "recommendation_engine"

Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host " Recommendation Engine Project Generator" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Project location:"
Write-Host $root
Write-Host ""

# ------------------------------------------------------------
# HELPER: CREATE DIRECTORY
# ------------------------------------------------------------

function New-Dir {
    param(
        [string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

# ------------------------------------------------------------
# HELPER: WRITE FILE
# ------------------------------------------------------------

function Write-ProjectFile {
    param(
        [string]$RelativePath,
        [string]$Content,
        [switch]$Overwrite
    )

    $fullPath = Join-Path $root $RelativePath
    $parent = Split-Path -Parent $fullPath

    if ((Test-Path -LiteralPath $fullPath) -and -not $Overwrite) {
        Write-Host "  Preserved: $RelativePath" -ForegroundColor DarkYellow
        return
    }

    if ($parent) {
        New-Dir $parent
    }

    [System.IO.File]::WriteAllText(
        $fullPath,
        $Content,
        [System.Text.UTF8Encoding]::new($false)
    )

    Write-Host "  Created: $RelativePath" -ForegroundColor DarkGray
}

# ------------------------------------------------------------
# CREATE PROJECT DIRECTORIES
# ------------------------------------------------------------

$directories = @(
    "config",

    "data",
    "data\raw",
    "data\raw\interactions",
    "data\raw\article_metadata",

    "data\staging",
    "data\staging\interactions",
    "data\staging\article_metadata",

    "data\clean",
    "data\clean\interactions",
    "data\clean\article_metadata",

    "data\features",
    "data\features\user",
    "data\features\article",
    "data\features\interaction",
    "data\features\behavioral",
    "data\features\model_ready",

    "data\quarantine",
    "data\quarantine\interactions",
    "data\quarantine\article_metadata",

    "data\manifests",

    "src",
    "src\ingestion",
    "src\validation",
    "src\cleaning",
    "src\features",
    "src\user_intelligence",
    "src\modeling",
    "src\modeling\affinity",
    "src\modeling\rules",
    "src\monitoring",
    "src\pipeline",
    "src\utils",

    "tests",

    "reports",
    "reports\data_quality",
    "reports\schema",
    "reports\run_history",
    "reports\drift",

    "logs",
    "models",
    "notebooks",
    "docs"
)

Write-Host "Creating directories..." -ForegroundColor Green

foreach ($dir in $directories) {
    New-Dir (Join-Path $root $dir)
}

Write-Host ""
Write-Host "Creating Python modules..." -ForegroundColor Green

# ============================================================
# PYTHON MODULE SPECIFICATIONS
# ============================================================
# Each specification is converted automatically into a Python
# module-level docstring.
# ============================================================

$specs = @(

    # --------------------------------------------------------
    # INGESTION
    # --------------------------------------------------------

    [PSCustomObject]@{
        Path = "src\ingestion\discover_files.py"
        Purpose = "Discover and classify files arriving in the raw data directories."
        Requirements = @(
            "Search configured raw interaction and article-metadata locations.",
            "Support CSV, XLSX, XLS and other explicitly configured formats.",
            "Collect filename, full path, extension, file size, modification time and content hash.",
            "Use the processing manifest to determine whether a file is new, already processed, failed, changed or duplicated.",
            "Do not modify raw files.",
            "Do not clean, transform, impute or engineer features.",
            "Return structured discovery results that downstream ingestion modules can consume.",
            "Support normal daily ingestion as well as historical backfill."
        )
    },

    [PSCustomObject]@{
        Path = "src\ingestion\load_interactions.py"
        Purpose = "Load raw user-interaction files into the staging layer."
        Requirements = @(
            "Read raw interaction files without silently changing their contents.",
            "Attach source filename, source path, ingestion run ID and ingestion timestamp.",
            "Preserve the original source row identity where practical.",
            "Record source row counts and load failures.",
            "Write staged data using the configured intermediate format.",
            "Do not perform feature engineering.",
            "Do not train models.",
            "Do not silently drop malformed records; failures must be reported for validation or quarantine."
        )
    },

    [PSCustomObject]@{
        Path = "src\ingestion\load_article_metadata.py"
        Purpose = "Load article/research metadata into the staging layer."
        Requirements = @(
            "Read the configured article metadata source.",
            "Preserve docid as the primary article reference.",
            "Attach ingestion and source metadata.",
            "Record source row counts and loading errors.",
            "Do not create embeddings.",
            "Do not create recommendation features.",
            "Do not train or score any model.",
            "Keep the staged representation traceable to the original metadata file."
        )
    },

    [PSCustomObject]@{
        Path = "src\ingestion\incremental_loader.py"
        Purpose = "Coordinate incremental discovery and loading for daily arrivals."
        Requirements = @(
            "Determine which files require processing using the manifest and file identity.",
            "Support idempotent daily execution.",
            "Avoid reprocessing successfully completed files unless explicitly requested.",
            "Detect changed files using hashes or other configured identity information.",
            "Support retries for failed files.",
            "Support both daily processing and historical backfill.",
            "Keep incremental logic separate from validation and cleaning logic."
        )
    },

    [PSCustomObject]@{
        Path = "src\ingestion\manifest_manager.py"
        Purpose = "Maintain the processing manifest and lifecycle state of every source file."
        Requirements = @(
            "Persist file name, source path, hash, size, date, run ID and row counts.",
            "Track schema validation status.",
            "Track cleaning status.",
            "Track final processing status.",
            "Track errors and warnings.",
            "Support states such as DISCOVERED, INGESTED, VALIDATED, CLEANED, COMPLETED, QUARANTINED, FAILED and SKIPPED.",
            "Make processing idempotent and auditable.",
            "Never treat the manifest as a replacement for the immutable raw data."
        )
    },

    # --------------------------------------------------------
    # VALIDATION
    # --------------------------------------------------------

    [PSCustomObject]@{
        Path = "src\validation\schema_validator.py"
        Purpose = "Validate the structure and schema of incoming datasets."
        Requirements = @(
            "Check required columns.",
            "Detect missing columns.",
            "Detect unexpected columns.",
            "Check configured datatype expectations.",
            "Support schema versioning.",
            "Compare schemas across incoming files.",
            "Return structured validation issues with severity and evidence.",
            "Do not modify the input data."
        )
    },

    [PSCustomObject]@{
        Path = "src\validation\missing_value_validator.py"
        Purpose = "Detect missing and empty values without performing cleaning."
        Requirements = @(
            "Detect null, NaN, empty string and whitespace-only values.",
            "Recognize configured textual missing-value representations such as NA, N/A and null.",
            "Calculate missing counts and percentages.",
            "Compare missingness with configured thresholds.",
            "Support historical missingness comparisons.",
            "Do not automatically impute or delete records.",
            "Return machine-readable validation results."
        )
    },

    [PSCustomObject]@{
        Path = "src\validation\duplicate_validator.py"
        Purpose = "Detect duplicate records while distinguishing legitimate repeated interactions."
        Requirements = @(
            "Detect exact row duplicates.",
            "Detect configured business-key duplicates.",
            "Detect duplicate records across files.",
            "Detect duplicate records across processing days.",
            "Do not assume repeated user interactions are duplicates.",
            "Use configured business semantics when deciding whether repetition is legitimate.",
            "Return duplicate counts, examples and severity."
        )
    },

    [PSCustomObject]@{
        Path = "src\validation\id_validator.py"
        Purpose = "Validate user_id, wireid and docid identifiers."
        Requirements = @(
            "Check required identifiers for missing values.",
            "Detect empty and whitespace-only identifiers.",
            "Validate configured datatype expectations.",
            "Detect unexpected formatting.",
            "Preserve meaningful leading zeros.",
            "Detect inconsistent identifier representation.",
            "Never invent identifiers.",
            "Never merge identifiers unless an explicit configured rule exists."
        )
    },

    [PSCustomObject]@{
        Path = "src\validation\referential_integrity_validator.py"
        Purpose = "Validate relationships between interaction records and article metadata."
        Requirements = @(
            "Validate that interaction docid values can be resolved against article metadata docid values.",
            "Detect interaction records whose article reference is missing from metadata.",
            "Detect duplicate article metadata keys.",
            "Calculate referential-integrity coverage.",
            "Report unresolved references separately from generic missing values.",
            "Do not fabricate missing article metadata.",
            "Make the validation result available to the quality report."
        )
    },

    [PSCustomObject]@{
        Path = "src\validation\datatype_validator.py"
        Purpose = "Validate canonical datatypes before cleaning."
        Requirements = @(
            "Validate identifier, timestamp, date, category, numeric and event-related fields.",
            "Detect mixed-type columns.",
            "Detect values that cannot be safely converted.",
            "Separate datatype violations from valid type variation.",
            "Use schema configuration rather than hard-coded assumptions.",
            "Do not silently coerce invalid values.",
            "Return examples of problematic values."
        )
    },

    [PSCustomObject]@{
        Path = "src\validation\timestamp_validator.py"
        Purpose = "Validate timestamps and dates."
        Requirements = @(
            "Check timestamp parseability.",
            "Detect missing timestamps.",
            "Detect impossible or malformed timestamps.",
            "Detect unexpected future timestamps.",
            "Validate configured timezone expectations.",
            "Detect inconsistent timestamp precision.",
            "Identify chronological anomalies where relevant.",
            "Report timestamp distributions for monitoring."
        )
    },

    [PSCustomObject]@{
        Path = "src\validation\range_validator.py"
        Purpose = "Validate numeric and configured business ranges."
        Requirements = @(
            "Read permitted ranges from configuration.",
            "Identify hard range violations.",
            "Separate hard violations from statistical anomalies.",
            "Provide counts and representative examples.",
            "Avoid inventing arbitrary thresholds.",
            "Keep business-specific thresholds in configuration."
        )
    },

    [PSCustomObject]@{
        Path = "src\validation\business_rule_validator.py"
        Purpose = "Validate explicit business semantics defined by configuration."
        Requirements = @(
            "Apply only documented business rules.",
            "Do not invent domain rules from assumptions.",
            "Return rule ID, affected records, severity and explanation.",
            "Allow rules to be enabled or disabled through configuration.",
            "Keep validation separate from cleaning.",
            "Make every rule auditable."
        )
    },

    [PSCustomObject]@{
        Path = "src\validation\distribution_validator.py"
        Purpose = "Measure dataset distributions and compare them with historical behavior."
        Requirements = @(
            "Measure total row volume.",
            "Measure unique users and unique articles.",
            "Measure interactions per user and per article.",
            "Measure event-type distributions.",
            "Measure category distributions when those fields exist.",
            "Measure missingness and referential-integrity rates.",
            "Compare current distributions with historical baselines.",
            "Flag meaningful anomalies without automatically deleting data."
        )
    },

    [PSCustomObject]@{
        Path = "src\validation\data_quality_runner.py"
        Purpose = "Orchestrate all configured validation modules."
        Requirements = @(
            "Run schema, missing-value, duplicate, ID, datatype, timestamp, range and business-rule validation.",
            "Run referential-integrity validation when both datasets are available.",
            "Run distribution checks.",
            "Create a consolidated issue inventory.",
            "Classify issues by severity.",
            "Identify blocking versus non-blocking issues.",
            "Produce machine-readable and human-readable validation results.",
            "Do not perform cleaning inside the validation runner."
        )
    },

    # --------------------------------------------------------
    # CLEANING
    # --------------------------------------------------------

    [PSCustomObject]@{
        Path = "src\cleaning\standardize_columns.py"
        Purpose = "Map incoming column names to canonical project column names."
        Requirements = @(
            "Use configured aliases and canonical names.",
            "Handle harmless differences such as case and whitespace where configured.",
            "Record every column mapping.",
            "Detect ambiguous mappings.",
            "Do not silently discard unexpected columns.",
            "Do not perform feature engineering."
        )
    },

    [PSCustomObject]@{
        Path = "src\cleaning\clean_missing_values.py"
        Purpose = "Apply configured missing-value handling rules."
        Requirements = @(
            "Use field-level configuration.",
            "Support retain, standardize, impute, reject and quarantine behaviors where explicitly configured.",
            "Do not apply blanket dropna logic.",
            "Preserve an audit trail of affected records.",
            "Report before-and-after counts.",
            "Do not invent imputation values."
        )
    },

    [PSCustomObject]@{
        Path = "src\cleaning\remove_duplicates.py"
        Purpose = "Remove only duplicates that have been confirmed by configured rules."
        Requirements = @(
            "Use exact or business-key definitions from configuration.",
            "Preserve legitimate repeated interactions.",
            "Make duplicate removal deterministic.",
            "Record how many rows were removed.",
            "Record which rule caused removal.",
            "Never silently remove records."
        )
    },

    [PSCustomObject]@{
        Path = "src\cleaning\standardize_ids.py"
        Purpose = "Normalize identifier representation without changing identity."
        Requirements = @(
            "Trim harmless whitespace.",
            "Apply canonical datatype conversion.",
            "Preserve meaningful leading zeros.",
            "Apply explicitly configured formatting rules.",
            "Do not generate new IDs.",
            "Do not merge users or articles."
        )
    },

    [PSCustomObject]@{
        Path = "src\cleaning\standardize_datatypes.py"
        Purpose = "Convert fields to schema-defined canonical datatypes."
        Requirements = @(
            "Read datatype definitions from schema configuration.",
            "Perform safe conversions.",
            "Detect conversion failures.",
            "Send invalid records to quarantine when configured.",
            "Record conversion statistics.",
            "Never silently coerce invalid information into misleading values."
        )
    },

    [PSCustomObject]@{
        Path = "src\cleaning\standardize_timestamps.py"
        Purpose = "Normalize valid timestamps and dates."
        Requirements = @(
            "Parse timestamps using configured formats.",
            "Apply configured timezone handling.",
            "Normalize timestamp precision where required.",
            "Preserve valid temporal meaning.",
            "Do not fabricate missing timestamps.",
            "Quarantine values that cannot be safely interpreted."
        )
    },

    [PSCustomObject]@{
        Path = "src\cleaning\standardize_categories.py"
        Purpose = "Normalize categorical values using approved mappings."
        Requirements = @(
            "Trim whitespace and normalize configured casing.",
            "Apply explicitly configured aliases.",
            "Map only approved equivalent values.",
            "Report unknown categories.",
            "Do not invent category mappings.",
            "Record all mappings for auditability."
        )
    },

    [PSCustomObject]@{
        Path = "src\cleaning\apply_business_rules.py"
        Purpose = "Apply explicit business cleaning rules."
        Requirements = @(
            "Read rules from business_rules.yaml.",
            "Apply only documented rules.",
            "Separate valid transformations from record rejection.",
            "Record rule IDs and affected row counts.",
            "Quarantine records that violate configured hard rules.",
            "Do not create recommendation features."
        )
    },

    [PSCustomObject]@{
        Path = "src\cleaning\clean_interactions.py"
        Purpose = "Orchestrate the complete interaction-data cleaning workflow."
        Requirements = @(
            "Apply canonical column naming.",
            "Standardize identifiers.",
            "Standardize datatypes.",
            "Standardize timestamps.",
            "Handle configured missing values.",
            "Remove confirmed duplicates.",
            "Standardize configured categorical/event values.",
            "Apply explicit business rules.",
            "Send invalid records to quarantine.",
            "Produce cleaning statistics and an audit trail.",
            "Do not perform feature engineering or model training."
        )
    },

    [PSCustomObject]@{
        Path = "src\cleaning\clean_article_metadata.py"
        Purpose = "Orchestrate cleaning of article metadata."
        Requirements = @(
            "Standardize article metadata column names.",
            "Validate and normalize docid.",
            "Standardize configured datatypes.",
            "Normalize timestamps and dates where applicable.",
            "Normalize configured categorical values.",
            "Handle configured missing values.",
            "Remove only confirmed duplicate article records.",
            "Apply explicit business rules.",
            "Do not create embeddings or recommendation features."
        )
    },

    [PSCustomObject]@{
        Path = "src\cleaning\quarantine_invalid_records.py"
        Purpose = "Persist invalid records separately instead of silently deleting them."
        Requirements = @(
            "Preserve the original record.",
            "Store source file information.",
            "Store pipeline run ID.",
            "Store issue ID or rule ID.",
            "Store severity and rejection reason.",
            "Keep quarantined records separate from clean data.",
            "Support later investigation and reprocessing.",
            "Never treat quarantine as successful clean data."
        )
    },

    # --------------------------------------------------------
    # MONITORING
    # --------------------------------------------------------

    [PSCustomObject]@{
        Path = "src\monitoring\generate_quality_report.py"
        Purpose = "Generate data-quality reports for every processing run."
        Requirements = @(
            "Summarize source files and row counts.",
            "Summarize validation results.",
            "Summarize cleaning actions.",
            "Summarize quarantined records.",
            "Summarize retained clean records.",
            "Show important quality trends.",
            "Write reports into reports/data_quality.",
            "Make reports understandable to both engineers and data stakeholders."
        )
    },

    [PSCustomObject]@{
        Path = "src\monitoring\generate_run_summary.py"
        Purpose = "Create a concise operational summary for each pipeline run."
        Requirements = @(
            "Record run ID.",
            "Record start and end time.",
            "Record processing mode.",
            "Record files discovered, processed, skipped and failed.",
            "Record input, output and quarantine row counts.",
            "Record warnings and errors.",
            "Record final pipeline status.",
            "Write results into reports/run_history."
        )
    },

    [PSCustomObject]@{
        Path = "src\monitoring\track_data_drift.py"
        Purpose = "Monitor changes in incoming data distributions."
        Requirements = @(
            "Track daily interaction volume.",
            "Track unique users and articles.",
            "Track event distributions.",
            "Track category distributions when available.",
            "Track missingness.",
            "Track referential-integrity coverage.",
            "Compare current data with configured historical baselines.",
            "Do not implement model drift or model-performance monitoring at this stage."
        )
    },

    [PSCustomObject]@{
        Path = "src\monitoring\track_row_counts.py"
        Purpose = "Track row retention through every pipeline layer."
        Requirements = @(
            "Track raw row counts.",
            "Track staging row counts.",
            "Track validated row counts.",
            "Track cleaned row counts.",
            "Track quarantined row counts.",
            "Track final output row counts.",
            "Track counts by source, date and run ID where available.",
            "Make unexpected row loss visible."
        )
    },

    [PSCustomObject]@{
        Path = "src\monitoring\track_rejected_records.py"
        Purpose = "Monitor rejected and quarantined records."
        Requirements = @(
            "Count rejected records by dataset.",
            "Count rejected records by validation or cleaning rule.",
            "Track severity.",
            "Track rejection rate.",
            "Track source file and processing date.",
            "Compare rejection rates across runs.",
            "Flag sudden increases in rejection."
        )
    },

    # --------------------------------------------------------
    # PIPELINE
    # --------------------------------------------------------

    [PSCustomObject]@{
        Path = "src\pipeline\daily_pipeline.py"
        Purpose = "Define the production-like daily preprocessing workflow."
        Requirements = @(
            "Create a unique pipeline run ID.",
            "Load configuration.",
            "Discover new source files.",
            "Update the processing manifest.",
            "Load files into staging.",
            "Run pre-clean validation.",
            "Separate invalid records according to configured rules.",
            "Run cleaning.",
            "Run post-clean validation.",
            "Write clean data.",
            "Write quarantine data.",
            "Update manifest status.",
            "Generate reports.",
            "Generate monitoring outputs.",
            "Be deterministic, restartable and idempotent.",
            "Do not perform feature engineering, matrix factorization or recommendation generation."
        )
    },

    [PSCustomObject]@{
        Path = "src\pipeline\backfill_pipeline.py"
        Purpose = "Process selected historical dates or files using the same production logic."
        Requirements = @(
            "Accept a configured date range or file selection.",
            "Reuse daily pipeline modules instead of duplicating processing logic.",
            "Support historical reprocessing.",
            "Generate the same validation, quarantine and monitoring outputs.",
            "Support retrying failed historical files.",
            "Keep raw data unchanged.",
            "Do not introduce separate cleaning rules for backfill."
        )
    },

    [PSCustomObject]@{
        Path = "src\pipeline\full_pipeline.py"
        Purpose = "Perform a complete rebuild when schemas, rules or implementation bugs require reprocessing."
        Requirements = @(
            "Process the complete configured raw dataset.",
            "Reuse ingestion, validation, cleaning and monitoring modules.",
            "Preserve historical run information.",
            "Never modify the raw layer.",
            "Allow a new run ID to distinguish the rebuild.",
            "Support comparison with previous pipeline runs.",
            "Do not perform feature engineering or model training."
        )
    },

    # --------------------------------------------------------
    # UTILITIES
    # --------------------------------------------------------

    [PSCustomObject]@{
        Path = "src\utils\logging_utils.py"
        Purpose = "Provide centralized structured logging."
        Requirements = @(
            "Support INFO, WARNING, ERROR and DEBUG levels.",
            "Include pipeline run ID when available.",
            "Include module and operation information.",
            "Support console and file logging.",
            "Log exceptions with useful context.",
            "Do not log secrets or sensitive user information."
        )
    },

    [PSCustomObject]@{
        Path = "src\utils\file_utils.py"
        Purpose = "Provide generic filesystem and file-identity utilities."
        Requirements = @(
            "Create directories safely.",
            "List files using configured extensions.",
            "Calculate file hashes.",
            "Read file metadata.",
            "Build standardized project paths.",
            "Do not contain business validation logic."
        )
    },

    [PSCustomObject]@{
        Path = "src\utils\date_utils.py"
        Purpose = "Provide consistent date and time utilities."
        Requirements = @(
            "Parse configured date formats.",
            "Handle configured timezone.",
            "Generate daily partition identifiers.",
            "Generate date ranges for backfill.",
            "Normalize run dates.",
            "Avoid inconsistent date handling across pipeline modules."
        )
    },

    [PSCustomObject]@{
        Path = "src\utils\validation_utils.py"
        Purpose = "Provide reusable low-level validation helpers."
        Requirements = @(
            "Provide null checks.",
            "Provide datatype checks.",
            "Calculate percentages and rates.",
            "Build structured validation results.",
            "Handle severity levels.",
            "Create representative samples.",
            "Compare distributions.",
            "Do not contain dataset-specific business rules."
        )
    },

    # --------------------------------------------------------
    # TESTS
    # --------------------------------------------------------

    [PSCustomObject]@{
        Path = "tests\test_schema.py"
        Purpose = "Test schema validation and schema standardization."
        Requirements = @(
            "Test required-column detection.",
            "Test unexpected-column detection.",
            "Test datatype expectations.",
            "Test valid and invalid schemas.",
            "Test schema version handling."
        )
    },

    [PSCustomObject]@{
        Path = "tests\test_cleaning.py"
        Purpose = "Test deterministic data-cleaning behavior."
        Requirements = @(
            "Test identifier normalization.",
            "Test datatype conversion.",
            "Test timestamp normalization.",
            "Test missing-value rules.",
            "Test duplicate handling.",
            "Test categorical normalization.",
            "Verify legitimate repeated interactions are preserved."
        )
    },

    [PSCustomObject]@{
        Path = "tests\test_referential_integrity.py"
        Purpose = "Test interaction-to-article metadata relationships."
        Requirements = @(
            "Test valid article references.",
            "Test missing article references.",
            "Test duplicate article keys.",
            "Test referential-integrity percentages.",
            "Test configured failure thresholds."
        )
    },

    [PSCustomObject]@{
        Path = "tests\test_business_rules.py"
        Purpose = "Test configured business validation and cleaning rules."
        Requirements = @(
            "Test each configured rule independently.",
            "Test valid records.",
            "Test invalid records.",
            "Test severity classification.",
            "Test quarantine behavior."
        )
    },

    [PSCustomObject]@{
        Path = "tests\test_pipeline.py"
        Purpose = "Test end-to-end pipeline behavior."
        Requirements = @(
            "Test daily pipeline execution on controlled sample data.",
            "Test idempotent reruns.",
            "Test manifest state transitions.",
            "Test quarantine behavior.",
            "Test row-count retention.",
            "Test failed-run handling.",
            "Test backfill and full-run orchestration."
        )
    },

    # --------------------------------------------------------
    # FEATURE ENGINEERING
    # --------------------------------------------------------

    [PSCustomObject]@{
        Path = "src\features\__init__.py"
        Purpose = "Expose the feature-engineering package without coupling it to preprocessing."
        Requirements = @("Feature engineering consumes clean datasets only.")
    },

    [PSCustomObject]@{
        Path = "src\features\user_features.py"
        Purpose = "Build user-level activity features without inferring intent."
        Requirements = @(
            "Measure interaction frequency, diversity, recency, recent activity and historical activity using observed fields only.",
            "Read user, article and timestamp columns from configuration based on the inspected schema.",
            "Do not infer intent or psychological, demographic or personal attributes.",
            "Preserve user identifiers and deterministic output."
        )
    },

    [PSCustomObject]@{
        Path = "src\features\article_features.py"
        Purpose = "Represent article metadata using only fields actually present in clean metadata."
        Requirements = @(
            "Preserve docid as the article key.",
            "Select metadata fields through configuration after inspecting the real dataset.",
            "Do not invent metadata fields or create embeddings."
        )
    },

    [PSCustomObject]@{
        Path = "src\features\interaction_features.py"
        Purpose = "Represent observed interaction strength using configurable semantics."
        Requirements = @(
            "Use configured event-strength mappings only when an event field and its values have been verified.",
            "Do not treat repeated interactions as duplicates by default.",
            "Retain user_id, docid, timestamp and traceable source keys where available."
        )
    },

    [PSCustomObject]@{
        Path = "src\features\temporal_features.py"
        Purpose = "Derive reproducible time-window, recency and sequence features."
        Requirements = @(
            "Use a configured as-of time and configured recent, medium and long-term windows.",
            "Prevent future events from contributing to historical snapshots.",
            "Represent sequences in chronological order with deterministic tie handling.",
            "Do not claim temporal correlation proves intent."
        )
    },

    [PSCustomObject]@{
        Path = "src\features\aggregation_features.py"
        Purpose = "Build deterministic user, article and interaction aggregates."
        Requirements = @(
            "Support configured time windows and aggregation keys.",
            "Use an explicit as-of cutoff to prevent temporal leakage.",
            "Do not discard repeated interactions unless an explicit rule requires it."
        )
    },

    [PSCustomObject]@{
        Path = "src\features\feature_validation.py"
        Purpose = "Validate generated feature datasets before they are written."
        Requirements = @(
            "Check configured datatypes, missing values, infinite values, key uniqueness and configured ranges.",
            "Check feature timestamps against the as-of cutoff for temporal leakage.",
            "Check deterministic output for identical inputs and configuration.",
            "Return structured issues without silently changing or dropping rows."
        )
    },

    [PSCustomObject]@{
        Path = "src\features\feature_pipeline.py"
        Purpose = "Orchestrate feature generation from clean data into data/features."
        Requirements = @(
            "Consume data/clean only and never read raw data as a feature source.",
            "Coordinate user, article, interaction, temporal and aggregate feature modules.",
            "Write configured outputs below data/features/user, article, interaction, behavioral and model_ready.",
            "Support deterministic daily updates and preserve run/as-of metadata.",
            "Do not modify preprocessing outputs or raw data."
        )
    },

    # --------------------------------------------------------
    # USER INTELLIGENCE
    # --------------------------------------------------------

    [PSCustomObject]@{
        Path = "src\user_intelligence\__init__.py"
        Purpose = "Expose the user-intelligence reasoning package."
        Requirements = @("Keep observed, derived and inferred information distinguishable.")
    },

    [PSCustomObject]@{
        Path = "src\user_intelligence\history_analyzer.py"
        Purpose = "Analyze each user's chronological interaction history with evidence."
        Requirements = @(
            "Identify repeated, recent, persistent, changing and isolated behavior plus long-term versus recent patterns.",
            "Retain supporting interaction references and time context for every derived pattern.",
            "Use only configured, verified input fields."
        )
    },

    [PSCustomObject]@{
        Path = "src\user_intelligence\behavior_analyzer.py"
        Purpose = "Identify recurring behavioral structures and their evidence strength."
        Requirements = @(
            "Analyze configured patterns, sequences, transitions, frequency, persistence, recency and behavior relationships.",
            "Distinguish strong from weak evidence using explicit configurable criteria.",
            "Keep behavior analysis separate from intent inference."
        )
    },

    [PSCustomObject]@{
        Path = "src\user_intelligence\intent_detector.py"
        Purpose = "Produce evidence-backed candidate intents as uncertain inferences."
        Requirements = @(
            "Represent candidate_intent, evidence, confidence, supporting_interactions and time_context.",
            "Allow multiple candidate intents and time-varying strength.",
            "Never represent inferred intent as a confirmed personal, psychological or demographic fact.",
            "Do not hard-code domain concepts; use configured/evolved relationship definitions."
        )
    },

    [PSCustomObject]@{
        Path = "src\user_intelligence\preference_profiler.py"
        Purpose = "Build an evidence-preserving profile of persistent, emerging, recent and uncertain preferences."
        Requirements = @(
            "Consider configured frequency, diversity, recency, persistence and interaction-strength signals.",
            "Label evidence quality and preserve supporting observations.",
            "Do not collapse the profile into one opaque score."
        )
    },

    [PSCustomObject]@{
        Path = "src\user_intelligence\behavior_relationships.py"
        Purpose = "Connect behaviorally related but non-identical signals through configurable relationships."
        Requirements = @(
            "Support direct similarity and higher-level behavioral relationships.",
            "Load relationship rules or mappings from configuration; keep unconfigured mappings empty.",
            "Return relationship evidence, provenance and confidence rather than assuming surface text identity.",
            "Do not hard-code example topics or infer unsupported semantics from unavailable metadata."
        )
    },

    [PSCustomObject]@{
        Path = "src\user_intelligence\user_profile_builder.py"
        Purpose = "Build a versioned, interpretable profile from user-intelligence outputs."
        Requirements = @(
            "Combine history, behavior, candidate intents, preferences, behavior relationships, recency and evidence.",
            "Keep OBSERVED, DERIVED and INFERRED sections explicitly separate.",
            "Attach profile version, as-of time and provenance to generated profiles.",
            "Do not reduce all concepts to one opaque preference value."
        )
    },

    [PSCustomObject]@{
        Path = "src\user_intelligence\user_intelligence_pipeline.py"
        Purpose = "Orchestrate deterministic daily user-profile updates."
        Requirements = @(
            "Run history, behavior, intent, preference, behavioral-relationship and profile-building stages in order.",
            "Support incremental daily updates while allowing deterministic rebuilds from clean data.",
            "Preserve evidence and as-of boundaries.",
            "Do not perform final recommendation ranking."
        )
    },

    # --------------------------------------------------------
    # AFFINITY AND RULE ENGINE
    # --------------------------------------------------------

    [PSCustomObject]@{
        Path = "src\modeling\__init__.py"
        Purpose = "Expose recommendation modeling components while keeping affinity and rules separate."
        Requirements = @("Do not make matrix factorization the default model.")
    },

    [PSCustomObject]@{
        Path = "src\modeling\affinity\__init__.py"
        Purpose = "Expose interpretable user-to-article affinity components."
        Requirements = @("Keep configurable affinity distinct from eligibility rules.")
    },

    [PSCustomObject]@{
        Path = "src\modeling\affinity\affinity_calculator.py"
        Purpose = "Calculate interpretable user-to-article affinity components."
        Requirements = @(
            "Support direct preference, behavioral relationship, recency, interaction strength, persistence and supported intent relevance.",
            "Read versioned experimental weights from configuration and preserve component contributions.",
            "Do not describe placeholder weights as scientifically validated."
        )
    },

    [PSCustomObject]@{
        Path = "src\modeling\affinity\affinity_matrix.py"
        Purpose = "Represent user-article affinity efficiently without unnecessary dense matrices."
        Requirements = @(
            "Support sparse representation, user IDs, article IDs and incremental updates.",
            "Preserve deterministic keys and configured storage semantics."
        )
    },

    [PSCustomObject]@{
        Path = "src\modeling\affinity\affinity_weights.py"
        Purpose = "Load and audit versioned affinity weights."
        Requirements = @(
            "Centralize configurable experimental weights.",
            "Record version and provenance; do not silently tune weights."
        )
    },

    [PSCustomObject]@{
        Path = "src\modeling\affinity\affinity_model.py"
        Purpose = "Provide deterministic single, batch and incremental affinity scoring."
        Requirements = @(
            "Accept a user profile and article representation and return score, component contributions and evidence metadata.",
            "Support configured thresholds and deterministic ordering.",
            "Keep eligibility decisions outside the affinity model."
        )
    },

    [PSCustomObject]@{
        Path = "src\modeling\rules\__init__.py"
        Purpose = "Expose auditable recommendation eligibility and business rules."
        Requirements = @("Rules remain separate from affinity calculation.")
    },

    [PSCustomObject]@{
        Path = "src\modeling\rules\rule_engine.py"
        Purpose = "Evaluate configured candidate rules and return an audit trail."
        Requirements = @(
            "Return passed/failed, rule ID, reason and affected candidate for every decision.",
            "Support rule priority and enable/disable configuration.",
            "Do not mix rule decisions into affinity scores."
        )
    },

    [PSCustomObject]@{
        Path = "src\modeling\rules\eligibility_rules.py"
        Purpose = "Evaluate explicitly configured candidate eligibility constraints."
        Requirements = @(
            "Provide interfaces for consumed-article exclusion, freshness and user-specific constraints only when configured.",
            "Do not invent default business rules or freshness windows.",
            "Make every decision auditable."
        )
    },

    [PSCustomObject]@{
        Path = "src\modeling\rules\business_rules.py"
        Purpose = "Apply configurable recommendation business rules after affinity scoring."
        Requirements = @(
            "Support rule priority, enable/disable settings and an audit trail.",
            "Keep business policy separate from affinity calculation.",
            "Apply only explicitly configured rules."
        )
    },

    # --------------------------------------------------------
    # RECOMMENDATION-STAGE TEST SPECIFICATIONS
    # --------------------------------------------------------

    [PSCustomObject]@{
        Path = "tests\test_features.py"
        Purpose = "Specify tests for feature generation, validation and temporal correctness."
        Requirements = @(
            "Test feature generation, validation, deterministic execution and aggregate correctness.",
            "Test temporal leakage prevention using explicit as-of cutoffs.",
            "Test repeated interactions are retained unless an explicit rule says otherwise."
        )
    },

    [PSCustomObject]@{
        Path = "tests\test_user_intelligence.py"
        Purpose = "Specify tests for evidence-backed user-intelligence behavior."
        Requirements = @(
            "Test history, repeated behavior, recency, persistence, intent confidence and preference profiling.",
            "Test configurable behavioral relationships, evidence preservation and deterministic profiles.",
            "Test that OBSERVED, DERIVED and INFERRED information remains distinct."
        )
    },

    [PSCustomObject]@{
        Path = "tests\test_affinity.py"
        Purpose = "Specify tests for interpretable affinity and configurable weights."
        Requirements = @(
            "Test direct preference, behavioral relationship, recency and interaction-strength components.",
            "Test component contributions, deterministic scores and configurable weights."
        )
    }
)

# ============================================================
# GENERATE PYTHON FILES
# ============================================================

$pythonHeader = @(
    "Generated project skeleton.",
    "This file intentionally contains architecture documentation rather than a finished implementation.",
    "",
    "Implementation rule:",
    "Read this complete docstring together with README.md,",
    "docs/data_pipeline_design.md and the configuration files",
    "before implementing this module.",
    "",
    "Do not redesign the project architecture unless a real",
    "technical contradiction is discovered."
)

$pythonCount = 0

foreach ($spec in $specs) {

    $lines = @()

    $lines += '"""'
    $lines += "MODULE: $($spec.Path)"
    $lines += ""
    $lines += "PURPOSE"
    $lines += "-------"
    $lines += $spec.Purpose
    $lines += ""
    $lines += "IMPLEMENTATION REQUIREMENTS"
    $lines += "---------------------------"

    foreach ($requirement in $spec.Requirements) {
        $lines += "- $requirement"
    }

    $lines += ""
    $lines += "ARCHITECTURAL CONSTRAINTS"
    $lines += "------------------------"
    $lines += "- Raw data must remain immutable."
    $lines += "- Validation and cleaning must remain separate responsibilities."
    $lines += "- Invalid records must be traceable through quarantine."
    $lines += "- Configuration should contain business-specific rules."
    $lines += "- Processing should be deterministic and idempotent."
    $lines += "- Every important transformation must be auditable."
    $lines += "- Do not silently discard records."
    $lines += "- Do not invent business rules."
    $lines += "- Do not perform feature engineering in preprocessing modules."
    $lines += "- Do not train recommendation models in preprocessing modules."
    $lines += ""
    $lines += "EXPECTED AI CODING AGENT BEHAVIOR"
    $lines += "--------------------------------"
    $lines += "- Inspect the repository before implementing."
    $lines += "- Inspect actual input data before assuming column names or types."
    $lines += "- Read configuration before hard-coding thresholds."
    $lines += "- Reuse existing utilities instead of duplicating logic."
    $lines += "- Add tests for important behavior."
    $lines += "- Preserve the directory architecture."
    $lines += '"""'
    $lines += ""
    $lines += "# Implementation intentionally left for the coding phase."
    $lines += ""

    Write-ProjectFile $spec.Path ($lines -join "`r`n")
    $pythonCount++
}

# ============================================================
# CONFIGURATION FILES
# ============================================================

$pipelineConfig = @(
    "# ============================================================",
    "# PIPELINE CONFIGURATION",
    "# ============================================================",
    "",
    "project:",
    "  name: recommendation_engine",
    "  stage: preprocessing",
    "  preprocessing_status: current",
    "  recommendation_architecture: user_intelligence_affinity",
    "",
    "processing:",
    "  mode: daily",
    "  timezone: Asia/Kolkata",
    "  idempotent: true",
    "  preserve_raw: true",
    "  quarantine_invalid: true",
    "",
    "formats:",
    "  preferred_intermediate: parquet",
    "  supported_input:",
    "    - csv",
    "    - xlsx",
    "    - xls",
    "",
    "paths:",
    "  raw_interactions: data/raw/interactions",
    "  raw_article_metadata: data/raw/article_metadata",
    "  staging_interactions: data/staging/interactions",
    "  staging_article_metadata: data/staging/article_metadata",
    "  clean_interactions: data/clean/interactions",
    "  clean_article_metadata: data/clean/article_metadata",
    "  features_user: data/features/user",
    "  features_article: data/features/article",
    "  features_interaction: data/features/interaction",
    "  features_behavioral: data/features/behavioral",
    "  features_model_ready: data/features/model_ready",
    "  quarantine_interactions: data/quarantine/interactions",
    "  quarantine_article_metadata: data/quarantine/article_metadata",
    "  manifests: data/manifests",
    "  reports: reports",
    "  logs: logs",
    "",
    "monitoring:",
    "  enabled: true",
    "  row_count_tracking: true",
    "  rejection_tracking: true",
    "  distribution_tracking: true",
    "  drift_tracking: true",
    "",
    "stages:",
    "  preprocessing:",
    "    status: current",
    "    output: data/clean",
    "  feature_engineering:",
    "    status: next",
    "    enabled: true",
    "  user_intelligence:",
    "    status: next",
    "    enabled: true",
    "  affinity_model:",
    "    status: intended_core_model",
    "    enabled: true",
    "  rule_engine:",
    "    status: next",
    "    enabled: true",
    "  candidate_generation:",
    "    status: future",
    "    enabled: false",
    "  ranking:",
    "    status: future",
    "    enabled: false",
    "  reranking:",
    "    status: future",
    "    enabled: false",
    "  matrix_factorization:",
    "    enabled: false",
    "    experimental: true",
    "    activation_requires_evaluation: true"
)

Write-ProjectFile "config\pipeline_config.yaml" ($pipelineConfig -join "`r`n") -Overwrite

$featureConfig = @(
    "# Experimental architecture defaults; values are not validated model parameters.",
    "feature_engineering:",
    "  enabled: true",
    "  deterministic: true",
    "  input_layer: data/clean",
    "  output_root: data/features",
    "  as_of_timestamp: null",
    "",
    "time_windows:",
    "  recent_days: 7",
    "  medium_days: 30",
    "  long_term_days: 180",
    "",
    "columns:",
    "  user_id: user_id",
    "  article_id: docid",
    "  timestamp: timestamp",
    "  event_type: null",
    "  article_metadata_fields: []",
    "",
    "interaction_strength:",
    "  default_strength: 1.0",
    "  event_weights: {}",
    "  repeated_interactions_are_valid: true",
    "",
    "user_intelligence:",
    "  enabled: true",
    "  history_analysis: true",
    "  behavior_analysis: true",
    "  intent_detection: true",
    "  preference_profiling: true",
    "  behavior_relationships: true",
    "  candidate_intent_rules: []",
    "  behavioral_relationship_rules: []",
    "",
    "affinity:",
    "  enabled: true",
    "  weight_version: experimental-v1",
    "  weights_are_validated: false",
    "  direct_preference_weight: 1.0",
    "  behavioral_relationship_weight: 1.0",
    "  recency_weight: 1.0",
    "  interaction_strength_weight: 1.0",
    "  persistence_weight: 1.0",
    "  intent_relevance_weight: 1.0",
    "",
    "matrix_factorization:",
    "  enabled: false",
    "  experimental: true",
    "  activation_requires_evaluation: true"
)

Write-ProjectFile "config\feature_config.yaml" ($featureConfig -join "`r`n")

$schemaConfig = @(
    "# ============================================================",
    "# SCHEMA CONFIGURATION",
    "# ============================================================",
    "#",
    "# IMPORTANT:",
    "# Replace placeholders with the real schema after inspecting",
    "# the incoming datasets.",
    "# Do not invent fields that do not exist in the source data.",
    "# ============================================================",
    "",
    "interaction_schema:",
    "  required_columns:",
    "    - user_id",
    "    - wireid",
    "    - docid",
    "    - timestamp",
    "",
    "  optional_columns: []",
    "",
    "  identifiers:",
    "    user_id:",
    "      required: true",
    "    wireid:",
    "      required: true",
    "    docid:",
    "      required: true",
    "",
    "article_metadata_schema:",
    "  required_columns:",
    "    - docid",
    "",
    "  optional_columns: []",
    "",
    "timestamp:",
    "  timezone: Asia/Kolkata",
    "  allow_future: false",
    "",
    "schema_policy:",
    "  reject_missing_required_columns: true",
    "  warn_unexpected_columns: true",
    "  fail_on_incompatible_datatype: true"
)

Write-ProjectFile "config\schema_config.yaml" ($schemaConfig -join "`r`n")

$businessRulesConfig = @(
    "# ============================================================",
    "# BUSINESS RULE CONFIGURATION",
    "# ============================================================",
    "#",
    "# IMPORTANT:",
    "# These are intentionally conservative placeholders.",
    "# Replace or extend them only after the actual business",
    "# requirements and source-data semantics are confirmed.",
    "# ============================================================",
    "",
    "rules:",
    "  missing_required_identifier:",
    "    enabled: true",
    "    severity: blocking",
    "    action: quarantine",
    "",
    "  invalid_timestamp:",
    "    enabled: true",
    "    severity: blocking",
    "    action: quarantine",
    "",
    "  unresolved_article_reference:",
    "    enabled: true",
    "    severity: warning",
    "    action: report",
    "",
    "  duplicate_article_key:",
    "    enabled: true",
    "    severity: blocking",
    "    action: quarantine",
    "",
    "  unexpected_category:",
    "    enabled: true",
    "    severity: warning",
    "    action: report",
    "",
    "thresholds:",
    "  maximum_missingness_warning_percent: 10",
    "  maximum_quarantine_warning_percent: 5",
    "  minimum_referential_integrity_percent: 95"
)

Write-ProjectFile "config\business_rules.yaml" ($businessRulesConfig -join "`r`n")

# ============================================================
# README
# ============================================================

$readme = @(
    "# Recommendation Engine",
    "",
    "## 1. Purpose",
    "",
    "This repository defines the production-style data ingestion, validation, cleaning, quarantine, monitoring and reporting layer for a recommendation engine.",
    "",
    "The existing preprocessing architecture remains responsible for producing clean data. Recommendation-stage directories and module specifications prepare the next stages; they do not claim that recommendation behavior has been implemented or evaluated.",
    "",
    "The project is designed for a system where historical interaction data already exists and new data will arrive regularly, potentially every day.",
    "",
    "The repository is intentionally structured so that an AI coding agent can inspect the architecture and implement each Python module according to its module-level docstring.",
    "",
    "## 2. Current Scope",
    "",
    "The current stage covers:",
    "",
    "- Raw data ingestion",
    "- Incremental file discovery",
    "- File manifests",
    "- Staging",
    "- Schema validation",
    "- Missing-value validation",
    "- Duplicate validation",
    "- Identifier validation",
    "- Datatype validation",
    "- Timestamp validation",
    "- Range validation",
    "- Business-rule validation",
    "- Referential-integrity validation",
    "- Distribution monitoring",
    "- Cleaning",
    "- Quarantine",
    "- Row-count tracking",
    "- Data-quality reporting",
    "- Data-drift monitoring",
    "- Daily processing",
    "- Historical backfill",
    "- Full rebuild",
    "- Automated tests",
    "",
    "## 3. Stage Boundaries",
    "",
    "Preprocessing ends at CLEAN DATA. Feature engineering and recommendation reasoning consume clean outputs in separate modules; they must not be mixed into cleaning.",
    "",
    "- Feature engineering must not be performed by preprocessing modules.",
    "- Raw data remains immutable; invalid data remains traceable through quarantine.",
    "- Recommendation-stage specifications are architectural preparation, not validated algorithms.",
    "",
    "## 4. Recommendation Architecture",
    "",
    "```text",
    "RAW DATA",
    "   |",
    "   v",
    "INGESTION",
    "   |",
    "   v",
    "STAGING",
    "   |",
    "   v",
    "VALIDATION",
    "   |",
    "   +---- invalid ----> QUARANTINE",
    "   |",
    "   v",
    "CLEANING",
    "   |",
    "   v",
    "CLEAN DATA",
    "   |",
    "   v",
    "FEATURE ENGINEERING",
    "   |",
    "   v",
    "USER INTELLIGENCE",
    "   |",
    "   v",
    "USER BEHAVIORAL PROFILE",
    "   |",
    "   v",
    "AFFINITY MODEL",
    "   |",
    "   v",
    "CANDIDATE GENERATION",
    "   |",
    "   v",
    "RULE ENGINE",
    "   |",
    "   v",
    "RANKING / RE-RANKING",
    "   |",
    "   v",
    "RECOMMENDATIONS",
    '```',
    "",
    "## 5. Data Sources",
    "",
    "The project currently expects two conceptual datasets:",
    "",
    "### Interaction Data",
    "",
    "Historical user-interaction files are expected to arrive in:",
    "",
    '`data/raw/interactions/`',
    "",
    "The known core identifiers are:",
    "",
    "- user_id",
    "- wireid",
    "- docid",
    "- timestamp",
    "",
    "The actual dataset must be inspected before implementation. Additional fields must not be invented.",
    "",
    "### Article Metadata",
    "",
    "Article/research metadata is expected in:",
    "",
    '`data/raw/article_metadata/`',
    "",
    "`docid` is the primary relationship key between article metadata and interaction records.",
    "",
    "## 6. Directory Structure",
    "",
    "```text",
    "recommendation_engine/",
    "|",
    "+-- config/",
    "|   +-- pipeline_config.yaml",
    "|   +-- schema_config.yaml",
    "|   +-- business_rules.yaml",
    "|   +-- feature_config.yaml",
    "|",
    "+-- data/",
    "|   +-- raw/",
    "|   |   +-- interactions/",
    "|   |   +-- article_metadata/",
    "|   |",
    "|   +-- staging/",
    "|   |   +-- interactions/",
    "|   |   +-- article_metadata/",
    "|   |",
    "|   +-- clean/",
    "|   |   +-- interactions/",
    "|   |   +-- article_metadata/",
    "|   |",
    "|   +-- features/",
    "|       +-- user/",
    "|       +-- article/",
    "|       +-- interaction/",
    "|       +-- behavioral/",
    "|       +-- model_ready/",
    "|",
    "|   +-- quarantine/",
    "|   |   +-- interactions/",
    "|   |   +-- article_metadata/",
    "|   |",
    "|   +-- manifests/",
    "|",
    "+-- src/",
    "|   +-- ingestion/",
    "|   +-- validation/",
    "|   +-- cleaning/",
    "|   +-- features/",
    "|   +-- user_intelligence/",
    "|   +-- modeling/affinity/",
    "|   +-- modeling/rules/",
    "|   +-- monitoring/",
    "|   +-- pipeline/",
    "|   +-- utils/",
    "|",
    "+-- tests/",
    "+-- reports/",
    "|   +-- data_quality/",
    "|   +-- schema/",
    "|   +-- run_history/",
    "|   +-- drift/",
    "+-- logs/",
    "+-- models/",
    "+-- notebooks/",
    "+-- docs/",
    "+-- README.md",
    "+-- requirements.txt",
    "+-- .gitignore",
    '```',
    "",
    "## 7. Data Layer Principles",
    "",
    "### Raw",
    "",
    "Raw files are immutable source-of-truth inputs.",
    "",
    "No cleaning or transformation should overwrite raw data.",
    "",
    "### Staging",
    "",
    "Staging contains data loaded from raw files with source traceability.",
    "",
    "### Clean",
    "",
    "Clean data contains records that have passed configured preprocessing rules.",
    "",
    "### Quarantine",
    "",
    "Quarantine contains records that cannot safely enter the clean dataset.",
    "",
    "Records must not simply disappear.",
    "",
    "### Manifest",
    "",
    "The manifest tracks what happened to each source file.",
    "",
    "## 8. Idempotency",
    "",
    "Running the same daily pipeline twice should not duplicate successfully processed data.",
    "",
    "The manifest and file identity information are used to determine whether a source file has already been processed.",
    "",
    "A rerun should either:",
    "",
    "1. Skip an already completed file, or",
    "2. Explicitly reprocess it as a new controlled run.",
    "",
    "The behavior must never accidentally append the same source data repeatedly.",
    "",
    "## 9. Validation",
    "",
    "Validation answers:",
    "",
    "> Is the incoming data acceptable?",
    "",
    "Validation must detect problems without silently modifying the data.",
    "",
    "Examples include:",
    "",
    "- Missing columns",
    "- Unexpected columns",
    "- Invalid datatypes",
    "- Missing identifiers",
    "- Duplicate records",
    "- Invalid timestamps",
    "- Invalid ranges",
    "- Missing article references",
    "- Unexpected categories",
    "- Abnormal distributions",
    "",
    "## 10. Cleaning",
    "",
    "Cleaning answers:",
    "",
    "> How should known data-quality problems be safely handled?",
    "",
    "Cleaning rules must be configuration-driven where possible.",
    "",
    "Examples include:",
    "",
    "- Standardizing column names",
    "- Trimming harmless whitespace",
    "- Standardizing datatypes",
    "- Normalizing timestamps",
    "- Applying approved category mappings",
    "- Removing confirmed duplicates",
    "- Applying explicit business rules",
    "",
    "## 11. Quarantine",
    "",
    "Quarantine is mandatory for records that cannot safely be converted into valid clean records.",
    "",
    "Each quarantined record should retain:",
    "",
    "- Original record information",
    "- Source file",
    "- Run ID",
    "- Rule or issue ID",
    "- Severity",
    "- Reason",
    "",
    "This makes rejection auditable and allows later investigation.",
    "",
    "## 12. Referential Integrity",
    "",
    "Interaction records reference articles through `docid`.",
    "",
    "The preprocessing pipeline must check whether interaction docids exist in the article metadata dataset.",
    "",
    "Missing references must be reported explicitly.",
    "",
    "The pipeline must not fabricate article metadata.",
    "",
    "## 13. Daily Processing",
    "",
    "The intended daily flow is:",
    "",
    "```text",
    "Discover files",
    "      |",
    "      v",
    "Check manifest",
    "      |",
    "      v",
    "Load new files",
    "      |",
    "      v",
    "Pre-validation",
    "      |",
    "      v",
    "Quarantine invalid records",
    "      |",
    "      v",
    "Clean valid data",
    "      |",
    "      v",
    "Post-clean validation",
    "      |",
    "      v",
    "Write clean data",
    "      |",
    "      v",
    "Update manifest",
    "      |",
    "      v",
    "Generate reports",
    "      |",
    "      v",
    "Update monitoring",
    '```',
    "",
    "## 14. Backfill",
    "",
    "Backfill is used when historical files must be processed again.",
    "",
    "The backfill pipeline must reuse the same validation and cleaning modules used by daily processing.",
    "",
    "There should not be one set of rules for daily processing and another unrelated set for historical data.",
    "",
    "## 15. Full Rebuild",
    "",
    "A full rebuild is appropriate when:",
    "",
    "- A cleaning rule changes",
    "- A schema interpretation changes",
    "- A serious implementation bug is discovered",
    "- Historical data must be regenerated",
    "",
    "The raw layer remains unchanged.",
    "",
    "A new run ID should distinguish the rebuild from previous runs.",
    "",
    "## 16. Monitoring",
    "",
    "Important operational metrics include:",
    "",
    "- Input rows",
    "- Clean rows",
    "- Quarantined rows",
    "- Rejected percentage",
    "- Unique users",
    "- Unique articles",
    "- Event distribution",
    "- Missingness",
    "- Referential-integrity coverage",
    "- Daily volume",
    "- Distribution changes",
    "",
    "The purpose is to make data problems visible before they reach later recommendation stages.",
    "",
    "## 17. Configuration",
    "",
    "Business-specific values should not be scattered throughout Python code.",
    "",
    "Configuration belongs primarily in:",
    "",
    '- `pipeline_config.yaml`',
    '- `schema_config.yaml`',
    '- `business_rules.yaml`',
    "",
    "The implementation should read these files rather than hard-code thresholds unnecessarily.",
    "",
    "`feature_config.yaml` contains architecture defaults and experimental parameters, not validated model weights or assumed source fields.",
    "",
    "## 18. AI Coding Agent Instructions",
    "",
    "Before implementing anything, the coding agent must:",
    "",
    "1. Read this README.",
    "2. Read `docs/data_pipeline_design.md`.",
    "3. Inspect every Python module docstring.",
    "4. Inspect the configuration files.",
    "5. Inspect the actual source data.",
    "6. Confirm the real schema before implementing assumptions.",
    "",
    "The coding agent must:",
    "",
    "- Preserve the existing architecture.",
    "- Implement the requested module responsibilities.",
    "- Reuse utilities.",
    "- Add tests.",
    "- Add logging.",
    "- Maintain idempotency.",
    "- Maintain raw-data immutability.",
    "- Preserve quarantine traceability.",
    "- Avoid silent row deletion.",
    "- Avoid invented business rules.",
    "- Keep feature engineering outside preprocessing and consume clean data only.",
    "- Do not claim recommendation algorithms are validated until evaluated on real data.",
    "",
    "## 19. User Intelligence and Affinity",
    "",
    "The core reasoning layer models why observed behavior may form a pattern, rather than only matching an article's surface similarity.",
    "",
    "Profiles keep OBSERVED interactions, DERIVED behavioral patterns and INFERRED candidate interests separate, with evidence, confidence and time context.",
    "",
    "Intent is inferred, not observed; it must never be presented as a confirmed personal or psychological fact. Configurable behavioral relationships may connect non-identical behaviors, but no relationship mapping is assumed until supported by inspected data and configuration.",
    "",
    "Affinity combines interpretable configured components and preserves their contributions. The rule engine separately decides candidate eligibility and records each decision. Candidate generation, ranking and re-ranking are later stages after affinity and eligibility.",
    "",
    "Daily profile updates should consume newly cleaned interactions using a recorded as-of cutoff, update evidence deterministically, and prevent future interactions from leaking into historical features or evaluations.",
    "",
    "Matrix factorization is an optional future experiment, disabled by default. It may be activated only after evaluation of real data demonstrates sufficient collaborative signal and measurable value.",
    "",
    "No recommendation quality or performance claim is made by this architecture scaffold.",
    ""
)

Write-ProjectFile "README.md" ($readme -join "`r`n") -Overwrite

# ============================================================
# DESIGN DOCUMENT
# ============================================================

$design = @(
    "# Data Pipeline Design",
    "",
    "## 1. Objective",
    "",
    "Build a reliable preprocessing layer for a recommendation engine that receives historical data and continuing daily data.",
    "",
    "The preprocessing system must make data quality visible, preserve source traceability and produce a clean dataset suitable for future feature engineering and recommendation modeling.",
    "",
    "## 2. Architectural Philosophy",
    "",
    "The architecture follows these principles:",
    "",
    "1. Raw data is immutable.",
    "2. Every source file is traceable.",
    "3. Validation happens before cleaning.",
    "4. Cleaning rules are explicit.",
    "5. Invalid records are quarantined rather than silently dropped.",
    "6. Every run has an identifier.",
    "7. Daily processing is idempotent.",
    "8. Historical backfill reuses production logic.",
    "9. Configuration controls business-specific rules.",
    "10. Monitoring exposes unexpected data changes.",
    "",
    "## 3. Data Layers",
    "",
    "### Raw",
    "",
    "Exact source files.",
    "",
    "### Staging",
    "",
    "Loaded representation with source metadata.",
    "",
    "### Clean",
    "",
    "Validated and cleaned records suitable for later modeling.",
    "",
    "### Quarantine",
    "",
    "Records rejected by explicit rules, retained for investigation.",
    "",
    "### Manifest",
    "",
    "Operational record of source-file processing state.",
    "",
    "## 4. Validation Architecture",
    "",
    "Validation modules are intentionally separated so that each type of quality issue can be tested independently.",
    "",
    "Validation categories:",
    "",
    "- Schema",
    "- Missing values",
    "- Duplicates",
    "- IDs",
    "- Datatypes",
    "- Timestamps",
    "- Ranges",
    "- Business rules",
    "- Referential integrity",
    "- Distribution",
    "",
    "The validation runner combines these results.",
    "",
    "## 5. Severity",
    "",
    "Validation issues should have a severity such as:",
    "",
    "- INFO",
    "- WARNING",
    "- ERROR",
    "- BLOCKING",
    "",
    "Severity determines whether processing can continue and whether a record must be quarantined.",
    "",
    "The exact behavior should be configuration-driven.",
    "",
    "## 6. Cleaning Architecture",
    "",
    "Cleaning should be composed from small deterministic modules.",
    "",
    "Recommended interaction cleaning order:",
    "",
    "```text",
    "Column standardization",
    "        |",
    "        v",
    "ID standardization",
    "        |",
    "        v",
    "Datatype standardization",
    "        |",
    "        v",
    "Timestamp standardization",
    "        |",
    "        v",
    "Missing-value handling",
    "        |",
    "        v",
    "Duplicate removal",
    "        |",
    "        v",
    "Category/event standardization",
    "        |",
    "        v",
    "Business rules",
    "        |",
    "        v",
    "Quarantine invalid records",
    '```',
    "",
    "The order may be adjusted if actual dataset characteristics require it, but any change should be deliberate and documented.",
    "",
    "## 7. Auditability",
    "",
    "Important transformations should produce audit information.",
    "",
    "Examples:",
    "",
    "- Number of rows before transformation",
    "- Number of rows after transformation",
    "- Number of rows quarantined",
    "- Rule responsible",
    "- Source file",
    "- Run ID",
    "",
    "This allows engineers to explain where rows went.",
    "",
    "## 8. Daily Processing",
    "",
    "Daily processing should be deterministic.",
    "",
    "A successful file should not be processed repeatedly simply because the pipeline is run again.",
    "",
    "The manifest provides the operational state required to support this.",
    "",
    "## 9. Late Arriving Data",
    "",
    "A file may arrive later than its logical data date.",
    "",
    "The system should distinguish:",
    "",
    "- File arrival date",
    "- Data/event date",
    "",
    "Late data should be processed according to the configured policy rather than silently ignored.",
    "",
    "## 10. Failed Processing",
    "",
    "A failed file should remain identifiable in the manifest.",
    "",
    "The system should record:",
    "",
    "- Failure status",
    "- Error message",
    "- Run ID",
    "- Timestamp",
    "",
    "Retry behavior should be deterministic.",
    "",
    "## 11. Row Retention",
    "",
    "Every major stage should provide row counts.",
    "",
    "Example:",
    "",
    "```text",
    "Raw              1,000,000",
    "Staging          1,000,000",
    "Validated          998,000",
    "Quarantine           2,000",
    "Clean              998,000",
    '```',
    "",
    "The numbers above are illustrative only and must not be treated as expected results.",
    "",
    "## 12. Data Drift",
    "",
    "Data drift monitoring at this stage means monitoring changes in the incoming data distribution.",
    "",
    "It does not mean model drift.",
    "",
    "Examples include:",
    "",
    "- Sudden interaction-volume changes",
    "- Sudden changes in event proportions",
    "- Sudden changes in missingness",
    "- Sudden changes in unique-user counts",
    "- Sudden changes in unique-article counts",
    "- Sudden changes in referential-integrity coverage",
    "",
    "## 13. Recommendation Architecture",
    "",
    "Preprocessing remains unchanged and ends at CLEAN DATA. Separate recommendation stages consume clean outputs:",
    "",
    "```text",
    "CLEAN DATA",
    "    |",
    "    v",
    "FEATURE ENGINEERING",
    "    |",
    "    v",
    "USER INTELLIGENCE",
    "    +-- History Analysis",
    "    +-- Behavior Analysis",
    "    +-- Intent Discovery",
    "    +-- Preference Profiling",
    "    +-- Behavioral Relationships",
    "    |",
    "    v",
    "USER BEHAVIORAL PROFILE",
    "    |",
    "    v",
    "AFFINITY ENGINE",
    "    |",
    "    v",
    "CANDIDATE GENERATION",
    "    |",
    "    v",
    "RULE ENGINE",
    "    |",
    "    v",
    "RANKING / RE-RANKING",
    "    |",
    "    v",
    "RECOMMENDATIONS",
    '```',
    "",
    "Feature engineering uses only actual inspected clean-data columns and metadata. It preserves user_id/docid/timestamp keys, repeated interaction evidence and an explicit as-of cutoff. Article features may use only real metadata fields; no embeddings or invented columns are assumed.",
    "",
    "## 14. User Intelligence and Inference",
    "",
    "User intelligence is the core reasoning layer: it analyzes chronological history and recurring patterns, then builds an interpretable profile that can explain affinities beyond exact article similarity.",
    "",
    "The profile distinguishes:",
    "",
    "- OBSERVED: source interactions and their timestamps/identifiers.",
    "- DERIVED: recurring behavior patterns calculated from observations.",
    "- INFERRED: candidate preferences or intents that may explain patterns.",
    "- MODEL SIGNAL: configured affinity contribution from supported evidence.",
    "- RULE: an auditable eligibility decision independent of affinity.",
    "",
    "Intent is inferred rather than directly observed. Every candidate intent must carry evidence, confidence, supporting interaction references and time context. It is never a confirmed psychological, demographic or personal fact; multiple candidates and changing strength are allowed.",
    "",
    "## 15. Behavioral Relationships and Preferences",
    "",
    "Relationship logic supports direct similarity and higher-level connections between non-identical behaviors. It must be configuration-driven and auditable; empty configuration means no asserted domain relationships. Example topics are illustrative, not hard-coded rules.",
    "",
    "Preference profiles distinguish persistent, emerging, recent and weak/uncertain signals, preserve evidence, and avoid one opaque preference score.",
    "",
    "## 16. Affinity and Rules",
    "",
    "Affinity combines configurable, interpretable components such as direct preference, behavioral relationship, recency, interaction strength, persistence and supported intent relevance. Component contributions, weight version and evidence are retained. Initial weights are experimental placeholders, not scientifically validated parameters, and must not be silently tuned.",
    "",
    "The rule engine remains separate: it determines candidate eligibility, returns passed/failed status, rule ID, reason and affected candidate, and preserves priority/configuration audit details. No consumed-item, freshness or business policy is assumed unless explicitly configured.",
    "",
    "Candidate generation follows user profile and affinity. Ranking and re-ranking are later stages and are not implemented by the intelligence pipeline.",
    "",
    "## 17. Daily Profile Updates and Temporal Safety",
    "",
    "Daily updates consume newly cleaned records, preserve prior evidence/profile versions, and record an as-of timestamp. Rebuilds from the same clean snapshot and configuration must be deterministic.",
    "",
    "Features, profile evidence and evaluation snapshots may use only events at or before their as-of cutoff. Future interactions must never contribute to historical aggregates, labels or recommendation evaluation. Temporal association alone does not prove intent.",
    "",
    "## 18. Optional Matrix-Factorization Experiment",
    "",
    "Matrix factorization is not the primary architecture and is disabled by default. It remains an optional experiment that may be activated only if evaluation on real data demonstrates sufficient collaborative signal and measurable value. No matrix-factorization code or fabricated evaluation metrics are included in this scaffold.",
    "",
    "## 19. Data and Evaluation Boundaries",
    "",
    "The actual dataset is authoritative. The inspected scaffold currently documents interaction identifiers user_id, wireid, docid and timestamp, and article key docid; no raw or clean data files were present during scaffold design. Any additional columns, event semantics, metadata, intent mappings and business rules require inspection and explicit configuration.",
    "",
    "Architecture specifications do not demonstrate that an algorithm works. Recommendation quality claims require real-data evaluation and documented methodology.",
    "",
    "## 20. AI Implementation Instruction",
    "",
    "An AI coding agent implementing this repository must first inspect:",
    "",
    "- README.md",
    "- docs/data_pipeline_design.md",
    "- All Python module docstrings",
    "- YAML configuration",
    "- Actual data files",
    "",
    "The agent should implement the requested responsibilities without redesigning the architecture.",
    "",
    "If an actual data column contradicts an assumed placeholder, the real data should be treated as authoritative and the configuration/documentation should be updated explicitly.",
    "",
    "The agent must not invent business semantics.",
    "",
    "The agent must not move feature engineering into preprocessing or implement assumptions unsupported by actual data.",
    ""
)

Write-ProjectFile "docs\data_pipeline_design.md" ($design -join "`r`n") -Overwrite

# ============================================================
# REQUIREMENTS
# ============================================================

$requirements = @(
    "pandas>=2.0",
    "numpy>=1.24",
    "pyarrow>=14.0",
    "openpyxl>=3.1",
    "pyyaml>=6.0",
    "pytest>=7.0",
    "python-dateutil>=2.8"
)

Write-ProjectFile "requirements.txt" ($requirements -join "`r`n")

# ============================================================
# GITIGNORE
# ============================================================

$gitignore = @(
    "__pycache__/",
    "*.py[cod]",
    ".pytest_cache/",
    ".venv/",
    "venv/",
    "env/",
    ".env",
    ".idea/",
    ".vscode/",
    "",
    "# Runtime data",
    "data/staging/*",
    "data/clean/*",
    "data/features/*",
    "data/quarantine/*",
    "data/manifests/*",
    "logs/*",
    "reports/*",
    "",
    "# Keep folder structure",
    "!data/staging/.gitkeep",
    "!data/clean/.gitkeep",
    "!data/features/user/",
    "!data/features/article/",
    "!data/features/interaction/",
    "!data/features/behavioral/",
    "!data/features/model_ready/",
    "!data/features/user/.gitkeep",
    "!data/features/article/.gitkeep",
    "!data/features/interaction/.gitkeep",
    "!data/features/behavioral/.gitkeep",
    "!data/features/model_ready/.gitkeep",
    "!data/quarantine/.gitkeep",
    "!data/manifests/.gitkeep",
    "!logs/.gitkeep",
    "!reports/.gitkeep"
)

Write-ProjectFile ".gitignore" ($gitignore -join "`r`n") -Overwrite

# ============================================================
# PACKAGE INIT FILES
# ============================================================

$initFiles = @(
    "src\__init__.py",
    "src\ingestion\__init__.py",
    "src\validation\__init__.py",
    "src\cleaning\__init__.py",
    "src\monitoring\__init__.py",
    "src\pipeline\__init__.py",
    "src\utils\__init__.py",
    "src\features\__init__.py",
    "src\user_intelligence\__init__.py",
    "src\modeling\__init__.py",
    "src\modeling\affinity\__init__.py",
    "src\modeling\rules\__init__.py"
)

foreach ($init in $initFiles) {
    if (-not (Test-Path (Join-Path $root $init))) {
        Write-ProjectFile $init "# Package initialization file.`r`n"
    }
}

# ============================================================
# OPTIONAL .GITKEEP FILES
# ============================================================

$gitkeepDirs = @(
    "data\raw\interactions",
    "data\raw\article_metadata",
    "data\staging\interactions",
    "data\staging\article_metadata",
    "data\clean\interactions",
    "data\clean\article_metadata",
    "data\features\user",
    "data\features\article",
    "data\features\interaction",
    "data\features\behavioral",
    "data\features\model_ready",
    "data\quarantine\interactions",
    "data\quarantine\article_metadata",
    "data\manifests",
    "reports\data_quality",
    "reports\schema",
    "reports\run_history",
    "reports\drift",
    "logs",
    "models",
    "notebooks"
)

foreach ($dir in $gitkeepDirs) {
    $gitkeep = Join-Path $root "$dir\.gitkeep"

    if (-not (Test-Path $gitkeep)) {
        [System.IO.File]::WriteAllText(
            $gitkeep,
            "",
            [System.Text.UTF8Encoding]::new($false)
        )
    }
}

# ============================================================
# VERIFICATION
# ============================================================

Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host " Verification" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

$actualPythonFiles = Get-ChildItem `
    -LiteralPath (Join-Path $root "src") `
    -Recurse `
    -Filter "*.py" `
    -File

$actualPythonCount = $actualPythonFiles.Count

$allSpecPaths = $specs.Path

$missingPython = @()

foreach ($path in $allSpecPaths) {
    if (-not (Test-Path (Join-Path $root $path))) {
        $missingPython += $path
    }
}

Write-Host ""
Write-Host "Expected documented Python modules : $pythonCount"
Write-Host "Actual Python files under src      : $actualPythonCount"

if ($missingPython.Count -eq 0) {
    Write-Host "Python module verification         : PASS" -ForegroundColor Green
}
else {
    Write-Host "Python module verification         : FAIL" -ForegroundColor Red

    foreach ($missing in $missingPython) {
        Write-Host "Missing: $missing" -ForegroundColor Red
    }
}

$requiredFiles = @(
    "README.md",
    "requirements.txt",
    ".gitignore",
    "config\pipeline_config.yaml",
    "config\schema_config.yaml",
    "config\business_rules.yaml",
    "config\feature_config.yaml",
    "docs\data_pipeline_design.md"
)

$missingFiles = @()

foreach ($file in $requiredFiles) {
    if (-not (Test-Path (Join-Path $root $file))) {
        $missingFiles += $file
    }
}

if ($missingFiles.Count -eq 0) {
    Write-Host "Documentation/config verification   : PASS" -ForegroundColor Green
}
else {
    Write-Host "Documentation/config verification   : FAIL" -ForegroundColor Red

    foreach ($missing in $missingFiles) {
        Write-Host "Missing: $missing" -ForegroundColor Red
    }
}

# ============================================================
# FINAL MESSAGE
# ============================================================

Write-Host ""
Write-Host "=============================================" -ForegroundColor Green
Write-Host " Project generation completed" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green
Write-Host ""

Write-Host "Project:"
Write-Host "  $root"

Write-Host ""
Write-Host "Python modules:"
Write-Host "  $actualPythonCount"

Write-Host ""
Write-Host "Next command:"
Write-Host "  tree .\recommendation_engine /F"

Write-Host ""
Write-Host "To inspect Python modules:"
Write-Host "  Get-ChildItem .\recommendation_engine\src -Recurse -Filter *.py"

Write-Host ""
Write-Host "IMPORTANT:"
Write-Host "The Python files contain specifications/docstrings only."
Write-Host "They are intentionally not implemented yet."
Write-Host ""