CREATE DATABASE IF NOT EXISTS `itb-kk`;
USE `itb-kk`;

DROP TABLE IF EXISTS tasks;
DROP TABLE IF EXISTS tasksV2;
DROP TABLE IF EXISTS status;
DROP TABLE IF EXISTS board;

CREATE TABLE tasks (
    taskId INT NOT NULL AUTO_INCREMENT,
    taskTitle TEXT NOT NULL,
    taskDescription TEXT(500),
    taskAssignees TEXT,
    taskStatus ENUM('NO_STATUS', 'TO_DO', 'DOING', 'DONE') DEFAULT 'NO_STATUS' NOT NULL,
    createdOn TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updatedOn TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT `checkTaskTitle_v1_LengthIn_1-100` CHECK (char_length(taskTitle) <= 100 AND taskTitle <>''),
    CONSTRAINT `checkMaxTaskDescription_v1_LengthIn_1-500` CHECK (char_length(taskDescription) <= 500 AND taskDescription<>''),
    CONSTRAINT `checkMaxTaskAssignees_v1_LengthIn_1-30` CHECK (char_length(taskAssignees) <= 30 AND taskAssignees<>''),
    PRIMARY KEY (taskId)
) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;



CREATE TABLE status (
    statusId INT NOT NULL AUTO_INCREMENT,
    statusName VARCHAR(50) UNIQUE NOT NULL,
    statusDescription TEXT,
    statusColor VARCHAR(7) DEFAULT '#999999',
    is_fixed_status BOOLEAN DEFAULT false,
    CONSTRAINT `checkStatusNameLengthIn_1-50` CHECK (char_length(statusName) <= 50 AND statusName <>''),
    CONSTRAINT `checkMaxStatusDescription_1-200` CHECK (char_length(statusDescription) <= 200 AND statusDescription<>''),
    PRIMARY KEY (statusId)
) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


DROP TRIGGER IF EXISTS updateFixedStatus;

DELIMITER //
CREATE TRIGGER updateFixedStatus
BEFORE UPDATE
ON status
FOR EACH ROW 
BEGIN
    IF OLD.is_fixed_status = true AND NEW.is_fixed_status = true THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot update: this status is fixed status cause it cannot update or delete';
    END IF;
END
// DELIMITER ; 


DROP TRIGGER IF EXISTS deleteFixedStatus;

DELIMITER //
CREATE TRIGGER deleteFixedStatus
BEFORE DELETE
ON status
FOR EACH ROW 
BEGIN
    IF OLD.is_fixed_status = true THEN
	SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot delete: this status is fixed status cause it cannot update or delete';
    END IF;
END
// DELIMITER ;

INSERT INTO status (
    statusName,
    statusDescription,
    statusColor,
    is_fixed_status
)
VALUES 
('No Status', 'A status has not been assigned', '#999999', true),
('Done','The task has been completed','#00a96e', true);



CREATE TABLE board (
    boardId INT NOT NULL AUTO_INCREMENT,
    is_limit_tasks BOOLEAN DEFAULT false,
    task_limit_per_status INT DEFAULT 10,
    PRIMARY KEY (boardId)
) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO board (
    is_limit_tasks,
    task_limit_per_status
)
VALUES 
(false, 10);



CREATE TABLE tasksV2 (
    taskId INT NOT NULL AUTO_INCREMENT,
    taskTitle TEXT NOT NULL,
    taskDescription TEXT,
    taskAssignees TEXT,
    statusId INT,
    boardId INT NOT NULL,
    createdOn TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updatedOn TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT `checkTaskTitle_v2_LengthIn_1-100` CHECK (char_length(taskTitle) <= 100 AND taskTitle <>''),
    CONSTRAINT `checkMaxTaskDescription_v2_LengthIn_1-500` CHECK (char_length(taskDescription) <= 500 AND taskDescription<>''),
    CONSTRAINT `checkMaxTaskAssignees_v2_LengthIn_1-30` CHECK (char_length(taskAssignees) <= 30 AND taskAssignees<>''),
    PRIMARY KEY (taskId),
    CONSTRAINT taskStatus FOREIGN KEY (`statusId`) REFERENCES `status`(`statusId`),
    CONSTRAINT taskBoard FOREIGN KEY (`boardId`) REFERENCES `board`(`boardId`)
) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET autocommit = off; 
COMMIT;

CREATE ROLE 'user';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, REFERENCES, ALTER, SHOW DATABASES ON *.* TO 'user'@'%';

CREATE USER 'tinnapop023'@'%' identified WITH mysql_native_password BY 'both-pl-1.mysql';
CREATE USER 'wanassanan070'@'%' identified WITH mysql_native_password BY 'ploy-pl-1.mysql';
CREATE USER 'sittha084'@'%' identified WITH mysql_native_password BY 'mink-pl-1.mysql';

GRANT 'user' TO 'tinnapop023'@'%';
GRANT 'user' TO 'wanassanan070'@'%';
GRANT 'user' TO 'sittha084'@'%';

SET DEFAULT ROLE 'user' TO 'tinnapop023'@'%';
SET DEFAULT ROLE 'user' TO 'wanassanan070'@'%';
SET DEFAULT ROLE 'user' TO 'sittha084'@'%';

CREATE USER 'itb-kk-be' identified WITH mysql_native_password BY 'itb-kk';
GRANT SELECT, INSERT, UPDATE, DELETE ON `itb-kk`.`tasks` TO 'itb-kk-be'@'%';  
GRANT SELECT, INSERT, UPDATE, DELETE ON `itb-kk`.`tasksV2` TO 'itb-kk-be'@'%';  
GRANT SELECT, INSERT, UPDATE, DELETE ON `itb-kk`.`status` TO 'itb-kk-be'@'%';  
GRANT SELECT, INSERT, UPDATE, DELETE ON `itb-kk`.`board` TO 'itb-kk-be'@'%';  
