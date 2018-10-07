CREATE ROLE rncs_worker_api_entreprise WITH LOGIN CREATEDB PASSWORD 'password';
CREATE DATABASE rncs_worker_api_entreprise_production WITH OWNER rncs_worker_api_entreprise;
CREATE DATABASE rncs_worker_api_entreprise_development WITH OWNER rncs_worker_api_entreprise;
CREATE DATABASE rncs_worker_api_entreprise_test WITH OWNER rncs_worker_api_entreprise;

\c rncs_worker_api_entreprise_production;
CREATE EXTENSION pgcrypto;

\c rncs_worker_api_entreprise_test;
CREATE EXTENSION pgcrypto;

\c rncs_worker_api_entreprise_development;
CREATE EXTENSION pgcrypto;
