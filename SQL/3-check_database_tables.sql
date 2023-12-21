/*
I can now call the stored procedure to get an overview of the tables I need
*/

USE example

EXEC get_table_info address_book

EXEC get_table_info subscriptions

/*
For the table "address book" I notice the only columns I actually need are:
"External ID",
"Zip",
"City",
"Country"

While I can see there are no duplicates in the External ID column, the number of entries in the other 3 do indicate we are missing some geographical data.
It is possible the missing data is irrelevant (eg. doesn't belong to subscribers),
or it could be extracted from other columns (eg. we can get the Country from the City).
Given the situation I can deal with this missing data as a later time.

For the table "subscriptions" the needed column are:
"id"
"partner_shipping_id/id"
"stage_id"
"order_line/product_id"
"order_line/name"

This second table unfortunately is a bit messy. I notice the presence of multiple missing rows on many columns:
Apparently subscription with more than one product have been registered in multiple rows.
Since I'll need this data to join the tables I'll have to recover it first.
*/