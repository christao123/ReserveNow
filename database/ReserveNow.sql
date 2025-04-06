--
-- PostgreSQL database dump
--

-- Dumped from database version 16.8
-- Dumped by pg_dump version 17.0

-- Started on 2025-03-13 13:13:35 EDT

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
-- TOC entry 856 (class 1247 OID 16463)
-- Name: reservation_status; Type: TYPE; Schema: public; Owner: avnadmin
--

CREATE TYPE public.reservation_status AS ENUM (
    'pending',
    'confirmed',
    'cancelled',
    'completed'
);


ALTER TYPE public.reservation_status OWNER TO avnadmin;

--
-- TOC entry 847 (class 1247 OID 16433)
-- Name: user_role; Type: TYPE; Schema: public; Owner: avnadmin
--

CREATE TYPE public.user_role AS ENUM (
    'customer',
    'restaurant_manager'
);


ALTER TYPE public.user_role OWNER TO avnadmin;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 220 (class 1259 OID 16472)
-- Name: reservations; Type: TABLE; Schema: public; Owner: avnadmin
--

CREATE TABLE public.reservations (
    reservation_id integer NOT NULL,
    customer_id integer NOT NULL,
    restaurant_id integer NOT NULL,
    reservation_time timestamp without time zone NOT NULL,
    number_of_customers integer NOT NULL,
    status public.reservation_status DEFAULT 'pending'::public.reservation_status,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.reservations OWNER TO avnadmin;

--
-- TOC entry 219 (class 1259 OID 16471)
-- Name: reservations_reservation_id_seq; Type: SEQUENCE; Schema: public; Owner: avnadmin
--

CREATE SEQUENCE public.reservations_reservation_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.reservations_reservation_id_seq OWNER TO avnadmin;

--
-- TOC entry 4470 (class 0 OID 0)
-- Dependencies: 219
-- Name: reservations_reservation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: avnadmin
--

ALTER SEQUENCE public.reservations_reservation_id_seq OWNED BY public.reservations.reservation_id;


--
-- TOC entry 218 (class 1259 OID 16448)
-- Name: restaurants; Type: TABLE; Schema: public; Owner: avnadmin
--

CREATE TABLE public.restaurants (
    restaurant_id integer NOT NULL,
    manager_id integer NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    cuisine character varying(50),
    location character varying(255) NOT NULL,
    opening_time time without time zone NOT NULL,
    closing_time time without time zone NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.restaurants OWNER TO avnadmin;

--
-- TOC entry 217 (class 1259 OID 16447)
-- Name: restaurants_restaurant_id_seq; Type: SEQUENCE; Schema: public; Owner: avnadmin
--

CREATE SEQUENCE public.restaurants_restaurant_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.restaurants_restaurant_id_seq OWNER TO avnadmin;

--
-- TOC entry 4471 (class 0 OID 0)
-- Dependencies: 217
-- Name: restaurants_restaurant_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: avnadmin
--

ALTER SEQUENCE public.restaurants_restaurant_id_seq OWNED BY public.restaurants.restaurant_id;


--
-- TOC entry 222 (class 1259 OID 16491)
-- Name: reviews; Type: TABLE; Schema: public; Owner: avnadmin
--

CREATE TABLE public.reviews (
    review_id integer NOT NULL,
    customer_id integer NOT NULL,
    restaurant_id integer NOT NULL,
    rating integer,
    review_text text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT reviews_rating_check CHECK (((rating >= 1) AND (rating <= 5)))
);


ALTER TABLE public.reviews OWNER TO avnadmin;

--
-- TOC entry 221 (class 1259 OID 16490)
-- Name: reviews_review_id_seq; Type: SEQUENCE; Schema: public; Owner: avnadmin
--

CREATE SEQUENCE public.reviews_review_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.reviews_review_id_seq OWNER TO avnadmin;

--
-- TOC entry 4472 (class 0 OID 0)
-- Dependencies: 221
-- Name: reviews_review_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: avnadmin
--

ALTER SEQUENCE public.reviews_review_id_seq OWNED BY public.reviews.review_id;


--
-- TOC entry 216 (class 1259 OID 16438)
-- Name: users; Type: TABLE; Schema: public; Owner: avnadmin
--

CREATE TABLE public.users (
    user_id integer NOT NULL,
    first_name character varying(50) NOT NULL,
    last_name character varying(50) NOT NULL,
    email character varying(100) NOT NULL,
    password_hash character varying(255) NOT NULL,
    phone_number character varying(20),
    role public.user_role NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.users OWNER TO avnadmin;

--
-- TOC entry 215 (class 1259 OID 16437)
-- Name: users_user_id_seq; Type: SEQUENCE; Schema: public; Owner: avnadmin
--

CREATE SEQUENCE public.users_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_user_id_seq OWNER TO avnadmin;

--
-- TOC entry 4473 (class 0 OID 0)
-- Dependencies: 215
-- Name: users_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: avnadmin
--

ALTER SEQUENCE public.users_user_id_seq OWNED BY public.users.user_id;


--
-- TOC entry 4293 (class 2604 OID 16475)
-- Name: reservations reservation_id; Type: DEFAULT; Schema: public; Owner: avnadmin
--

ALTER TABLE ONLY public.reservations ALTER COLUMN reservation_id SET DEFAULT nextval('public.reservations_reservation_id_seq'::regclass);


--
-- TOC entry 4291 (class 2604 OID 16451)
-- Name: restaurants restaurant_id; Type: DEFAULT; Schema: public; Owner: avnadmin
--

ALTER TABLE ONLY public.restaurants ALTER COLUMN restaurant_id SET DEFAULT nextval('public.restaurants_restaurant_id_seq'::regclass);


--
-- TOC entry 4296 (class 2604 OID 16494)
-- Name: reviews review_id; Type: DEFAULT; Schema: public; Owner: avnadmin
--

ALTER TABLE ONLY public.reviews ALTER COLUMN review_id SET DEFAULT nextval('public.reviews_review_id_seq'::regclass);


--
-- TOC entry 4289 (class 2604 OID 16441)
-- Name: users user_id; Type: DEFAULT; Schema: public; Owner: avnadmin
--

ALTER TABLE ONLY public.users ALTER COLUMN user_id SET DEFAULT nextval('public.users_user_id_seq'::regclass);


--
-- TOC entry 4462 (class 0 OID 16472)
-- Dependencies: 220
-- Data for Name: reservations; Type: TABLE DATA; Schema: public; Owner: avnadmin
--

COPY public.reservations (reservation_id, customer_id, restaurant_id, reservation_time, number_of_customers, status, created_at) FROM stdin;
1	1	1	2025-02-10 19:00:00	2	confirmed	2025-02-22 20:32:21.156627
2	2	1	2025-02-11 20:00:00	4	pending	2025-02-22 20:32:21.156627
3	1	2	2025-02-12 18:30:00	3	cancelled	2025-02-22 20:32:21.156627
\.


--
-- TOC entry 4460 (class 0 OID 16448)
-- Dependencies: 218
-- Data for Name: restaurants; Type: TABLE DATA; Schema: public; Owner: avnadmin
--

COPY public.restaurants (restaurant_id, manager_id, name, description, cuisine, location, opening_time, closing_time, created_at) FROM stdin;
1	3	Gourmet Delight	A high-end dining experience offering international cuisine.	International	123 Main Street, Boston, MA	11:00:00	23:00:00	2025-02-22 20:31:58.028906
2	4	Pasta Paradise	Authentic Italian cuisine made fresh daily.	Italian	456 Elm Street, Boston, MA	10:00:00	22:00:00	2025-02-22 20:31:58.028906
\.


--
-- TOC entry 4464 (class 0 OID 16491)
-- Dependencies: 222
-- Data for Name: reviews; Type: TABLE DATA; Schema: public; Owner: avnadmin
--

COPY public.reviews (review_id, customer_id, restaurant_id, rating, review_text, created_at) FROM stdin;
1	1	1	5	Amazing food and excellent service. Highly recommend!	2025-02-22 20:32:40.372658
2	2	1	4	Great ambiance, but the food was slightly overpriced.	2025-02-22 20:32:40.372658
3	1	2	3	The pasta was decent, but the service was slow.	2025-02-22 20:32:40.372658
\.


--
-- TOC entry 4458 (class 0 OID 16438)
-- Dependencies: 216
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: avnadmin
--

COPY public.users (user_id, first_name, last_name, email, password_hash, phone_number, role, created_at) FROM stdin;
1	John	Doe	john.doe@example.com	hashed_password_1	\N	customer	2025-02-22 20:31:19.801109
2	Jane	Smith	jane.smith@example.com	hashed_password_2	\N	customer	2025-02-22 20:31:19.801109
3	Emily	Johnson	emily.johnson@example.com	hashed_password_3	\N	restaurant_manager	2025-02-22 20:31:19.801109
4	Michael	Brown	michael.brown@example.com	hashed_password_4	\N	restaurant_manager	2025-02-22 20:31:19.801109
\.


--
-- TOC entry 4474 (class 0 OID 0)
-- Dependencies: 219
-- Name: reservations_reservation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: avnadmin
--

SELECT pg_catalog.setval('public.reservations_reservation_id_seq', 3, true);


--
-- TOC entry 4475 (class 0 OID 0)
-- Dependencies: 217
-- Name: restaurants_restaurant_id_seq; Type: SEQUENCE SET; Schema: public; Owner: avnadmin
--

SELECT pg_catalog.setval('public.restaurants_restaurant_id_seq', 2, true);


--
-- TOC entry 4476 (class 0 OID 0)
-- Dependencies: 221
-- Name: reviews_review_id_seq; Type: SEQUENCE SET; Schema: public; Owner: avnadmin
--

SELECT pg_catalog.setval('public.reviews_review_id_seq', 3, true);


--
-- TOC entry 4477 (class 0 OID 0)
-- Dependencies: 215
-- Name: users_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: avnadmin
--

SELECT pg_catalog.setval('public.users_user_id_seq', 4, true);


--
-- TOC entry 4306 (class 2606 OID 16479)
-- Name: reservations reservations_pkey; Type: CONSTRAINT; Schema: public; Owner: avnadmin
--

ALTER TABLE ONLY public.reservations
    ADD CONSTRAINT reservations_pkey PRIMARY KEY (reservation_id);


--
-- TOC entry 4304 (class 2606 OID 16456)
-- Name: restaurants restaurants_pkey; Type: CONSTRAINT; Schema: public; Owner: avnadmin
--

ALTER TABLE ONLY public.restaurants
    ADD CONSTRAINT restaurants_pkey PRIMARY KEY (restaurant_id);


--
-- TOC entry 4308 (class 2606 OID 16500)
-- Name: reviews reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: avnadmin
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_pkey PRIMARY KEY (review_id);


--
-- TOC entry 4300 (class 2606 OID 16446)
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: avnadmin
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- TOC entry 4302 (class 2606 OID 16444)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: avnadmin
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- TOC entry 4310 (class 2606 OID 16480)
-- Name: reservations reservations_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: avnadmin
--

ALTER TABLE ONLY public.reservations
    ADD CONSTRAINT reservations_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- TOC entry 4311 (class 2606 OID 16485)
-- Name: reservations reservations_restaurant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: avnadmin
--

ALTER TABLE ONLY public.reservations
    ADD CONSTRAINT reservations_restaurant_id_fkey FOREIGN KEY (restaurant_id) REFERENCES public.restaurants(restaurant_id) ON DELETE CASCADE;


--
-- TOC entry 4309 (class 2606 OID 16457)
-- Name: restaurants restaurants_manager_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: avnadmin
--

ALTER TABLE ONLY public.restaurants
    ADD CONSTRAINT restaurants_manager_id_fkey FOREIGN KEY (manager_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- TOC entry 4312 (class 2606 OID 16501)
-- Name: reviews reviews_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: avnadmin
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- TOC entry 4313 (class 2606 OID 16506)
-- Name: reviews reviews_restaurant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: avnadmin
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_restaurant_id_fkey FOREIGN KEY (restaurant_id) REFERENCES public.restaurants(restaurant_id) ON DELETE CASCADE;


-- Completed on 2025-03-13 13:13:37 EDT

--
-- PostgreSQL database dump complete
--

