CREATE DATABASE bank_churn;
USE bank_churn;
/*Q1. What is the bank's overall churn rate, and how much deposit balance has already been lost to churned customers 
— both in absolute terms and as a share of total deposits? */
SELECT* FROM customers;
SELECT 100.0*churn/total_cust as churn_rate FROM 
(SELECT SUM(exited) as Churn ,COUNT(customer_id) as total_cust FROM customers) AS T
SELECT 100.0*balance_lost/total_bal as balance_lost1 FROM(SELECT SUM(CASE WHEN exited =1 THEN balance ELSE 0 END )
as balance_lost,SUM(balance) AS total_bal FROM customers) AS T 

/*Q2. How does churn vary across zones (West, North, South) — and is the worst zone's problem a rate 
problem (customers there are likelier to leave) or a volume problem (it simply has more customers)?*/
SELECT zone,
       COUNT(*)                                        AS customers,
       SUM(exited)                                     AS churned,
       ROUND(AVG(CAST(exited AS FLOAT)) * 100, 1)      AS churn_rate_pct,
       ROUND(SUM(exited) * 100.0
             / (SELECT SUM(exited) FROM customers), 1) AS share_of_all_churn_pct
FROM customers
GROUP BY zone
ORDER BY churn_rate_pct DESC;




/*Q3. Which age band loses the highest proportion of customers, and how steeply does churn risk climb with age?*/
SELECT age_band,
       COUNT(*)                                        AS customers,
       ROUND(AVG(CAST(exited AS FLOAT)) * 100, 1)      AS churn_rate_pct
FROM customers
GROUP BY age_band
ORDER BY age_band;




/*Q4. Does holding more products make customers stickier — or is there a point where additional
products are associated with higher churn?*/
SELECT num_of_products,
       COUNT(*)                                        AS customers,
       ROUND(AVG(CAST(exited AS FLOAT)) * 100, 1)      AS churn_rate_pct
FROM customers
GROUP BY num_of_products
ORDER BY num_of_products;


/*Q5. How much does being an active member reduce churn risk, and how much deposit money is
currently held by inactive members?*/
SELECT CASE is_active_member WHEN 1 THEN 'active' ELSE 'inactive' END
                                                       AS member_status,
       COUNT(*)                                        AS customers,
       ROUND(AVG(CAST(exited AS FLOAT)) * 100, 1)      AS churn_rate_pct,
       ROUND(SUM(balance), 0)                          AS total_balance_held
FROM customers
GROUP BY is_active_member;


/*Q6. Is churn concentrated among low-balance customers the bank can afford to lose,
or are high-value customers leaving at the same rate?*/
WITH tiers AS (
  SELECT balance, exited,
         NTILE(4) OVER (ORDER BY balance) AS balance_quartile
  FROM customers
  WHERE balance > 0
)
SELECT balance_quartile,
       COUNT(*)                                        AS customers,
       ROUND(MIN(balance), 0)                          AS tier_min,
       ROUND(MAX(balance), 0)                          AS tier_max,
       ROUND(AVG(CAST(exited AS FLOAT)) * 100, 1)      AS churn_rate_pct
FROM tiers
GROUP BY balance_quartile
ORDER BY balance_quartile;


/*Q7. When customers are segmented by zone, age band, and activity status together, which five segments 
have the highest churn rates — and how much balance does each hold?*/
SELECT TOP 5
       zone, age_band,
       CASE is_active_member WHEN 1 THEN 'active' ELSE 'inactive' END
                                                       AS member_status,
       COUNT(*)                                        AS customers,
       ROUND(AVG(CAST(exited AS FLOAT)) * 100, 1)      AS churn_rate_pct,
       ROUND(SUM(balance), 0)                          AS balance_held
FROM customers
GROUP BY zone, age_band, is_active_member
HAVING COUNT(*) >= 100
ORDER BY churn_rate_pct DESC;


/*Q8. How many current customers match the highest-risk profile (aged 45+, inactive), and what total deposit 
value do they represent as a share of all retained balances?*/
SELECT COUNT(*)                                        AS at_risk_customers,
       ROUND(SUM(balance), 0)                          AS balance_at_risk,
       ROUND(SUM(balance) * 100.0 /
             (SELECT SUM(balance) FROM customers WHERE exited = 0), 1)
                                                       AS pct_of_retained_balance
FROM customers
WHERE exited = 0 AND age >= 45 AND is_active_member = 0;


/*Q9.Does tenure protect against churn — do long-standing customers leave less often than recent joiners?*/
SELECT tenure,
       COUNT(*)                                        AS customers,
       ROUND(AVG(CAST(exited AS FLOAT)) * 100, 1)      AS churn_rate_pct
FROM customers
GROUP BY tenure
ORDER BY tenure;


/*Q10. Is the churn gap between male and female customers consistent across zones, or does gender
matter more in some regions than others?*/
WITH by_gender AS (
  SELECT zone, gender,
         ROUND(AVG(CAST(exited AS FLOAT)) * 100, 1) AS churn_rate_pct
  FROM customers
  GROUP BY zone, gender
)
SELECT zone, gender, churn_rate_pct,
       ROUND(churn_rate_pct
             - AVG(churn_rate_pct) OVER (PARTITION BY zone), 1)
                                                       AS gap_vs_zone_avg
FROM by_gender
ORDER BY zone, gender;


/*Q11. Does holding the bank's credit card — the flagship "stickiness" product — 
actually correspond to lower churn?*/
SELECT CASE has_cr_card WHEN 1 THEN 'has card' ELSE 'no card' END
                                                       AS card_status,
       COUNT(*)                                        AS customers,
       ROUND(AVG(CAST(exited AS FLOAT)) * 100, 1)      AS churn_rate_pct
FROM customers
GROUP BY has_cr_card;


/*Q12. Did churned customers show a measurable decline in transaction activity before 
leaving — and how does their decline compare to that of retained customers?*/
SELECT exited,
       COUNT(*)                                        AS customers,
       ROUND(AVG(activity_decline_pct), 1)             AS avg_activity_decline_pct
FROM customers
GROUP BY exited;


/*Q13. How strongly do complaints predict churn — what is the churn rate for customers with zero, one,
and multiple complaints?*/
SELECT CASE WHEN complaint_count = 0 THEN '0'
            WHEN complaint_count = 1 THEN '1'
            ELSE '2+' END                              AS complaints,
       COUNT(*)                                        AS customers,
       ROUND(AVG(CAST(exited AS FLOAT)) * 100, 1)      AS churn_rate_pct
FROM customers
GROUP BY CASE WHEN complaint_count = 0 THEN '0'
              WHEN complaint_count = 1 THEN '1'
              ELSE '2+' END
ORDER BY complaints;


/*Q14.Which product's holders are the stickiest, and which product's holders churn the most?*/
SELECT 'FixedDeposit' AS product,
       ROUND(AVG(CASE WHEN has_fixeddeposit = 1
       THEN CAST(exited AS FLOAT) END) * 100, 1) AS churn_rate_pct
FROM customers
UNION ALL
SELECT 'Insurance',
       ROUND(AVG(CASE WHEN has_insurance = 1
       THEN CAST(exited AS FLOAT) END) * 100, 1)
FROM customers
UNION ALL
SELECT 'MutualFund',
       ROUND(AVG(CASE WHEN has_mutualfund = 1
       THEN CAST(exited AS FLOAT) END) * 100, 1)
FROM customers
UNION ALL
SELECT 'PersonalLoan',
       ROUND(AVG(CASE WHEN has_personalloan = 1
       THEN CAST(exited AS FLOAT) END) * 100, 1)
FROM customers
UNION ALL
SELECT 'CreditCard',
       ROUND(AVG(CASE WHEN has_creditcard = 1
       THEN CAST(exited AS FLOAT) END) * 100, 1)
FROM customers
ORDER BY churn_rate_pct DESC;


/*Q15. How is each zone performing against its deposit target after churn losses, and how does 
relationship-manager workload compare across zones?*/
SELECT zone,
       MAX(deposit_target_cr)                          AS deposit_target_cr,
       ROUND(SUM(CASE WHEN exited = 0 THEN balance ELSE 0 END) / 1e7, 1)
                                                       AS retained_deposits_cr,
       ROUND(SUM(CASE WHEN exited = 0 THEN balance ELSE 0 END) / 1e7
             * 100.0 / MAX(deposit_target_cr), 1)      AS pct_of_target,
       ROUND(COUNT(CASE WHEN exited = 0 THEN 1 END) * 1.0
             / MAX(rm_headcount), 0)                   AS customers_per_rm
FROM customers
GROUP BY zone
ORDER BY pct_of_target;


/*Q16. Which specific current customers should the retention team contact first — customers who are still
with the bank, match the high-risk profile, and show a recent activity collapse — ranked by the balance at stake?*/
SELECT customer_id, zone, age_band, gender,
       ROUND(balance, 0)                               AS balance,
       activity_decline_pct, complaint_count
FROM customers
WHERE exited = 0
  AND age >= 45
  AND activity_decline_pct > 50
ORDER BY balance DESC;


/*Q17. If a targeted retention campaign reduced churn in the 45+ inactive segment by five percentage points,
how much deposit balance would the bank retain?*/
SELECT COUNT(*)                                        AS segment_size,
       ROUND(AVG(balance), 0)                          AS avg_balance,
       ROUND(COUNT(*) * 0.05 * AVG(balance), 0)        AS balance_saved_per_5pt_reduction
FROM customers
WHERE age >= 45 AND is_active_member = 0;