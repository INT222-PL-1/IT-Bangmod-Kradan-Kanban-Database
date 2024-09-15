CREATE DATABASE IF NOT EXISTS `itb-kk`;
USE `itb-kk`;

DROP TABLE IF EXISTS taskV1;

DROP TABLE IF EXISTS taskV2;
DROP TABLE IF EXISTS statusV2;
DROP TABLE IF EXISTS boardV2;
DROP TRIGGER IF EXISTS updateFixedStatusV2;
DROP TRIGGER IF EXISTS deleteFixedStatusV2;

DROP TABLE IF EXISTS taskV3;
DROP TABLE IF EXISTS statusV3;
DROP TABLE IF EXISTS boardV3;
DROP TABLE IF EXISTS userV3;
DROP TRIGGER IF EXISTS updateFixedStatusV3;
DROP TRIGGER IF EXISTS deleteFixedStatusV3;


# ======== Version 1 ========================================

CREATE TABLE taskV1 (
    taskId INT NOT NULL AUTO_INCREMENT,
    taskTitle TEXT NOT NULL,
    taskDescription TEXT(500),
    taskAssignees TEXT,
    taskStatus ENUM('NO_STATUS', 'TO_DO', 'DOING', 'DONE') DEFAULT 'NO_STATUS' NOT NULL,
    createdOn TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updatedOn TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT `checkTaskV1TitleLengthIn_1-100` CHECK (char_length(taskTitle) <= 100 AND taskTitle <>''),
    CONSTRAINT `checkTaskV1DescriptionLengthIn_1-500` CHECK (char_length(taskDescription) <= 500 AND taskDescription<>''),
    CONSTRAINT `checkTaskV1AssigneesLengthIn_1-30` CHECK (char_length(taskAssignees) <= 30 AND taskAssignees<>''),
    PRIMARY KEY (taskId)
) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- INSERT INTO taskV1 (
--     taskTitle,
--     taskDescription,
--     taskAssignees,
--     taskStatus,
--     createdOn,
--     updatedOn
-- )
-- VALUES 
-- ('TaskTitle1TaskTitle2TaskTitle3TaskTitle4TaskTitle5TaskTitle6TaskTitle7TaskTitle8TaskTitle9TaskTitle0','Descripti1Descripti2Descripti3Descripti4Descripti5Descripti6Descripti7Descripti8Descripti9Descripti1Descripti1Descripti2Descripti3Descripti4Descripti5Descripti6Descripti7Descripti8Descripti9Descripti2Descripti1Descripti2Descripti3Descripti4Descripti5Descripti6Descripti7Descripti8Descripti9Descripti3Descripti1Descripti2Descripti3Descripti4Descripti5Descripti6Descripti7Descripti8Descripti9Descripti4Descripti1Descripti2Descripti3Descripti4Descripti5Descripti6Descripti7Descripti8Descripti9Descripti5','Assignees1Assignees2Assignees3','NO_STATUS','2024-04-22 09:00:00','2024-04-22 09:00:00'),
-- ('Repository', null, null,'TO_DO','2024-04-22  09:05:00','2024-04-22 14:00:00'),
-- ('ดาต้าเบส','ສ້າງຖານຂໍ້ມູນ','あなた、彼、彼女 (私ではありません)','DOING','2024-04-22  09:10:00','2024-04-25 00:00:00'),
-- ('_Infrastructure_','_Setup containers_','ไก่งวง กับ เพนกวิน','DONE','2024-04-22 09:15:00','2024-04-22 10:00:00');



# ======== Version 2 ========================================

CREATE TABLE statusV2 (
    statusId INT NOT NULL AUTO_INCREMENT,
    statusName VARCHAR(50) UNIQUE NOT NULL,
    statusDescription TEXT,
    statusColor VARCHAR(7) DEFAULT '#999999',
    is_fixed_status BOOLEAN DEFAULT false,
      constraint `checkStatusV2NameLengthIn_1-50` CHECK (char_length(statusName) <= 50 AND statusName <> ''),
      constraint `checkStatusV2DescriptionLengthIn_1-200` CHECK (char_length(statusDescription) <= 200 AND statusDescription <> ''),
    PRIMARY KEY (statusId)
) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO statusV2 (
    statusName,
    statusDescription,
    statusColor,
    is_fixed_status
)
VALUES 
('No Status', 'A status has not been assigned', '#4b5563', true),
('To Do', 'The task is included in the project', '#ff5861', false),
('In Progress', 'The task is being worked on', '#ffbe00', false),
('Reviewing', 'The task is being reviewed', '#ffbe00', false),
('Testing', 'The task is being tested', '#ffbe00', false),
('Waiting', 'The task is waiting for a resource', '#ffbe00', false),
('Done', 'The task has been completed', '#00a96e', true);

DELIMITER $$

CREATE TRIGGER updateFixedStatusV2
BEFORE UPDATE
ON statusV2
FOR EACH ROW 
BEGIN
	IF OLD.is_fixed_status = true AND NEW.is_fixed_status = true THEN
	SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Cannot update: this status is fixed status cause it cannot update or delete';
	END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER deleteFixedStatusV2
BEFORE DELETE
ON statusV2
FOR EACH ROW 
BEGIN
	IF OLD.is_fixed_status = true THEN
	SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Cannot delete: this status is fixed status cause it cannot update or delete';
	END IF;
END$$

DELIMITER ;

CREATE TABLE boardV2 (
    boardId INT NOT NULL AUTO_INCREMENT,
    is_limit_tasks BOOLEAN default false,
    task_limit_per_status INT default 10,
    PRIMARY KEY (boardId)
) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO boardV2 (
    is_limit_tasks,
    task_limit_per_status
)
VALUES 
(true, 10);

CREATE TABLE taskV2 (
    taskId INT NOT NULL AUTO_INCREMENT,
    taskTitle TEXT NOT NULL,
    taskDescription TEXT,
    taskAssignees TEXT,
    statusId INT,
    boardId INT NOT NULL,
    createdOn TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updatedOn TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL,
      constraint `checkTaskV2TitleLengthIn_1-100` CHECK (char_length(taskTitle) <= 100 AND taskTitle <>''),
      constraint `checkTaskV2DescriptionLengthIn_1-500` CHECK (char_length(taskDescription) <= 500 AND taskDescription<>''),
      constraint `checkTaskV2AssigneesLengthIn_1-30` CHECK (char_length(taskAssignees) <= 30 AND taskAssignees<>''),
    PRIMARY KEY (taskId),
    CONSTRAINT fk_taskV2_statusV2 FOREIGN KEY (`statusId`) REFERENCES `statusV2`(`statusId`),
    CONSTRAINT fk_taskV2_boardV2 FOREIGN KEY (`boardId`) REFERENCES `boardV2`(`boardId`)
) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO taskV2 (
    taskId,
    taskTitle,
    statusId,
    createdOn,
    updatedOn,
    boardId
)
VALUES
(1, 'NS01', 1, '2024-05-14 09:00:00', '2024-05-14 09:00:00', 1),
(2, 'TD01', 2, '2024-05-14 09:10:00', '2024-05-14 09:10:00', 1),
(3, 'IP01', 3, '2024-05-14 09:20:00', '2024-05-14 09:20:00', 1),
(4, 'TD02', 2, '2024-05-14 09:30:00', '2024-05-14 09:30:00', 1),
(5, 'DO01', 7, '2024-05-14 09:40:00', '2024-05-14 09:40:00', 1),
(6, 'IP02', 3, '2024-05-14 09:50:00', '2024-05-14 09:50:00', 1);



# ======== Version 3 ========================================

-- CREATE TABLE userV3 (

-- ) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE boardV3 (
    boardId VARCHAR(10) NOT NULL,
    owner_oid VARCHAR(36) NOT NULL,
    name VARCHAR(120) NOT NULL, 
    is_limit_tasks BOOLEAN DEFAULT false,
    task_limit_per_status INT DEFAULT 10,
    default_statuses_config VARCHAR(5) NULL DEFAULT '11',
    PRIMARY KEY (boardId)
) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE statusV3 (
    statusId INT NOT NULL AUTO_INCREMENT,
    statusName VARCHAR(50) NOT NULL,
    statusDescription TEXT,
    statusColor VARCHAR(7) DEFAULT '#999999',
    is_fixed_status BOOLEAN DEFAULT false,
    boardId VARCHAR(10) NULL,
    CONSTRAINT `checkStatusV3NameInLength_1-50` CHECK (char_length(statusName) <= 50 AND statusName <>''),
    CONSTRAINT `checkStatusV3DescriptionInLength_1-200` CHECK (char_length(statusDescription) <= 200 AND statusDescription<>''),
    PRIMARY KEY (statusId),
    CONSTRAINT fk_statusV3_boardV3 FOREIGN KEY (`boardId`) REFERENCES `boardV3` (`boardId`)
) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DELIMITER $$

CREATE TRIGGER updateFixedStatusV3
BEFORE UPDATE
ON statusV3
FOR EACH ROW 
BEGIN
    IF OLD.is_fixed_status = true AND NEW.is_fixed_status = true THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot update: this status is fixed status cause it cannot update or delete';
    END IF;
END$$

DELIMITER ; 

DELIMITER $$

CREATE TRIGGER deleteFixedStatusV3
BEFORE DELETE
ON statusV3
FOR EACH ROW 
BEGIN
    IF OLD.is_fixed_status = true THEN
	    SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot delete: this status is fixed status cause it cannot update or delete';
    END IF;
END$$

DELIMITER ;

INSERT INTO statusV3 (
    statusName,
    statusDescription,
    statusColor,
    is_fixed_status
)
VALUES 
('No Status', 'A status has not been assigned', '#999999', true),
('To Do','The task is included in the project','#3cb371', false),
('In Progress','The task is being worked on','#ffa500', false),
('Done','The task has been completed','#8142ff', true);

CREATE TABLE taskV3 (
    taskId INT NOT NULL AUTO_INCREMENT,
    taskTitle TEXT NOT NULL,
    taskDescription TEXT,
    taskAssignees TEXT,
    statusId INT NOT NULL,
    boardId VARCHAR(10) NOT NULL,
    createdOn TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updatedOn TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT `checkTaskV3TitleLengthIn_1-100` CHECK (char_length(taskTitle) <= 100 AND taskTitle <>''),
    CONSTRAINT `checkTaskV3DescriptionLengthIn_1-500` CHECK (char_length(taskDescription) <= 500 AND taskDescription<>''),
    CONSTRAINT `checkTaskV3AssigneesLengthIn_1-30` CHECK (char_length(taskAssignees) <= 30 AND taskAssignees<>''),
    CONSTRAINT fk_taskV3_statusV3 FOREIGN KEY (`statusId`) REFERENCES `statusV3`(`statusId`),
    CONSTRAINT fk_taskV3_boardV3 FOREIGN KEY (`boardId`) REFERENCES `boardV3`(`boardId`),
    PRIMARY KEY (taskId)
) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP USER IF EXISTS `itb-kk-be`;
CREATE USER 'itb-kk-be' identified WITH mysql_native_password BY 'itb-kk';
GRANT SELECT, INSERT, UPDATE, DELETE ON `itb-kk`.`taskV1` TO 'itb-kk-be'@'%';  
GRANT SELECT, INSERT, UPDATE, DELETE ON `itb-kk`.`taskV2` TO 'itb-kk-be'@'%';  
GRANT SELECT, INSERT, UPDATE, DELETE ON `itb-kk`.`taskV3` TO 'itb-kk-be'@'%';  
GRANT SELECT, INSERT, UPDATE, DELETE ON `itb-kk`.`statusV2` TO 'itb-kk-be'@'%';  
GRANT SELECT, INSERT, UPDATE, DELETE ON `itb-kk`.`statusV3` TO 'itb-kk-be'@'%';  
GRANT SELECT, INSERT, UPDATE, DELETE ON `itb-kk`.`boardV2` TO 'itb-kk-be'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON `itb-kk`.`boardV3` TO 'itb-kk-be'@'%';

SET autocommit = off; 
COMMIT;
