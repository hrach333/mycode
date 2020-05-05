--
-- PostgreSQL database dump
--

-- Dumped from database version 10.12 (Ubuntu 10.12-0ubuntu0.18.04.1)
-- Dumped by pg_dump version 10.12 (Ubuntu 10.12-0ubuntu0.18.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: citext; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;


--
-- Name: EXTENSION citext; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';


--
-- Name: email; Type: DOMAIN; Schema: public; Owner: postgres
--

CREATE DOMAIN public.email AS public.citext
	CONSTRAINT email_check CHECK ((VALUE OPERATOR(public.~) '^([A-Za-z0-9_\-\.]{1,})+\@([A-Za-z0-9_\-\.]{1,})+\.([A-Za-z]{2,4})$'::public.citext));


ALTER DOMAIN public.email OWNER TO postgres;

--
-- Name: name_surname; Type: DOMAIN; Schema: public; Owner: postgres
--

CREATE DOMAIN public.name_surname AS character varying(1500)
	CONSTRAINT name_surname_check CHECK (((VALUE)::text ~ '^\D+$'::text));


ALTER DOMAIN public.name_surname OWNER TO postgres;

--
-- Name: delete_old_acc(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.delete_old_acc() RETURNS trigger
    LANGUAGE plpgsql
    AS $$BEGIN
	DELETE FROM public.account
	WHERE email_verified = false
		AND date_created < (SELECT NOW() - interval '3 days');
	RETURN  NULL;
END;
$$;


ALTER FUNCTION public.delete_old_acc() OWNER TO postgres;

--
-- Name: func_timestamp(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.func_timestamp() RETURNS trigger
    LANGUAGE plpgsql
    AS $$DECLARE
	tstamp timestamp without time zone;
BEGIN
	tstamp = NOW();
	IF TG_OP = 'INSERT' THEN
		NEW.date_created = tstamp;
		NEW.date_updated = tstamp;
		RETURN NEW;
	ELSEIF TG_OP = 'UPDATE' THEN
		NEW.date_updated = tstamp;
		RETURN NEW;
	END IF;
END;$$;


ALTER FUNCTION public.func_timestamp() OWNER TO postgres;

--
-- Name: func_token(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.func_token() RETURNS trigger
    LANGUAGE plpgsql
    AS $$DECLARE
	tstr varchar(10);
BEGIN
	IF TG_OP = 'INSERT' THEN
		tstr = (SELECT array_to_string(ARRAY(SELECT chr((48 + round(random() * 59)) :: integer) 
			FROM generate_series(1,10)), ''));
		NEW.session_token = tstr;
		RETURN NEW;
	END IF;
END;

$$;


ALTER FUNCTION public.func_token() OWNER TO postgres;

--
-- Name: account_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.account_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.account_id_seq OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: account; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.account (
    id bigint DEFAULT nextval('public.account_id_seq'::regclass) NOT NULL,
    first_name public.name_surname,
    email public.email NOT NULL,
    last_name public.name_surname,
    phone numeric,
    email_verified boolean DEFAULT false NOT NULL,
    admin_privileges boolean DEFAULT false NOT NULL,
    passwd text,
    date_created timestamp with time zone NOT NULL,
    date_updated timestamp with time zone NOT NULL,
    scores integer,
    expired integer
);


ALTER TABLE public.account OWNER TO postgres;

--
-- Name: account_session; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.account_session (
    id bigint NOT NULL,
    session_token character varying(10) NOT NULL,
    account_id bigint NOT NULL
);


ALTER TABLE public.account_session OWNER TO postgres;

--
-- Name: account_session_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.account_session_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.account_session_id_seq OWNER TO postgres;

--
-- Name: account_session_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.account_session_id_seq OWNED BY public.account_session.id;


--
-- Name: album_audio; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.album_audio (
    id bigint NOT NULL,
    album_name character varying(255) NOT NULL,
    description text,
    owner_id bigint NOT NULL,
    date_created timestamp with time zone NOT NULL,
    date_updated timestamp with time zone NOT NULL
);


ALTER TABLE public.album_audio OWNER TO postgres;

--
-- Name: album_audio_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.album_audio_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.album_audio_id_seq OWNER TO postgres;

--
-- Name: album_audio_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.album_audio_id_seq OWNED BY public.album_audio.id;


--
-- Name: album_photo_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.album_photo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.album_photo_id_seq OWNER TO postgres;

--
-- Name: album_photo; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.album_photo (
    id bigint DEFAULT nextval('public.album_photo_id_seq'::regclass) NOT NULL,
    album_name character varying(255) NOT NULL,
    description text,
    owner_id bigint NOT NULL,
    date_created timestamp with time zone NOT NULL,
    date_updated timestamp with time zone NOT NULL
);


ALTER TABLE public.album_photo OWNER TO postgres;

--
-- Name: album_story_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.album_story_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.album_story_id_seq OWNER TO postgres;

--
-- Name: album_story; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.album_story (
    id bigint DEFAULT nextval('public.album_story_id_seq'::regclass) NOT NULL,
    album_name character varying(255) NOT NULL,
    description text,
    owner_id bigint NOT NULL,
    date_created timestamp with time zone NOT NULL,
    date_updated timestamp with time zone NOT NULL
);


ALTER TABLE public.album_story OWNER TO postgres;

--
-- Name: album_video; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.album_video (
    id bigint NOT NULL,
    album_name character varying(255) NOT NULL,
    description text,
    owner_id bigint NOT NULL,
    date_created timestamp with time zone NOT NULL,
    date_updated timestamp with time zone NOT NULL
);


ALTER TABLE public.album_video OWNER TO postgres;

--
-- Name: album_video_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.album_video_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.album_video_id_seq OWNER TO postgres;

--
-- Name: album_video_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.album_video_id_seq OWNED BY public.album_video.id;


--
-- Name: family; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.family (
    id integer NOT NULL,
    last_name public.name_surname NOT NULL,
    person_role character varying(30),
    ico_url character varying(255)
);


ALTER TABLE public.family OWNER TO postgres;

--
-- Name: COLUMN family.person_role; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.family.person_role IS '?';


--
-- Name: family_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.family_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.family_id_seq OWNER TO postgres;

--
-- Name: family_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.family_id_seq OWNED BY public.family.id;


--
-- Name: members_of_audio; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.members_of_audio (
    audio_id bigint NOT NULL,
    member_id bigint NOT NULL
);


ALTER TABLE public.members_of_audio OWNER TO postgres;

--
-- Name: members_of_photo; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.members_of_photo (
    photo_id bigint NOT NULL,
    member_id bigint NOT NULL
);


ALTER TABLE public.members_of_photo OWNER TO postgres;

--
-- Name: members_of_story; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.members_of_story (
    story_id bigint NOT NULL,
    member_id bigint NOT NULL
);


ALTER TABLE public.members_of_story OWNER TO postgres;

--
-- Name: members_of_video; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.members_of_video (
    video_id bigint NOT NULL,
    member_id bigint NOT NULL
);


ALTER TABLE public.members_of_video OWNER TO postgres;

--
-- Name: person_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.person_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.person_id_seq OWNER TO postgres;

--
-- Name: person; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.person (
    id bigint DEFAULT nextval('public.person_id_seq'::regclass) NOT NULL,
    first_name character varying(1500),
    patronymic character varying(30),
    last_name character varying(50),
    email public.citext,
    city text,
    marital_status character varying(8),
    phone numeric,
    role_in_family character varying(30),
    ico_url character varying(255),
    scores integer,
    creator_id bigint NOT NULL
);


ALTER TABLE public.person OWNER TO postgres;

--
-- Name: COLUMN person.marital_status; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.person.marital_status IS '?';


--
-- Name: COLUMN person.role_in_family; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.person.role_in_family IS '?';


--
-- Name: COLUMN person.ico_url; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.person.ico_url IS 'Or photo_id as name of this column and fkey to photo.id?';


--
-- Name: person_questionnaire; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.person_questionnaire (
    biography text,
    person_id bigint NOT NULL
);


ALTER TABLE public.person_questionnaire OWNER TO postgres;

--
-- Name: relation_album_audio; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.relation_album_audio (
    album_id bigint NOT NULL,
    audio_id bigint NOT NULL
);


ALTER TABLE public.relation_album_audio OWNER TO postgres;

--
-- Name: relation_album_photo; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.relation_album_photo (
    album_id bigint NOT NULL,
    photo_id bigint NOT NULL
);


ALTER TABLE public.relation_album_photo OWNER TO postgres;

--
-- Name: relation_album_story; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.relation_album_story (
    album_id bigint NOT NULL,
    story_id bigint NOT NULL
);


ALTER TABLE public.relation_album_story OWNER TO postgres;

--
-- Name: relation_album_video; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.relation_album_video (
    album_id bigint NOT NULL,
    video_id bigint NOT NULL
);


ALTER TABLE public.relation_album_video OWNER TO postgres;

--
-- Name: relation_family_person; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.relation_family_person (
    family_id integer NOT NULL,
    person_id bigint NOT NULL,
    person_role character varying(30)
);


ALTER TABLE public.relation_family_person OWNER TO postgres;

--
-- Name: COLUMN relation_family_person.person_role; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.relation_family_person.person_role IS '?';


--
-- Name: unit_audio_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.unit_audio_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.unit_audio_id_seq OWNER TO postgres;

--
-- Name: unit_audio; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.unit_audio (
    id bigint DEFAULT nextval('public.unit_audio_id_seq'::regclass) NOT NULL,
    content_url character varying(255) NOT NULL,
    owner_id bigint NOT NULL,
    date_created timestamp with time zone NOT NULL,
    date_updated timestamp with time zone NOT NULL
);


ALTER TABLE public.unit_audio OWNER TO postgres;

--
-- Name: unit_photo_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.unit_photo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.unit_photo_id_seq OWNER TO postgres;

--
-- Name: unit_photo; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.unit_photo (
    id bigint DEFAULT nextval('public.unit_photo_id_seq'::regclass) NOT NULL,
    content_url character varying(255) NOT NULL,
    owner_id bigint NOT NULL,
    date_created timestamp with time zone NOT NULL,
    date_updated timestamp with time zone NOT NULL,
    coordinates text,
    reference boolean DEFAULT false NOT NULL
);


ALTER TABLE public.unit_photo OWNER TO postgres;

--
-- Name: unit_story_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.unit_story_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.unit_story_id_seq OWNER TO postgres;

--
-- Name: unit_story; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.unit_story (
    id bigint DEFAULT nextval('public.unit_story_id_seq'::regclass) NOT NULL,
    content_url character varying(255) NOT NULL,
    owner_id bigint NOT NULL,
    date_created timestamp with time zone NOT NULL,
    date_updated timestamp with time zone NOT NULL
);


ALTER TABLE public.unit_story OWNER TO postgres;

--
-- Name: unit_video_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.unit_video_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.unit_video_id_seq OWNER TO postgres;

--
-- Name: unit_video; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.unit_video (
    id bigint DEFAULT nextval('public.unit_video_id_seq'::regclass) NOT NULL,
    content_url character varying(255) NOT NULL,
    owner_id bigint NOT NULL,
    date_created timestamp with time zone NOT NULL,
    date_updated timestamp with time zone NOT NULL
);


ALTER TABLE public.unit_video OWNER TO postgres;

--
-- Name: account_session id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_session ALTER COLUMN id SET DEFAULT nextval('public.account_session_id_seq'::regclass);


--
-- Name: album_audio id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.album_audio ALTER COLUMN id SET DEFAULT nextval('public.album_audio_id_seq'::regclass);


--
-- Name: album_video id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.album_video ALTER COLUMN id SET DEFAULT nextval('public.album_video_id_seq'::regclass);


--
-- Name: family id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.family ALTER COLUMN id SET DEFAULT nextval('public.family_id_seq'::regclass);


--
-- Data for Name: account; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.account (id, first_name, email, last_name, phone, email_verified, admin_privileges, passwd, date_created, date_updated, scores, expired) FROM stdin;
25	\N	hrach@hrach.ru	\N	\N	f	f	$2y$10$xyKy9TdfU19CjzOHd/g6seEDy6WuvwIo1AFhJ/bMZG34gJc5Juoq6	2020-05-02 21:46:57.216871+03	2020-05-02 21:46:57.216871+03	\N	\N
\.


--
-- Data for Name: account_session; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.account_session (id, session_token, account_id) FROM stdin;
\.


--
-- Data for Name: album_audio; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.album_audio (id, album_name, description, owner_id, date_created, date_updated) FROM stdin;
\.


--
-- Data for Name: album_photo; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.album_photo (id, album_name, description, owner_id, date_created, date_updated) FROM stdin;
\.


--
-- Data for Name: album_story; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.album_story (id, album_name, description, owner_id, date_created, date_updated) FROM stdin;
\.


--
-- Data for Name: album_video; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.album_video (id, album_name, description, owner_id, date_created, date_updated) FROM stdin;
\.


--
-- Data for Name: family; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.family (id, last_name, person_role, ico_url) FROM stdin;
\.


--
-- Data for Name: members_of_audio; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.members_of_audio (audio_id, member_id) FROM stdin;
\.


--
-- Data for Name: members_of_photo; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.members_of_photo (photo_id, member_id) FROM stdin;
\.


--
-- Data for Name: members_of_story; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.members_of_story (story_id, member_id) FROM stdin;
\.


--
-- Data for Name: members_of_video; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.members_of_video (video_id, member_id) FROM stdin;
\.


--
-- Data for Name: person; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.person (id, first_name, patronymic, last_name, email, city, marital_status, phone, role_in_family, ico_url, scores, creator_id) FROM stdin;
\.


--
-- Data for Name: person_questionnaire; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.person_questionnaire (biography, person_id) FROM stdin;
\.


--
-- Data for Name: relation_album_audio; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.relation_album_audio (album_id, audio_id) FROM stdin;
\.


--
-- Data for Name: relation_album_photo; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.relation_album_photo (album_id, photo_id) FROM stdin;
\.


--
-- Data for Name: relation_album_story; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.relation_album_story (album_id, story_id) FROM stdin;
\.


--
-- Data for Name: relation_album_video; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.relation_album_video (album_id, video_id) FROM stdin;
\.


--
-- Data for Name: relation_family_person; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.relation_family_person (family_id, person_id, person_role) FROM stdin;
\.


--
-- Data for Name: unit_audio; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.unit_audio (id, content_url, owner_id, date_created, date_updated) FROM stdin;
\.


--
-- Data for Name: unit_photo; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.unit_photo (id, content_url, owner_id, date_created, date_updated, coordinates, reference) FROM stdin;
\.


--
-- Data for Name: unit_story; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.unit_story (id, content_url, owner_id, date_created, date_updated) FROM stdin;
\.


--
-- Data for Name: unit_video; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.unit_video (id, content_url, owner_id, date_created, date_updated) FROM stdin;
\.


--
-- Name: account_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.account_id_seq', 41, true);


--
-- Name: account_session_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.account_session_id_seq', 2, true);


--
-- Name: album_audio_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.album_audio_id_seq', 1, true);


--
-- Name: album_photo_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.album_photo_id_seq', 13, true);


--
-- Name: album_story_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.album_story_id_seq', 1, false);


--
-- Name: album_video_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.album_video_id_seq', 1, true);


--
-- Name: family_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.family_id_seq', 3, true);


--
-- Name: person_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.person_id_seq', 3, true);


--
-- Name: unit_audio_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.unit_audio_id_seq', 5, true);


--
-- Name: unit_photo_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.unit_photo_id_seq', 37, true);


--
-- Name: unit_story_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.unit_story_id_seq', 1, true);


--
-- Name: unit_video_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.unit_video_id_seq', 1, true);


--
-- Name: account account_email_idx; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account
    ADD CONSTRAINT account_email_idx UNIQUE (email);


--
-- Name: account account_phone_idx; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account
    ADD CONSTRAINT account_phone_idx UNIQUE (phone);


--
-- Name: account account_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account
    ADD CONSTRAINT account_pkey PRIMARY KEY (id);


--
-- Name: album_audio album_audio_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.album_audio
    ADD CONSTRAINT album_audio_pkey PRIMARY KEY (id);


--
-- Name: album_photo album_photo_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.album_photo
    ADD CONSTRAINT album_photo_pkey PRIMARY KEY (id);


--
-- Name: album_story album_story_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.album_story
    ADD CONSTRAINT album_story_pkey PRIMARY KEY (id);


--
-- Name: album_video album_video_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.album_video
    ADD CONSTRAINT album_video_pkey PRIMARY KEY (id);


--
-- Name: family family_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.family
    ADD CONSTRAINT family_pkey PRIMARY KEY (id);


--
-- Name: members_of_audio members_of_audio_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.members_of_audio
    ADD CONSTRAINT members_of_audio_pkey PRIMARY KEY (audio_id, member_id);


--
-- Name: members_of_photo members_of_photo_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.members_of_photo
    ADD CONSTRAINT members_of_photo_pkey PRIMARY KEY (photo_id, member_id);


--
-- Name: members_of_story members_of_story_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.members_of_story
    ADD CONSTRAINT members_of_story_pkey PRIMARY KEY (story_id, member_id);


--
-- Name: members_of_video members_of_video_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.members_of_video
    ADD CONSTRAINT members_of_video_pkey PRIMARY KEY (video_id, member_id);


--
-- Name: person person_email_idx; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.person
    ADD CONSTRAINT person_email_idx UNIQUE (email);


--
-- Name: person person_phone_idx; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.person
    ADD CONSTRAINT person_phone_idx UNIQUE (phone);


--
-- Name: person_questionnaire person_questionnaire_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.person_questionnaire
    ADD CONSTRAINT person_questionnaire_pkey PRIMARY KEY (person_id);


--
-- Name: person persons_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.person
    ADD CONSTRAINT persons_pkey PRIMARY KEY (id);


--
-- Name: relation_album_audio relation_album_audio_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.relation_album_audio
    ADD CONSTRAINT relation_album_audio_pkey PRIMARY KEY (album_id, audio_id);


--
-- Name: relation_album_photo relation_album_photo_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.relation_album_photo
    ADD CONSTRAINT relation_album_photo_pkey PRIMARY KEY (album_id, photo_id);


--
-- Name: relation_album_story relation_album_story_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.relation_album_story
    ADD CONSTRAINT relation_album_story_pkey PRIMARY KEY (album_id, story_id);


--
-- Name: relation_album_video relation_album_video_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.relation_album_video
    ADD CONSTRAINT relation_album_video_pkey PRIMARY KEY (album_id, video_id);


--
-- Name: relation_family_person relation_family_person_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.relation_family_person
    ADD CONSTRAINT relation_family_person_pkey PRIMARY KEY (family_id, person_id);


--
-- Name: account_session session_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_session
    ADD CONSTRAINT session_pkey PRIMARY KEY (id);


--
-- Name: unit_audio unit_audio_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.unit_audio
    ADD CONSTRAINT unit_audio_pkey PRIMARY KEY (id);


--
-- Name: unit_photo unit_photo_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.unit_photo
    ADD CONSTRAINT unit_photo_pkey PRIMARY KEY (id);


--
-- Name: unit_story unit_story_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.unit_story
    ADD CONSTRAINT unit_story_pkey PRIMARY KEY (id);


--
-- Name: unit_video unit_video_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.unit_video
    ADD CONSTRAINT unit_video_pkey PRIMARY KEY (id);


--
-- Name: person_lower_email_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX person_lower_email_idx ON public.person USING btree (lower((email)::text));


--
-- Name: account t_delete_old_acc; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER t_delete_old_acc AFTER INSERT OR DELETE OR UPDATE ON public.account FOR EACH ROW EXECUTE PROCEDURE public.delete_old_acc();


--
-- Name: account t_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER t_timestamp BEFORE INSERT OR UPDATE ON public.account FOR EACH ROW EXECUTE PROCEDURE public.func_timestamp();


--
-- Name: album_audio t_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER t_timestamp BEFORE INSERT OR UPDATE ON public.album_audio FOR EACH ROW EXECUTE PROCEDURE public.func_timestamp();


--
-- Name: album_photo t_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER t_timestamp BEFORE INSERT OR UPDATE ON public.album_photo FOR EACH ROW EXECUTE PROCEDURE public.func_timestamp();


--
-- Name: album_story t_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER t_timestamp BEFORE INSERT OR UPDATE ON public.album_story FOR EACH ROW EXECUTE PROCEDURE public.func_timestamp();


--
-- Name: album_video t_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER t_timestamp BEFORE INSERT OR UPDATE ON public.album_video FOR EACH ROW EXECUTE PROCEDURE public.func_timestamp();


--
-- Name: unit_audio t_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER t_timestamp BEFORE INSERT OR UPDATE ON public.unit_audio FOR EACH ROW EXECUTE PROCEDURE public.func_timestamp();


--
-- Name: unit_photo t_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER t_timestamp BEFORE INSERT OR UPDATE ON public.unit_photo FOR EACH ROW EXECUTE PROCEDURE public.func_timestamp();


--
-- Name: unit_story t_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER t_timestamp BEFORE INSERT OR UPDATE ON public.unit_story FOR EACH ROW EXECUTE PROCEDURE public.func_timestamp();


--
-- Name: unit_video t_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER t_timestamp BEFORE INSERT OR UPDATE ON public.unit_video FOR EACH ROW EXECUTE PROCEDURE public.func_timestamp();


--
-- Name: account_session t_token; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER t_token BEFORE INSERT ON public.account_session FOR EACH ROW EXECUTE PROCEDURE public.func_token();


--
-- Name: account_session account_session_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_session
    ADD CONSTRAINT account_session_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.account(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: album_audio album_audio_owner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.album_audio
    ADD CONSTRAINT album_audio_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES public.account(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: album_photo album_photo_owner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.album_photo
    ADD CONSTRAINT album_photo_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES public.account(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: album_story album_story_owner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.album_story
    ADD CONSTRAINT album_story_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES public.account(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: album_video album_video_owner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.album_video
    ADD CONSTRAINT album_video_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES public.account(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: members_of_audio members_of_audio_audio_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.members_of_audio
    ADD CONSTRAINT members_of_audio_audio_id_fkey FOREIGN KEY (audio_id) REFERENCES public.unit_audio(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: members_of_audio members_of_audio_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.members_of_audio
    ADD CONSTRAINT members_of_audio_member_id_fkey FOREIGN KEY (member_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: members_of_photo members_of_photo_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.members_of_photo
    ADD CONSTRAINT members_of_photo_member_id_fkey FOREIGN KEY (member_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: members_of_photo members_of_photo_photo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.members_of_photo
    ADD CONSTRAINT members_of_photo_photo_id_fkey FOREIGN KEY (photo_id) REFERENCES public.unit_photo(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: members_of_story members_of_story_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.members_of_story
    ADD CONSTRAINT members_of_story_person_id_fkey FOREIGN KEY (member_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: members_of_story members_of_story_story_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.members_of_story
    ADD CONSTRAINT members_of_story_story_id_fkey FOREIGN KEY (story_id) REFERENCES public.unit_story(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: members_of_video members_of_video_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.members_of_video
    ADD CONSTRAINT members_of_video_member_id_fkey FOREIGN KEY (member_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: members_of_video members_of_video_video_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.members_of_video
    ADD CONSTRAINT members_of_video_video_id_fkey FOREIGN KEY (video_id) REFERENCES public.unit_video(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: person person_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.person
    ADD CONSTRAINT person_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES public.account(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: person_questionnaire person_questionnaire_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.person_questionnaire
    ADD CONSTRAINT person_questionnaire_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: relation_album_audio relation_album_audio_album_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.relation_album_audio
    ADD CONSTRAINT relation_album_audio_album_id_fkey FOREIGN KEY (album_id) REFERENCES public.album_audio(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: relation_album_audio relation_album_audio_audio_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.relation_album_audio
    ADD CONSTRAINT relation_album_audio_audio_id_fkey FOREIGN KEY (audio_id) REFERENCES public.unit_audio(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: relation_album_photo relation_album_photo_album_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.relation_album_photo
    ADD CONSTRAINT relation_album_photo_album_id_fkey FOREIGN KEY (album_id) REFERENCES public.album_photo(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: relation_album_photo relation_album_photo_photo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.relation_album_photo
    ADD CONSTRAINT relation_album_photo_photo_id_fkey FOREIGN KEY (photo_id) REFERENCES public.unit_photo(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: relation_album_story relation_album_story_album_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.relation_album_story
    ADD CONSTRAINT relation_album_story_album_id_fkey FOREIGN KEY (album_id) REFERENCES public.album_story(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: relation_album_story relation_album_story_story_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.relation_album_story
    ADD CONSTRAINT relation_album_story_story_id_fkey FOREIGN KEY (story_id) REFERENCES public.unit_story(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: relation_album_video relation_album_video_album_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.relation_album_video
    ADD CONSTRAINT relation_album_video_album_id_fkey FOREIGN KEY (album_id) REFERENCES public.album_video(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: relation_album_video relation_album_video_video_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.relation_album_video
    ADD CONSTRAINT relation_album_video_video_id_fkey FOREIGN KEY (video_id) REFERENCES public.unit_video(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: relation_family_person relation_family_person_family_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.relation_family_person
    ADD CONSTRAINT relation_family_person_family_id_fkey FOREIGN KEY (family_id) REFERENCES public.family(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: relation_family_person relation_family_person_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.relation_family_person
    ADD CONSTRAINT relation_family_person_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: unit_audio unit_audio_owner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.unit_audio
    ADD CONSTRAINT unit_audio_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES public.account(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: unit_photo unit_photo_owner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.unit_photo
    ADD CONSTRAINT unit_photo_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES public.account(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: unit_story unit_story_owner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.unit_story
    ADD CONSTRAINT unit_story_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES public.account(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: unit_video unit_video_owner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.unit_video
    ADD CONSTRAINT unit_video_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES public.account(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--
