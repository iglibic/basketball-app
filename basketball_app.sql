--
-- PostgreSQL database dump
--

\restrict sLdMbPEyuW7ysd8vWzMFDdG76t6fDcgYixoCphfUvPF6VOiHXrNErNseqendPnT

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: shots; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shots (
    shot_id integer NOT NULL,
    training_id integer NOT NULL,
    zone_id integer NOT NULL,
    made boolean NOT NULL,
    shot_order integer,
    notes text,
    shot_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT shots_shot_order_check CHECK (((shot_order IS NULL) OR (shot_order > 0)))
);


ALTER TABLE public.shots OWNER TO postgres;

--
-- Name: shots_shot_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.shots_shot_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.shots_shot_id_seq OWNER TO postgres;

--
-- Name: shots_shot_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.shots_shot_id_seq OWNED BY public.shots.shot_id;


--
-- Name: template_zones; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.template_zones (
    template_zone_id integer NOT NULL,
    template_id integer NOT NULL,
    zone_id integer NOT NULL,
    planned_shots integer NOT NULL,
    CONSTRAINT template_zones_planned_shots_check CHECK ((planned_shots >= 0))
);


ALTER TABLE public.template_zones OWNER TO postgres;

--
-- Name: template_zones_template_zone_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.template_zones_template_zone_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.template_zones_template_zone_id_seq OWNER TO postgres;

--
-- Name: template_zones_template_zone_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.template_zones_template_zone_id_seq OWNED BY public.template_zones.template_zone_id;


--
-- Name: training_templates; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.training_templates (
    template_id integer NOT NULL,
    template_name character varying(100) NOT NULL,
    description text,
    total_shots integer NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    creator_user_id integer,
    is_public boolean DEFAULT false,
    CONSTRAINT training_templates_total_shots_check CHECK ((total_shots >= 0))
);


ALTER TABLE public.training_templates OWNER TO postgres;

--
-- Name: training_templates_template_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.training_templates_template_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.training_templates_template_id_seq OWNER TO postgres;

--
-- Name: training_templates_template_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.training_templates_template_id_seq OWNED BY public.training_templates.template_id;


--
-- Name: trainings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.trainings (
    training_id integer NOT NULL,
    user_id integer NOT NULL,
    template_id integer,
    training_name character varying(100) NOT NULL,
    started_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    finished_at timestamp without time zone,
    duration_minutes integer,
    notes text,
    CONSTRAINT trainings_duration_minutes_check CHECK (((duration_minutes IS NULL) OR (duration_minutes >= 0)))
);


ALTER TABLE public.trainings OWNER TO postgres;

--
-- Name: trainings_training_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.trainings_training_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.trainings_training_id_seq OWNER TO postgres;

--
-- Name: trainings_training_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.trainings_training_id_seq OWNED BY public.trainings.training_id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    user_id integer NOT NULL,
    first_name character varying(50) NOT NULL,
    last_name character varying(50) NOT NULL,
    nickname character varying(50) NOT NULL,
    email character varying(100) NOT NULL,
    password_hash character varying(255) NOT NULL,
    is_verified boolean DEFAULT false,
    verification_token character varying(255),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_user_id_seq OWNER TO postgres;

--
-- Name: users_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_user_id_seq OWNED BY public.users.user_id;


--
-- Name: zones; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.zones (
    zone_id integer NOT NULL,
    zone_name character varying(100) NOT NULL,
    description text,
    x_position numeric(5,2),
    y_position numeric(5,2),
    display_order integer NOT NULL,
    is_active boolean DEFAULT true
);


ALTER TABLE public.zones OWNER TO postgres;

--
-- Name: zones_zone_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.zones_zone_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.zones_zone_id_seq OWNER TO postgres;

--
-- Name: zones_zone_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.zones_zone_id_seq OWNED BY public.zones.zone_id;


--
-- Name: shots shot_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shots ALTER COLUMN shot_id SET DEFAULT nextval('public.shots_shot_id_seq'::regclass);


--
-- Name: template_zones template_zone_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.template_zones ALTER COLUMN template_zone_id SET DEFAULT nextval('public.template_zones_template_zone_id_seq'::regclass);


--
-- Name: training_templates template_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.training_templates ALTER COLUMN template_id SET DEFAULT nextval('public.training_templates_template_id_seq'::regclass);


--
-- Name: trainings training_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trainings ALTER COLUMN training_id SET DEFAULT nextval('public.trainings_training_id_seq'::regclass);


--
-- Name: users user_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN user_id SET DEFAULT nextval('public.users_user_id_seq'::regclass);


--
-- Name: zones zone_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zones ALTER COLUMN zone_id SET DEFAULT nextval('public.zones_zone_id_seq'::regclass);


--
-- Data for Name: shots; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shots (shot_id, training_id, zone_id, made, shot_order, notes, shot_time) FROM stdin;
2	1	2	t	\N	\N	2026-03-30 21:32:19.625046
3	1	2	t	\N	\N	2026-03-30 21:38:25.060959
4	1	2	t	\N	\N	2026-05-24 10:05:51.045598
\.


--
-- Data for Name: template_zones; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.template_zones (template_zone_id, template_id, zone_id, planned_shots) FROM stdin;
1	1	1	10
\.


--
-- Data for Name: training_templates; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.training_templates (template_id, template_name, description, total_shots, created_at, creator_user_id, is_public) FROM stdin;
1	50 shots corner	\N	50	2026-05-24 10:22:40.863442	1	t
\.


--
-- Data for Name: trainings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.trainings (training_id, user_id, template_id, training_name, started_at, finished_at, duration_minutes, notes) FROM stdin;
1	1	\N	Test trening	2026-03-25 11:50:09.177892	\N	\N	\N
2	1	\N	Test trening	2026-03-30 21:30:28.091232	\N	\N	\N
3	1	\N	Test trening	2026-05-24 09:57:17.252567	\N	\N	\N
4	1	\N	Test trening	2026-05-24 10:05:25.48534	\N	\N	\N
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (user_id, first_name, last_name, nickname, email, password_hash, is_verified, verification_token, created_at) FROM stdin;
1	Ivan	Test	ivan12345	ivan12345@test.com	$2b$10$Y7BQ.0mTK5Us9KSib1mwTeClPOOQV7G64rqvUV5B0Tr3rPrqJuijK	f	\N	2026-03-25 11:45:54.616071
2	Ivan	Test	ivan123	test@test.com	$2b$10$xbcW0xI/QI/jfKjEdu6NI.0nD3gLHvODHZqp6orltiiTJ/GXPyoWe	f	\N	2026-05-24 09:55:42.584472
\.


--
-- Data for Name: zones; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.zones (zone_id, zone_name, description, x_position, y_position, display_order, is_active) FROM stdin;
1	Left Corner 3	Left corner three point shot	10.00	90.00	1	t
2	Left Wing 3	Left wing three point shot	25.00	65.00	2	t
3	Top of Key 3	Top of the key three point shot	50.00	55.00	3	t
4	Right Wing 3	Right wing three point shot	75.00	65.00	4	t
5	Right Corner 3	Right corner three point shot	90.00	90.00	5	t
6	Left Midrange	Left midrange shot	25.00	75.00	6	t
7	Right Midrange	Right midrange shot	75.00	75.00	7	t
8	Free Throw	Free throw line	50.00	70.00	8	t
\.


--
-- Name: shots_shot_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.shots_shot_id_seq', 4, true);


--
-- Name: template_zones_template_zone_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.template_zones_template_zone_id_seq', 1, true);


--
-- Name: training_templates_template_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.training_templates_template_id_seq', 1, true);


--
-- Name: trainings_training_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.trainings_training_id_seq', 4, true);


--
-- Name: users_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_user_id_seq', 2, true);


--
-- Name: zones_zone_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.zones_zone_id_seq', 8, true);


--
-- Name: shots shots_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shots
    ADD CONSTRAINT shots_pkey PRIMARY KEY (shot_id);


--
-- Name: template_zones template_zones_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.template_zones
    ADD CONSTRAINT template_zones_pkey PRIMARY KEY (template_zone_id);


--
-- Name: template_zones template_zones_template_id_zone_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.template_zones
    ADD CONSTRAINT template_zones_template_id_zone_id_key UNIQUE (template_id, zone_id);


--
-- Name: training_templates training_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.training_templates
    ADD CONSTRAINT training_templates_pkey PRIMARY KEY (template_id);


--
-- Name: trainings trainings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trainings
    ADD CONSTRAINT trainings_pkey PRIMARY KEY (training_id);


--
-- Name: training_templates unique_template_name; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.training_templates
    ADD CONSTRAINT unique_template_name UNIQUE (creator_user_id, template_name);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_nickname_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_nickname_key UNIQUE (nickname);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- Name: zones zones_display_order_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zones
    ADD CONSTRAINT zones_display_order_key UNIQUE (display_order);


--
-- Name: zones zones_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zones
    ADD CONSTRAINT zones_pkey PRIMARY KEY (zone_id);


--
-- Name: zones zones_zone_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zones
    ADD CONSTRAINT zones_zone_name_key UNIQUE (zone_name);


--
-- Name: idx_shots_training; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_shots_training ON public.shots USING btree (training_id);


--
-- Name: idx_shots_training_zone; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_shots_training_zone ON public.shots USING btree (training_id, zone_id);


--
-- Name: idx_shots_zone; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_shots_zone ON public.shots USING btree (zone_id);


--
-- Name: idx_template_zones_template; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_template_zones_template ON public.template_zones USING btree (template_id);


--
-- Name: idx_trainings_template; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_trainings_template ON public.trainings USING btree (template_id);


--
-- Name: idx_trainings_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_trainings_user ON public.trainings USING btree (user_id);


--
-- Name: training_templates fk_creator; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.training_templates
    ADD CONSTRAINT fk_creator FOREIGN KEY (creator_user_id) REFERENCES public.users(user_id) ON DELETE SET NULL;


--
-- Name: shots shots_training_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shots
    ADD CONSTRAINT shots_training_id_fkey FOREIGN KEY (training_id) REFERENCES public.trainings(training_id) ON DELETE CASCADE;


--
-- Name: shots shots_zone_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shots
    ADD CONSTRAINT shots_zone_id_fkey FOREIGN KEY (zone_id) REFERENCES public.zones(zone_id) ON DELETE RESTRICT;


--
-- Name: template_zones template_zones_template_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.template_zones
    ADD CONSTRAINT template_zones_template_id_fkey FOREIGN KEY (template_id) REFERENCES public.training_templates(template_id) ON DELETE CASCADE;


--
-- Name: template_zones template_zones_zone_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.template_zones
    ADD CONSTRAINT template_zones_zone_id_fkey FOREIGN KEY (zone_id) REFERENCES public.zones(zone_id) ON DELETE CASCADE;


--
-- Name: trainings trainings_template_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trainings
    ADD CONSTRAINT trainings_template_id_fkey FOREIGN KEY (template_id) REFERENCES public.training_templates(template_id) ON DELETE SET NULL;


--
-- Name: trainings trainings_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trainings
    ADD CONSTRAINT trainings_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict sLdMbPEyuW7ysd8vWzMFDdG76t6fDcgYixoCphfUvPF6VOiHXrNErNseqendPnT

