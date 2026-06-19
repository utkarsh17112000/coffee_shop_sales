/*
1. Which cities generate the highest total revenue and average transaction value?
Business Goal: Identify premium markets for expansion and pricing optimization.

2. Which store types (Standalone, Mall Kiosk, Airport) generate the highest revenue efficiency per transaction?
Business Goal: Evaluate whether airport premium pricing justifies lower traffic volume.

3. Which products generate the highest total revenue globally?
Business Goal: Identify flagship products driving business performance.

4. Which products have high sales volume but low revenue contribution?
Business Goal: Detect underpriced "traffic-driver" products for repricing opportunities.

5. How much revenue is impacted by discounts and promotional campaigns?
Business Goal: Measure promotion effectiveness vs revenue leakage.

6. During which hours of the day does the business generate peak revenue?
Business Goal: Optimize staffing, inventory, and operational planning.

7. What percentage of daily revenue comes from Morning Rush hours (7 AM–10 AM)?
Business Goal: Measure dependency on commuter coffee traffic.

8. Which days of the week generate the highest and lowest sales?
Business Goal: Improve weekday targeting and staffing allocation.

9. Which months demonstrate seasonal spikes or declines in sales?
Business Goal: Forecast inventory demand and hiring needs.

10. How do public holidays impact customer spending behavior?
Business Goal: Evaluate holiday-driven revenue opportunities.

11. How do weather conditions affect total sales and customer purchasing patterns?
Business Goal: Build weather-sensitive forecasting models.

12. Which product categories perform best during rainy or snowy weather?
Business Goal: Create weather-driven promotional campaigns.

13. Is there a correlation between temperature and cold beverage sales?
Business Goal: Forecast seasonal beverage demand.

14. Which cities are most sensitive to weather-related sales fluctuations?
Business Goal: Develop region-specific forecasting strategies.

15. Which customer age groups contribute the highest revenue?
Business Goal: Identify core target audiences for marketing campaigns.

16. Do loyalty program members spend more per transaction than non-members?
Business Goal: Evaluate loyalty program ROI and customer value.

17. Which customer segments respond the most to discounts and promotions?
Business Goal: Optimize personalized promotional targeting.

18. What is the repeat purchase behavior of loyalty customers?
Business Goal: Measure retention and customer engagement.

19. Which payment methods dominate across countries and store types?
Business Goal: Optimize POS infrastructure and payment partnerships.

20. Which countries generate the highest revenue per store?
Business Goal: Identify the strongest international markets by operational efficiency.

21. Which product categories dominate peak-hour sales?
Business Goal: Optimize menu placement and operational focus during rush periods.

22. Are airport stores truly benefiting from premium pricing strategies?
Business Goal: Validate airport expansion and pricing strategies.

23. Which cities have the highest average basket size (quantity per transaction)?
Business Goal: Study customer purchasing depth and upselling opportunities.

24. Which products should be promoted, repriced, or removed based on demand and revenue performance?
Business Goal: Perform menu engineering optimization.

25. Which customer demographics generate the highest revenue under adverse weather conditions?
Business Goal: Develop weather-targeted personalization campaigns.


*/


SELECT * FROM coffee_shop_sales.coffee_shop_sales;


# 1. Which cities generate the highest total revenue and average transaction value?
# Business Goal: Identify premium markets for expansion and pricing optimization.
SELECT city,
round(sum(total_amount),2) as total_amount,
round(avg(total_amount),2) average_transaction_value,
ROUND(SUM(total_amount) * 100 /
(SELECT SUM(total_amount) FROM coffee_shop_sales.coffee_shop_sales),2) AS revenue_contribution_pct
 FROM coffee_shop_sales.coffee_shop_sales
 GROUP BY city
 ORDER BY total_amount desc,average_transaction_value desc;



# 2. Which store types (Standalone, Mall Kiosk, Airport) generate the highest revenue efficiency per transaction?
# Business Goal: Evaluate whether airport premium pricing justifies lower traffic volume.
SELECT store_type,
COUNT(transaction_id) AS total_transactions,
round(sum(total_amount),2) as total_amount,
round(avg(total_amount),2) average_transaction_value,
ROUND(SUM(total_amount) * 100 /
(SELECT SUM(total_amount) FROM coffee_shop_sales.coffee_shop_sales),2) AS revenue_contribution_pct
 FROM coffee_shop_sales.coffee_shop_sales
 GROUP BY store_type
 ORDER BY average_transaction_value desc;


# 3. Which products generate the highest total revenue globally?
# Business Goal: Identify flagship products driving business performance.
SELECT product_name,
round(sum(total_amount),2) as total_amount,
round(avg(total_amount),2) average_transaction_value,
ROUND(SUM(total_amount) * 100 /
(SELECT SUM(total_amount) FROM coffee_shop_sales.coffee_shop_sales),2) AS revenue_contribution_pct
 FROM coffee_shop_sales.coffee_shop_sales
 GROUP BY product_name
 ORDER BY total_amount desc,average_transaction_value desc;
 
 
# 4. Which products have high sales volume but low revenue contribution?
# Business Goal: Detect underpriced "traffic-driver" products for repricing opportunities.
SELECT 
    product_name,
    SUM(quantity) AS total_sales_volume,
    ROUND(SUM(total_amount),2) AS total_revenue,
    ROUND(SUM(total_amount)/SUM(quantity),2) AS revenue_per_unit,
    ROUND(
        SUM(total_amount) * 100 /
        (SELECT SUM(total_amount)
         FROM coffee_shop_sales.coffee_shop_sales),2
    ) AS revenue_contribution_pct
FROM coffee_shop_sales.coffee_shop_sales
GROUP BY product_name
ORDER BY total_sales_volume DESC;
 
# 5. How much revenue is impacted by discounts and promotional campaigns?
# Business Goal: Measure promotion effectiveness vs revenue leakage.
SELECT discount_applied,
round(sum(total_amount),2) as total_amount,
round(avg(`Estimated Discount Value`),2) average_Estimated_Discount_Value,
COUNT(transaction_id) AS total_transactions,
ROUND(SUM(total_amount) * 100 /
(SELECT SUM(total_amount) FROM coffee_shop_sales.coffee_shop_sales),2) AS revenue_contribution_pct
 FROM coffee_shop_sales.coffee_shop_sales
 GROUP BY discount_applied
 ORDER BY total_amount desc,average_Estimated_Discount_Value desc;


# 6. During which hours of the day does the business generate peak revenue?
# Business Goal: Optimize staffing, inventory, and operational planning.
SELECT 
    HOUR(
        STR_TO_DATE(
            REPLACE(timestamp,'.',':'),
            '%d-%m-%Y %H:%i'
        )
    ) AS hour_of_day,

    COUNT(transaction_id) AS total_transactions,

    ROUND(SUM(total_amount),2) AS total_revenue,

    ROUND(AVG(total_amount),2) AS avg_transaction_value,

    ROUND(
        SUM(total_amount) * 100 /
        (SELECT SUM(total_amount)
         FROM coffee_shop_sales.coffee_shop_sales),2
    ) AS revenue_contribution_pct

FROM coffee_shop_sales.coffee_shop_sales

GROUP BY hour_of_day

ORDER BY total_revenue DESC;

# 7. What percentage of daily revenue comes from Morning Rush hours (7 AM–10 AM)?
# Business Goal: Measure dependency on commuter coffee traffic.
select 
Case when hour(STR_TO_DATE(REPLACE(timestamp,'.',':'),'%d-%m-%Y %H:%i')) between 7 and 10 then "Morning Rush"
else "Other Hours" end as Rush_Category,
round(SUM(total_amount),2) as total_amount,
ROUND(SUM(total_amount) * 100 /(SELECT SUM(total_amount) FROM coffee_shop_sales.coffee_shop_sales),2
) AS revenue_contribution_pct
FROM coffee_shop_sales.coffee_shop_sales
GROUP BY Rush_Category;



# 8. Which days of the week generate the highest and lowest sales?
# Business Goal: Improve weekday targeting and staffing allocation.
select 
dayname(STR_TO_DATE(REPLACE(timestamp,'.',':'),'%d-%m-%Y %H:%i')) as day_of_week,
round(SUM(total_amount),2) as total_amount,
ROUND(SUM(total_amount) * 100 /(SELECT SUM(total_amount) FROM coffee_shop_sales.coffee_shop_sales),2
) AS revenue_contribution_pct
FROM coffee_shop_sales.coffee_shop_sales
GROUP BY day_of_week
order by total_amount desc; 


# 9. Which months demonstrate seasonal spikes or declines in sales?
# Business Goal: Forecast inventory demand and hiring needs.
select 
monthname(STR_TO_DATE(REPLACE(timestamp,'.',':'),'%d-%m-%Y %H:%i')) as month_name,
month(STR_TO_DATE(REPLACE(timestamp,'.',':'),'%d-%m-%Y %H:%i')) as month_number,
round(SUM(total_amount),2) as total_amount,
ROUND(SUM(total_amount) * 100 /(SELECT SUM(total_amount) FROM coffee_shop_sales.coffee_shop_sales),2
) AS revenue_contribution_pct
FROM coffee_shop_sales.coffee_shop_sales
GROUP BY month_name,month_number
order by month_number; 


# 10. How do public holidays impact customer spending behavior?
# Business Goal: Evaluate holiday-driven revenue opportunities.
select 
holiday_name,
round(SUM(total_amount),2) as total_amount,ROUND(AVG(total_amount),2) AS avg_transaction_value,
ROUND(SUM(total_amount) * 100 /(SELECT SUM(total_amount) FROM coffee_shop_sales.coffee_shop_sales),2
) AS revenue_contribution_pct
FROM coffee_shop_sales.coffee_shop_sales
WHERE holiday_name <> 'No Holiday'
GROUP BY holiday_name
order by total_amount desc; 


# 11. How do weather conditions affect total sales and customer purchasing patterns?
# Business Goal: Build weather-sensitive forecasting models.
SELECT 
    weather_condition,
    COUNT(transaction_id) AS total_transactions,
    ROUND(SUM(total_amount),2) AS total_revenue,
    ROUND(AVG(total_amount),2) AS avg_transaction_value,
    ROUND(
        SUM(total_amount) * 100 /
        (SELECT SUM(total_amount)
         FROM coffee_shop_sales.coffee_shop_sales),2
    ) AS revenue_contribution_pct
FROM coffee_shop_sales.coffee_shop_sales
GROUP BY weather_condition
ORDER BY total_revenue DESC;


# 12. Which product categories perform best during rainy or snowy weather?
# Business Goal: Create weather-driven promotional campaigns.
SELECT 
    weather_condition,product_category,
    COUNT(transaction_id) AS total_transactions,
    ROUND(SUM(total_amount),2) AS total_revenue,
    ROUND(AVG(total_amount),2) AS avg_transaction_value,
    ROUND(
        SUM(total_amount) * 100 /
        (SELECT SUM(total_amount)
         FROM coffee_shop_sales.coffee_shop_sales),2
    ) AS revenue_contribution_pct
FROM coffee_shop_sales.coffee_shop_sales
where weather_condition in ("Rainy","Snowy")
GROUP BY weather_condition,product_category
ORDER BY total_revenue DESC;

# 13. Is there a correlation between temperature and cold beverage sales?
# Business Goal: Forecast seasonal beverage demand.
SELECT 

CASE
    WHEN temperature_c < 10 THEN 'Cold'
    WHEN temperature_c BETWEEN 10 AND 20 THEN 'Mild'
    WHEN temperature_c BETWEEN 21 AND 30 THEN 'Warm'
    ELSE 'Hot'
END AS temperature_band,
COUNT(transaction_id) AS total_transactions,
SUM(quantity) AS total_units_sold,
ROUND(SUM(total_amount),2) AS total_revenue,
ROUND(AVG(total_amount),2) AS avg_transaction_value
FROM coffee_shop_sales.coffee_shop_sales
WHERE product_name IN (
'Large Berry Blast',
'Medium Berry Blast',
'Large Iced Coffee',
'Medium Iced Coffee',
'Large Matcha Latte',
'Medium Matcha Latte',
'Small Matcha Latte'
)
GROUP BY temperature_band
ORDER BY total_revenue DESC;

# 14. Which cities are most sensitive to weather-related sales fluctuations?
# Business Goal: Develop region-specific forecasting strategies.
SELECT 
    city, weather_condition,
    COUNT(transaction_id) AS total_transactions,
    ROUND(SUM(total_amount),2) AS total_revenue,
    ROUND(AVG(total_amount),2) AS avg_transaction_value,
    ROUND(
        SUM(total_amount) * 100 /
        SUM(SUM(total_amount)) OVER(PARTITION BY city),
        2
    ) AS city_weather_revenue_pct
FROM coffee_shop_sales.coffee_shop_sales
where weather_condition<>"Unknown"
GROUP BY city,weather_condition
ORDER BY city ;


# 15. Which customer age groups contribute the highest revenue?
# Business Goal: Identify core target audiences for marketing campaigns.
select 
customer_age_group,
COUNT(transaction_id) AS total_transactions,
round(SUM(total_amount),2) as total_amount,ROUND(AVG(total_amount),2) AS avg_transaction_value,
ROUND(SUM(total_amount) * 100 /(SELECT SUM(total_amount) FROM coffee_shop_sales.coffee_shop_sales),2
) AS revenue_contribution_pct
FROM coffee_shop_sales.coffee_shop_sales
WHERE customer_age_group <> 'Unknown'
GROUP BY customer_age_group
order by total_amount desc; 


# 16. Do loyalty program members spend more per transaction than non-members?
# Business Goal: Evaluate loyalty program ROI and customer value.
SELECT 
    loyalty_member,
    COUNT(transaction_id) AS total_transactions,
    ROUND(SUM(total_amount),2) AS total_revenue,
    ROUND(AVG(total_amount),2) AS avg_transaction_value,
    ROUND(
        SUM(total_amount) * 100 /
        SUM(SUM(total_amount)) OVER(),
        2
    ) AS loyalty_revenue_pct,
     ROUND(
        COUNT(transaction_id) /
        COUNT(DISTINCT customer_id),
        2
    ) AS transactions_per_customer
FROM coffee_shop_sales.coffee_shop_sales
GROUP BY loyalty_member
ORDER BY loyalty_revenue_pct ;


# 17. Which customer segments respond the most to discounts and promotions?
# Business Goal: Optimize personalized promotional targeting.
SELECT
    customer_age_group,
    COUNT(*) AS total_transactions,
    SUM(CASE WHEN discount_applied = 1 THEN 1 ELSE 0 END) AS promo_transactions,
    ROUND(SUM(CASE WHEN discount_applied = 1 THEN 1 ELSE 0 END)
        *100.0 / COUNT(*), 2 ) AS promo_adoption_rate_pct,
    ROUND(
        SUM(CASE WHEN discount_applied = 1 THEN total_amount ELSE 0 END),2
    ) AS promo_revenue
FROM coffee_shop_sales.coffee_shop_sales
WHERE customer_age_group <> 'Unknown'
GROUP BY customer_age_group
ORDER BY promo_adoption_rate_pct DESC;


# 18. What is the repeat purchase behavior of loyalty customers?
# Business Goal: Measure retention and customer engagement.
WITH customer_purchases AS
(
    SELECT
        customer_id,
        COUNT(*) AS purchase_count
    FROM coffee_shop_sales.coffee_shop_sales
    WHERE loyalty_member = 1
    GROUP BY customer_id
)
SELECT
CASE
    WHEN purchase_count = 1 THEN 'One-Time'
    WHEN purchase_count BETWEEN 2 AND 3 THEN 'Occasional'
    WHEN purchase_count BETWEEN 4 AND 5 THEN 'Frequent'
    ELSE 'Highly Loyal'
END AS customer_segment,
COUNT(*) AS customers
FROM customer_purchases
GROUP BY customer_segment
ORDER BY customers DESC;

# 19. Which payment methods dominate across countries and store types?
# Business Goal: Optimize POS infrastructure and payment partnerships.
SELECT country,
    store_type,
    payment_method,
    COUNT(transaction_id) AS total_transactions,
    ROUND(SUM(total_amount),2) AS total_revenue,
    ROUND(AVG(total_amount),2) AS avg_transaction_value,
    ROUND(
        SUM(total_amount) * 100 /
        SUM(SUM(total_amount)) OVER(PARTITION BY country, store_type),
        2
    ) AS country_revenue_pct
FROM coffee_shop_sales.coffee_shop_sales
GROUP BY country, store_type, payment_method
ORDER BY country, store_type ;



# 20. Which countries generate the highest revenue per store?
# Business Goal: Identify the strongest international markets by operational efficiency.
SELECT 
    country,
    COUNT(transaction_id) AS total_transactions,
    ROUND(SUM(total_amount),2) AS total_revenue,
    count(distinct store_id) as total_stores,
    ROUND(AVG(total_amount),2) AS avg_transaction_value,
    ROUND(
        SUM(total_amount)/
        count(distinct store_id),
        2
    ) AS total_revenue_per_stores,
     ROUND(
        COUNT(transaction_id) /
        COUNT(DISTINCT customer_id),
        2
    ) AS transactions_per_customer
FROM coffee_shop_sales.coffee_shop_sales
GROUP BY country
ORDER BY total_revenue_per_stores desc;


# 21. Which product categories dominate peak-hour sales?
# Business Goal: Optimize menu placement and operational focus during rush periods.

# 22. Are airport stores truly benefiting from premium pricing strategies?
# Business Goal: Validate airport expansion and pricing strategies.

# 23. Which cities have the highest average basket size (quantity per transaction)?
# Business Goal: Study customer purchasing depth and upselling opportunities.

# 24. Which products should be promoted, repriced, or removed based on demand and revenue performance?
# Business Goal: Perform menu engineering optimization.

# 25. Which customer demographics generate the highest revenue under adverse weather conditions?
# Business Goal: Develop weather-targeted personalization campaigns.























