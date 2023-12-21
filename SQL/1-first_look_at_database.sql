/*
The task at hand is to create a geographic visualization of active subscribers.
For that I will need to retrieve informations about the subscriptions and the the subscribers's locations.
I am not familiar with the database/data where this information is stored,
except for the fact it's contained in two tables (subscriptions and address book), so I'll have to check what's available first.

Sensitive informatiomation has been redacted
*/

--First check which tables are in the database
USE example
SELECT name
FROM example.sys.tables;