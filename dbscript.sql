use `itb-kk`;

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
      constraint `checkTaskTitle_v1_LengthIn_1-100` CHECK (char_length(taskTitle) <= 100 AND taskTitle <>''),
      constraint `checkMaxTaskDescription_v1_LengthIn_1-500` CHECK (char_length(taskDescription) <= 500 AND taskDescription<>''),
      constraint `checkMaxTaskAssignees_v1_LengthIn_1-30` CHECK (char_length(taskAssignees) <= 30 AND taskAssignees<>''),
    PRIMARY KEY (taskId)
) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;



CREATE TABLE status (
    statusId INT NOT NULL AUTO_INCREMENT,
    statusName VARCHAR(50) UNIQUE NOT NULL,
    statusDescription TEXT,
    statusColor VARCHAR(7) DEFAULT '#999999',
    is_fixed_status BOOLEAN DEFAULT false,
      constraint `checkStatusNameLengthIn_1-50` CHECK (char_length(statusName) <= 50 AND statusName <>''),
      constraint `checkMaxStatusDescription_1-200` CHECK (char_length(statusDescription) <= 200 AND statusDescription<>''),
    PRIMARY KEY (statusId)
) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


DROP TRIGGER IF EXISTS updateFixedStatus;
show triggers;

CREATE TRIGGER updateFixedStatus
BEFORE UPDATE
ON status
FOR EACH ROW 
BEGIN
	IF OLD.is_fixed_status = true AND NEW.is_fixed_status = true THEN
	SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Cannot update: this status is fixed status cause it cannot update or delete';
	END IF;
END;


DROP TRIGGER IF EXISTS deleteFixedStatus;

CREATE TRIGGER deleteFixedStatus
BEFORE DELETE
ON status
FOR EACH ROW 
BEGIN
	IF OLD.is_fixed_status = true THEN
	SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Cannot delete: this status is fixed status cause it cannot update or delete';
	END IF;
END;

INSERT INTO status (
    statusName,
    statusDescription,
    statusColor,
    is_fixed_status
)
VALUES 
('No Status', 'The default status', '#4b5563', true),
('Done','Finished','#00a96e', true);



CREATE TABLE board (
    boardId INT NOT NULL AUTO_INCREMENT,
    is_limit_tasks BOOLEAN default false,
    task_limit_per_status INT default 10,
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
      constraint `checkTaskTitle_v2_LengthIn_1-100` CHECK (char_length(taskTitle) <= 100 AND taskTitle <>''),
      constraint `checkMaxTaskDescription_v2_LengthIn_1-500` CHECK (char_length(taskDescription) <= 500 AND taskDescription<>''),
      constraint `checkMaxTaskAssignees_v2_LengthIn_1-30` CHECK (char_length(taskAssignees) <= 30 AND taskAssignees<>''),
    PRIMARY KEY (taskId),
    CONSTRAINT taskStatus FOREIGN KEY (`statusId`) REFERENCES `status`(`statusId`),
    CONSTRAINT taskBoard FOREIGN KEY (`boardId`) REFERENCES `board`(`boardId`)
) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

set autocommit = off; 
commit;
