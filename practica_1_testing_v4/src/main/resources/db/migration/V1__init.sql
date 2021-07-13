CREATE TABLE book (
	id BIGINT NOT NULL AUTO_INCREMENT, 
	PRIMARY KEY(id),
	title varchar(255) not null,
	description varchar(5000) not null
);

insert into book (title, description) values ('100 años de soledad', 'Un viaje en el tiempo');