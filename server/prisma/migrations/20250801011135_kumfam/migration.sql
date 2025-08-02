-- CreateTable
CREATE TABLE "data_sources" (
    "id" SERIAL NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "provider" VARCHAR(100),
    "api_endpoint" TEXT,
    "credibility_score" DECIMAL(3,2) DEFAULT 0.95,
    "last_update" TIMESTAMP(3),
    "update_frequency" VARCHAR(50) DEFAULT 'weekly',
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "api_key_required" BOOLEAN NOT NULL DEFAULT false,
    "rate_limit_per_hour" INTEGER DEFAULT 1000,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "data_sources_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "drug_interactions" (
    "id" SERIAL NOT NULL,
    "drug1_id" INTEGER NOT NULL,
    "drug2_id" INTEGER NOT NULL,
    "drug1_rxcui" VARCHAR(20),
    "drug2_rxcui" VARCHAR(20),
    "severity" VARCHAR(20) NOT NULL DEFAULT 'unknown',
    "mechanism" TEXT,
    "clinical_significance" TEXT,
    "evidence_level" VARCHAR(20) DEFAULT 'C',
    "onset" VARCHAR(20) DEFAULT 'variable',
    "documentation" VARCHAR(20) DEFAULT 'fair',
    "management_recommendation" TEXT,
    "source_id" INTEGER NOT NULL,
    "confidence_score" DECIMAL(3,2) DEFAULT 0.80,
    "interaction_type" VARCHAR(50) DEFAULT 'drug-drug',
    "frequency" VARCHAR(20) DEFAULT 'unknown',
    "last_verified" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "drug_interactions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "clinical_alerts" (
    "id" SERIAL NOT NULL,
    "alert_type" VARCHAR(50) NOT NULL,
    "severity" VARCHAR(20) NOT NULL DEFAULT 'medium',
    "affected_drugs" TEXT[],
    "affected_rxcuis" TEXT[],
    "title" TEXT NOT NULL,
    "description" TEXT,
    "recommendation" TEXT,
    "source_url" TEXT,
    "source_id" INTEGER,
    "effective_date" DATE,
    "expiry_date" DATE,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "priority" INTEGER DEFAULT 50,
    "target_audience" VARCHAR(100) DEFAULT 'healthcare_providers',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "clinical_alerts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "update_sessions" (
    "id" SERIAL NOT NULL,
    "session_type" VARCHAR(50) NOT NULL DEFAULT 'weekly',
    "trigger_type" VARCHAR(50) DEFAULT 'scheduled',
    "start_time" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "end_time" TIMESTAMP(3),
    "status" VARCHAR(20) NOT NULL DEFAULT 'running',
    "records_updated" INTEGER NOT NULL DEFAULT 0,
    "records_added" INTEGER NOT NULL DEFAULT 0,
    "records_deleted" INTEGER NOT NULL DEFAULT 0,
    "errors_count" INTEGER NOT NULL DEFAULT 0,
    "success_rate" DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    "summary_report" JSONB,
    "triggered_by" VARCHAR(100) DEFAULT 'system',
    "source_ids" INTEGER[],
    "total_api_calls" INTEGER NOT NULL DEFAULT 0,
    "api_failures" INTEGER NOT NULL DEFAULT 0,
    "processing_time_ms" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "update_sessions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "drug_rxnorm_mapping" (
    "id" SERIAL NOT NULL,
    "drug_id" INTEGER NOT NULL,
    "rxcui" VARCHAR(20) NOT NULL,
    "concept_name" VARCHAR(255),
    "term_type" VARCHAR(10),
    "source" VARCHAR(50) DEFAULT 'manual',
    "confidence_score" DECIMAL(3,2) DEFAULT 0.90,
    "verified" BOOLEAN DEFAULT false,
    "verified_by" VARCHAR(100),
    "verified_at" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "drug_rxnorm_mapping_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "interaction_validation_log" (
    "id" SERIAL NOT NULL,
    "interaction_id" INTEGER NOT NULL,
    "validation_source" VARCHAR(100) NOT NULL,
    "validation_status" VARCHAR(20) NOT NULL,
    "validation_score" DECIMAL(3,2),
    "validation_notes" TEXT,
    "validated_by" VARCHAR(100) DEFAULT 'system',
    "validated_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "interaction_validation_log_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "drug_interactions_drug1_id_drug2_id_source_id_key" ON "drug_interactions"("drug1_id", "drug2_id", "source_id");

-- CreateIndex
CREATE UNIQUE INDEX "drug_rxnorm_mapping_drug_id_rxcui_key" ON "drug_rxnorm_mapping"("drug_id", "rxcui");

-- AddForeignKey
ALTER TABLE "drug_interactions" ADD CONSTRAINT "drug_interactions_drug1_id_fkey" FOREIGN KEY ("drug1_id") REFERENCES "drugs"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "drug_interactions" ADD CONSTRAINT "drug_interactions_drug2_id_fkey" FOREIGN KEY ("drug2_id") REFERENCES "drugs"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "drug_interactions" ADD CONSTRAINT "drug_interactions_source_id_fkey" FOREIGN KEY ("source_id") REFERENCES "data_sources"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "clinical_alerts" ADD CONSTRAINT "clinical_alerts_source_id_fkey" FOREIGN KEY ("source_id") REFERENCES "data_sources"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "drug_rxnorm_mapping" ADD CONSTRAINT "drug_rxnorm_mapping_drug_id_fkey" FOREIGN KEY ("drug_id") REFERENCES "drugs"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "interaction_validation_log" ADD CONSTRAINT "interaction_validation_log_interaction_id_fkey" FOREIGN KEY ("interaction_id") REFERENCES "drug_interactions"("id") ON DELETE CASCADE ON UPDATE CASCADE;
