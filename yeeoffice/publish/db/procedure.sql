USE yungalaxy_merchant_102;

DELIMITER $$


DROP PROCEDURE IF EXISTS YeeOffice_Document_DocFav_Add$$

CREATE DEFINER = 'yeeoffice_uatdba'@'%'
PROCEDURE YeeOffice_Document_DocFav_Add(_AccountID BIGINT(20), 
	_UserName VARCHAR(500), 
	_Created datetime, 
	_CreatBy VARCHAR(500), 
	_CreatByUserName VARCHAR(500), 
	_CreatBySPUserName VARCHAR(500), 
	_TenantID BIGINT(20), 
	_ID BIGINT(20), 
	_YGDocSPGUID VARCHAR(500))
BEGIN
	DECLARE _YGDocURL VARCHAR(2500);
	DECLARE _YGDocName VARCHAR(255);
	DECLARE _YGLibSPGUID VARCHAR(255);
	DECLARE _SiteURL VARCHAR(255);

	SELECT  YGDocURL,YGDocName,YGLibSPGUID,SiteURL INTO _YGDocURL,_YGDocName, _YGLibSPGUID,_SiteURL
	FROM yeeoffice_doc_info
	WHERE YGDocSPGUID = _YGDocSPGUID
	LIMIT 0, 1;

	INSERT INTO yeeoffice_doc_favorites (OperationTime, AccountID, UserName, Created, CreatBy
		, CreatByUserName, CreatBySPUserName, TenantID, ID, YGDocURL
		, YGDocName, YGDocSPGUID, YGLibSPGUID, SiteURL)
	VALUES (_Created, _AccountID, _UserName, _Created, _CreatBy
		, _CreatByUserName, _CreatBySPUserName, _TenantID, _ID, _YGDocURL
		, _YGDocName, _YGDocSPGUID, _YGLibSPGUID, _SiteURL);
END
$$

DELIMITER ;

DELIMITER $$


DROP PROCEDURE IF EXISTS YeeOffice_Document_DocFav_Del$$

CREATE DEFINER = 'yeeoffice_uatdba'@'%'
PROCEDURE YeeOffice_Document_DocFav_Del(_TenantID BIGINT(20),
  _YGDocSPGUID VARCHAR(500))
BEGIN
   DELETE
    FROM yeeoffice_doc_favorites
    WHERE YGDocSPGUID=_YGDocSPGUID AND TenantID=_TenantID;
  END
$$

DELIMITER ;

DELIMITER $$


DROP PROCEDURE IF EXISTS YeeOffice_Document_DocFav_GetMyFav$$

CREATE DEFINER = 'yeeoffice_uatdba'@'%'
PROCEDURE YeeOffice_Document_DocFav_GetMyFav(
IN _PageIndex int,
IN _PageSize int,
IN _AccountID varchar(100)
)
BEGIN
  SET _PageIndex = _PageIndex  * _PageSize;
  SELECT *,(  SELECT COUNT(*) FROM yeeoffice_doc_favorites ydf
    WHERE
    ydf.AccountID=_AccountID 
    AND (SELECT COUNT(*) FROM yeeoffice_doc_info ydi WHERE  ydf.YGDocSPGUID=ydf.YGDocSPGUID AND ydi.IsDelete=0)>0) AS TotalNum FROM yeeoffice_doc_favorites ydf
    WHERE
    ydf.AccountID=_AccountID
    AND (SELECT COUNT(*) FROM yeeoffice_doc_info ydi WHERE  ydf.YGDocSPGUID=ydf.YGDocSPGUID AND ydi.IsDelete=0)>0
    ORDER BY ydf.OperationTime DESC
    LIMIT _PageIndex, _PageSize;
  END
$$

DELIMITER ;

DELIMITER $$


DROP PROCEDURE IF EXISTS YeeOffice_Document_DocFav_Select$$

CREATE DEFINER = 'yeeoffice_uatdba'@'%'
PROCEDURE YeeOffice_Document_DocFav_Select(_TenantID bigint(20),
_YGDocSPGUID text)
BEGIN

    SELECT 
    distinct YGDocSPGUID,
    1 AS `Status` 
    FROM yeeoffice_doc_favorites 
    WHERE FIND_IN_SET(YGDocSPGUID,_YGDocSPGUID) AND TenantID= _TenantID;

END
$$

DELIMITER ;

DELIMITER $$


DROP PROCEDURE IF EXISTS YeeOffice_Document_DocInfo_DelBySPGUID$$

CREATE DEFINER = 'yeeoffice_uatdba'@'%'
PROCEDURE YeeOffice_Document_DocInfo_DelBySPGUID(_TenantID bigint(20),
_YGDocSPGUID text,
_RecycleBinItemID varchar(500),
_DeletedBy bigint(20),
_Deleted datetime)
BEGIN

  UPDATE yeeoffice_doc_info
  SET RecycleBinItemID = _RecycleBinItemID,
      IsDelete = TRUE,
      DeletedBy = _DeletedBy,
      Deleted = _Deleted
  WHERE FIND_IN_SET(YGDocSPGUID, _YGDocSPGUID) AND TenantID = _TenantID;

END
$$

DELIMITER ;

DELIMITER $$


DROP PROCEDURE IF EXISTS YeeOffice_Document_DocInfo_DelRecycle$$

CREATE DEFINER = 'yeeoffice_uatdba'@'%'
PROCEDURE YeeOffice_Document_DocInfo_DelRecycle(
  _TenantID BIGINT(20),
  _YGDocIDList TEXT
)
BEGIN
DELETE FROM yeeoffice_doc_info WHERE FIND_IN_SET(YGDocID,_YGDocIDList) AND TenantID=_TenantID;
  
  END
$$

DELIMITER ;

DELIMITER $$


DROP PROCEDURE IF EXISTS YeeOffice_Document_DocInfo_EmptyRecycle$$

CREATE DEFINER = 'yeeoffice_uatdba'@'%'
PROCEDURE YeeOffice_Document_DocInfo_EmptyRecycle(
  _TenantID BIGINT(20),
  _CreatBy BIGINT(20)
)
BEGIN
   DELETE FROM yeeoffice_doc_info
    WHERE _CreatBy =_CreatBy AND TenantID=_TenantID;
  END
$$

DELIMITER ;

DELIMITER $$


DROP PROCEDURE IF EXISTS YeeOffice_Document_DocInfo_Insert$$

CREATE DEFINER = 'yeeoffice_uatdba'@'%'
PROCEDURE YeeOffice_Document_DocInfo_Insert(_Created datetime,
_CreatBy varchar(500),
_YGDocDesc varchar(500),
_YGDocURL varchar(500),
_YGDocSize varchar(500),
_YGDocFolderUrl varchar(500),
_YGDocID bigint(20),
_TenantID bigint(20),
_YGDocSPGUID varchar(500),
_YGDocName varchar(500),
_RecycleBinItemID varchar(500),
_YGLibSPGUID varchar(500),
_YGDocLibID bigint(20),
_SiteURL varchar(500))
BEGIN

  DECLARE HASFILE int;
  SELECT
    COUNT(*) INTO HASFILE
  FROM yeeoffice_doc_info ydi
  WHERE ydi.YGDocSPGUID = _YGDocSPGUID;
  IF HASFILE <> 0
    THEN
    DELETE
      FROM yeeoffice_doc_info
    WHERE YGDocID
      = (SELECT
          ydi.YGDocID
        FROM yeeoffice_doc_info ydi
        WHERE ydi.YGDocSPGUID = _YGDocSPGUID LIMIT 0, 1);
  END IF;


  INSERT INTO yeeoffice_doc_info (YGDocID, CreatBy, YGDocDesc, YGDocURL, YGDocSize
  , YGDocFolderUrl, TenantID, YGDocSPGUID, YGDocName, RecycleBinItemID
  , YGLibSPGUID, YGDocLibID, SiteURL, Created, IsDelete)
    VALUES (_YGDocID, _CreatBy, _YGDocDesc, _YGDocURL, _YGDocSize, _YGDocFolderUrl, _TenantID, _YGDocSPGUID, _YGDocName, _RecycleBinItemID, _YGLibSPGUID, _YGDocLibID, _SiteURL, _Created, FALSE);
END
$$

DELIMITER ;

DELIMITER $$


DROP PROCEDURE IF EXISTS YeeOffice_Document_DocInfo_Rename$$

CREATE DEFINER = 'yeeoffice_uatdba'@'%'
PROCEDURE YeeOffice_Document_DocInfo_Rename(_TenantID BIGINT(20),
  _YGDocSPGUID varchar(255),
  _YGDocName varchar(255))
BEGIN
    set @docoldurl='';
     set @docnewurl = '';
    set @docoldname ='';
    SELECT YGDocURL,YGDocName INTO @docoldurl, @docoldname  FROM yeeoffice_doc_info yde where yde.YGDocSPGUID=_YGDocSPGUID;

    SET @docnewurl=REPLACE(@docoldurl,@docoldname,_YGDocName);
    UPDATE yeeoffice_doc_info ydi SET ydi.YGDocName=_YGDocName, ydi.YGDocURL= @docnewurl WHERE ydi.YGDocSPGUID=_YGDocSPGUID;
END
$$

DELIMITER ;

DELIMITER $$


DROP PROCEDURE IF EXISTS YeeOffice_Document_DocInfo_RestoreRecycle$$

CREATE DEFINER = 'yeeoffice_uatdba'@'%'
PROCEDURE YeeOffice_Document_DocInfo_RestoreRecycle(_TenantID BIGINT(20),
  _YGDocSPGUID varchar(255))
BEGIN
SET @where = CONCAT(' where ydi.YGDocID in (', _YGDocSPGUID,')');
  SET @querySqlStr = CONCAT('UPDATE yeeoffice_doc_info ydi SET ydi.IsDelete=false',@where);
  PREPARE stmt FROM @querySqlStr;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
END
$$

DELIMITER ;

DELIMITER $$


DROP PROCEDURE IF EXISTS YeeOffice_Document_DocInfo_restoreSelectItems$$

CREATE DEFINER = 'yeeoffice_uatdba'@'%'
PROCEDURE YeeOffice_Document_DocInfo_restoreSelectItems(_TenantID BIGINT(20),_RestoreSelectItems varchar(255))
BEGIN
  SELECT * from yeeoffice_doc_info  where FIND_IN_SET(YGDocID,_RestoreSelectItems);
	#Routine body goes here...
  UPDATE yeeoffice_doc_info ydi SET ydi.IsDelete=0 WHERE FIND_IN_SET(YGDocID,_RestoreSelectItems)AND ydi.TenantID=_TenantID;
END
$$

DELIMITER ;

DELIMITER $$


DROP PROCEDURE IF EXISTS YeeOffice_Document_DocLibraryOwner_Delete$$

CREATE DEFINER = 'yeeoffice_uatdba'@'%'
PROCEDURE YeeOffice_Document_DocLibraryOwner_Delete(_YGDocLibID bigint(20))
BEGIN
	delete from yeeoffice_doc_libraryowner where  YGDocLibID = _YGDocLibID;
END
$$

DELIMITER ;

DELIMITER $$


DROP PROCEDURE IF EXISTS YeeOffice_Document_DocLibraryOwner_Insert$$

CREATE DEFINER = 'yeeoffice_uatdba'@'%'
PROCEDURE YeeOffice_Document_DocLibraryOwner_Insert(
  _ID bigint(20),
  _YGDocLibID bigint(20),
  _YGDocLibOwner bigint(20),
  _Created datetime,
  _CreatBy bigint(20),
  _Modified datetime,
  _ModifyBy bigint(20),
  _TenantID bigint(20),
  _SPAccoutID varchar(200)
)
BEGIN
INSERT INTO `yeeoffice_doc_libraryowner`(ID,YGDocLibID,YGDocLibOwner,Created,CreatBy,Modified,ModifyBy,TenantID,SPAccoutID)
VALUES
(_ID,_YGDocLibID,_YGDocLibOwner,_Created,_CreatBy,_Modified,_ModifyBy,_TenantID,_SPAccoutID)
;

END
$$

DELIMITER ;

DELIMITER $$


DROP PROCEDURE IF EXISTS YeeOffice_Document_DocLibraryOwner_Select$$

CREATE DEFINER = 'yeeoffice_uatdba'@'%'
PROCEDURE YeeOffice_Document_DocLibraryOwner_Select(
_YGDocLibID varchar(255)
)
BEGIN

  select * from yeeoffice_doc_libraryowner ydl where YGDocLibID=_YGDocLibID;

END
$$

DELIMITER ;

DELIMITER $$


DROP PROCEDURE IF EXISTS YeeOffice_Document_DocLibrary_Delete$$

CREATE DEFINER = 'yeeoffice_uatdba'@'%'
PROCEDURE YeeOffice_Document_DocLibrary_Delete(_YGDocLibID bigint(20))
BEGIN
	delete from yeeoffice_doc_library where YGDocLibID = _YGDocLibID;
END
$$

DELIMITER ;

DELIMITER $$


DROP PROCEDURE IF EXISTS YeeOffice_Document_DocLibrary_GetByPage$$

CREATE DEFINER = 'yeeoffice_uatdba'@'%'
PROCEDURE YeeOffice_Document_DocLibrary_GetByPage(IN _BeginIndex int, IN _PageSize int, IN _YGDocPropID varchar(255), 
  IN _libName varchar(255), IN _TenantID bigint(20))
BEGIN

SET _BeginIndex = _BeginIndex * _PageSize;


SET @WHERE = ' where 1=1 ';


SET @WHERE = CONCAT(
	@WHERE,
	' and dl.TenantID = ',
	_TenantID
);


IF _libName <> "" THEN

SET @WHERE = CONCAT(
	@WHERE,
	' and dl.YGDocLibName like "%',
	_libName,
	'%"'
);


END
IF;


IF _YGDocPropID <> "" THEN

SET @WHERE = CONCAT(
	@WHERE,
	' and dl.YGDocPropID in (',
	_YGDocPropID,
	')'
);


END
IF;


SET @querySqlStr = CONCAT(
	'
SELECT 
    0 AS TotalNum
    ,YGDocLibID
    ,YGDocLibName
    ,YGDocLibDesc
    ,YGDocPropID
    ,CreatBy
    ,Created
    ,ModifyBy
    ,Modified
    ,YGPropName
    ,YGDocLibImage
    ,YGDocLibManager
    ,YGDocLibPath
    ,YGDocLibType
    ,YGDocLibGUID
    ,YGDocLibCapacity
    ,YGDocLibFileSizeControl
    ,YGDocLibStaticName
    ,IsIcon
    ,CompetenceID
    ,DocNum
    ,FolderNum                                                                                                                                                                                                                        
     FROM (
          SELECT 
          dl.YGDocLibID
          ,dl.YGDocLibName
          ,dl.YGDocLibDesc
          ,dl.YGDocPropID
          ,dl.CreatBy
          ,dl.Created
          ,dl.ModifyBy
          ,dl.Modified
          ,dpt.YGPropName
          ,dl.YGDocLibImage
          ,dl.YGDocLibManager
          ,dl.YGDocLibPath
          ,dpt.YGPropName as YGDocLibType
          ,dl.YGDocLibGUID
          ,dl.YGDocLibCapacity
          ,dl.YGDocLibFileSizeControl
          ,dl.YGDocLibStaticName
          ,dl.IsIcon
          ,0 AS CompetenceID
          ,0 as DocNum
          ,0 as FolderNum
          FROM yeeoffice_doc_library dl
          LEFT JOIN yeeoffice_doc_proptype dpt ON dl.YGDocPropID = dpt.YGDocPropID' ,@WHERE,
	') AS result 
ORDER BY Created DESC  
LIMIT ',
	CEIL(_BeginIndex),
	',',
	CEIL(_PageSize)
);

PREPARE stmt
FROM
	@querySqlStr;

EXECUTE stmt;

DEALLOCATE PREPARE stmt;


END
$$

DELIMITER ;

DELIMITER $$


DROP PROCEDURE IF EXISTS YeeOffice_Document_DocLibrary_GetByPage_backup$$

CREATE DEFINER = 'yeeoffice_uatdba'@'%'
PROCEDURE YeeOffice_Document_DocLibrary_GetByPage_backup(IN _BeginIndex int, IN _PageSize int, IN _where varchar(255), 
  IN _libName varchar(255), IN _TenantID bigint(20))
BEGIN  
-- _BeginIndex 前端默认传的第一页是0，所以这里要�?
SET	_BeginIndex=_BeginIndex+1;
SET _BeginIndex = (_BeginIndex - 1) * _PageSize;

SET @where = ' where 1=1 ';
SET @where = CONCAT(@where,' and dl.TenantID = ', _TenantID);
IF _libName <> "" THEN
   SET @where = CONCAT(@where,' and dl.YGDocLibName like "%', _libName,'%"');
END IF;

IF _where <> "" THEN
   SET @where = CONCAT(@where,' and dl.YGDocPropID in (', _where,')');
END IF;

  
SET @querySqlStr = CONCAT('
SELECT 
  (SELECT
     COUNT(1)
   FROM (
    SELECT 
      dl.YGDocLibID  
    FROM yeeoffice_doc_library dl
    LEFT JOIN yeeoffice_doc_proptype dpt ON dl.YGDocPropID = dpt.YGDocPropID 
    LEFT JOIN (SELECT COUNT(1) AS num,YGDocLibID FROM yeeoffice_doc_info
               WHERE  LENGTH(YGDocURL) > 0 AND IsDelete <> 1 GROUP By YGDocLibID) Doc ON dl.YGDocLibID=Doc.YGDocLibID
    LEFT JOIN (SELECT COUNT(1) AS num,YGDocLibID FROM yeeoffice_doc_info
               WHERE  LENGTH(YGDocURL) = 0 AND IsDelete <> 1 GROUP By YGDocLibID) Folder ON dl.YGDocLibID=Folder.YGDocLibID ',@where,
        ') AS result
   ) AS TotalNum
    ,YGDocLibID
    ,YGDocLibName
    ,YGDocLibDesc
    ,YGDocPropID
    ,CreatBy
    ,Created
    ,ModifyBy
    ,Modified
    ,YGPropName
    ,YGDocLibImage
    ,YGDocLibManager
    ,YGDocLibPath
    ,YGDocLibType
    ,YGDocLibGUID
    ,YGDocLibCapacity
    ,YGDocLibFileSizeControl
    ,YGDocLibStaticName
    ,IsIcon
    ,CompetenceID
    ,DocNum
    ,FolderNum                                                                                                                                                                                                                        
     FROM (
          SELECT 
          dl.YGDocLibID
          ,dl.YGDocLibName
          ,dl.YGDocLibDesc
          ,dl.YGDocPropID
          ,dl.CreatBy
          ,dl.Created
          ,dl.ModifyBy
          ,dl.Modified
          ,dpt.YGPropName
          ,dl.YGDocLibImage
          ,dl.YGDocLibManager
          ,dl.YGDocLibPath
          ,dpt.YGPropName as YGDocLibType
          ,dl.YGDocLibGUID
          ,dl.YGDocLibCapacity
          ,dl.YGDocLibFileSizeControl
          ,dl.YGDocLibStaticName
          ,dl.IsIcon
          ,3 AS CompetenceID
          ,(case when Doc.num IS NULL THEN 0
                  else Doc.num end)as DocNum
          ,(case when Folder.num IS NULL THEN 0
                  else Folder.num end) as FolderNum
          FROM yeeoffice_doc_library dl
          LEFT JOIN yeeoffice_doc_proptype dpt ON dl.YGDocPropID = dpt.YGDocPropID 
          LEFT JOIN (SELECT COUNT(1) AS num,YGDocLibID FROM yeeoffice_doc_info
                WHERE  LENGTH(YGDocURL) > 0 AND IsDelete <> 1 GROUP By YGDocLibID) Doc ON dl.YGDocLibID=Doc.YGDocLibID
          LEFT JOIN (SELECT COUNT(1) AS num,YGDocLibID FROM yeeoffice_doc_info
                WHERE  LENGTH(YGDocURL) = 0 AND IsDelete <> 1 GROUP By YGDocLibID) Folder ON dl.YGDocLibID=Folder.YGDocLibID ',@where,
          ') AS result 
ORDER BY Created DESC  
LIMIT ', CEIL(_BeginIndex), ',', CEIL(_PageSize));

PREPARE stmt FROM @querySqlStr;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

END
$$

DELIMITER ;

DELIMITER $$


DROP PROCEDURE IF EXISTS YeeOffice_Document_DocLibrary_GetItem$$

CREATE DEFINER = 'yeeoffice_uatdba'@'%'
PROCEDURE YeeOffice_Document_DocLibrary_GetItem(
_YGDocLibID varchar(255)
)
BEGIN

  select * from yeeoffice_doc_library where YGDocLibID=_YGDocLibID;

END
$$

DELIMITER ;

DELIMITER $$


DROP PROCEDURE IF EXISTS YeeOffice_Document_DocLibrary_Insert$$

CREATE DEFINER = 'yeeoffice_uatdba'@'%'
PROCEDURE YeeOffice_Document_DocLibrary_Insert(
  _YGDocLibID bigint(20),
  _YGDocLibName varchar(50),
  _YGDocLibDesc varchar(250),
  _YGDocPropID bigint(20),
  _CreatBy bigint(20),
  _Created datetime,
  _ModifyBy bigint(20),
  _Modified datetime,
  _YGDocLibImage varchar(500),
  _YGDocLibManager varchar(50),
  _YGDocLibPath mediumtext,
  _YGDocLibType varchar(200),
  _YGDocLibGUID varchar(50),
  _YGDocLibCapacity varchar(100),
  _YGDocLibFileSizeControl varchar(100),
  _YGDocLibStaticName varchar(50),
  _TenantID bigint(20),
  _IsIcon bit(1)
)
BEGIN
INSERT INTO `yeeoffice_doc_library`(YGDocLibID,YGDocLibName,YGDocLibDesc,YGDocPropID,CreatBy,Created,ModifyBy,Modified,YGDocLibImage,YGDocLibManager,YGDocLibPath,
  YGDocLibType,YGDocLibGUID,YGDocLibCapacity,YGDocLibFileSizeControl,YGDocLibStaticName,TenantID,IsIcon)
VALUES
(_YGDocLibID,_YGDocLibName,_YGDocLibDesc,_YGDocPropID,_CreatBy,_Created,_ModifyBy,_Modified,_YGDocLibImage,_YGDocLibManager,_YGDocLibPath,
  _YGDocLibType,_YGDocLibGUID,_YGDocLibCapacity,_YGDocLibFileSizeControl,_YGDocLibStaticName,_TenantID,_IsIcon)
    ON DUPLICATE KEY UPDATE YGDocLibName=_YGDocLibName,YGDocLibDesc=_YGDocLibDesc,YGDocPropID=_YGDocPropID,ModifyBy=_ModifyBy,Modified=_Modified,
YGDocLibImage=_YGDocLibImage,YGDocLibManager=_YGDocLibManager,YGDocLibPath=_YGDocLibPath,YGDocLibType=_YGDocLibType,YGDocLibCapacity=_YGDocLibCapacity,
  YGDocLibFileSizeControl=_YGDocLibFileSizeControl,YGDocLibStaticName=_YGDocLibStaticName,IsIcon=_IsIcon
;

END
$$

DELIMITER ;

DELIMITER $$


DROP PROCEDURE IF EXISTS YeeOffice_Document_DocProptype_Delete$$

CREATE DEFINER = 'yeeoffice_uatdba'@'%'
PROCEDURE YeeOffice_Document_DocProptype_Delete(_YGDocPropID bigint(20))
BEGIN
	delete from yeeoffice_doc_proptype where YGDocPropID = _YGDocPropID;
END
$$

DELIMITER ;

DELIMITER $$


DROP PROCEDURE IF EXISTS YeeOffice_Document_DocProptype_Insert$$

CREATE DEFINER = 'yeeoffice_uatdba'@'%'
PROCEDURE YeeOffice_Document_DocProptype_Insert(
  _YGDocPropID bigint(20),
  _YGPropName varchar(500),
  _YGPropertyTypeOrder INT(11),
  _CreatBy bigint(20),
  _Created datetime,
  _ModifyBy bigint(20),
  _Modified datetime,
  _YGDocCategoryContent varchar(500),
  _DocPropParentID bigint(20),
  _TenantID bigint(20)
)
BEGIN
INSERT INTO `yeeoffice_doc_proptype`(YGDocPropID,YGPropName,YGPropertyTypeOrder,CreatBy,Created,ModifyBy,Modified,YGDocCategoryContent,DocPropParentID,TenantID)
VALUES
(_YGDocPropID,_YGPropName,_YGPropertyTypeOrder,_CreatBy,_Created,_ModifyBy,_Modified,_YGDocCategoryContent,_DocPropParentID,_TenantID)
    ON DUPLICATE KEY UPDATE YGPropName=_YGPropName,ModifyBy=_ModifyBy,Modified=_Modified
;

END
$$

DELIMITER ;

DELIMITER $$


DROP PROCEDURE IF EXISTS YeeOffice_Document_DocProptype_Select$$

CREATE DEFINER = 'yeeoffice_uatdba'@'%'
PROCEDURE YeeOffice_Document_DocProptype_Select(
_YGDocPropID varchar(255)
)
BEGIN

  select * from yeeoffice_doc_library where YGDocPropID=_YGDocPropID;

END
$$

DELIMITER ;

DELIMITER $$


DROP PROCEDURE IF EXISTS YeeOffice_Document_DocProptype_SelectAll$$

CREATE DEFINER = 'yeeoffice_uatdba'@'%'
PROCEDURE YeeOffice_Document_DocProptype_SelectAll(
_TenantID bigint(20)
)
BEGIN

  select 
    *,
(  select 
    COUNT(1)
    from yeeoffice_doc_proptype where YGDocPropID!=0 AND TenantID=_TenantID) AS TotalNum
    from yeeoffice_doc_proptype where YGDocPropID!=0 AND TenantID=_TenantID;

END
$$

DELIMITER ;

DELIMITER $$


DROP PROCEDURE IF EXISTS YeeOffice_Document_Get_YGDocProps$$

CREATE DEFINER = 'yeeoffice_uatdba'@'%'
PROCEDURE YeeOffice_Document_Get_YGDocProps(`_YGDocPropID` bigint)
BEGIN

SET @RESULT ="";
SET @PARENTTEMP =_YGDocPropID;
SET @NUM =1;

WHILE @PARENTTEMP is not NULL do 
SET @RESULT = CONCAT(@RESULT,',',@PARENTTEMP);
SELECT YGDocPropID,COUNT(*) into @PARENTTEMP,@NUM from yeeoffice_doc_proptype WHERE DocPropParentID = @PARENTTEMP;
if @NUM =0 then 
set @PARENTTEMP = NULL;
end if;
end WHILE;
select @RESULT;
END
$$

DELIMITER ;

DELIMITER $$


DROP PROCEDURE IF EXISTS YeeOffice_Document_MyDeleted_Select$$

CREATE DEFINER = 'yeeoffice_uatdba'@'%'
PROCEDURE YeeOffice_Document_MyDeleted_Select(_PageIndex int,
  _PageSize int,
  _TenantID BIGINT(20),
  _CreatBy BIGINT(20))
BEGIN
    SET _PageIndex = (_PageIndex) * _PageSize;
    set @DataCount=0;     
    select count(*) INTO @DataCount FROM yeeoffice_doc_info ycc WHERE ycc.IsDelete=1 AND ycc.TenantID=_TenantID AND ycc.CreatBy=_CreatBy;  
    SELECT *,@DataCount as DataCount  FROM yeeoffice_doc_info ycc WHERE ycc.IsDelete=1 AND ycc.TenantID=_TenantID AND ycc.CreatBy=_CreatBy ORDER BY ycc.Deleted DESC LIMIT _PageIndex,_PageSize;
END
$$

DELIMITER ;

DELIMITER $$


DROP PROCEDURE IF EXISTS YeeOffice_Document_MyUpload_Select$$

CREATE DEFINER = 'yeeoffice_uatdba'@'%'
PROCEDURE YeeOffice_Document_MyUpload_Select(_PageIndex int,
  _PageSize int,
  _TenantID BIGINT(20),
  _CreatBy BIGINT(20))
BEGIN
    SET _PageIndex = (_PageIndex) * _PageSize;
    set @DataCount=0;  
    select count(*) INTO @DataCount FROM yeeoffice_doc_info ycc WHERE ycc.IsDelete=0 AND ycc.TenantID=_TenantID AND ycc.CreatBy=_CreatBy;
    SELECT *,@DataCount as DataCount FROM yeeoffice_doc_info ycc WHERE ycc.IsDelete=0 AND ycc.TenantID=_TenantID AND ycc.CreatBy=_CreatBy ORDER BY ycc.Created  DESC LIMIT _PageIndex,_PageSize;
END
$$

DELIMITER ;