-- NOTE: This field can't have the NOT NULL constraint cause if you rollback, the old version won't know about this field
-- and will always set it to NULL
ALTER TABLE book ADD preface varchar(5000);

-- WE'RE ASSUMING THAT IT'S A FAST MIGRATION - OTHERWISE WE WOULD HAVE TO MIGRATE IN BATCHES
UPDATE book SET book.preface = book.description;
