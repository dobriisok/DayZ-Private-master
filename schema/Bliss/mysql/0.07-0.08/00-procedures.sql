DROP PROCEDURE IF EXISTS `delO`;
CREATE PROCEDURE `proc_deleteObject`(IN `p_UniqueId` VARCHAR(50))
	LANGUAGE SQL
	NOT DETERMINISTIC
	CONTAINS SQL
	SQL SECURITY DEFINER
	COMMENT ''
BEGIN
      DELETE FROM objects WHERE uid=p_UniqueId; --
END;


DROP PROCEDURE IF EXISTS `getLoadout`;
CREATE PROCEDURE `proc_getInstanceLoadout`(IN `p_InstanceId` INT)
	LANGUAGE SQL
	NOT DETERMINISTIC
	CONTAINS SQL
	SQL SECURITY DEFINER
	COMMENT ''
BEGIN
   SELECT loadout FROM instances WHERE instance = p_InstanceId; --
END;


DROP PROCEDURE IF EXISTS `getO`;
CREATE PROCEDURE `proc_getObjects`(IN `p_InstanceId` int, IN `p_CurrentPage` int)
	LANGUAGE SQL
	NOT DETERMINISTIC
	CONTAINS SQL
	SQL SECURITY DEFINER
	COMMENT ''
BEGIN
	DECLARE itemsPerPage INT DEFAULT 5; -- Must match proc_getObjectPageCount
	DECLARE currentOffset INT DEFAULT (itemsPerPage * p_CurrentPage); --
	SELECT id, otype, oid, pos, inventory, health, fuel, damage FROM objects WHERE instance = p_InstanceId LIMIT currentOffset, itemsPerPage; --
END;


DROP PROCEDURE IF EXISTS `getOC`;
CREATE PROCEDURE `proc_getObjectPageCount`(IN `p_InstanceId` int)
	LANGUAGE SQL
	NOT DETERMINISTIC
	CONTAINS SQL
	SQL SECURITY DEFINER
	COMMENT ''
BEGIN
	DECLARE itemsPerPage INT DEFAULT 5; -- Must match proc_getObjects
	SELECT FLOOR(COUNT(*) / itemsPerPage) from objects WHERE instance = p_InstanceId; --
END;


DROP PROCEDURE IF EXISTS `getTasks`;
CREATE PROCEDURE `proc_getSchedulerTasks`(IN `p_InstanceId` int, IN `p_CurrentPage` int)
	LANGUAGE SQL
	NOT DETERMINISTIC
	CONTAINS SQL
	SQL SECURITY DEFINER
	COMMENT ''
BEGIN
	DECLARE itemsPerPage INT DEFAULT 10; -- Must match proc_getSchedulerTaskPageCount
	DECLARE currentOffset INT DEFAULT (itemsPerPage * p_CurrentPage); --
	SELECT message, mtype, looptime, mstart FROM scheduler JOIN instances ON instances.mvisibility = scheduler.visibility WHERE instances.instance = p_InstanceId LIMIT currentOffset, itemsPerPage; --
END;


DROP PROCEDURE IF EXISTS `getTC`;
CREATE PROCEDURE `proc_getSchedulerTaskPageCount`(IN `p_InstanceId` int)
	LANGUAGE SQL
	NOT DETERMINISTIC
	CONTAINS SQL
	SQL SECURITY DEFINER
	COMMENT ''
BEGIN
	DECLARE itemsPerPage INT DEFAULT 10; -- Must match proc_getSchedulerTasks
	SELECT FLOOR(COUNT(*) / itemsPerPage) FROM scheduler JOIN instances ON instances.mvisibility = scheduler.visibility WHERE instances.instance = p_InstanceId; --
END;

DROP PROCEDURE IF EXISTS `getTime`;
CREATE PROCEDURE `proc_getInstanceTime`(IN `p_InstanceID` INT)
	LANGUAGE SQL
	NOT DETERMINISTIC
	CONTAINS SQL
	SQL SECURITY DEFINER
	COMMENT 'Gets the current game time for an instance, respecting the timezone offset as per defined in the instances table.'
BEGIN
	DECLARE server_time DATETIME DEFAULT NOW(); -- Declare a variable to hold the localised server time, the default is NOW() in case the instance param is invalid in the query below.
	SELECT NOW() + INTERVAL (timezone) HOUR INTO server_time FROM instances WHERE instance = p_InstanceID; -- Select the current server DATETIME and modify it by the timezone offset, before stuffing it into the variable, skipped if timezone == null
	SELECT DATE_FORMAT(server_time,'%d-%m-%Y'), TIME_FORMAT(server_time, '%T'); -- Return the results.
END;


DROP PROCEDURE IF EXISTS `insOselI`;
CREATE PROCEDURE `proc_insertObject`(IN `p_ObjectUniqueId` VARCHAR(50), IN `p_ObjectType` VARCHAR(255), IN `p_ObjectHealth` VARCHAR(1024), IN `p_ObjectDamage` DOUBLE, IN `p_ObjectFuel` DOUBLE, IN `p_ObjectOwner` INT, IN `p_ObjectPosition` VARCHAR(255), IN `p_InstanceId` INT)
	LANGUAGE SQL
	NOT DETERMINISTIC
	CONTAINS SQL
	SQL SECURITY DEFINER
	COMMENT 'Inserts a new object into the Database'
BEGIN
	INSERT INTO objects (uid,otype,health,damage,oid,pos,fuel,instance) VALUES (p_ObjectUniqueId, p_ObjectType, p_ObjectHealth, p_ObjectDamage, p_ObjectOwner, p_ObjectPosition, p_ObjectFuel, p_InstanceId); --
END;

DROP PROCEDURE IF EXISTS `insUNselI`;
CREATE PROCEDURE `proc_insertPlayer`(IN `p_PlayerUniqueId` varchar(128), IN `p_PlayerName` varchar(255))
	LANGUAGE SQL
	NOT DETERMINISTIC
	CONTAINS SQL
	SQL SECURITY DEFINER
	COMMENT ''
BEGIN
	INSERT INTO main (uid, name, survival) VALUES (p_PlayerUniqueId, p_PlayerName, NOW()); --
	SELECT LAST_INSERT_ID(); --
END;

DROP PROCEDURE IF EXISTS `logLogin`;
CREATE PROCEDURE `proc_logLogin`(IN `p_PlayerUniqueId` varchar(50))
	LANGUAGE SQL
	NOT DETERMINISTIC
	CONTAINS SQL
	SQL SECURITY DEFINER
	COMMENT ''
BEGIN
	INSERT INTO log_entry (profile_id, log_code_id) VALUES (p_PlayerUniqueId, 1); --
END;


DROP PROCEDURE IF EXISTS `logLogout`;
CREATE PROCEDURE `proc_logLogout`(IN `p_PlayerUniqueId` varchar(50))
	LANGUAGE SQL
	NOT DETERMINISTIC
	CONTAINS SQL
	SQL SECURITY DEFINER
	COMMENT ''
BEGIN
	INSERT INTO log_entry (profile_id, log_code_id) VALUES (p_PlayerUniqueId, 2); --
END;


DROP PROCEDURE IF EXISTS `selIIBSM`;
CREATE PROCEDURE `proc_getPlayer`(IN `p_PlayerUniqueId` varchar(128), IN `p_PlayerName` VARCHAR(128))
	LANGUAGE SQL
	NOT DETERMINISTIC
	CONTAINS SQL
	SQL SECURITY DEFINER
	COMMENT 'Select ID, Inventory, Backpack, Survival Time and Model.'
BEGIN 
	UPDATE main SET name = p_PlayerName WHERE uid = p_PlayerUniqueId; --
	SELECT id, inventory, backpack, FLOOR(TIME_TO_SEC(TIMEDIFF(NOW(), survival))/60), model, late, ldrank FROM main WHERE uid = p_PlayerUniqueId AND death = 0; --
END;



DROP PROCEDURE IF EXISTS `selMPSSH`;
CREATE PROCEDURE `proc_getPlayerStats`(IN `p_PlayerID` INT)
	LANGUAGE SQL
	NOT DETERMINISTIC
	CONTAINS SQL
	SQL SECURITY DEFINER
	COMMENT ''
BEGIN
      SELECT medical, pos, kills, state, humanity, hs, hkills, bkills FROM main WHERE id = p_PlayerID AND death=0; --
END;


DROP PROCEDURE IF EXISTS `setCD`;
CREATE PROCEDURE `proc_setPlayerDead`(IN `p_PlayerId` INT)
	LANGUAGE SQL
	NOT DETERMINISTIC
	CONTAINS SQL
	SQL SECURITY DEFINER
	COMMENT ''
BEGIN
      UPDATE main SET death=1 WHERE id = p_PlayerId; --
END;

DROP PROCEDURE IF EXISTS `update`;
CREATE PROCEDURE `proc_updatePlayer`(IN `p_PlayerId` int, IN `p_PlayerPositon` varchar(1024), IN `p_PlayerInventory` varchar(2048), IN `p_PlayerBackpack` varchar(2048), IN `p_PlayerMedicalStatus` varchar(1024), IN `p_PlayerLastAte` int, IN `p_PlayerLastDrank` int, IN `p_PlayerSurvivalTime` int, IN `p_PlayerModel` varchar(255), IN `p_PlayerHumanity` int, IN `p_PlayerZombieKills` int, IN `p_PlayerHeadshots` int, IN `p_PlayerMurders` int, IN `p_PlayerBanditKills` int, IN `p_PlayerState` varchar(255))
	LANGUAGE SQL
	NOT DETERMINISTIC
	CONTAINS SQL
	SQL SECURITY DEFINER
	COMMENT ''
BEGIN
	UPDATE main SET
		kills=kills+p_PlayerZombieKills,
		hs=hs+p_PlayerHeadshots,
		bkills=bkills+p_PlayerBanditKills,
		hkills=hkills+p_PlayerMurders,
		state=p_PlayerState,
		model=IF(p_PlayerModel='any',model,p_PlayerModel),
		late=IF(p_PlayerLastAte=-1,0,late+p_PlayerLastAte),
		ldrank=IF(p_PlayerLastDrank<-1,0,ldrank+p_PlayerLastDrank),
		stime=stime+p_PlayerSurvivalTime,
		pos=IF(p_PlayerPositon='[]', pos, p_PlayerPositon),
		humanity=IF(p_PlayerHumanity=0, humanity, p_PlayerHumanity),
		medical=IF(p_PlayerMedicalStatus='[]', medical, p_PlayerMedicalStatus),
		backpack=IF(p_PlayerBackpack='[]', backpack, p_PlayerBackpack),
		inventory=IF(p_PlayerInventory='[]', inventory, p_PlayerInventory)
	WHERE id = p_PlayerId; --
END;

DROP PROCEDURE IF EXISTS `updIH`;
CREATE PROCEDURE `proc_updateObjectHealth`(IN `p_ObjectId` INT, IN `p_ObjectHealth` VARCHAR(1024), IN `p_ObjectDamage` DOUBLE)
	LANGUAGE SQL
	NOT DETERMINISTIC
	CONTAINS SQL
	SQL SECURITY DEFINER
	COMMENT ''
BEGIN
	UPDATE objects SET health=p_ObjectHealth,damage=p_ObjectDamage WHERE id=p_ObjectId; --
END;


DROP PROCEDURE IF EXISTS `updII`;
CREATE PROCEDURE `proc_updateObjectInventory`(IN `p_ObjectId` int, IN `p_ObjectInventory` varchar(1024))
	LANGUAGE SQL
	NOT DETERMINISTIC
	CONTAINS SQL
	SQL SECURITY DEFINER
	COMMENT ''
BEGIN
	UPDATE objects SET inventory=p_ObjectInventory WHERE id = p_ObjectId; --
END;


DROP PROCEDURE IF EXISTS `updIPF`;
CREATE PROCEDURE `proc_updateObjectPosition`(IN `p_ObjectId` INT, IN `p_ObjectPosition` VARCHAR(255), IN `p_ObjectFuel` DOUBLE)
	LANGUAGE SQL
	NOT DETERMINISTIC
	CONTAINS SQL
	SQL SECURITY DEFINER
	COMMENT ''
BEGIN
	UPDATE objects SET pos=if(p_ObjectPosition='[]', pos, p_ObjectPosition),fuel=p_ObjectFuel WHERE id = p_ObjectId; --
END;


DROP PROCEDURE IF EXISTS `updUI`;
CREATE PROCEDURE `proc_updateObjectInventoryByUID`(IN `p_ObjectUniqueId` varchar(50), IN `p_ObjectInventory` varchar(8192))
	LANGUAGE SQL
	NOT DETERMINISTIC
	CONTAINS SQL
	SQL SECURITY DEFINER
	COMMENT ''
BEGIN
	UPDATE objects SET inventory = p_ObjectInventory WHERE uid NOT LIKE '%.%' AND (CONVERT(uid, UNSIGNED INTEGER) BETWEEN (CONVERT(p_ObjectUniqueId, UNSIGNED INTEGER) - 2) AND (CONVERT(p_ObjectUniqueId, UNSIGNED INTEGER) + 2)); --
END;


DROP PROCEDURE IF EXISTS `updV`;
CREATE PROCEDURE `proc_updateObject`(IN `p_ObjectUniqueId` VARCHAR(50), IN `p_ObjectType` VARCHAR(255) , IN `p_ObjectPosition` VARCHAR(255), IN `p_ObjectHealth` VARCHAR(1024))
	LANGUAGE SQL
	NOT DETERMINISTIC
	CONTAINS SQL
	SQL SECURITY DEFINER
	COMMENT ''
BEGIN
	UPDATE objects SET otype=if(p_ObjectType='',otype,p_ObjectType),health=p_ObjectHealth,pos=if(p_ObjectPosition='[]', pos, p_ObjectPosition) WHERE uid=p_ObjectUniqueId; --
END;


DROP PROCEDURE `selIPIBMSSS`;
