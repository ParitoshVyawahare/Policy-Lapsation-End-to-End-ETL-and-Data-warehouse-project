
drop database lapsation;



CREATE TABLE customers (
    Customer_ID INT PRIMARY KEY,
    First_Name VARCHAR(100),
    Last_Name VARCHAR(100),
    Gender VARCHAR(10),
    DOB DATE,
    Email VARCHAR(150),
    Phone VARCHAR(15),
    Address TEXT,
    City VARCHAR(100),
    Zip_Code VARCHAR(10),
    Occupation VARCHAR(100),
    Annual_Income NUMERIC(15, 2),
    Source_Channel VARCHAR(50),
    Created_At DATE
);


CREATE TABLE agents (
    Agent_ID INT PRIMARY KEY,
    First_Name VARCHAR(100),
    Last_Name VARCHAR(100),
    Email VARCHAR(150),
    Phone VARCHAR(15),
    Joining_Date DATE,
    Status VARCHAR(50),
    Commission_Rate NUMERIC(5, 2)
);

CREATE TABLE branches (
    Branch_ID INT PRIMARY KEY,
    Branch_Name VARCHAR(100),
    Address TEXT,
    City VARCHAR(100),
    Zip_Code VARCHAR(10)
);


CREATE TABLE branch_rm (
    RM_ID INT PRIMARY KEY,
    First_Name VARCHAR(100),
    Last_Name VARCHAR(100),
    Email VARCHAR(150),
    Phone VARCHAR(15),
    Joining_Date DATE,
    Status VARCHAR(50),
    Branch_ID INT,
    FOREIGN KEY (Branch_ID) REFERENCES branches (Branch_ID) ON DELETE CASCADE
);



CREATE TABLE policy_types (
    Policytype_ID VARCHAR(10) PRIMARY KEY,
    Type_Name VARCHAR(100),
    Description TEXT,
    Min_Term_Year INT,
    Max_Term_Year INT,
    Min_Sum_Assured NUMERIC(15, 2),
    Max_Sum_Assured NUMERIC(15, 2)
);


CREATE TABLE applications (
    Application_ID INT PRIMARY KEY,
    Customer_ID INT,
    Policytype_ID VARCHAR(10),
    Agent_ID INT,
    RM_ID INT,
    Application_Date DATE,
    Status VARCHAR(50),
    Sum_Assured NUMERIC(15, 2),
    Premium_Amount NUMERIC(15, 2),
    Premium_Frequency VARCHAR(50),
    Term_Years INT,
    Payment_Method VARCHAR(50),
    Marital_Status VARCHAR(50),

    -- Foreign Key Constraints
    FOREIGN KEY (Customer_ID) REFERENCES customers (Customer_ID) ON DELETE CASCADE,
    FOREIGN KEY (Policytype_ID) REFERENCES policy_types (Policytype_ID) ON DELETE CASCADE,
    FOREIGN KEY (Agent_ID) REFERENCES agents (Agent_ID) ON DELETE CASCADE,
    FOREIGN KEY (RM_ID) REFERENCES branch_rm (RM_ID) ON DELETE CASCADE
);


CREATE TABLE status_log (
    Status_Code INT PRIMARY KEY,
    Description VARCHAR(100)
);

-- Insert exact status codes and descriptions
INSERT INTO status_log (Status_Code, Description) VALUES
(0, '01 Policy Active'),
(1, '02 Policy Lapsed Payment Overdue'),
(2, '03 Withdrawn'),
(3, '04 Free Look Cancellation');

select * from status_log;

CREATE TABLE policies (
    Policy_Number VARCHAR(20) PRIMARY KEY,
    Application_ID INT,
    Status_Code INT,
    Issue_Date DATE,
    Maturity_Date DATE,
    Premium_Amount NUMERIC(15, 2),

    -- Foreign Key Constraints
    FOREIGN KEY (Application_ID) REFERENCES applications (Application_ID) ON DELETE CASCADE,
    FOREIGN KEY (Status_Code) REFERENCES status_log (Status_Code) ON DELETE SET NULL
);



CREATE TABLE inactive_policies (
    Inactive_ID VARCHAR(20) PRIMARY KEY,
    Policy_Number VARCHAR(20),
    Status_Code INT,
    Status_Change_Date DATE,

    -- Foreign Key Constraints
    FOREIGN KEY (Policy_Number) REFERENCES policies (Policy_Number) ON DELETE CASCADE,
    FOREIGN KEY (Status_Code) REFERENCES status_log (Status_Code) ON DELETE SET null
    
);



CREATE TABLE premium_schedule (
    Schedule_ID SERIAL PRIMARY KEY,
    Policy_Number VARCHAR(20),
    Due_Date DATE,
    Amount NUMERIC(15, 2),
    Status VARCHAR(20),
    Grace_Period_Days INT,

    -- Foreign Key Constraint
    FOREIGN KEY (Policy_Number) REFERENCES policies (Policy_Number) ON DELETE CASCADE
);


CREATE TABLE premium_payments(
    Transaction_ID VARCHAR(20) PRIMARY KEY,
    Policy_Number VARCHAR(20),
    Payment_Date DATE,
    Amount NUMERIC(15, 2),
    Status VARCHAR(20),

    -- Foreign Key Constraint
    FOREIGN KEY (Policy_Number) REFERENCES policies (Policy_Number) ON DELETE CASCADE
);



CREATE TABLE auto_pay (
    Transaction_ID VARCHAR(20) PRIMARY KEY,
    Auto_Pay_Method VARCHAR(50),  -- e.g., Credit Card, Bank Transfer
    Auto_Pay_Status VARCHAR(20),  -- e.g., Active, Cancelled

    -- Foreign Key Constraint
    FOREIGN KEY (Transaction_ID) REFERENCES premium_payments (Transaction_ID) ON DELETE CASCADE
);

CREATE TABLE non_auto_pay (
    Transaction_ID VARCHAR(20) PRIMARY KEY,
    Payment_Channel VARCHAR(50),  -- e.g., Cash, Check, Online Payment
    Receipt_Number VARCHAR(20),

    -- Foreign Key Constraint
    FOREIGN KEY (Transaction_ID) REFERENCES premium_payments (Transaction_ID) ON DELETE CASCADE
);


CREATE TABLE communication_log (
    Log_ID VARCHAR(20) PRIMARY KEY,
    Policy_Number VARCHAR(20),
    Communication_Type VARCHAR(20),
    Sent_Date DATE,
    Message_Type VARCHAR(20),

    -- Foreign Key Constraint
    FOREIGN KEY (Policy_Number) REFERENCES policies (Policy_Number) ON DELETE CASCADE
);


CREATE TABLE lapsation_records (
    Lapsation_ID VARCHAR(20) PRIMARY KEY,
    Policy_Number VARCHAR(20),
    Lapsation_Date DATE,
    Reason VARCHAR(50),
    Days_Overdue INT,
    Amount_Due NUMERIC(15, 2),
    Reinstatement_Eligibility VARCHAR(10),

    -- Foreign Key Constraint
    FOREIGN KEY (Policy_Number) REFERENCES policies (Policy_Number) ON DELETE CASCADE
);


CREATE TABLE reinstatements (
    Reinstatement_ID VARCHAR(20) PRIMARY KEY,
    Policy_Number VARCHAR(20),
    Lapsation_ID VARCHAR(20),
    Request_Date DATE,
    Status VARCHAR(20),
    Approved_Date DATE,

    -- Foreign Key Constraints
    FOREIGN KEY (Policy_Number) REFERENCES policies (Policy_Number) ON DELETE CASCADE,
    FOREIGN KEY (Lapsation_ID) REFERENCES lapsation_records (Lapsation_ID) ON DELETE CASCADE
);


