# README

* Strong Migrations: Safe Practices

Column Operations
 Add columns without defaults first
 Backfill data in separate migration
 Add constraints after backfill
 Use 3-step process for column removal/rename
Index Operations
 Always use algorithm: :concurrently
 Disable DDL transactions for concurrent indexes
 Monitor index creation on large tables
Foreign Key Operations
 Add with validate: false
 Validate in separate migration
 Consider impact on related tables