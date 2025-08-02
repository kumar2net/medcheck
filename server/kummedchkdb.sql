--
-- PostgreSQL database dump
--

-- Dumped from database version 17.5 (Homebrew)
-- Dumped by pg_dump version 17.5 (Homebrew)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: kumar
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO kumar;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: kumar
--

COMMENT ON SCHEMA public IS '';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: _prisma_migrations; Type: TABLE; Schema: public; Owner: kumar
--

CREATE TABLE public._prisma_migrations (
    id character varying(36) NOT NULL,
    checksum character varying(64) NOT NULL,
    finished_at timestamp with time zone,
    migration_name character varying(255) NOT NULL,
    logs text,
    rolled_back_at timestamp with time zone,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    applied_steps_count integer DEFAULT 0 NOT NULL
);


ALTER TABLE public._prisma_migrations OWNER TO kumar;

--
-- Name: clinical_alerts; Type: TABLE; Schema: public; Owner: kumar
--

CREATE TABLE public.clinical_alerts (
    id integer NOT NULL,
    alert_type character varying(50) NOT NULL,
    severity character varying(20) DEFAULT 'medium'::character varying NOT NULL,
    affected_drugs text[],
    affected_rxcuis text[],
    title text NOT NULL,
    description text,
    recommendation text,
    source_url text,
    source_id integer,
    effective_date date,
    expiry_date date,
    is_active boolean DEFAULT true NOT NULL,
    priority integer DEFAULT 50,
    target_audience character varying(100) DEFAULT 'healthcare_providers'::character varying,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.clinical_alerts OWNER TO kumar;

--
-- Name: clinical_alerts_id_seq; Type: SEQUENCE; Schema: public; Owner: kumar
--

CREATE SEQUENCE public.clinical_alerts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.clinical_alerts_id_seq OWNER TO kumar;

--
-- Name: clinical_alerts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kumar
--

ALTER SEQUENCE public.clinical_alerts_id_seq OWNED BY public.clinical_alerts.id;


--
-- Name: data_sources; Type: TABLE; Schema: public; Owner: kumar
--

CREATE TABLE public.data_sources (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    provider character varying(100),
    api_endpoint text,
    credibility_score numeric(3,2) DEFAULT 0.95,
    last_update timestamp(3) without time zone,
    update_frequency character varying(50) DEFAULT 'weekly'::character varying,
    is_active boolean DEFAULT true NOT NULL,
    api_key_required boolean DEFAULT false NOT NULL,
    rate_limit_per_hour integer DEFAULT 1000,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.data_sources OWNER TO kumar;

--
-- Name: data_sources_id_seq; Type: SEQUENCE; Schema: public; Owner: kumar
--

CREATE SEQUENCE public.data_sources_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.data_sources_id_seq OWNER TO kumar;

--
-- Name: data_sources_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kumar
--

ALTER SEQUENCE public.data_sources_id_seq OWNED BY public.data_sources.id;


--
-- Name: drug_interactions; Type: TABLE; Schema: public; Owner: kumar
--

CREATE TABLE public.drug_interactions (
    id integer NOT NULL,
    drug1_id integer NOT NULL,
    drug2_id integer NOT NULL,
    drug1_rxcui character varying(20),
    drug2_rxcui character varying(20),
    severity character varying(20) DEFAULT 'unknown'::character varying NOT NULL,
    mechanism text,
    clinical_significance text,
    evidence_level character varying(20) DEFAULT 'C'::character varying,
    onset character varying(20) DEFAULT 'variable'::character varying,
    documentation character varying(20) DEFAULT 'fair'::character varying,
    management_recommendation text,
    source_id integer NOT NULL,
    confidence_score numeric(3,2) DEFAULT 0.80,
    interaction_type character varying(50) DEFAULT 'drug-drug'::character varying,
    frequency character varying(20) DEFAULT 'unknown'::character varying,
    last_verified timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.drug_interactions OWNER TO kumar;

--
-- Name: drug_interactions_id_seq; Type: SEQUENCE; Schema: public; Owner: kumar
--

CREATE SEQUENCE public.drug_interactions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.drug_interactions_id_seq OWNER TO kumar;

--
-- Name: drug_interactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kumar
--

ALTER SEQUENCE public.drug_interactions_id_seq OWNED BY public.drug_interactions.id;


--
-- Name: drug_rxnorm_mapping; Type: TABLE; Schema: public; Owner: kumar
--

CREATE TABLE public.drug_rxnorm_mapping (
    id integer NOT NULL,
    drug_id integer NOT NULL,
    rxcui character varying(20) NOT NULL,
    concept_name character varying(255),
    term_type character varying(10),
    source character varying(50) DEFAULT 'manual'::character varying,
    confidence_score numeric(3,2) DEFAULT 0.90,
    verified boolean DEFAULT false,
    verified_by character varying(100),
    verified_at timestamp(3) without time zone,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.drug_rxnorm_mapping OWNER TO kumar;

--
-- Name: drug_rxnorm_mapping_id_seq; Type: SEQUENCE; Schema: public; Owner: kumar
--

CREATE SEQUENCE public.drug_rxnorm_mapping_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.drug_rxnorm_mapping_id_seq OWNER TO kumar;

--
-- Name: drug_rxnorm_mapping_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kumar
--

ALTER SEQUENCE public.drug_rxnorm_mapping_id_seq OWNED BY public.drug_rxnorm_mapping.id;


--
-- Name: drugs; Type: TABLE; Schema: public; Owner: kumar
--

CREATE TABLE public.drugs (
    id integer NOT NULL,
    name text NOT NULL,
    category text NOT NULL,
    combination text,
    strength text,
    "dosageForm" text,
    manufacturer text,
    price numeric(65,30),
    "sideEffects" text,
    alternatives text
);


ALTER TABLE public.drugs OWNER TO kumar;

--
-- Name: drugs_id_seq; Type: SEQUENCE; Schema: public; Owner: kumar
--

CREATE SEQUENCE public.drugs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.drugs_id_seq OWNER TO kumar;

--
-- Name: drugs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kumar
--

ALTER SEQUENCE public.drugs_id_seq OWNED BY public.drugs.id;


--
-- Name: family_medications; Type: TABLE; Schema: public; Owner: kumar
--

CREATE TABLE public.family_medications (
    id integer NOT NULL,
    "familyMemberId" integer NOT NULL,
    "drugId" integer NOT NULL,
    dosage text,
    frequency text,
    "startDate" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "endDate" timestamp(3) without time zone,
    notes text,
    "isActive" boolean DEFAULT true NOT NULL,
    cost numeric(65,30),
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.family_medications OWNER TO kumar;

--
-- Name: family_medications_id_seq; Type: SEQUENCE; Schema: public; Owner: kumar
--

CREATE SEQUENCE public.family_medications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.family_medications_id_seq OWNER TO kumar;

--
-- Name: family_medications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kumar
--

ALTER SEQUENCE public.family_medications_id_seq OWNED BY public.family_medications.id;


--
-- Name: family_members; Type: TABLE; Schema: public; Owner: kumar
--

CREATE TABLE public.family_members (
    id integer NOT NULL,
    name text NOT NULL,
    age integer,
    photo text,
    allergies text,
    conditions text,
    "emergencyContact" text,
    "emergencyPhone" text,
    role text DEFAULT 'member'::text NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.family_members OWNER TO kumar;

--
-- Name: family_members_id_seq; Type: SEQUENCE; Schema: public; Owner: kumar
--

CREATE SEQUENCE public.family_members_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.family_members_id_seq OWNER TO kumar;

--
-- Name: family_members_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kumar
--

ALTER SEQUENCE public.family_members_id_seq OWNED BY public.family_members.id;


--
-- Name: interaction_validation_log; Type: TABLE; Schema: public; Owner: kumar
--

CREATE TABLE public.interaction_validation_log (
    id integer NOT NULL,
    interaction_id integer NOT NULL,
    validation_source character varying(100) NOT NULL,
    validation_status character varying(20) NOT NULL,
    validation_score numeric(3,2),
    validation_notes text,
    validated_by character varying(100) DEFAULT 'system'::character varying,
    validated_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.interaction_validation_log OWNER TO kumar;

--
-- Name: interaction_validation_log_id_seq; Type: SEQUENCE; Schema: public; Owner: kumar
--

CREATE SEQUENCE public.interaction_validation_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.interaction_validation_log_id_seq OWNER TO kumar;

--
-- Name: interaction_validation_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kumar
--

ALTER SEQUENCE public.interaction_validation_log_id_seq OWNED BY public.interaction_validation_log.id;


--
-- Name: update_sessions; Type: TABLE; Schema: public; Owner: kumar
--

CREATE TABLE public.update_sessions (
    id integer NOT NULL,
    session_type character varying(50) DEFAULT 'weekly'::character varying NOT NULL,
    trigger_type character varying(50) DEFAULT 'scheduled'::character varying,
    start_time timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    end_time timestamp(3) without time zone,
    status character varying(20) DEFAULT 'running'::character varying NOT NULL,
    records_updated integer DEFAULT 0 NOT NULL,
    records_added integer DEFAULT 0 NOT NULL,
    records_deleted integer DEFAULT 0 NOT NULL,
    errors_count integer DEFAULT 0 NOT NULL,
    success_rate numeric(5,2) DEFAULT 0.00 NOT NULL,
    summary_report jsonb,
    triggered_by character varying(100) DEFAULT 'system'::character varying,
    source_ids integer[],
    total_api_calls integer DEFAULT 0 NOT NULL,
    api_failures integer DEFAULT 0 NOT NULL,
    processing_time_ms integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.update_sessions OWNER TO kumar;

--
-- Name: update_sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: kumar
--

CREATE SEQUENCE public.update_sessions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.update_sessions_id_seq OWNER TO kumar;

--
-- Name: update_sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kumar
--

ALTER SEQUENCE public.update_sessions_id_seq OWNED BY public.update_sessions.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: kumar
--

CREATE TABLE public.users (
    id integer NOT NULL,
    username text NOT NULL,
    email text NOT NULL,
    password text NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp(3) without time zone
);


ALTER TABLE public.users OWNER TO kumar;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: kumar
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO kumar;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kumar
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: clinical_alerts id; Type: DEFAULT; Schema: public; Owner: kumar
--

ALTER TABLE ONLY public.clinical_alerts ALTER COLUMN id SET DEFAULT nextval('public.clinical_alerts_id_seq'::regclass);


--
-- Name: data_sources id; Type: DEFAULT; Schema: public; Owner: kumar
--

ALTER TABLE ONLY public.data_sources ALTER COLUMN id SET DEFAULT nextval('public.data_sources_id_seq'::regclass);


--
-- Name: drug_interactions id; Type: DEFAULT; Schema: public; Owner: kumar
--

ALTER TABLE ONLY public.drug_interactions ALTER COLUMN id SET DEFAULT nextval('public.drug_interactions_id_seq'::regclass);


--
-- Name: drug_rxnorm_mapping id; Type: DEFAULT; Schema: public; Owner: kumar
--

ALTER TABLE ONLY public.drug_rxnorm_mapping ALTER COLUMN id SET DEFAULT nextval('public.drug_rxnorm_mapping_id_seq'::regclass);


--
-- Name: drugs id; Type: DEFAULT; Schema: public; Owner: kumar
--

ALTER TABLE ONLY public.drugs ALTER COLUMN id SET DEFAULT nextval('public.drugs_id_seq'::regclass);


--
-- Name: family_medications id; Type: DEFAULT; Schema: public; Owner: kumar
--

ALTER TABLE ONLY public.family_medications ALTER COLUMN id SET DEFAULT nextval('public.family_medications_id_seq'::regclass);


--
-- Name: family_members id; Type: DEFAULT; Schema: public; Owner: kumar
--

ALTER TABLE ONLY public.family_members ALTER COLUMN id SET DEFAULT nextval('public.family_members_id_seq'::regclass);


--
-- Name: interaction_validation_log id; Type: DEFAULT; Schema: public; Owner: kumar
--

ALTER TABLE ONLY public.interaction_validation_log ALTER COLUMN id SET DEFAULT nextval('public.interaction_validation_log_id_seq'::regclass);


--
-- Name: update_sessions id; Type: DEFAULT; Schema: public; Owner: kumar
--

ALTER TABLE ONLY public.update_sessions ALTER COLUMN id SET DEFAULT nextval('public.update_sessions_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: kumar
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: _prisma_migrations; Type: TABLE DATA; Schema: public; Owner: kumar
--

COPY public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) FROM stdin;
528ee39f-2f6e-4ce0-a593-a0e89ad2f627	b3921f7377ee82febf9d483eebd2c38cd2fee84c3fc080cb0e9492fe32264fe4	2025-07-31 03:45:54.214954+05:30	20250720010731_init_family_features	\N	\N	2025-07-31 03:45:54.201763+05:30	1
8e2ad4f3-d794-4f5d-8c1d-296cac5d9037	8b4071bf985dd21f45417e7b48c003055428f345fc85c64fb1c2c484a3fc02e8	2025-08-01 06:41:35.883787+05:30	20250801011135_kumfam	\N	\N	2025-08-01 06:41:35.849916+05:30	1
\.


--
-- Data for Name: clinical_alerts; Type: TABLE DATA; Schema: public; Owner: kumar
--

COPY public.clinical_alerts (id, alert_type, severity, affected_drugs, affected_rxcuis, title, description, recommendation, source_url, source_id, effective_date, expiry_date, is_active, priority, target_audience, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: data_sources; Type: TABLE DATA; Schema: public; Owner: kumar
--

COPY public.data_sources (id, name, provider, api_endpoint, credibility_score, last_update, update_frequency, is_active, api_key_required, rate_limit_per_hour, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: drug_interactions; Type: TABLE DATA; Schema: public; Owner: kumar
--

COPY public.drug_interactions (id, drug1_id, drug2_id, drug1_rxcui, drug2_rxcui, severity, mechanism, clinical_significance, evidence_level, onset, documentation, management_recommendation, source_id, confidence_score, interaction_type, frequency, last_verified, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: drug_rxnorm_mapping; Type: TABLE DATA; Schema: public; Owner: kumar
--

COPY public.drug_rxnorm_mapping (id, drug_id, rxcui, concept_name, term_type, source, confidence_score, verified, verified_by, verified_at, created_at, updated_at) FROM stdin;
1	78	1095636	acetaminophen 32 MG/ML Oral Solution [Panadol]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-01 06:33:39.972	2025-08-01 06:33:39.973	2025-08-01 06:33:39.973
2	79	200977	acetaminophen 500 MG Oral Tablet [Panadol]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-01 06:33:39.982	2025-08-01 06:33:39.983	2025-08-01 06:33:39.983
3	80	1665214	200 ML ciprofloxacin 2 MG/ML Injection [Cipro]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-01 06:34:16.373	2025-08-01 06:34:16.374	2025-08-01 06:34:16.374
4	81	205769	ciprofloxacin 250 MG Oral Tablet [Cipro]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-01 06:34:16.377	2025-08-01 06:34:16.378	2025-08-01 06:34:16.378
5	82	205770	ciprofloxacin 500 MG Oral Tablet [Cipro]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-01 06:34:16.38	2025-08-01 06:34:16.381	2025-08-01 06:34:16.381
6	83	213224	ciprofloxacin 50 MG/ML Oral Suspension [Cipro]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-01 06:34:16.383	2025-08-01 06:34:16.384	2025-08-01 06:34:16.384
7	84	213226	ciprofloxacin 100 MG/ML Oral Suspension [Cipro]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-01 06:34:16.386	2025-08-01 06:34:16.387	2025-08-01 06:34:16.387
8	85	847488	24 HR ciprofloxacin 1000 MG Extended Release Oral Tablet [Cipro]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-01 06:34:16.39	2025-08-01 06:34:16.391	2025-08-01 06:34:16.391
9	86	899122	24 HR ciprofloxacin 500 MG Extended Release Oral Tablet [Cipro]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-01 06:34:16.393	2025-08-01 06:34:16.394	2025-08-01 06:34:16.394
10	87	103943	ciprofloxacin 3 MG/ML Ophthalmic Solution [Ciloxan]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:44:02.681	2025-08-02 00:44:02.682	2025-08-02 00:44:02.682
11	88	1740002	ciprofloxacin 60 MG/ML Otic Suspension [Otiprio]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:44:02.687	2025-08-02 00:44:02.688	2025-08-02 00:44:02.688
12	89	1792391	ciprofloxacin 3 MG/ML / fluocinolone acetonide 0.25 MG/ML Otic Solution [Otovel]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:44:02.69	2025-08-02 00:44:02.691	2025-08-02 00:44:02.691
13	90	213307	ciprofloxacin 0.003 MG/MG Ophthalmic Ointment [Ciloxan]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:44:02.696	2025-08-02 00:44:02.696	2025-08-02 00:44:02.696
14	91	213320	ciprofloxacin 2 MG/ML / hydrocortisone 10 MG/ML Otic Suspension [Cipro HC]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:44:02.698	2025-08-02 00:44:02.699	2025-08-02 00:44:02.699
15	92	404630	ciprofloxacin 3 MG/ML / dexamethasone 1 MG/ML Otic Suspension [Ciprodex]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:44:02.701	2025-08-02 00:44:02.702	2025-08-02 00:44:02.702
16	93	672912	24 HR ciprofloxacin 500 MG Extended Release Oral Tablet [Proquin]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:44:02.704	2025-08-02 00:44:02.705	2025-08-02 00:44:02.705
17	94	848960	ciprofloxacin 2 MG/ML Otic Solution [Cetraxal]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:44:02.708	2025-08-02 00:44:02.708	2025-08-02 00:44:02.708
18	95	1665210	100 ML ciprofloxacin 2 MG/ML Injection	SCD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:44:02.713	2025-08-02 00:44:02.714	2025-08-02 00:44:02.714
19	96	1665229	40 ML ciprofloxacin 10 MG/ML Injection	SCD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:44:02.717	2025-08-02 00:44:02.717	2025-08-02 00:44:02.717
20	97	197512	ciprofloxacin 750 MG Oral Tablet	SCD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:44:02.722	2025-08-02 00:44:02.722	2025-08-02 00:44:02.722
21	98	199370	ciprofloxacin 100 MG Oral Tablet	SCD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:44:02.724	2025-08-02 00:44:02.725	2025-08-02 00:44:02.725
25	102	1291987	{4 (amoxicillin 500 MG Oral Capsule) / 2 (clarithromycin 500 MG Oral Tablet) / 2 (omeprazole 20 MG Delayed Release Oral Capsule) } Pack [Omeclamox]	BPCK	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:45:24.143	2025-08-02 00:45:24.144	2025-08-02 00:45:24.144
26	103	2604802	{84 (amoxicillin 500 MG Oral Capsule) / 28 (vonoprazan 20 MG Oral Tablet) } Pack [Voquezna 14 Day DualPak 20;500]	BPCK	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:45:24.148	2025-08-02 00:45:24.149	2025-08-02 00:45:24.149
27	104	2604804	{56 (amoxicillin 500 MG Oral Capsule) / 28 (clarithromycin 500 MG Oral Tablet) / 28 (vonoprazan 20 MG Oral Tablet) } Pack [Voquezna 14 Day TriplePak 20;500;500]	BPCK	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:45:24.151	2025-08-02 00:45:24.152	2025-08-02 00:45:24.152
28	105	757969	{4 (amoxicillin 500 MG Oral Capsule [Trimox]) / 2 (clarithromycin 500 MG Oral Tablet [Biaxin]) / 2 (lansoprazole 30 MG Delayed Release Oral Capsule [Prevacid]) } Pack [Prevpac]	BPCK	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:45:24.154	2025-08-02 00:45:24.155	2025-08-02 00:45:24.155
29	106	757968	{4 (amoxicillin 500 MG Oral Capsule) / 2 (clarithromycin 500 MG Oral Tablet) / 2 (lansoprazole 30 MG Delayed Release Oral Capsule) } Pack	GPCK	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:45:24.158	2025-08-02 00:45:24.159	2025-08-02 00:45:24.159
30	107	1358974	amoxicillin 400 MG Oral Tablet [Amoxi-tabs]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:45:24.161	2025-08-02 00:45:24.162	2025-08-02 00:45:24.162
31	108	1359005	amoxicillin 150 MG Oral Tablet [Amoxi-tabs]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:45:24.163	2025-08-02 00:45:24.164	2025-08-02 00:45:24.164
32	109	1359009	amoxicillin 200 MG Oral Tablet [Amoxi-tabs]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:45:24.166	2025-08-02 00:45:24.167	2025-08-02 00:45:24.167
33	110	1360635	amoxicillin 100 MG Oral Tablet [Amoxi-tabs]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:45:24.169	2025-08-02 00:45:24.169	2025-08-02 00:45:24.169
34	111	1360637	amoxicillin 50 MG Oral Tablet [Amoxi-tabs]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:45:24.171	2025-08-02 00:45:24.172	2025-08-02 00:45:24.172
35	112	205730	amoxicillin 50 MG/ML Oral Suspension [Biomox]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:45:24.174	2025-08-02 00:45:24.174	2025-08-02 00:45:24.174
36	113	2105791	amoxicillin 100 MG / clavulanate 25 MG Chewable Tablet [Clavamox]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:45:24.176	2025-08-02 00:45:24.177	2025-08-02 00:45:24.177
37	114	2105794	amoxicillin 200 MG / clavulanate 50 MG Chewable Tablet [Clavamox]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:45:24.179	2025-08-02 00:45:24.179	2025-08-02 00:45:24.179
38	115	2105797	amoxicillin 300 MG / clavulanate 75 MG Chewable Tablet [Clavamox]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:45:24.181	2025-08-02 00:45:24.182	2025-08-02 00:45:24.182
39	116	2105800	amoxicillin 50 MG / clavulanate 12.5 MG Chewable Tablet [Clavamox]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:45:24.184	2025-08-02 00:45:24.184	2025-08-02 00:45:24.184
40	117	2108828	amoxicillin 100 MG / clavulanate 25 MG Oral Tablet [Clavacillin]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:45:24.186	2025-08-02 00:45:24.187	2025-08-02 00:45:24.187
41	118	2108831	amoxicillin 200 MG / clavulanate 50 MG Oral Tablet [Clavacillin]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:45:24.189	2025-08-02 00:45:24.19	2025-08-02 00:45:24.19
42	119	2108833	amoxicillin 300 MG / clavulanate 75 MG Oral Tablet [Clavacillin]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:45:24.192	2025-08-02 00:45:24.193	2025-08-02 00:45:24.193
43	120	2108835	amoxicillin 50 MG / clavulanate 12.5 MG Oral Tablet [Clavacillin]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:45:24.195	2025-08-02 00:45:24.196	2025-08-02 00:45:24.196
44	121	2262032	amoxicillin 250 MG / omeprazole 10 MG / rifabutin 12.5 MG Delayed Release Oral Capsule [Talicia]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:45:24.198	2025-08-02 00:45:24.199	2025-08-02 00:45:24.199
45	122	2598546	amoxicillin 100 MG / clavulanate 25 MG Oral Tablet [Umbrellin]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:45:24.201	2025-08-02 00:45:24.201	2025-08-02 00:45:24.201
46	123	2598548	amoxicillin 200 MG / clavulanate 50 MG Oral Tablet [Umbrellin]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:45:24.203	2025-08-02 00:45:24.204	2025-08-02 00:45:24.204
47	124	2598550	amoxicillin 300 MG / clavulanate 75 MG Oral Tablet [Umbrellin]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:45:24.206	2025-08-02 00:45:24.207	2025-08-02 00:45:24.207
48	125	2598552	amoxicillin 50 MG / clavulanate 12.5 MG Oral Tablet [Umbrellin]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:45:24.209	2025-08-02 00:45:24.209	2025-08-02 00:45:24.209
49	126	2598556	amoxicillin 50 MG/ML / clavulanate 12.5 MG/ML Oral Suspension [Umbrellin]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:45:24.211	2025-08-02 00:45:24.212	2025-08-02 00:45:24.212
50	127	2668476	amoxicillin 50 MG/ML / clavulanate 12.5 MG/ML Oral Suspension [Clavacillin]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:45:24.214	2025-08-02 00:45:24.215	2025-08-02 00:45:24.215
51	128	2692884	amoxicillin 100 MG / clavulanate 25 MG Oral Tablet [Betacilin]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:45:24.218	2025-08-02 00:45:24.218	2025-08-02 00:45:24.218
52	129	2692886	amoxicillin 200 MG / clavulanate 50 MG Oral Tablet [Betacilin]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:45:24.22	2025-08-02 00:45:24.221	2025-08-02 00:45:24.221
53	130	2692888	amoxicillin 300 MG / clavulanate 75 MG Oral Tablet [Betacilin]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:45:24.223	2025-08-02 00:45:24.223	2025-08-02 00:45:24.223
54	131	2692890	amoxicillin 50 MG / clavulanate 12.5 MG Oral Tablet [Betacilin]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:45:24.225	2025-08-02 00:45:24.226	2025-08-02 00:45:24.226
55	132	2692894	amoxicillin 50 MG/ML / clavulanate 12.5 MG/ML Oral Suspension [Betacilin]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:45:24.228	2025-08-02 00:45:24.229	2025-08-02 00:45:24.229
56	133	2697446	amoxicillin 100 MG / clavulanate 25 MG Chewable Tablet [Kesium]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:45:24.23	2025-08-02 00:45:24.231	2025-08-02 00:45:24.231
57	134	2697448	amoxicillin 200 MG / clavulanate 50 MG Chewable Tablet [Kesium]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:45:24.232	2025-08-02 00:45:24.233	2025-08-02 00:45:24.233
58	135	2697450	amoxicillin 300 MG / clavulanate 75 MG Chewable Tablet [Kesium]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:45:24.234	2025-08-02 00:45:24.235	2025-08-02 00:45:24.235
59	136	2697452	amoxicillin 50 MG / clavulanate 12.5 MG Chewable Tablet [Kesium]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:45:24.237	2025-08-02 00:45:24.238	2025-08-02 00:45:24.238
60	137	617333	amoxicillin 25 MG/ML / clavulanate 6.25 MG/ML Oral Suspension [Augmentin]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:45:24.239	2025-08-02 00:45:24.24	2025-08-02 00:45:24.24
61	138	617339	amoxicillin 50 MG/ML / clavulanate 12.5 MG/ML Oral Suspension [Augmentin]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:45:24.242	2025-08-02 00:45:24.243	2025-08-02 00:45:24.243
62	139	617432	amoxicillin 80 MG/ML / clavulanate 11.4 MG/ML Oral Suspension [Augmentin]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:45:24.244	2025-08-02 00:45:24.245	2025-08-02 00:45:24.245
63	140	618028	amoxicillin 120 MG/ML / clavulanate 8.58 MG/ML Oral Suspension [Augmentin]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:45:24.247	2025-08-02 00:45:24.247	2025-08-02 00:45:24.247
64	141	791942	amoxicillin 100 MG Oral Tablet [Biomox]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:45:24.249	2025-08-02 00:45:24.25	2025-08-02 00:45:24.25
65	142	791944	amoxicillin 200 MG Oral Tablet [Biomox]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:45:24.252	2025-08-02 00:45:24.252	2025-08-02 00:45:24.252
66	143	791949	amoxicillin 50 MG Oral Tablet [Biomox]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:45:24.255	2025-08-02 00:45:24.255	2025-08-02 00:45:24.255
67	144	824186	amoxicillin 250 MG / clavulanate 125 MG Oral Tablet [Augmentin]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:45:24.257	2025-08-02 00:45:24.257	2025-08-02 00:45:24.257
68	145	824190	amoxicillin 500 MG / clavulanate 125 MG Oral Tablet [Augmentin]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:45:24.259	2025-08-02 00:45:24.26	2025-08-02 00:45:24.26
69	146	824194	amoxicillin 875 MG / clavulanate 125 MG Oral Tablet [Augmentin]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:45:24.261	2025-08-02 00:45:24.262	2025-08-02 00:45:24.262
70	147	828246	amoxicillin 775 MG Extended Release Oral Tablet [Moxatag]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:45:24.264	2025-08-02 00:45:24.264	2025-08-02 00:45:24.264
71	148	861689	12 HR amoxicillin 1000 MG / clavulanate 62.5 MG Extended Release Oral Tablet [Augmentin]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:45:24.266	2025-08-02 00:45:24.266	2025-08-02 00:45:24.266
72	149	897048	amoxicillin 50 MG/ML / clavulanate 12.5 MG/ML Oral Suspension [Clavamox]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:45:24.268	2025-08-02 00:45:24.268	2025-08-02 00:45:24.268
73	150	897052	amoxicillin 50 MG/ML Oral Suspension [Amoxi Drop]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:45:24.27	2025-08-02 00:45:24.271	2025-08-02 00:45:24.271
74	151	105152	amoxicillin 60 MG/ML Oral Suspension	SCD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:45:24.273	2025-08-02 00:45:24.274	2025-08-02 00:45:24.274
75	152	199694	amoxicillin 167 MG/ML Injectable Solution	SCD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:45:24.277	2025-08-02 00:45:24.278	2025-08-02 00:45:24.278
76	153	199928	amoxicillin 200 MG/ML Injectable Solution	SCD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:45:24.28	2025-08-02 00:45:24.28	2025-08-02 00:45:24.28
77	154	246282	amoxicillin 100 MG/ML Oral Suspension	SCD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:45:24.286	2025-08-02 00:45:24.286	2025-08-02 00:45:24.286
78	155	308177	amoxicillin 125 MG Chewable Tablet	SCD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:45:24.287	2025-08-02 00:45:24.288	2025-08-02 00:45:24.288
79	156	308182	amoxicillin 250 MG Oral Capsule	SCD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:45:24.289	2025-08-02 00:45:24.29	2025-08-02 00:45:24.29
80	157	308188	amoxicillin 400 MG Chewable Tablet	SCD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:45:24.291	2025-08-02 00:45:24.292	2025-08-02 00:45:24.292
81	158	308189	amoxicillin 80 MG/ML Oral Suspension	SCD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:45:24.293	2025-08-02 00:45:24.293	2025-08-02 00:45:24.293
82	159	308192	amoxicillin 500 MG Oral Tablet	SCD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:45:24.295	2025-08-02 00:45:24.295	2025-08-02 00:45:24.295
83	160	308194	amoxicillin 875 MG Oral Tablet	SCD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:45:24.297	2025-08-02 00:45:24.297	2025-08-02 00:45:24.297
84	161	313797	amoxicillin 25 MG/ML Oral Suspension	SCD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:45:24.298	2025-08-02 00:45:24.299	2025-08-02 00:45:24.299
85	162	313850	amoxicillin 40 MG/ML Oral Suspension	SCD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:45:24.3	2025-08-02 00:45:24.301	2025-08-02 00:45:24.301
86	163	562253	amoxicillin 125 MG / clavulanate 31.2 MG Chewable Tablet	SCD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:45:24.303	2025-08-02 00:45:24.303	2025-08-02 00:45:24.303
87	164	598025	amoxicillin 250 MG Chewable Tablet	SCD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:45:24.305	2025-08-02 00:45:24.305	2025-08-02 00:45:24.305
88	165	617295	amoxicillin 50 MG/ML / clavulanate 10 MG/ML Injectable Solution	SCD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:45:24.306	2025-08-02 00:45:24.307	2025-08-02 00:45:24.307
89	166	617304	amoxicillin 250 MG / clavulanate 62.5 MG Chewable Tablet	SCD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:45:24.309	2025-08-02 00:45:24.31	2025-08-02 00:45:24.31
90	167	617309	amoxicillin 200 MG / clavulanate 28.5 MG Chewable Tablet	SCD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:45:24.311	2025-08-02 00:45:24.311	2025-08-02 00:45:24.311
91	168	617316	amoxicillin 400 MG / clavulanate 57 MG Chewable Tablet	SCD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:45:24.312	2025-08-02 00:45:24.313	2025-08-02 00:45:24.313
92	169	617423	amoxicillin 40 MG/ML / clavulanate 5.7 MG/ML Oral Suspension	SCD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:45:24.314	2025-08-02 00:45:24.315	2025-08-02 00:45:24.315
93	170	617996	amoxicillin 800 MG / clavulanate 125 MG Oral Tablet	SCD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 00:45:24.317	2025-08-02 00:45:24.318	2025-08-02 00:45:24.318
97	179	1189106	levothyroxine sodium 0.1 MG Oral Tablet [Thyro-Tabs]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.503	2025-08-02 01:28:43.504	2025-08-02 01:28:43.504
98	180	1189191	levothyroxine sodium 0.2 MG Oral Tablet [Thyro-Tabs]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.508	2025-08-02 01:28:43.509	2025-08-02 01:28:43.509
99	181	1189685	levothyroxine sodium 0.3 MG Oral Tablet [Thyro-Tabs]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.511	2025-08-02 01:28:43.512	2025-08-02 01:28:43.512
100	182	1189687	levothyroxine sodium 0.4 MG Oral Tablet [Thyro-Tabs]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.514	2025-08-02 01:28:43.515	2025-08-02 01:28:43.515
101	183	1189689	levothyroxine sodium 0.5 MG Oral Tablet [Thyro-Tabs]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.517	2025-08-02 01:28:43.517	2025-08-02 01:28:43.517
102	184	1189691	levothyroxine sodium 0.6 MG Oral Tablet [Thyro-Tabs]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.519	2025-08-02 01:28:43.52	2025-08-02 01:28:43.52
103	185	1189693	levothyroxine sodium 0.7 MG Oral Tablet [Thyro-Tabs]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.522	2025-08-02 01:28:43.523	2025-08-02 01:28:43.523
104	186	1189695	levothyroxine sodium 0.8 MG Oral Tablet [Thyro-Tabs]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.526	2025-08-02 01:28:43.526	2025-08-02 01:28:43.526
105	187	1189697	levothyroxine sodium 1 MG Oral Tablet [Thyro-Tabs]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.528	2025-08-02 01:28:43.529	2025-08-02 01:28:43.529
106	188	1421056	levothyroxine sodium 0.1 MG Oral Tablet [ThyroKare]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.531	2025-08-02 01:28:43.531	2025-08-02 01:28:43.531
107	189	1421058	levothyroxine sodium 0.2 MG Oral Tablet [ThyroKare]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.533	2025-08-02 01:28:43.534	2025-08-02 01:28:43.534
108	190	1421060	levothyroxine sodium 0.3 MG Oral Tablet [ThyroKare]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.535	2025-08-02 01:28:43.536	2025-08-02 01:28:43.536
109	191	1421067	levothyroxine sodium 0.4 MG Oral Tablet [ThyroKare]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.538	2025-08-02 01:28:43.539	2025-08-02 01:28:43.539
110	192	1421069	levothyroxine sodium 0.5 MG Oral Tablet [ThyroKare]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.541	2025-08-02 01:28:43.542	2025-08-02 01:28:43.542
111	193	1421071	levothyroxine sodium 0.6 MG Oral Tablet [ThyroKare]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.544	2025-08-02 01:28:43.544	2025-08-02 01:28:43.544
112	194	1421073	levothyroxine sodium 0.7 MG Oral Tablet [ThyroKare]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.546	2025-08-02 01:28:43.547	2025-08-02 01:28:43.547
113	195	1421075	levothyroxine sodium 0.8 MG Oral Tablet [ThyroKare]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.549	2025-08-02 01:28:43.549	2025-08-02 01:28:43.549
114	196	1923049	levothyroxine sodium 0.175 MG Oral Capsule [Tirosint]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.551	2025-08-02 01:28:43.552	2025-08-02 01:28:43.552
115	197	1923052	levothyroxine sodium 0.2 MG Oral Capsule [Tirosint]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.553	2025-08-02 01:28:43.554	2025-08-02 01:28:43.554
116	198	2056466	levothyroxine sodium 0.025 MG/ML Oral Solution [Tirosint]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.556	2025-08-02 01:28:43.557	2025-08-02 01:28:43.557
117	199	2056470	levothyroxine sodium 0.05 MG/ML Oral Solution [Tirosint]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.558	2025-08-02 01:28:43.559	2025-08-02 01:28:43.559
118	200	2056474	levothyroxine sodium 0.075 MG/ML Oral Solution [Tirosint]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.561	2025-08-02 01:28:43.562	2025-08-02 01:28:43.562
119	201	2056478	levothyroxine sodium 0.088 MG/ML Oral Solution [Tirosint]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.564	2025-08-02 01:28:43.564	2025-08-02 01:28:43.564
120	202	2056482	levothyroxine sodium 0.1 MG/ML Oral Solution [Tirosint]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.566	2025-08-02 01:28:43.567	2025-08-02 01:28:43.567
121	203	2056486	levothyroxine sodium 0.112 MG/ML Oral Solution [Tirosint]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.569	2025-08-02 01:28:43.569	2025-08-02 01:28:43.569
122	204	2056490	levothyroxine sodium 0.125 MG/ML Oral Solution [Tirosint]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.571	2025-08-02 01:28:43.572	2025-08-02 01:28:43.572
123	205	2056494	levothyroxine sodium 0.013 MG/ML Oral Solution [Tirosint]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.573	2025-08-02 01:28:43.574	2025-08-02 01:28:43.574
124	206	2056498	levothyroxine sodium 0.137 MG/ML Oral Solution [Tirosint]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.576	2025-08-02 01:28:43.576	2025-08-02 01:28:43.576
125	207	2056502	levothyroxine sodium 0.15 MG/ML Oral Solution [Tirosint]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.578	2025-08-02 01:28:43.578	2025-08-02 01:28:43.578
126	208	2056506	levothyroxine sodium 0.175 MG/ML Oral Solution [Tirosint]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.58	2025-08-02 01:28:43.58	2025-08-02 01:28:43.58
127	209	2056510	levothyroxine sodium 0.2 MG/ML Oral Solution [Tirosint]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.582	2025-08-02 01:28:43.583	2025-08-02 01:28:43.583
128	210	2100023	levothyroxine sodium 0.0022 MG/MG Oral Powder [ThyroKare]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.584	2025-08-02 01:28:43.584	2025-08-02 01:28:43.584
129	211	2104866	levothyroxine sodium 0.137 MG Oral Tablet [Euthyrox]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.586	2025-08-02 01:28:43.586	2025-08-02 01:28:43.586
130	212	2473282	levothyroxine sodium 0.02 MG/ML Oral Solution [Thyquidity]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.588	2025-08-02 01:28:43.589	2025-08-02 01:28:43.589
131	213	2566610	levothyroxine sodium 0.0625 MG/ML Oral Solution [Tirosint]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.59	2025-08-02 01:28:43.591	2025-08-02 01:28:43.591
132	214	2566615	levothyroxine sodium 0.0375 MG/ML Oral Solution [Tirosint]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.592	2025-08-02 01:28:43.593	2025-08-02 01:28:43.593
133	215	2566619	levothyroxine sodium 0.044 MG/ML Oral Solution [Tirosint]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.594	2025-08-02 01:28:43.594	2025-08-02 01:28:43.594
134	216	2569974	levothyroxine sodium 1 MG Oral Tablet [ThyroKare]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.596	2025-08-02 01:28:43.596	2025-08-02 01:28:43.596
135	217	2626056	levothyroxine sodium 0.03 MG/ML Oral Solution [Ermeza]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.597	2025-08-02 01:28:43.598	2025-08-02 01:28:43.598
136	218	2630740	levothyroxine sodium 0.0375 MG Oral Capsule [Tirosint]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.599	2025-08-02 01:28:43.6	2025-08-02 01:28:43.6
137	219	2630744	levothyroxine sodium 0.044 MG Oral Capsule [Tirosint]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.601	2025-08-02 01:28:43.601	2025-08-02 01:28:43.601
138	220	2630748	levothyroxine sodium 0.0625 MG Oral Capsule [Tirosint]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.602	2025-08-02 01:28:43.603	2025-08-02 01:28:43.603
139	221	2675685	levothyroxine sodium 0.0022 MG/MG Oral Powder [Thyrocryn]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.604	2025-08-02 01:28:43.605	2025-08-02 01:28:43.605
140	222	903287	levothyroxine sodium 0.0125 MG / liothyronine sodium 0.0031 MG Oral Tablet [Thyrolar]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.606	2025-08-02 01:28:43.606	2025-08-02 01:28:43.606
141	223	903302	levothyroxine sodium 0.15 MG / liothyronine sodium 0.0375 MG Oral Tablet [Thyrolar]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.607	2025-08-02 01:28:43.608	2025-08-02 01:28:43.608
142	224	903309	levothyroxine sodium 0.1 MG / liothyronine sodium 0.025 MG Oral Tablet [Thyrolar]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.609	2025-08-02 01:28:43.609	2025-08-02 01:28:43.609
143	225	903316	levothyroxine sodium 0.025 MG / liothyronine sodium 0.00625 MG Oral Tablet [Thyrolar]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.61	2025-08-02 01:28:43.611	2025-08-02 01:28:43.611
144	226	903442	levothyroxine sodium 0.05 MG / liothyronine sodium 0.0125 MG Oral Tablet [Thyrolar]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.612	2025-08-02 01:28:43.612	2025-08-02 01:28:43.612
145	227	905453	levothyroxine sodium 0.112 MG Oral Capsule [Tirosint]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.613	2025-08-02 01:28:43.614	2025-08-02 01:28:43.614
146	228	905457	levothyroxine sodium 0.137 MG Oral Capsule [Tirosint]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.615	2025-08-02 01:28:43.616	2025-08-02 01:28:43.616
147	229	905460	levothyroxine sodium 0.075 MG Oral Capsule [Tirosint]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.617	2025-08-02 01:28:43.618	2025-08-02 01:28:43.618
148	230	905464	levothyroxine sodium 0.088 MG Oral Capsule [Tirosint]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.619	2025-08-02 01:28:43.619	2025-08-02 01:28:43.619
149	231	966153	levothyroxine sodium 0.025 MG Oral Tablet [Euthyrox]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.62	2025-08-02 01:28:43.621	2025-08-02 01:28:43.621
150	232	966154	levothyroxine sodium 0.025 MG Oral Tablet [Levo-T]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.622	2025-08-02 01:28:43.623	2025-08-02 01:28:43.623
151	233	966157	levothyroxine sodium 0.025 MG Oral Tablet [Levoxyl]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.624	2025-08-02 01:28:43.624	2025-08-02 01:28:43.624
152	234	966158	levothyroxine sodium 0.025 MG Oral Tablet [Synthroid]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.625	2025-08-02 01:28:43.626	2025-08-02 01:28:43.626
153	235	966160	levothyroxine sodium 0.05 MG Oral Tablet [Euthyrox]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.626	2025-08-02 01:28:43.627	2025-08-02 01:28:43.627
154	236	966161	levothyroxine sodium 0.05 MG Oral Tablet [Levo-T]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.628	2025-08-02 01:28:43.628	2025-08-02 01:28:43.628
155	237	966164	levothyroxine sodium 0.05 MG Oral Tablet [Levoxyl]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.629	2025-08-02 01:28:43.63	2025-08-02 01:28:43.63
156	238	966166	levothyroxine sodium 0.075 MG Oral Tablet [Euthyrox]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.63	2025-08-02 01:28:43.631	2025-08-02 01:28:43.631
157	239	966167	levothyroxine sodium 0.075 MG Oral Tablet [Levo-T]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.632	2025-08-02 01:28:43.632	2025-08-02 01:28:43.632
158	240	966170	levothyroxine sodium 0.075 MG Oral Tablet [Levoxyl]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.633	2025-08-02 01:28:43.634	2025-08-02 01:28:43.634
159	241	966171	levothyroxine sodium 0.075 MG Oral Tablet [Synthroid]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.634	2025-08-02 01:28:43.635	2025-08-02 01:28:43.635
160	242	966173	levothyroxine sodium 0.088 MG Oral Tablet [Euthyrox]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.636	2025-08-02 01:28:43.636	2025-08-02 01:28:43.636
161	243	966175	levothyroxine sodium 0.088 MG Oral Tablet [Levoxyl]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.637	2025-08-02 01:28:43.637	2025-08-02 01:28:43.637
162	244	966177	levothyroxine sodium 0.1 MG Oral Tablet [Euthyrox]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.638	2025-08-02 01:28:43.639	2025-08-02 01:28:43.639
163	245	966178	levothyroxine sodium 0.1 MG Oral Tablet [Levo-T]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.639	2025-08-02 01:28:43.64	2025-08-02 01:28:43.64
164	246	966182	levothyroxine sodium 0.112 MG Oral Tablet [Euthyrox]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.641	2025-08-02 01:28:43.641	2025-08-02 01:28:43.641
165	247	966184	levothyroxine sodium 0.112 MG Oral Tablet [Levoxyl]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.643	2025-08-02 01:28:43.643	2025-08-02 01:28:43.643
166	248	966185	levothyroxine sodium 0.112 MG Oral Tablet [Synthroid]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.644	2025-08-02 01:28:43.644	2025-08-02 01:28:43.644
167	249	966187	levothyroxine sodium 0.125 MG Oral Tablet [Euthyrox]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.645	2025-08-02 01:28:43.646	2025-08-02 01:28:43.646
168	250	966188	levothyroxine sodium 0.125 MG Oral Tablet [Levo-T]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.647	2025-08-02 01:28:43.647	2025-08-02 01:28:43.647
169	251	966190	levothyroxine sodium 0.125 MG Oral Tablet [Levoxyl]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.648	2025-08-02 01:28:43.649	2025-08-02 01:28:43.649
170	252	966191	levothyroxine sodium 0.125 MG Oral Tablet [Synthroid]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.649	2025-08-02 01:28:43.65	2025-08-02 01:28:43.65
171	253	966194	levothyroxine sodium 0.137 MG Oral Tablet [Levoxyl]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.651	2025-08-02 01:28:43.651	2025-08-02 01:28:43.651
172	254	966196	levothyroxine sodium 0.15 MG Oral Tablet [Euthyrox]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.652	2025-08-02 01:28:43.653	2025-08-02 01:28:43.653
173	255	966197	levothyroxine sodium 0.15 MG Oral Tablet [Levo-T]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.653	2025-08-02 01:28:43.654	2025-08-02 01:28:43.654
174	256	966200	levothyroxine sodium 0.15 MG Oral Tablet [Levoxyl]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.655	2025-08-02 01:28:43.655	2025-08-02 01:28:43.655
175	257	966201	levothyroxine sodium 0.15 MG Oral Tablet [Synthroid]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.656	2025-08-02 01:28:43.657	2025-08-02 01:28:43.657
176	258	966202	levothyroxine sodium 0.175 MG Oral Tablet [Euthyrox]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.658	2025-08-02 01:28:43.658	2025-08-02 01:28:43.658
177	259	966204	levothyroxine sodium 0.175 MG Oral Tablet [Levoxyl]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.659	2025-08-02 01:28:43.66	2025-08-02 01:28:43.66
178	260	966205	levothyroxine sodium 0.175 MG Oral Tablet [Synthroid]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.661	2025-08-02 01:28:43.661	2025-08-02 01:28:43.661
179	261	966207	levothyroxine sodium 0.2 MG Oral Tablet [Euthyrox]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.662	2025-08-02 01:28:43.663	2025-08-02 01:28:43.663
180	262	966208	levothyroxine sodium 0.2 MG Oral Tablet [Levo-T]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.664	2025-08-02 01:28:43.664	2025-08-02 01:28:43.664
181	263	966211	levothyroxine sodium 0.2 MG Oral Tablet [Levoxyl]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.665	2025-08-02 01:28:43.666	2025-08-02 01:28:43.666
182	264	966214	levothyroxine sodium 0.3 MG Oral Tablet [Levo-T]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.666	2025-08-02 01:28:43.667	2025-08-02 01:28:43.667
183	265	966218	levothyroxine sodium 0.3 MG Oral Tablet [Synthroid]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.668	2025-08-02 01:28:43.668	2025-08-02 01:28:43.668
184	266	966228	levothyroxine sodium 0.025 MG Oral Tablet [Unithroid]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.669	2025-08-02 01:28:43.669	2025-08-02 01:28:43.669
185	267	966232	levothyroxine sodium 0.088 MG Oral Tablet [Unithroid]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.67	2025-08-02 01:28:43.671	2025-08-02 01:28:43.671
186	268	966233	levothyroxine sodium 0.1 MG Oral Tablet [Unithroid]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.672	2025-08-02 01:28:43.672	2025-08-02 01:28:43.672
187	269	966235	levothyroxine sodium 0.112 MG Oral Tablet [Unithroid]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.673	2025-08-02 01:28:43.674	2025-08-02 01:28:43.674
188	270	966237	levothyroxine sodium 0.125 MG Oral Tablet [Unithroid]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.674	2025-08-02 01:28:43.675	2025-08-02 01:28:43.675
189	271	966238	levothyroxine sodium 0.15 MG Oral Tablet [Unithroid]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.676	2025-08-02 01:28:43.677	2025-08-02 01:28:43.677
190	272	966241	levothyroxine sodium 0.2 MG Oral Tablet [Unithroid]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.677	2025-08-02 01:28:43.678	2025-08-02 01:28:43.678
191	273	966243	levothyroxine sodium 0.3 MG Oral Tablet [Unithroid]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.679	2025-08-02 01:28:43.679	2025-08-02 01:28:43.679
192	274	966244	levothyroxine sodium 0.05 MG Oral Tablet [Unithroid]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.68	2025-08-02 01:28:43.681	2025-08-02 01:28:43.681
193	275	966246	levothyroxine sodium 0.175 MG Oral Tablet [Unithroid]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.682	2025-08-02 01:28:43.682	2025-08-02 01:28:43.682
194	276	966247	levothyroxine sodium 0.05 MG Oral Tablet [Synthroid]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.683	2025-08-02 01:28:43.683	2025-08-02 01:28:43.683
195	277	966250	levothyroxine sodium 0.1 MG Oral Tablet [Synthroid]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.684	2025-08-02 01:28:43.685	2025-08-02 01:28:43.685
196	278	966251	levothyroxine sodium 0.2 MG Oral Tablet [Synthroid]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.686	2025-08-02 01:28:43.686	2025-08-02 01:28:43.686
197	279	966271	levothyroxine sodium 0.137 MG Oral Tablet [Synthroid]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.687	2025-08-02 01:28:43.688	2025-08-02 01:28:43.688
198	280	966282	levothyroxine sodium 0.088 MG Oral Tablet [Synthroid]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.688	2025-08-02 01:28:43.689	2025-08-02 01:28:43.689
199	281	966283	levothyroxine sodium 0.1 MG Oral Tablet [Levoxyl]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.69	2025-08-02 01:28:43.69	2025-08-02 01:28:43.69
200	282	966286	levothyroxine sodium 0.075 MG Oral Tablet [Unithroid]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.691	2025-08-02 01:28:43.692	2025-08-02 01:28:43.692
201	283	966397	levothyroxine sodium 0.112 MG Oral Tablet [Levo-T]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.693	2025-08-02 01:28:43.693	2025-08-02 01:28:43.693
202	284	966399	levothyroxine sodium 0.175 MG Oral Tablet [Levo-T]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.694	2025-08-02 01:28:43.694	2025-08-02 01:28:43.694
203	285	966401	levothyroxine sodium 0.088 MG Oral Tablet [Levo-T]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.695	2025-08-02 01:28:43.696	2025-08-02 01:28:43.696
204	286	966410	levothyroxine sodium 0.137 MG Oral Tablet [Levo-T]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.697	2025-08-02 01:28:43.697	2025-08-02 01:28:43.697
205	287	966415	levothyroxine sodium 0.1 MG Oral Capsule [Tirosint]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.698	2025-08-02 01:28:43.698	2025-08-02 01:28:43.698
206	288	966417	levothyroxine sodium 0.125 MG Oral Capsule [Tirosint]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.699	2025-08-02 01:28:43.699	2025-08-02 01:28:43.699
207	289	966420	levothyroxine sodium 0.15 MG Oral Capsule [Tirosint]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.7	2025-08-02 01:28:43.701	2025-08-02 01:28:43.701
208	290	966423	levothyroxine sodium 0.025 MG Oral Capsule [Tirosint]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.701	2025-08-02 01:28:43.702	2025-08-02 01:28:43.702
209	291	966426	levothyroxine sodium 0.05 MG Oral Capsule [Tirosint]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.703	2025-08-02 01:28:43.703	2025-08-02 01:28:43.703
210	292	966434	levothyroxine sodium 0.013 MG Oral Capsule [Tirosint]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.704	2025-08-02 01:28:43.705	2025-08-02 01:28:43.705
211	293	966436	levothyroxine sodium 0.137 MG Oral Tablet [Unithroid]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.706	2025-08-02 01:28:43.706	2025-08-02 01:28:43.706
212	294	1115267	levothyroxine sodium 0.1 MG Injection	SCD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.707	2025-08-02 01:28:43.707	2025-08-02 01:28:43.707
213	295	1115269	levothyroxine sodium 0.2 MG Injection	SCD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.708	2025-08-02 01:28:43.709	2025-08-02 01:28:43.709
214	296	2166148	5 ML levothyroxine sodium 0.1 MG/ML Injection	SCD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.716	2025-08-02 01:28:43.716	2025-08-02 01:28:43.716
215	297	2166193	5 ML levothyroxine sodium 0.02 MG/ML Injection	SCD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.717	2025-08-02 01:28:43.718	2025-08-02 01:28:43.718
216	298	2166196	5 ML levothyroxine sodium 0.04 MG/ML Injection	SCD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.718	2025-08-02 01:28:43.719	2025-08-02 01:28:43.719
217	299	2621123	1 ML levothyroxine sodium 0.1 MG/ML Injection	SCD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.722	2025-08-02 01:28:43.722	2025-08-02 01:28:43.722
218	300	966219	levothyroxine sodium 0.5 MG Injection	SCD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.731	2025-08-02 01:28:43.732	2025-08-02 01:28:43.732
219	301	966280	levothyroxine sodium 0.0125 MG Oral Tablet	SCD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:28:43.737	2025-08-02 01:28:43.737	2025-08-02 01:28:43.737
220	302	979482	losartan potassium 100 MG Oral Tablet [Cozaar]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:29:50.229	2025-08-02 01:29:50.229	2025-08-02 01:29:50.229
221	303	979487	losartan potassium 25 MG Oral Tablet [Cozaar]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:29:50.234	2025-08-02 01:29:50.235	2025-08-02 01:29:50.235
222	304	979494	losartan potassium 50 MG Oral Tablet [Cozaar]	SBD	rxnav_auto_import	0.95	t	auto_import	2025-08-02 01:29:50.238	2025-08-02 01:29:50.238	2025-08-02 01:29:50.238
\.


--
-- Data for Name: drugs; Type: TABLE DATA; Schema: public; Owner: kumar
--

COPY public.drugs (id, name, category, combination, strength, "dosageForm", manufacturer, price, "sideEffects", alternatives) FROM stdin;
77	Zolfresh 5mg	Sleep Aid	\N	Zolpidem 5 mg	Tablet	\N	\N	Drowsiness, dizziness, headache	\N
78	acetaminophen 32 MG/ML Oral Solution [Panadol]	Pain Relief	Panadol 32 MG/ML Oral Solution	32 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
79	acetaminophen 500 MG Oral Tablet [Panadol]	Pain Relief	Panadol 500 MG Oral Tablet	500 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
5	Sacurise	Diabetes	Vildagliptin + Metformin	Vildagliptin 50 mg + Metformin 500 mg	Tablet	Novartis India Ltd	18.500000000000000000000000000000	["Nausea","Diarrhea","Upper respiratory tract infection","Headache","Dizziness","Vomiting","Hypoglycemia (when used with insulin or sulfonylureas)","Metallic taste","Stomach upset"]	["Jalra M","Zomelis Met","Viglim M","Vildaray M","Dynaglipt M"]
6	Dolo 650	Pain Relief	Paracetamol	Paracetamol 650 mg	Tablet	Micro Labs Ltd	2.500000000000000000000000000000	["Nausea","Vomiting","Stomach upset","Liver damage (with overdose)","Allergic reactions (rare)","Skin rash (rare)"]	["Crocin 650","Calpol 650","Pacimol 650","Paracip 650","Tylenol"]
80	200 ML ciprofloxacin 2 MG/ML Injection [Cipro]	Antibiotics	Cipro 400 MG per 200 ML Injection	200 ML	Injection	RxNav Import	\N	Consult healthcare provider for side effects	\N
81	ciprofloxacin 250 MG Oral Tablet [Cipro]	Antibiotics	Cipro 250 MG Oral Tablet	250 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
82	ciprofloxacin 500 MG Oral Tablet [Cipro]	Antibiotics	Cipro 500 MG Oral Tablet	500 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
83	ciprofloxacin 50 MG/ML Oral Suspension [Cipro]	Antibiotics	Cipro 50 MG/ML Oral Suspension	50 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
84	ciprofloxacin 100 MG/ML Oral Suspension [Cipro]	Antibiotics	Cipro 100 MG/ML Oral Suspension	100 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
7	Azithral 500	Antibiotics	Azithromycin	Azithromycin 500 mg	Tablet	Alembic Pharmaceuticals Ltd	12.000000000000000000000000000000	["Nausea","Vomiting","Diarrhea","Stomach pain","Headache","Dizziness","Hearing problems (rare)","Heart rhythm changes (rare)"]	["Zithromax","Azimax","Azax","Zady","Azicip"]
8	Amlodac 5	Hypertension	Amlodipine	Amlodipine 5 mg	Tablet	Cadila Healthcare Ltd	4.250000000000000000000000000000	["Ankle swelling","Fatigue","Dizziness","Flushing","Headache","Palpitations","Nausea","Abdominal pain"]	["Amlong","Stamlo 5","Lupidip","Amlovas","Norvasc"]
47	Lipikind CV 10	Cardiovascular	Atorvastatin + Clopidogrel	Atorvastatin 10 mg + Clopidogrel 75 mg	Capsule	Mankind Pharma Ltd	18.000000000000000000000000000000	["Muscle pain","Headache","Nausea","Diarrhea","Bleeding risk","Stomach upset","Dizziness","Liver enzyme elevation (rare)"]	["Rosulip Plus","Ecosprin AV","Storvas CV","Atorlip CV","Lipitor Plus"]
9	Lipikind CV 20	Cardiovascular	Atorvastatin + Clopidogrel	Atorvastatin 20 mg + Clopidogrel 75 mg	Capsule	Mankind Pharma Ltd	22.000000000000000000000000000000	["Muscle pain","Headache","Nausea","Diarrhea","Bleeding risk","Stomach upset","Dizziness","Liver enzyme elevation (rare)"]	["Rosulip Plus","Ecosprin AV","Storvas CV","Atorlip CV","Lipitor Plus"]
10	Neurobion Forte	Supplements	Vitamin B Complex	B1(10mg) + B6(3mg) + B12(15mcg)	Tablet	Merck Ltd	8.750000000000000000000000000000	["Mild stomach upset","Nausea","Allergic reactions (rare)","Flushing","Tingling sensation (rare)"]	["Becosules","Supradyn","Nervijen Plus","Cobadex CZS","Vitcofol"]
19	Bisolong 5	Hypertension	Bisoprolol Fumarate	Bisoprolol 5 mg	Tablet	Micro Labs Ltd	6.750000000000000000000000000000	["Fatigue","Dizziness","Headache","Cold hands and feet","Nausea","Diarrhea","Slow heart rate","Low blood pressure","Sleep disturbances","Depression (rare)"]	["Concor 5","Corbis 5","Bisoprol","Bisocar","Cardivas"]
29	Bisolong 2.5	Hypertension	Bisoprolol Fumarate	Bisoprolol 2.5 mg	Tablet	Micro Labs Ltd	4.250000000000000000000000000000	["Fatigue","Dizziness","Headache","Cold hands and feet","Nausea","Diarrhea","Slow heart rate","Low blood pressure","Sleep disturbances","Depression (rare)"]	["Concor 2.5","Corbis 2.5","Bisoheart 2.5","Bisocard 2.5","Nebilong 2.5"]
85	24 HR ciprofloxacin 1000 MG Extended Release Oral Tablet [Cipro]	Antibiotics	24 HR Cipro 1000 MG Extended Release Oral Tablet	1000 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
86	24 HR ciprofloxacin 500 MG Extended Release Oral Tablet [Cipro]	Antibiotics	24 HR Cipro 500 MG Extended Release Oral Tablet	500 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
1	Startglim M2	Diabetes	Glimepiride + Metformin Hydrochloride	Glimepiride 2 mg + Metformin 500 mg	Tablet	Mankind Pharma Ltd	10.000000000000000000000000000000	["Hypoglycemia","Headache","Nausea","Dizziness","Weight gain","Stomach upset","Diarrhea","Metallic taste","Anemia (rare)","Lactic acidosis (rare)"]	["Glimestar M2","Glycomet GP2","Glimy M2","Azulix 2 MF","Gluconorm G2"]
2	Dapa 10 mg	Diabetes	Dapagliflozin	Dapagliflozin 10 mg	Tablet	Shrrishti Health Care Products Pvt Ltd	15.000000000000000000000000000000	["Increased urination","Urinary tract infection","Genital fungal infection","Dehydration","Dizziness","Back pain","Hypoglycemia (with other antidiabetics)","Ketoacidosis (rare)"]	["Forxiga","Dapanorm","Dapamac","Sugaflo","Dapaford"]
40	Dytor Plus 5	Diuretics	Torsemide + Spironolactone	Torsemide 5 mg + Spironolactone 50 mg	Tablet	Cipla Ltd	12.750000000000000000000000000000	["Dizziness","Headache","Nausea","Dehydration","Low blood pressure","Electrolyte imbalance","Kidney function changes","Increased urination","Fatigue","Muscle cramps"]	["Tor Plus","Dytor 20 Plus","Torsid Plus","Dynapress Plus","Torsinex Plus"]
87	ciprofloxacin 3 MG/ML Ophthalmic Solution [Ciloxan]	Antibiotics	Ciloxan 0.3 % Ophthalmic Solution	3 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
88	ciprofloxacin 60 MG/ML Otic Suspension [Otiprio]	Antibiotics	Otiprio 6 % Otic Suspension	60 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
89	ciprofloxacin 3 MG/ML / fluocinolone acetonide 0.25 MG/ML Otic Solution [Otovel]	Antibiotics	Otovel (ciprofloxacin 0.3 % / fluocinolone acetonide 0.025 % ) Otic Solution	3 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
90	ciprofloxacin 0.003 MG/MG Ophthalmic Ointment [Ciloxan]	Antibiotics	Ciloxan 0.3 % Ophthalmic Ointment	0.003 MG	Topical	RxNav Import	\N	Consult healthcare provider for side effects	\N
91	ciprofloxacin 2 MG/ML / hydrocortisone 10 MG/ML Otic Suspension [Cipro HC]	Antibiotics	Cipro HC 2/10 Otic Suspension	2 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
92	ciprofloxacin 3 MG/ML / dexamethasone 1 MG/ML Otic Suspension [Ciprodex]	Antibiotics	Ciprodex (ciprofloxacin 0.3 % / dexamethasone 0.1 % ) Otic Suspension	3 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
93	24 HR ciprofloxacin 500 MG Extended Release Oral Tablet [Proquin]	Antibiotics	24 HR Proquin 500 MG Extended Release Oral Tablet	500 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
94	ciprofloxacin 2 MG/ML Otic Solution [Cetraxal]	Antibiotics	Cetraxal 0.2 % Otic Solution	2 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
95	100 ML ciprofloxacin 2 MG/ML Injection	Antibiotics	ciprofloxacin 200 MG per 100 ML Injection	100 ML	Injection	RxNav Import	\N	Consult healthcare provider for side effects	\N
96	40 ML ciprofloxacin 10 MG/ML Injection	Antibiotics	ciprofloxacin 400 MG per 40 ML Injection	40 ML	Injection	RxNav Import	\N	Consult healthcare provider for side effects	\N
97	ciprofloxacin 750 MG Oral Tablet	Antibiotics	ciprofloxacin (as ciprofloxacin hydrochloride) 750 MG Oral Tablet	750 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
98	ciprofloxacin 100 MG Oral Tablet	Antibiotics	ciprofloxacin (as ciprofloxacin hydrochloride) 100 MG Oral Tablet	100 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
99	Cipro (ciprofloxacin)	Antibiotics	Indian brand name for ciprofloxacin	\N	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
100	Ciplox (ciprofloxacin)	Antibiotics	Indian brand name for ciprofloxacin	\N	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
101	Cifran (ciprofloxacin)	Antibiotics	Indian brand name for ciprofloxacin	\N	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
102	{4 (amoxicillin 500 MG Oral Capsule) / 2 (clarithromycin 500 MG Oral Tablet) / 2 (omeprazole 20 MG Delayed Release Oral Capsule) } Pack [Omeclamox]	Antibiotics	Omeclamox-Pak	500 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
103	{84 (amoxicillin 500 MG Oral Capsule) / 28 (vonoprazan 20 MG Oral Tablet) } Pack [Voquezna 14 Day DualPak 20;500]	Antibiotics	Voquezna 14 Day DualPak 20 MG; 500 MG Pack	500 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
104	{56 (amoxicillin 500 MG Oral Capsule) / 28 (clarithromycin 500 MG Oral Tablet) / 28 (vonoprazan 20 MG Oral Tablet) } Pack [Voquezna 14 Day TriplePak 20;500;500]	Antibiotics	Voquezna 14 Day TriplePak 20 MG; 500 MG; 500 MG Pack	500 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
105	{4 (amoxicillin 500 MG Oral Capsule [Trimox]) / 2 (clarithromycin 500 MG Oral Tablet [Biaxin]) / 2 (lansoprazole 30 MG Delayed Release Oral Capsule [Prevacid]) } Pack [Prevpac]	Antibiotics	Prevpac Patient Therapy Pack	500 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
106	{4 (amoxicillin 500 MG Oral Capsule) / 2 (clarithromycin 500 MG Oral Tablet) / 2 (lansoprazole 30 MG Delayed Release Oral Capsule) } Pack	Antibiotics	\N	500 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
107	amoxicillin 400 MG Oral Tablet [Amoxi-tabs]	Antibiotics	Amoxi-tabs 400 MG Oral Tablet	400 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
108	amoxicillin 150 MG Oral Tablet [Amoxi-tabs]	Antibiotics	Amoxi-tabs 150 MG Oral Tablet	150 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
109	amoxicillin 200 MG Oral Tablet [Amoxi-tabs]	Antibiotics	Amoxi-tabs 200 MG Oral Tablet	200 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
110	amoxicillin 100 MG Oral Tablet [Amoxi-tabs]	Antibiotics	Amoxi-tabs 100 MG Oral Tablet	100 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
111	amoxicillin 50 MG Oral Tablet [Amoxi-tabs]	Antibiotics	Amoxi-tabs 50 MG Oral Tablet	50 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
112	amoxicillin 50 MG/ML Oral Suspension [Biomox]	Antibiotics	Biomox 50 MG/ML Oral Suspension	50 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
113	amoxicillin 100 MG / clavulanate 25 MG Chewable Tablet [Clavamox]	Antibiotics	Clavamox 100 MG / 25 MG Chewable Tablet	100 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
114	amoxicillin 200 MG / clavulanate 50 MG Chewable Tablet [Clavamox]	Antibiotics	Clavamox 200 MG / 50 MG Chewable Tablet	200 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
115	amoxicillin 300 MG / clavulanate 75 MG Chewable Tablet [Clavamox]	Antibiotics	Clavamox 300 MG / 75 MG Chewable Tablet	300 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
116	amoxicillin 50 MG / clavulanate 12.5 MG Chewable Tablet [Clavamox]	Antibiotics	Clavamox 50 MG / 12.5 MG Chewable Tablet	50 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
117	amoxicillin 100 MG / clavulanate 25 MG Oral Tablet [Clavacillin]	Antibiotics	Clavacillin 100 MG / 25 MG Oral Tablet	100 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
118	amoxicillin 200 MG / clavulanate 50 MG Oral Tablet [Clavacillin]	Antibiotics	Clavacillin 200 MG / 50 MG Oral Tablet	200 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
119	amoxicillin 300 MG / clavulanate 75 MG Oral Tablet [Clavacillin]	Antibiotics	Clavacillin 300 MG / 75 MG Oral Tablet	300 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
120	amoxicillin 50 MG / clavulanate 12.5 MG Oral Tablet [Clavacillin]	Antibiotics	Clavacillin 50 MG / 12.5 MG Oral Tablet	50 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
121	amoxicillin 250 MG / omeprazole 10 MG / rifabutin 12.5 MG Delayed Release Oral Capsule [Talicia]	Antibiotics	Talicia 250 MG / 10 MG / 12.5 MG Delayed Release Oral Capsule	250 MG	Capsule	RxNav Import	\N	Consult healthcare provider for side effects	\N
122	amoxicillin 100 MG / clavulanate 25 MG Oral Tablet [Umbrellin]	Antibiotics	Umbrellin (amoxicillin 100 MG / clavulanate potassium 25 MG) Oral Tablet	100 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
123	amoxicillin 200 MG / clavulanate 50 MG Oral Tablet [Umbrellin]	Antibiotics	Umbrellin (amoxicillin 200 MG / clavulanate potassium 50 MG) Oral Tablet	200 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
124	amoxicillin 300 MG / clavulanate 75 MG Oral Tablet [Umbrellin]	Antibiotics	Umbrellin (amoxicillin 300 MG / clavulanate potassium 75 MG) Oral Tablet	300 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
125	amoxicillin 50 MG / clavulanate 12.5 MG Oral Tablet [Umbrellin]	Antibiotics	Umbrellin (amoxicillin 50 MG / clavulanate potassium 12.5 MG) Oral Tablet	50 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
126	amoxicillin 50 MG/ML / clavulanate 12.5 MG/ML Oral Suspension [Umbrellin]	Antibiotics	Umbrellin (amoxicillin (as amoxicillin trihydrate)) 250 MG / clavulanic acid (as clavulanate potassium) 62.5 MG per 5 Oral Suspension	50 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
127	amoxicillin 50 MG/ML / clavulanate 12.5 MG/ML Oral Suspension [Clavacillin]	Antibiotics	Clavacillin 250 MG / 62.5 MG per 5 ML Oral Suspension	50 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
165	amoxicillin 50 MG/ML / clavulanate 10 MG/ML Injectable Solution	Antibiotics	\N	50 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
128	amoxicillin 100 MG / clavulanate 25 MG Oral Tablet [Betacilin]	Antibiotics	Betacilin (amoxicillin 100 MG / clavulanate potassium 25 MG) Oral Tablet	100 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
129	amoxicillin 200 MG / clavulanate 50 MG Oral Tablet [Betacilin]	Antibiotics	Betacilin (amoxicillin 200 MG / clavulanate potassium 50 MG) Oral Tablet	200 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
130	amoxicillin 300 MG / clavulanate 75 MG Oral Tablet [Betacilin]	Antibiotics	Betacilin (amoxicillin 300 MG / clavulanate potassium 75 MG) Oral Tablet	300 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
131	amoxicillin 50 MG / clavulanate 12.5 MG Oral Tablet [Betacilin]	Antibiotics	Betacilin (amoxicillin 50 MG / clavulanate potassium 12.5 MG) Oral Tablet	50 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
132	amoxicillin 50 MG/ML / clavulanate 12.5 MG/ML Oral Suspension [Betacilin]	Antibiotics	Betacilin 250 MG / 62.5 MG per 5 ML Oral Suspension	50 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
133	amoxicillin 100 MG / clavulanate 25 MG Chewable Tablet [Kesium]	Antibiotics	Kesium 100 MG / 25 MG Chewable Tablet	100 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
134	amoxicillin 200 MG / clavulanate 50 MG Chewable Tablet [Kesium]	Antibiotics	Kesium 200 MG / 50 MG Chewable Tablet	200 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
135	amoxicillin 300 MG / clavulanate 75 MG Chewable Tablet [Kesium]	Antibiotics	Kesium 300 MG / 75 MG Chewable Tablet	300 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
136	amoxicillin 50 MG / clavulanate 12.5 MG Chewable Tablet [Kesium]	Antibiotics	Kesium 50 MG / 12.5 MG Chewable Tablet	50 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
137	amoxicillin 25 MG/ML / clavulanate 6.25 MG/ML Oral Suspension [Augmentin]	Antibiotics	Augmentin 125 MG / 31.25 MG per 5 ML Oral Suspension	25 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
138	amoxicillin 50 MG/ML / clavulanate 12.5 MG/ML Oral Suspension [Augmentin]	Antibiotics	Augmentin 250 mg / 62.5 MG per 5 ML Oral Suspension	50 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
139	amoxicillin 80 MG/ML / clavulanate 11.4 MG/ML Oral Suspension [Augmentin]	Antibiotics	Augmentin (amoxicillin 400 MG / clavulanate 57 MG) per 5 ML Oral Suspension	80 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
140	amoxicillin 120 MG/ML / clavulanate 8.58 MG/ML Oral Suspension [Augmentin]	Antibiotics	Augmentin ES 600 MG / 42.9 MG per 5 ML Oral Suspension	120 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
141	amoxicillin 100 MG Oral Tablet [Biomox]	Antibiotics	Biomox 100 MG Oral Tablet	100 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
142	amoxicillin 200 MG Oral Tablet [Biomox]	Antibiotics	Biomox 200 MG Oral Tablet	200 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
143	amoxicillin 50 MG Oral Tablet [Biomox]	Antibiotics	Biomox 50 MG Oral Tablet	50 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
144	amoxicillin 250 MG / clavulanate 125 MG Oral Tablet [Augmentin]	Antibiotics	Augmentin 250-mg Oral Tablet	250 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
145	amoxicillin 500 MG / clavulanate 125 MG Oral Tablet [Augmentin]	Antibiotics	Augmentin 500-mg Oral Tablet	500 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
146	amoxicillin 875 MG / clavulanate 125 MG Oral Tablet [Augmentin]	Antibiotics	Augmentin 875-mg Oral Tablet	875 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
147	amoxicillin 775 MG Extended Release Oral Tablet [Moxatag]	Antibiotics	Moxatag 775 MG Extended Release Oral Tablet	775 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
148	12 HR amoxicillin 1000 MG / clavulanate 62.5 MG Extended Release Oral Tablet [Augmentin]	Antibiotics	Augmentin XR 12 HR 1000 MG Extended Release Oral Tablet	1000 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
149	amoxicillin 50 MG/ML / clavulanate 12.5 MG/ML Oral Suspension [Clavamox]	Antibiotics	Clavamox (amoxicillin 50 MG/ML / clavulanate 12.5 MG/ML) Oral Suspension	50 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
150	amoxicillin 50 MG/ML Oral Suspension [Amoxi Drop]	Antibiotics	Amoxi-Drop 50 MG/ML Oral Suspension	50 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
151	amoxicillin 60 MG/ML Oral Suspension	Antibiotics	\N	60 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
152	amoxicillin 167 MG/ML Injectable Solution	Antibiotics	\N	167 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
153	amoxicillin 200 MG/ML Injectable Solution	Antibiotics	\N	200 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
154	amoxicillin 100 MG/ML Oral Suspension	Antibiotics	amoxicillin (as amoxicillin trihydrate) 100 MG/ML Oral Suspension	100 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
155	amoxicillin 125 MG Chewable Tablet	Antibiotics	\N	125 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
156	amoxicillin 250 MG Oral Capsule	Antibiotics	amoxicillin (as amoxicillin trihydrate) 250 MG Oral Capsule	250 MG	Capsule	RxNav Import	\N	Consult healthcare provider for side effects	\N
157	amoxicillin 400 MG Chewable Tablet	Antibiotics	\N	400 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
158	amoxicillin 80 MG/ML Oral Suspension	Antibiotics	amoxicillin (as amoxicillin trihydrate) 400 MG per 5 ML Oral Suspension	80 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
159	amoxicillin 500 MG Oral Tablet	Antibiotics	\N	500 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
160	amoxicillin 875 MG Oral Tablet	Antibiotics	amoxicillin (as amoxicillin trihydrate) 875 MG Oral Tablet	875 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
161	amoxicillin 25 MG/ML Oral Suspension	Antibiotics	amoxicillin 125 MG per 5 ML Oral Suspension	25 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
162	amoxicillin 40 MG/ML Oral Suspension	Antibiotics	amoxicillin 200 MG per 5 ML Oral Suspension	40 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
163	amoxicillin 125 MG / clavulanate 31.2 MG Chewable Tablet	Antibiotics	\N	125 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
164	amoxicillin 250 MG Chewable Tablet	Antibiotics	\N	250 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
166	amoxicillin 250 MG / clavulanate 62.5 MG Chewable Tablet	Antibiotics	amoxicillin 250 MG / clavulanate (as clavulanate potassium) 62.5 MG Chewable Tablet	250 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
167	amoxicillin 200 MG / clavulanate 28.5 MG Chewable Tablet	Antibiotics	amoxicillin 200 MG / clavulanate (as clavulanate potassium) 28.5 MG Chewable Tablet	200 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
168	amoxicillin 400 MG / clavulanate 57 MG Chewable Tablet	Antibiotics	amoxicillin 400 MG / clavulanate (as clavulanate potassium) 57 MG Chewable Tablet	400 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
169	amoxicillin 40 MG/ML / clavulanate 5.7 MG/ML Oral Suspension	Antibiotics	amoxicillin 200 MG / clavulanic acid 28.5 MG per 5 ML Oral Suspension	40 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
170	amoxicillin 800 MG / clavulanate 125 MG Oral Tablet	Antibiotics	\N	800 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
171	Amoxil (amoxicillin)	Antibiotics	Indian brand name for amoxicillin	\N	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
172	Augmentin (amoxicillin)	Antibiotics	Indian brand name for amoxicillin	\N	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
173	Amox (amoxicillin)	Antibiotics	Indian brand name for amoxicillin	\N	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
174	Glucophage (metformin)	Diabetes	Indian brand name for metformin	\N	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
175	Glycomet (metformin)	Diabetes	Indian brand name for metformin	\N	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
176	Metfor (metformin)	Diabetes	Indian brand name for metformin	\N	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
177	Metformin 850mg	Antidiabetic	Metformin Hydrochloride	850mg	Tablet	Generic	45.000000000000000000000000000000	["Nausea","Vomiting","Diarrhea","Stomach upset","Metallic taste"]	["Metformin 500mg","Metformin 1000mg","Glucophage"]
178	Atorvastatin 10mg	Cardiovascular	Atorvastatin Calcium	10mg	Tablet	Generic	85.000000000000000000000000000000	["Muscle pain","Headache","Dizziness","Nausea","Fatigue"]	["Atorvastatin 20mg","Atorvastatin 40mg","Rosuvastatin","Simvastatin"]
179	levothyroxine sodium 0.1 MG Oral Tablet [Thyro-Tabs]	General Medicine	Thyro-Tabs 0.1 MG Oral Tablet	0.1 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
180	levothyroxine sodium 0.2 MG Oral Tablet [Thyro-Tabs]	General Medicine	Thyro-Tabs 0.2 MG Oral Tablet	0.2 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
181	levothyroxine sodium 0.3 MG Oral Tablet [Thyro-Tabs]	General Medicine	Thyro-Tabs 0.3 MG Oral Tablet	0.3 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
182	levothyroxine sodium 0.4 MG Oral Tablet [Thyro-Tabs]	General Medicine	Thyro-Tabs 0.4 MG Oral Tablet	0.4 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
183	levothyroxine sodium 0.5 MG Oral Tablet [Thyro-Tabs]	General Medicine	Thyro-Tabs 0.5 MG Oral Tablet	0.5 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
184	levothyroxine sodium 0.6 MG Oral Tablet [Thyro-Tabs]	General Medicine	Thyro-Tabs 0.6 MG Oral Tablet	0.6 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
185	levothyroxine sodium 0.7 MG Oral Tablet [Thyro-Tabs]	General Medicine	Thyro-Tabs 0.7 MG Oral Tablet	0.7 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
186	levothyroxine sodium 0.8 MG Oral Tablet [Thyro-Tabs]	General Medicine	Thyro-Tabs 0.8 MG Oral Tablet	0.8 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
187	levothyroxine sodium 1 MG Oral Tablet [Thyro-Tabs]	General Medicine	Thyro-Tabs 1 MG Oral Tablet	1 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
188	levothyroxine sodium 0.1 MG Oral Tablet [ThyroKare]	General Medicine	ThyroKare 0.1 MG Oral Tablet	0.1 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
189	levothyroxine sodium 0.2 MG Oral Tablet [ThyroKare]	General Medicine	ThyroKare 0.2 MG Oral Tablet	0.2 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
190	levothyroxine sodium 0.3 MG Oral Tablet [ThyroKare]	General Medicine	ThyroKare 0.3 MG Oral Tablet	0.3 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
191	levothyroxine sodium 0.4 MG Oral Tablet [ThyroKare]	General Medicine	ThyroKare 0.4 MG Oral Tablet	0.4 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
192	levothyroxine sodium 0.5 MG Oral Tablet [ThyroKare]	General Medicine	ThyroKare 0.5 MG Oral Tablet	0.5 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
193	levothyroxine sodium 0.6 MG Oral Tablet [ThyroKare]	General Medicine	ThyroKare 0.6 MG Oral Tablet	0.6 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
194	levothyroxine sodium 0.7 MG Oral Tablet [ThyroKare]	General Medicine	ThyroKare 0.7 MG Oral Tablet	0.7 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
195	levothyroxine sodium 0.8 MG Oral Tablet [ThyroKare]	General Medicine	ThyroKare 0.8 MG Oral Tablet	0.8 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
196	levothyroxine sodium 0.175 MG Oral Capsule [Tirosint]	General Medicine	Tirosint 175 MCG Oral Capsule	0.175 MG	Capsule	RxNav Import	\N	Consult healthcare provider for side effects	\N
197	levothyroxine sodium 0.2 MG Oral Capsule [Tirosint]	General Medicine	Tirosint 0.2 MG Oral Capsule	0.2 MG	Capsule	RxNav Import	\N	Consult healthcare provider for side effects	\N
198	levothyroxine sodium 0.025 MG/ML Oral Solution [Tirosint]	General Medicine	Tirosint SOL 0.025 MG per 1 ML Oral Solution	0.025 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
199	levothyroxine sodium 0.05 MG/ML Oral Solution [Tirosint]	General Medicine	Tirosint SOL 0.05 MG per 1 ML Oral Solution	0.05 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
200	levothyroxine sodium 0.075 MG/ML Oral Solution [Tirosint]	General Medicine	Tirosint SOL 0.075 MG per 1 ML Oral Solution	0.075 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
201	levothyroxine sodium 0.088 MG/ML Oral Solution [Tirosint]	General Medicine	Tirosint SOL 0.088 MG per 1 ML Oral Solution	0.088 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
202	levothyroxine sodium 0.1 MG/ML Oral Solution [Tirosint]	General Medicine	Tirosint SOL 0.1 MG per 1 ML Oral Solution	0.1 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
203	levothyroxine sodium 0.112 MG/ML Oral Solution [Tirosint]	General Medicine	Tirosint SOL 0.112 MG per 1 ML Oral Solution	0.112 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
204	levothyroxine sodium 0.125 MG/ML Oral Solution [Tirosint]	General Medicine	Tirosint SOL 0.125 MG per 1 ML Oral Solution	0.125 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
205	levothyroxine sodium 0.013 MG/ML Oral Solution [Tirosint]	General Medicine	Tirosint SOL 0.013 MG per 1 ML Oral Solution	0.013 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
206	levothyroxine sodium 0.137 MG/ML Oral Solution [Tirosint]	General Medicine	Tirosint SOL 0.137 MG per 1 ML Oral Solution	0.137 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
207	levothyroxine sodium 0.15 MG/ML Oral Solution [Tirosint]	General Medicine	Tirosint SOL 0.15 MG per 1 ML Oral Solution	0.15 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
208	levothyroxine sodium 0.175 MG/ML Oral Solution [Tirosint]	General Medicine	Tirosint SOL 0.175 MG per 1 ML Oral Solution	0.175 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
209	levothyroxine sodium 0.2 MG/ML Oral Solution [Tirosint]	General Medicine	Tirosint SOL 0.2 MG per 1 ML Oral Solution	0.2 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
210	levothyroxine sodium 0.0022 MG/MG Oral Powder [ThyroKare]	General Medicine	ThyroKare 0.0022 MG/MG Oral Powder	0.0022 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
211	levothyroxine sodium 0.137 MG Oral Tablet [Euthyrox]	General Medicine	Euthyrox 137 MCG Oral Tablet	0.137 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
212	levothyroxine sodium 0.02 MG/ML Oral Solution [Thyquidity]	General Medicine	Thyquidity 0.02 MG/ML Oral Solution	0.02 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
213	levothyroxine sodium 0.0625 MG/ML Oral Solution [Tirosint]	General Medicine	Tirosint 0.0625 MG/ML Oral Solution	0.0625 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
214	levothyroxine sodium 0.0375 MG/ML Oral Solution [Tirosint]	General Medicine	Tirosint 0.0375 MG/ML Oral Solution	0.0375 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
215	levothyroxine sodium 0.044 MG/ML Oral Solution [Tirosint]	General Medicine	Tirosint 0.044 MG/ML Oral Solution	0.044 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
216	levothyroxine sodium 1 MG Oral Tablet [ThyroKare]	General Medicine	ThyroKare 1 MG Oral Tablet	1 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
217	levothyroxine sodium 0.03 MG/ML Oral Solution [Ermeza]	General Medicine	Ermeza 0.03 MG/ML Oral Solution	0.03 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
218	levothyroxine sodium 0.0375 MG Oral Capsule [Tirosint]	General Medicine	Tirosint 37.5 MCG Oral Capsule	0.0375 MG	Capsule	RxNav Import	\N	Consult healthcare provider for side effects	\N
219	levothyroxine sodium 0.044 MG Oral Capsule [Tirosint]	General Medicine	Tirosint 44 MCG Oral Capsule	0.044 MG	Capsule	RxNav Import	\N	Consult healthcare provider for side effects	\N
220	levothyroxine sodium 0.0625 MG Oral Capsule [Tirosint]	General Medicine	Tirosint 62.5 MCG Oral Capsule	0.0625 MG	Capsule	RxNav Import	\N	Consult healthcare provider for side effects	\N
221	levothyroxine sodium 0.0022 MG/MG Oral Powder [Thyrocryn]	General Medicine	Thyrocryn 0.22 % Oral Powder	0.0022 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
222	levothyroxine sodium 0.0125 MG / liothyronine sodium 0.0031 MG Oral Tablet [Thyrolar]	General Medicine	Thyrolar 1/4 (levothyroxine sodium 12.5 MCG / liothyronine sodium 3.1 MCG) Oral Tablet	0.0125 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
223	levothyroxine sodium 0.15 MG / liothyronine sodium 0.0375 MG Oral Tablet [Thyrolar]	General Medicine	Thyrolar 3 (levothyroxine sodium 150 MCG / liothyronine sodium 37.5 MCG) Oral Tablet	0.15 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
224	levothyroxine sodium 0.1 MG / liothyronine sodium 0.025 MG Oral Tablet [Thyrolar]	General Medicine	Thyrolar 2 (levothyroxine sodium 100 MCG / liothyronine sodium 25 MCG) Oral Tablet	0.1 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
225	levothyroxine sodium 0.025 MG / liothyronine sodium 0.00625 MG Oral Tablet [Thyrolar]	General Medicine	Thyrolar 1/2 (levothyroxine sodium 25 MCG / liothyronine sodium 6.25 MCG) Oral Tablet	0.025 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
226	levothyroxine sodium 0.05 MG / liothyronine sodium 0.0125 MG Oral Tablet [Thyrolar]	General Medicine	Thyrolar 1 (levothyroxine sodium 50 MCG / liothyronine sodium 12.5 MCG) Oral Tablet	0.05 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
227	levothyroxine sodium 0.112 MG Oral Capsule [Tirosint]	General Medicine	Tirosint 112 MCG Oral Capsule	0.112 MG	Capsule	RxNav Import	\N	Consult healthcare provider for side effects	\N
228	levothyroxine sodium 0.137 MG Oral Capsule [Tirosint]	General Medicine	Tirosint 137 MCG Oral Capsule	0.137 MG	Capsule	RxNav Import	\N	Consult healthcare provider for side effects	\N
229	levothyroxine sodium 0.075 MG Oral Capsule [Tirosint]	General Medicine	Tirosint 75 MCG Oral Capsule	0.075 MG	Capsule	RxNav Import	\N	Consult healthcare provider for side effects	\N
230	levothyroxine sodium 0.088 MG Oral Capsule [Tirosint]	General Medicine	Tirosint 88 MCG Oral Capsule	0.088 MG	Capsule	RxNav Import	\N	Consult healthcare provider for side effects	\N
231	levothyroxine sodium 0.025 MG Oral Tablet [Euthyrox]	General Medicine	Euthyrox 25 MCG Oral Tablet	0.025 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
232	levothyroxine sodium 0.025 MG Oral Tablet [Levo-T]	General Medicine	Levo-T 25 MCG Oral Tablet	0.025 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
233	levothyroxine sodium 0.025 MG Oral Tablet [Levoxyl]	General Medicine	Levoxyl 25 MCG Oral Tablet	0.025 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
234	levothyroxine sodium 0.025 MG Oral Tablet [Synthroid]	General Medicine	Synthroid 25 MCG Oral Tablet	0.025 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
235	levothyroxine sodium 0.05 MG Oral Tablet [Euthyrox]	General Medicine	Euthyrox 50 MCG Oral Tablet	0.05 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
236	levothyroxine sodium 0.05 MG Oral Tablet [Levo-T]	General Medicine	Levo-T 50 MCG Oral Tablet	0.05 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
237	levothyroxine sodium 0.05 MG Oral Tablet [Levoxyl]	General Medicine	Levoxyl 50 MCG Oral Tablet	0.05 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
238	levothyroxine sodium 0.075 MG Oral Tablet [Euthyrox]	General Medicine	Euthyrox 75 MCG Oral Tablet	0.075 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
239	levothyroxine sodium 0.075 MG Oral Tablet [Levo-T]	General Medicine	Levo-T 75 MCG Oral Tablet	0.075 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
240	levothyroxine sodium 0.075 MG Oral Tablet [Levoxyl]	General Medicine	Levoxyl 75 MCG Oral Tablet	0.075 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
241	levothyroxine sodium 0.075 MG Oral Tablet [Synthroid]	General Medicine	Synthroid 75 MCG Oral Tablet	0.075 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
242	levothyroxine sodium 0.088 MG Oral Tablet [Euthyrox]	General Medicine	Euthyrox 88 MCG Oral Tablet	0.088 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
243	levothyroxine sodium 0.088 MG Oral Tablet [Levoxyl]	General Medicine	Levoxyl 88 MCG Oral Tablet	0.088 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
244	levothyroxine sodium 0.1 MG Oral Tablet [Euthyrox]	General Medicine	Euthyrox 0.1 MG Oral Tablet	0.1 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
245	levothyroxine sodium 0.1 MG Oral Tablet [Levo-T]	General Medicine	Levo-T 0.1 MG Oral Tablet	0.1 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
246	levothyroxine sodium 0.112 MG Oral Tablet [Euthyrox]	General Medicine	Euthyrox 112 MCG Oral Tablet	0.112 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
247	levothyroxine sodium 0.112 MG Oral Tablet [Levoxyl]	General Medicine	Levoxyl 112 MCG Oral Tablet	0.112 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
248	levothyroxine sodium 0.112 MG Oral Tablet [Synthroid]	General Medicine	Synthroid 112 MCG Oral Tablet	0.112 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
249	levothyroxine sodium 0.125 MG Oral Tablet [Euthyrox]	General Medicine	Euthyrox 125 MCG Oral Tablet	0.125 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
250	levothyroxine sodium 0.125 MG Oral Tablet [Levo-T]	General Medicine	Levo-T 125 MCG Oral Tablet	0.125 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
251	levothyroxine sodium 0.125 MG Oral Tablet [Levoxyl]	General Medicine	Levoxyl 125 MCG Oral Tablet	0.125 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
252	levothyroxine sodium 0.125 MG Oral Tablet [Synthroid]	General Medicine	Synthroid 125 MCG Oral Tablet	0.125 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
253	levothyroxine sodium 0.137 MG Oral Tablet [Levoxyl]	General Medicine	Levoxyl 137 MCG Oral Tablet	0.137 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
254	levothyroxine sodium 0.15 MG Oral Tablet [Euthyrox]	General Medicine	Euthyrox 0.15 MG Oral Tablet	0.15 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
255	levothyroxine sodium 0.15 MG Oral Tablet [Levo-T]	General Medicine	Levo-T 0.15 MG Oral Tablet	0.15 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
256	levothyroxine sodium 0.15 MG Oral Tablet [Levoxyl]	General Medicine	Levoxyl 0.15 MG Oral Tablet	0.15 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
257	levothyroxine sodium 0.15 MG Oral Tablet [Synthroid]	General Medicine	Synthroid 0.15 MG Oral Tablet	0.15 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
258	levothyroxine sodium 0.175 MG Oral Tablet [Euthyrox]	General Medicine	Euthyrox 175 MCG Oral Tablet	0.175 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
259	levothyroxine sodium 0.175 MG Oral Tablet [Levoxyl]	General Medicine	Levoxyl 175 MCG Oral Tablet	0.175 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
260	levothyroxine sodium 0.175 MG Oral Tablet [Synthroid]	General Medicine	Synthroid 175 MCG Oral Tablet	0.175 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
261	levothyroxine sodium 0.2 MG Oral Tablet [Euthyrox]	General Medicine	Euthyrox 0.2 MG Oral Tablet	0.2 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
262	levothyroxine sodium 0.2 MG Oral Tablet [Levo-T]	General Medicine	Levo-T 0.2 MG Oral Tablet	0.2 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
263	levothyroxine sodium 0.2 MG Oral Tablet [Levoxyl]	General Medicine	Levoxyl 0.2 MG Oral Tablet	0.2 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
264	levothyroxine sodium 0.3 MG Oral Tablet [Levo-T]	General Medicine	Levo-T 0.3 MG Oral Tablet	0.3 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
265	levothyroxine sodium 0.3 MG Oral Tablet [Synthroid]	General Medicine	Synthroid 0.3 MG Oral Tablet	0.3 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
266	levothyroxine sodium 0.025 MG Oral Tablet [Unithroid]	General Medicine	Unithroid 25 MCG Oral Tablet	0.025 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
267	levothyroxine sodium 0.088 MG Oral Tablet [Unithroid]	General Medicine	Unithroid 88 MCG Oral Tablet	0.088 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
268	levothyroxine sodium 0.1 MG Oral Tablet [Unithroid]	General Medicine	Unithroid 0.1 MG Oral Tablet	0.1 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
269	levothyroxine sodium 0.112 MG Oral Tablet [Unithroid]	General Medicine	Unithroid 112 MCG Oral Tablet	0.112 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
270	levothyroxine sodium 0.125 MG Oral Tablet [Unithroid]	General Medicine	Unithroid 125 MCG Oral Tablet	0.125 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
271	levothyroxine sodium 0.15 MG Oral Tablet [Unithroid]	General Medicine	Unithroid 0.15 MG Oral Tablet	0.15 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
272	levothyroxine sodium 0.2 MG Oral Tablet [Unithroid]	General Medicine	Unithroid 0.2 MG Oral Tablet	0.2 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
273	levothyroxine sodium 0.3 MG Oral Tablet [Unithroid]	General Medicine	Unithroid 0.3 MG Oral Tablet	0.3 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
274	levothyroxine sodium 0.05 MG Oral Tablet [Unithroid]	General Medicine	Unithroid 50 MCG Oral Tablet	0.05 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
275	levothyroxine sodium 0.175 MG Oral Tablet [Unithroid]	General Medicine	Unithroid 175 MCG Oral Tablet	0.175 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
276	levothyroxine sodium 0.05 MG Oral Tablet [Synthroid]	General Medicine	Synthroid 50 MCG Oral Tablet	0.05 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
277	levothyroxine sodium 0.1 MG Oral Tablet [Synthroid]	General Medicine	Synthroid 0.1 MG Oral Tablet	0.1 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
278	levothyroxine sodium 0.2 MG Oral Tablet [Synthroid]	General Medicine	Synthroid 0.2 MG Oral Tablet	0.2 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
279	levothyroxine sodium 0.137 MG Oral Tablet [Synthroid]	General Medicine	Synthroid 137 MCG Oral Tablet	0.137 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
280	levothyroxine sodium 0.088 MG Oral Tablet [Synthroid]	General Medicine	Synthroid 88 MCG Oral Tablet	0.088 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
281	levothyroxine sodium 0.1 MG Oral Tablet [Levoxyl]	General Medicine	Levoxyl 0.1 MG Oral Tablet	0.1 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
282	levothyroxine sodium 0.075 MG Oral Tablet [Unithroid]	General Medicine	Unithroid 75 MCG Oral Tablet	0.075 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
283	levothyroxine sodium 0.112 MG Oral Tablet [Levo-T]	General Medicine	Levo-T 112 MCG Oral Tablet	0.112 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
284	levothyroxine sodium 0.175 MG Oral Tablet [Levo-T]	General Medicine	Levo-T 175 MCG Oral Tablet	0.175 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
285	levothyroxine sodium 0.088 MG Oral Tablet [Levo-T]	General Medicine	Levo-T 88 MCG Oral Tablet	0.088 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
286	levothyroxine sodium 0.137 MG Oral Tablet [Levo-T]	General Medicine	Levo-T 137 MCG Oral Tablet	0.137 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
287	levothyroxine sodium 0.1 MG Oral Capsule [Tirosint]	General Medicine	Tirosint 0.1 MG Oral Capsule	0.1 MG	Capsule	RxNav Import	\N	Consult healthcare provider for side effects	\N
288	levothyroxine sodium 0.125 MG Oral Capsule [Tirosint]	General Medicine	Tirosint 125 MCG Oral Capsule	0.125 MG	Capsule	RxNav Import	\N	Consult healthcare provider for side effects	\N
289	levothyroxine sodium 0.15 MG Oral Capsule [Tirosint]	General Medicine	Tirosint 0.15 MG Oral Capsule	0.15 MG	Capsule	RxNav Import	\N	Consult healthcare provider for side effects	\N
290	levothyroxine sodium 0.025 MG Oral Capsule [Tirosint]	General Medicine	Tirosint 25 MCG Oral Capsule	0.025 MG	Capsule	RxNav Import	\N	Consult healthcare provider for side effects	\N
291	levothyroxine sodium 0.05 MG Oral Capsule [Tirosint]	General Medicine	Tirosint 50 MCG Oral Capsule	0.05 MG	Capsule	RxNav Import	\N	Consult healthcare provider for side effects	\N
292	levothyroxine sodium 0.013 MG Oral Capsule [Tirosint]	General Medicine	Tirosint 13 MCG Oral Capsule	0.013 MG	Capsule	RxNav Import	\N	Consult healthcare provider for side effects	\N
293	levothyroxine sodium 0.137 MG Oral Tablet [Unithroid]	General Medicine	Unithroid 137 MCG Oral Tablet	0.137 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
294	levothyroxine sodium 0.1 MG Injection	General Medicine	levothyroxine sodium 100 MCG Injection	0.1 MG	Injection	RxNav Import	\N	Consult healthcare provider for side effects	\N
295	levothyroxine sodium 0.2 MG Injection	General Medicine	levothyroxine sodium 200 MCG Injection	0.2 MG	Injection	RxNav Import	\N	Consult healthcare provider for side effects	\N
296	5 ML levothyroxine sodium 0.1 MG/ML Injection	General Medicine	levothyroxine sodium 500 MCG per 5 ML Injection	5 ML	Injection	RxNav Import	\N	Consult healthcare provider for side effects	\N
297	5 ML levothyroxine sodium 0.02 MG/ML Injection	General Medicine	levothyroxine sodium 100 MCG per 5 ML Injection	5 ML	Injection	RxNav Import	\N	Consult healthcare provider for side effects	\N
298	5 ML levothyroxine sodium 0.04 MG/ML Injection	General Medicine	levothyroxine sodium 200 MCG per 5 ML Injection	5 ML	Injection	RxNav Import	\N	Consult healthcare provider for side effects	\N
299	1 ML levothyroxine sodium 0.1 MG/ML Injection	General Medicine	levothyroxine sodium 100 MCG per 1 ML Injection	1 ML	Injection	RxNav Import	\N	Consult healthcare provider for side effects	\N
300	levothyroxine sodium 0.5 MG Injection	General Medicine	levothyroxine sodium 500 MCG Injection	0.5 MG	Injection	RxNav Import	\N	Consult healthcare provider for side effects	\N
301	levothyroxine sodium 0.0125 MG Oral Tablet	General Medicine	levothyroxine sodium 12.5 MCG Oral Tablet	0.0125 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
302	losartan potassium 100 MG Oral Tablet [Cozaar]	General Medicine	Cozaar 100 MG Oral Tablet	100 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
303	losartan potassium 25 MG Oral Tablet [Cozaar]	General Medicine	Cozaar 25 MG Oral Tablet	25 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
304	losartan potassium 50 MG Oral Tablet [Cozaar]	General Medicine	Cozaar 50 MG Oral Tablet	50 MG	Tablet	RxNav Import	\N	Consult healthcare provider for side effects	\N
\.


--
-- Data for Name: family_medications; Type: TABLE DATA; Schema: public; Owner: kumar
--

COPY public.family_medications (id, "familyMemberId", "drugId", dosage, frequency, "startDate", "endDate", notes, "isActive", cost, created_at, updated_at) FROM stdin;
6	1	29		once daily	2025-07-30 22:47:27.196	\N		t	\N	2025-07-30 22:47:27.196	2025-07-30 23:08:30.864
5	1	40		once daily	2025-07-30 22:47:06.51	\N		t	\N	2025-07-30 22:47:06.51	2025-07-30 23:09:01.596
4	1	9	10 mg	once daily	2025-07-30 22:40:55.597	\N		t	\N	2025-07-30 22:40:55.597	2025-07-31 00:07:55.544
3	1	5	100	half daily	2025-07-30 22:40:41.049	\N		t	\N	2025-07-30 22:40:41.049	2025-07-31 00:11:00.094
2	1	1		once daily	2025-07-30 22:19:57.632	\N		t	\N	2025-07-30 22:19:57.632	2025-07-31 00:11:37.094
1	1	2		once daily	2025-07-30 22:19:08.478	\N		t	\N	2025-07-30 22:19:08.478	2025-07-31 00:12:05.325
8	2	178	10mg		2025-08-02 01:00:32.186	\N		t	\N	2025-08-02 01:00:32.186	2025-08-02 01:00:32.186
7	2	174	850mg		2025-08-02 00:54:24.21	\N		t	\N	2025-08-02 00:54:24.21	2025-08-02 01:00:59.08
9	2	10			2025-08-02 01:01:19.278	\N		t	\N	2025-08-02 01:01:19.278	2025-08-02 01:01:19.278
10	3	179	100mcg		2025-08-02 01:29:07.585	\N		t	\N	2025-08-02 01:29:07.585	2025-08-02 01:29:07.585
11	3	302	50mg		2025-08-02 01:30:26.216	\N		t	\N	2025-08-02 01:30:26.216	2025-08-02 01:30:26.216
\.


--
-- Data for Name: family_members; Type: TABLE DATA; Schema: public; Owner: kumar
--

COPY public.family_members (id, name, age, photo, allergies, conditions, "emergencyContact", "emergencyPhone", role, "isActive", created_at, updated_at) FROM stdin;
1	Kumar	59		[]	["Diabetic","Low LVEF=24"]			member	t	2025-07-30 22:18:40.616	2025-07-30 22:47:58.23
2	Babu	58		[]	[]			member	t	2025-08-02 00:46:24.544	2025-08-02 00:46:24.544
3	Chitra	52		[]	["Thyroid","BP"]			member	t	2025-08-02 01:28:33.714	2025-08-02 01:28:33.714
\.


--
-- Data for Name: interaction_validation_log; Type: TABLE DATA; Schema: public; Owner: kumar
--

COPY public.interaction_validation_log (id, interaction_id, validation_source, validation_status, validation_score, validation_notes, validated_by, validated_at) FROM stdin;
\.


--
-- Data for Name: update_sessions; Type: TABLE DATA; Schema: public; Owner: kumar
--

COPY public.update_sessions (id, session_type, trigger_type, start_time, end_time, status, records_updated, records_added, records_deleted, errors_count, success_rate, summary_report, triggered_by, source_ids, total_api_calls, api_failures, processing_time_ms) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: kumar
--

COPY public.users (id, username, email, password, created_at, updated_at) FROM stdin;
\.


--
-- Name: clinical_alerts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: kumar
--

SELECT pg_catalog.setval('public.clinical_alerts_id_seq', 1, false);


--
-- Name: data_sources_id_seq; Type: SEQUENCE SET; Schema: public; Owner: kumar
--

SELECT pg_catalog.setval('public.data_sources_id_seq', 1, false);


--
-- Name: drug_interactions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: kumar
--

SELECT pg_catalog.setval('public.drug_interactions_id_seq', 1, false);


--
-- Name: drug_rxnorm_mapping_id_seq; Type: SEQUENCE SET; Schema: public; Owner: kumar
--

SELECT pg_catalog.setval('public.drug_rxnorm_mapping_id_seq', 222, true);


--
-- Name: drugs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: kumar
--

SELECT pg_catalog.setval('public.drugs_id_seq', 304, true);


--
-- Name: family_medications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: kumar
--

SELECT pg_catalog.setval('public.family_medications_id_seq', 11, true);


--
-- Name: family_members_id_seq; Type: SEQUENCE SET; Schema: public; Owner: kumar
--

SELECT pg_catalog.setval('public.family_members_id_seq', 3, true);


--
-- Name: interaction_validation_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: kumar
--

SELECT pg_catalog.setval('public.interaction_validation_log_id_seq', 1, false);


--
-- Name: update_sessions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: kumar
--

SELECT pg_catalog.setval('public.update_sessions_id_seq', 1, false);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: kumar
--

SELECT pg_catalog.setval('public.users_id_seq', 1, false);


--
-- Name: _prisma_migrations _prisma_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: kumar
--

ALTER TABLE ONLY public._prisma_migrations
    ADD CONSTRAINT _prisma_migrations_pkey PRIMARY KEY (id);


--
-- Name: clinical_alerts clinical_alerts_pkey; Type: CONSTRAINT; Schema: public; Owner: kumar
--

ALTER TABLE ONLY public.clinical_alerts
    ADD CONSTRAINT clinical_alerts_pkey PRIMARY KEY (id);


--
-- Name: data_sources data_sources_pkey; Type: CONSTRAINT; Schema: public; Owner: kumar
--

ALTER TABLE ONLY public.data_sources
    ADD CONSTRAINT data_sources_pkey PRIMARY KEY (id);


--
-- Name: drug_interactions drug_interactions_pkey; Type: CONSTRAINT; Schema: public; Owner: kumar
--

ALTER TABLE ONLY public.drug_interactions
    ADD CONSTRAINT drug_interactions_pkey PRIMARY KEY (id);


--
-- Name: drug_rxnorm_mapping drug_rxnorm_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: kumar
--

ALTER TABLE ONLY public.drug_rxnorm_mapping
    ADD CONSTRAINT drug_rxnorm_mapping_pkey PRIMARY KEY (id);


--
-- Name: drugs drugs_pkey; Type: CONSTRAINT; Schema: public; Owner: kumar
--

ALTER TABLE ONLY public.drugs
    ADD CONSTRAINT drugs_pkey PRIMARY KEY (id);


--
-- Name: family_medications family_medications_pkey; Type: CONSTRAINT; Schema: public; Owner: kumar
--

ALTER TABLE ONLY public.family_medications
    ADD CONSTRAINT family_medications_pkey PRIMARY KEY (id);


--
-- Name: family_members family_members_pkey; Type: CONSTRAINT; Schema: public; Owner: kumar
--

ALTER TABLE ONLY public.family_members
    ADD CONSTRAINT family_members_pkey PRIMARY KEY (id);


--
-- Name: interaction_validation_log interaction_validation_log_pkey; Type: CONSTRAINT; Schema: public; Owner: kumar
--

ALTER TABLE ONLY public.interaction_validation_log
    ADD CONSTRAINT interaction_validation_log_pkey PRIMARY KEY (id);


--
-- Name: update_sessions update_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: kumar
--

ALTER TABLE ONLY public.update_sessions
    ADD CONSTRAINT update_sessions_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: kumar
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: drug_interactions_drug1_id_drug2_id_source_id_key; Type: INDEX; Schema: public; Owner: kumar
--

CREATE UNIQUE INDEX drug_interactions_drug1_id_drug2_id_source_id_key ON public.drug_interactions USING btree (drug1_id, drug2_id, source_id);


--
-- Name: drug_rxnorm_mapping_drug_id_rxcui_key; Type: INDEX; Schema: public; Owner: kumar
--

CREATE UNIQUE INDEX drug_rxnorm_mapping_drug_id_rxcui_key ON public.drug_rxnorm_mapping USING btree (drug_id, rxcui);


--
-- Name: drugs_name_key; Type: INDEX; Schema: public; Owner: kumar
--

CREATE UNIQUE INDEX drugs_name_key ON public.drugs USING btree (name);


--
-- Name: users_email_key; Type: INDEX; Schema: public; Owner: kumar
--

CREATE UNIQUE INDEX users_email_key ON public.users USING btree (email);


--
-- Name: clinical_alerts clinical_alerts_source_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kumar
--

ALTER TABLE ONLY public.clinical_alerts
    ADD CONSTRAINT clinical_alerts_source_id_fkey FOREIGN KEY (source_id) REFERENCES public.data_sources(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: drug_interactions drug_interactions_drug1_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kumar
--

ALTER TABLE ONLY public.drug_interactions
    ADD CONSTRAINT drug_interactions_drug1_id_fkey FOREIGN KEY (drug1_id) REFERENCES public.drugs(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: drug_interactions drug_interactions_drug2_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kumar
--

ALTER TABLE ONLY public.drug_interactions
    ADD CONSTRAINT drug_interactions_drug2_id_fkey FOREIGN KEY (drug2_id) REFERENCES public.drugs(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: drug_interactions drug_interactions_source_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kumar
--

ALTER TABLE ONLY public.drug_interactions
    ADD CONSTRAINT drug_interactions_source_id_fkey FOREIGN KEY (source_id) REFERENCES public.data_sources(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: drug_rxnorm_mapping drug_rxnorm_mapping_drug_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kumar
--

ALTER TABLE ONLY public.drug_rxnorm_mapping
    ADD CONSTRAINT drug_rxnorm_mapping_drug_id_fkey FOREIGN KEY (drug_id) REFERENCES public.drugs(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: family_medications family_medications_drugId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kumar
--

ALTER TABLE ONLY public.family_medications
    ADD CONSTRAINT "family_medications_drugId_fkey" FOREIGN KEY ("drugId") REFERENCES public.drugs(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: family_medications family_medications_familyMemberId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kumar
--

ALTER TABLE ONLY public.family_medications
    ADD CONSTRAINT "family_medications_familyMemberId_fkey" FOREIGN KEY ("familyMemberId") REFERENCES public.family_members(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: interaction_validation_log interaction_validation_log_interaction_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kumar
--

ALTER TABLE ONLY public.interaction_validation_log
    ADD CONSTRAINT interaction_validation_log_interaction_id_fkey FOREIGN KEY (interaction_id) REFERENCES public.drug_interactions(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: kumar
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;


--
-- PostgreSQL database dump complete
--

