/*
Having identified the tables, I want to have a look at the data they contain, in particular which columns contain the information I'm looking for and how many entries they store.

Since I'm going to use the query on multiple tables, I'm creating a stored procedure to call upon for the different tables.

Instead of manually checking the columns one by one, I used a cursor to scan them and store the result in a temporary table.
*/

CREATE PROCEDURE get_table_info
	@table_name NVARCHAR(128)

AS
BEGIN

	-- Create a temporary table to store results
	DROP TABLE IF EXISTS #table_info

	CREATE TABLE #table_info (
		column_name NVARCHAR(128),
		total_rows INT,
		entries INT,
		entries_distinct INT
	)

	-- Define the cursor
	DECLARE column_cursor CURSOR FOR
	SELECT COLUMN_NAME
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = @table_name

	DECLARE @column_name NVARCHAR(128)
	DECLARE @sql NVARCHAR(MAX)

	OPEN column_cursor

	FETCH NEXT FROM column_cursor INTO @column_name

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @sql = 
			'INSERT INTO #table_info (column_name, total_rows, entries, entries_distinct)
			SELECT 
				''' + @column_name + ''',
				COUNT(*),
				COUNT(' + QUOTENAME(@column_name) + '),
				COUNT(DISTINCT ' + QUOTENAME(@column_name) + ')
			FROM ' + QUOTENAME(@table_name)

		EXEC sp_executesql @sql

		FETCH NEXT FROM column_cursor INTO @column_name
	END

	CLOSE column_cursor
	DEALLOCATE column_cursor

	SELECT * FROM #table_info

	DROP TABLE #table_info

	SET @sql = 'SELECT TOP (10) * FROM ' +@table_name

	EXEC sp_executesql @sql

END