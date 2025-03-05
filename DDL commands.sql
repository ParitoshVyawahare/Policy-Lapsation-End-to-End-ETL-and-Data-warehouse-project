-- DROP DATABASE IF EXISTS lifeinsurance_dw;
-- CREATE DATABASE lifeinsurance_dw;

-- Creating Dimension Tables

-- City, State, Country Hierarchy

CREATE TABLE dim_city (
    city_key SERIAL PRIMARY KEY,
    city_name VARCHAR(50),
    state_id INT REFERENCES dim_state(state_id) ON DELETE CASCADE
);

CREATE TABLE dim_state (
    state_id SERIAL PRIMARY KEY,
    state_name VARCHAR(50),
    country_key INT REFERENCES dim_country(country_key) ON DELETE CASCADE
);

CREATE TABLE dim_country (
    country_key SERIAL PRIMARY KEY,
    country_name VARCHAR(50)
);


-- Customer Dimension (dim_customers)
-- Customer Dimension (dim_customers) with SCD Type 2
CREATE TABLE dim_customers (
    customer_key SERIAL PRIMARY KEY,
    customer_id VARCHAR(10) UNIQUE,
    occupation VARCHAR(100),
    marital_status VARCHAR(15) CHECK (marital_status IN ('Married', 'Unmarried', 'Divorced')),
    age_group VARCHAR(15),
    zip_code VARCHAR(10),
    city_key INT REFERENCES dim_city(city_key) ON DELETE CASCADE,
    effective_start_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- Track when the record is inserted
    effective_end_date TIMESTAMP DEFAULT NULL,                 -- NULL means the record is current
    is_current BOOLEAN DEFAULT TRUE                           -- Marks active records
);




-- Policy Type Generalized Hierarchy

CREATE TABLE dim_policy_type (
    policy_type_key SERIAL PRIMARY KEY,
    policy_type_id VARCHAR(15),
    policy_type_name VARCHAR(100),
    lapsed_key INT REFERENCES dim_lapsed(lapsed_key),
    non_lapsed_key INT REFERENCES dim_non_lapsed(non_lapsed_key)
);

CREATE TABLE dim_lapsed (
    lapsed_key SERIAL PRIMARY KEY,
    reinstatement_key INT REFERENCES dim_reinstatement(reinstatement_key)
);

CREATE TABLE dim_non_lapsed (
    non_lapsed_key SERIAL PRIMARY KEY
);

CREATE TABLE dim_reinstatement (
    reinstatement_key SERIAL PRIMARY KEY,
    reinstatement_id VARCHAR(15),
    status VARCHAR(20) CHECK (status IN ('Pending', 'Approved', 'Rejected'))
);



--- Policy Dimension (dim_policies) -- --- scd type 2



CREATE TABLE dim_policies (
    policy_key SERIAL PRIMARY KEY,
    policy_number VARCHAR(15) UNIQUE,
    status_code VARCHAR(2),
    premium_frequency VARCHAR(15) CHECK (premium_frequency IN ('Monthly', 'Quarterly', 'Semi-Annually', 'Annually')),
    policy_type_key INT REFERENCES dim_policy_type(policy_type_key) ON DELETE CASCADE,
    effective_start_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    effective_end_date TIMESTAMP DEFAULT NULL,
    is_current BOOLEAN DEFAULT TRUE
);


-- Payment Method Dimension (dim_payment_methods) with SCD Type 3
CREATE TABLE dim_payment_methods (
    payment_method_key SERIAL PRIMARY KEY,
    auto_pay_key INT REFERENCES dim_auto_pay(auto_pay_key),
    non_auto_pay_key INT REFERENCES dim_non_auto_pay(non_auto_pay_key),
    current_payment_method VARCHAR(15) CHECK (current_payment_method IN ('Auto Pay', 'Non Auto Pay')), 
    previous_payment_method VARCHAR(15) CHECK (previous_payment_method IN ('Auto Pay', 'Non Auto Pay')), 
    payment_method_change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP  -- Stores the date of change
);

-- Auto Pay Table
CREATE TABLE dim_auto_pay (
    auto_pay_key SERIAL PRIMARY KEY
);

-- Non Auto Pay Table
CREATE TABLE dim_non_auto_pay (
    non_auto_pay_key SERIAL PRIMARY KEY
);


-- Agent Dimension (dim_agents) --- scd type 2

CREATE TABLE dim_agents (
    agent_key SERIAL PRIMARY KEY,
    agent_id VARCHAR(10) UNIQUE,
    agent_name VARCHAR(100),
    status_id INT REFERENCES dim_status(status_id) ON DELETE CASCADE,
    effective_start_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    effective_end_date TIMESTAMP DEFAULT NULL,
    is_current BOOLEAN DEFAULT TRUE
);

-- dim_status (Convert to SCD Type 3)

CREATE TABLE dim_status (
    status_id SERIAL PRIMARY KEY,
    status_name VARCHAR(15) CHECK (status_name IN ('Active', 'Inactive')),
    previous_status VARCHAR(15),  -- Stores the last known status
    status_change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP  -- When the change happened
);



-- Time Dimension (dim_time)

CREATE TABLE dim_time (
    time_key SERIAL PRIMARY KEY,
    date DATE UNIQUE,
    day_nb_month INT,
    day_nb_year INT,
    month_number INT,
    month_name VARCHAR(15),
    quarter INT,
    year INT
);


-- Branch Dimension (dim_branches)

CREATE TABLE dim_branches (
    branch_key SERIAL PRIMARY KEY,
    branch_name VARCHAR(100),
    zip_code VARCHAR(10),
    branch_id VARCHAR(10) UNIQUE,
    city_key INT REFERENCES dim_city(city_key) ON DELETE CASCADE
);


-- Creating Fact Tables

-- Customer Retention Fact Table (fact_customer_retention)
CREATE TABLE fact_customer_retention (
    fact_id SERIAL PRIMARY KEY,
    customer_key INT REFERENCES dim_customers(customer_key) ON DELETE CASCADE,
    issue_date_key INT REFERENCES dim_time(time_key) ON DELETE CASCADE,
    lapsation_date_key INT REFERENCES dim_time(time_key) ON DELETE CASCADE,
    reinstatement_date_key INT REFERENCES dim_time(time_key) ON DELETE CASCADE,
    policy_key INT REFERENCES dim_policies(policy_key) ON DELETE CASCADE,
    payment_method_key INT REFERENCES dim_payment_methods(payment_method_key) ON DELETE CASCADE,
    annual_income NUMERIC(10,2),
    premium_amount NUMERIC(10,2),
    sum_assured NUMERIC(12,2),
    lapsation_flag BOOLEAN,
    reinstatement_flag BOOLEAN,
    autopay_enrolled BOOLEAN
);


-- Payment Analysis Fact Table (fact_payment_analysis)
CREATE TABLE fact_payment_analysis (
    fact_id SERIAL PRIMARY KEY,
    policy_key INT REFERENCES dim_policies(policy_key) ON DELETE CASCADE,
    payment_key INT REFERENCES dim_payment_methods(payment_method_key) ON DELETE CASCADE,
    customer_key INT REFERENCES dim_customers(customer_key) ON DELETE CASCADE,
    agent_key INT REFERENCES dim_agents(agent_key) ON DELETE CASCADE,
    total_payments_made INT,
    total_auto_pay_transactions INT,
    total_non_auto_pay_transactions INT
);


-- Agent-Branch Performance Fact Table (fact_agent_branch_performance)
CREATE TABLE fact_agent_branch_performance (
    fact_id SERIAL PRIMARY KEY,
    agent_key INT REFERENCES dim_agents(agent_key) ON DELETE CASCADE,
    branch_key INT REFERENCES dim_branches(branch_key) ON DELETE CASCADE,
    policy_key INT REFERENCES dim_policies(policy_key) ON DELETE CASCADE,
    total_policies_sold INT,
    total_lapsed_policies INT,
    commission_earned NUMERIC(10,2),
    premium_revenue NUMERIC(12,2)
);




select * from fact_agent_branch_performance;

select * from fact_customer_retention;


select * from dim_lapsed dl  









































