CREATE DATABASE `itb-kk`;

CREATE USER tinnapop023 IDENTIFIED WITH mysql_native_password BY 'both-pl-1.mysql';
CREATE USER wanassanan070 IDENTIFIED WITH mysql_native_password BY 'ploy-pl-1.mysql';
CREATE USER sittha084 IDENTIFIED WITH mysql_native_password BY 'mink-pl-1.mysql';

CREATE ROLE `user`;
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, REFERENCES, ALTER, SHOW DATABASES ON *.* TO `user`;

GRANT `user` TO tinnapop023;
GRANT `user` TO wanassanan070;
GRANT `user` TO sittha084;

SET DEFAULT ROLE `user` TO tinnapop023;
SET DEFAULT ROLE `user` TO wanassanan070;
SET DEFAULT ROLE `user` TO sittha084;

USE `itb-kk`;

CREATE TABLE tasks (
   taskId int NOT NULL AUTO_INCREMENT,
   taskTitle TINYTEXT NOT NULL,
   taskDescription TEXT(500),
   taskAssignees TINYTEXT,
   taskStatus ENUM('NO_STATUS', 'TO_DO', 'DOING', 'DONE') DEFAULT 'NO_STATUS' NOT NULL,
   createdOn TIMESTAMP NOT NULL,
   updatedOn TIMESTAMP NOT NULL,
   PRIMARY KEY (taskId)
) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET AUTOCOMMIT = off;
