USE example

-- I need a temporary table to index the rows
DROP TABLE IF EXISTS #indexed_subscriptions

CREATE TABLE #indexed_subscriptions (
    temp_index INT IDENTITY(1, 1) PRIMARY KEY,
    subscription_id VARCHAR(500),
    shipping_id VARCHAR(500),
	stage_id VARCHAR(100),
	product_id VARCHAR(500),
	notes VARCHAR(500)
)

INSERT INTO #indexed_subscriptions (subscription_id, shipping_id, stage_id, product_id, notes)
SELECT "id", "partner_shipping_id/id", "stage_id","order_line/product_id","order_line/name"
FROM subscriptions

/*
Now I can use the indexed table to fill the missing values with those in the previous row.
I'm not using a proper temporary table beacuse I cannot call my previously stored function on that.
*/
DROP TABLE IF EXISTS temp_subscriptions_fixed

CREATE TABLE temp_subscriptions_fixed (
    subscription_id VARCHAR(500),
    shipping_id VARCHAR(500),
	stage_id VARCHAR(100),
	product_id VARCHAR(500),
	notes VARCHAR(500)
)

INSERT INTO temp_subscriptions_fixed (subscription_id, shipping_id, stage_id, product_id, notes)
SELECT
	COALESCE(subscription_id, LAG(subscription_id) OVER (ORDER BY temp_index), LAG(subscription_id,2) OVER (ORDER BY temp_index)),
	COALESCE(shipping_id, LAG(shipping_id) OVER (ORDER BY temp_index), LAG(shipping_id,2) OVER (ORDER BY temp_index)),
	COALESCE(stage_id, LAG(stage_id) OVER (ORDER BY temp_index), LAG(stage_id,2) OVER (ORDER BY temp_index)),
	product_id,
	notes
FROM #indexed_subscriptions

DROP TABLE #indexed_subscriptions

EXEC get_table_info temp_subscriptions_fixed

/*
I can see there are some blank values in the product_id column.
Looking at the data shows that's either because the subscriptions were closed or the row has been duplicated to accomodate notes in another column.
In either case we do not need these rows.
*/

SELECT * FROM temp_subscriptions_fixed
WHERE product_id IS Null AND stage_id = 'In Progress'

/*
Now that I have identified the data I need in each table, I can join it in a sigle one to export and work on it elsewhere.

Since I need all the active subscriptions (even if for some reason they are not in the address book), but I do not need the addresses of non-active subscribers, I perform a LEFT JOIN.

Now I'm ready to export the table "subscriptions_addresses" which contains all the data I need and nothing superfluous.
*/

DROP TABLE IF EXISTS subscriptions_addresses

SELECT subscription_id, shipping_id, product_id, Zip as zip, City as city, Country as country 
INTO subscriptions_addresses
FROM temp_subscriptions_fixed
LEFT JOIN address_book
	ON shipping_id = "External ID"
WHERE stage_id = 'In Progress' AND product_id IS NOT NULL

DROP TABLE temp_subscriptions_fixed

-- Just a quick check to make sure the data is all right. The previously created stored procedure is quite useful.
EXEC get_table_info 'subscriptions_addresses'

-- Table is fine and ready to export
