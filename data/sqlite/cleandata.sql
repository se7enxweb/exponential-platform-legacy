-- ================================================
-- SQLite cleandata.sql for Exponential Platform Legacy (Platform v3)
-- Generated from data/mysql/cleandata.sql — adapted for SQLite 3.x
-- Used by: php bin/console ezplatform:install exponential-oss
-- Transformations applied:
--   - AUTO_INCREMENT removed
--   - ENGINE/CHARSET/COLLATE table options stripped
--   - Inline KEY/INDEX clauses removed (SQLite uses separate CREATE INDEX)
--   - MySQL prefix-length index refs `col`(N) stripped
--   - UNSIGNED removed
--   - CHARACTER SET/COLLATE column options removed
-- ================================================

PRAGMA journal_mode=WAL;
PRAGMA foreign_keys=OFF;

INSERT INTO `ezcobj_state` (`default_language_id`, `group_id`, `id`, `identifier`, `language_mask`, `priority`)
VALUES (2, 2, 1, 'not_locked', 3, 0),
       (2, 2, 2, 'locked', 3, 1);

INSERT INTO `ezcobj_state_group` (`default_language_id`, `id`, `identifier`, `language_mask`)
VALUES (2,2,'ez_lock',3);

INSERT INTO `ezcobj_state_group_language` (`contentobject_state_group_id`, `description`, `language_id`, `name`, `real_language_id`)
VALUES (2,'',3,'Lock',2);

INSERT INTO `ezcobj_state_language` (`contentobject_state_id`, `description`, `language_id`, `name`)
VALUES (1,'',3,'Not locked'),
       (2,'',3,'Locked');

INSERT INTO `ezcobj_state_link` (`contentobject_id`, `contentobject_state_id`)
VALUES (1, 1),
       (4, 1),
       (10, 1),
       (11, 1),
       (12, 1),
       (13, 1),
       (14, 1),
       (41, 1),
       (42, 1),
       (49, 1),
       (50, 1),
       (51, 1);

INSERT INTO `ezcontent_language` (`disabled`, `id`, `locale`, `name`)
VALUES (0, 2, 'eng-GB', 'English (United Kingdom)');

INSERT INTO `ezcontentclass` (`always_available`, `contentobject_name`, `created`, `creator_id`, `id`, `identifier`, `initial_language_id`, `is_container`, `language_mask`, `modified`, `modifier_id`, `remote_id`, `serialized_description_list`, `serialized_name_list`, `sort_field`, `sort_order`, `url_alias_name`, `version`)
VALUES (1,'<short_name|name>',1024392098,14,1,'folder',2,1,2,1448831672,14,'a3d405b81be900468eb153d774f4f0d2','a:0:{}','a:1:{s:6:"eng-GB";s:6:"Folder";}',1,1,NULL,0),
       (0,'<short_title|title>',1024392098,14,2,'article',2,1,3,1082454989,14,'c15b600eb9198b1924063b5a68758232',NULL,'a:2:{s:6:"eng-GB";s:7:"Article";s:16:"always-available";s:6:"eng-GB";}',1,1,NULL,0),
       (1,'<name>',1024392098,14,3,'user_group',2,1,3,1048494743,14,'25b4268cdcd01921b808a0d854b877ef',NULL,'a:2:{s:6:"eng-GB";s:10:"User group";s:16:"always-available";s:6:"eng-GB";}',1,1,NULL,0),
       (1,'<first_name> <last_name>',1024392098,14,4,'user',2,0,3,1082018364,14,'40faa822edc579b02c25f6bb7beec3ad',NULL,'a:2:{s:6:"eng-GB";s:4:"User";s:16:"always-available";s:6:"eng-GB";}',1,1,NULL,0),
       (1,'<name>',1031484992,14,5,'image',2,0,3,1048494784,14,'f6df12aa74e36230eb675f364fccd25a',NULL,'a:2:{s:6:"eng-GB";s:5:"Image";s:16:"always-available";s:6:"eng-GB";}',1,1,NULL,0),
       (1,'<name>',1052385472,14,12,'file',2,0,3,1052385669,14,'637d58bfddf164627bdfd265733280a0',NULL,'a:2:{s:6:"eng-GB";s:4:"File";s:16:"always-available";s:6:"eng-GB";}',1,1,NULL,0);

INSERT INTO `ezcontentclass_attribute` (`can_translate`, `category`, `contentclass_id`, `data_float1`, `data_float2`, `data_float3`, `data_float4`, `data_int1`, `data_int2`, `data_int3`, `data_int4`, `data_text1`, `data_text2`, `data_text3`, `data_text4`, `data_text5`, `data_type_string`, `id`, `identifier`, `is_information_collector`, `is_required`, `is_searchable`, `placement`, `serialized_data_text`, `serialized_description_list`, `serialized_name_list`, `version`)
VALUES (1,'',2,0,0,0,0,255,0,0,0,'New article','','','','','ezstring',1,'title',0,1,1,1,NULL,NULL,'a:2:{s:6:"eng-GB";s:5:"Title";s:16:"always-available";s:6:"eng-GB";}',0),
       (1,'',1,NULL,NULL,NULL,NULL,255,0,NULL,NULL,'Folder',NULL,NULL,NULL,NULL,'ezstring',4,'name',0,1,1,1,'N;','a:0:{}','a:1:{s:6:"eng-GB";s:4:"Name";}',0),
       (1,'',3,0,0,0,0,255,0,0,0,'','','','',NULL,'ezstring',6,'name',0,1,1,1,NULL,NULL,'a:2:{s:6:"eng-GB";s:4:"Name";s:16:"always-available";s:6:"eng-GB";}',0),
       (1,'',3,0,0,0,0,255,0,0,0,'','','','',NULL,'ezstring',7,'description',0,0,1,2,NULL,NULL,'a:2:{s:6:"eng-GB";s:11:"Description";s:16:"always-available";s:6:"eng-GB";}',0),
       (1,'',4,0,0,0,0,255,0,0,0,'','','','','','ezstring',8,'first_name',0,1,1,1,NULL,NULL,'a:2:{s:6:"eng-GB";s:10:"First name";s:16:"always-available";s:6:"eng-GB";}',0),
       (1,'',4,0,0,0,0,255,0,0,0,'','','','','','ezstring',9,'last_name',0,1,1,2,NULL,NULL,'a:2:{s:6:"eng-GB";s:9:"Last name";s:16:"always-available";s:6:"eng-GB";}',0),
       (0,'',4,0,0,0,0,7,10,0,0,'','^[^@]+$','','','','ezuser',12,'user_account',0,1,0,3,NULL,NULL,'a:2:{s:6:"eng-GB";s:12:"User account";s:16:"always-available";s:6:"eng-GB";}',0),
       (1,'',5,0,0,0,0,150,0,0,0,'','','','',NULL,'ezstring',116,'name',0,1,1,1,NULL,NULL,'a:2:{s:6:"eng-GB";s:4:"Name";s:16:"always-available";s:6:"eng-GB";}',0),
       (1,'',5,0,0,0,0,10,0,0,0,'','','','',NULL,'ezrichtext',117,'caption',0,0,1,2,NULL,NULL,'a:2:{s:6:"eng-GB";s:7:"Caption";s:16:"always-available";s:6:"eng-GB";}',0),
       (1,'',5,0,0,0,0,10,0,0,0,'','','','',NULL,'ezimage',118,'image',0,0,0,3,NULL,NULL,'a:2:{s:6:"eng-GB";s:5:"Image";s:16:"always-available";s:6:"eng-GB";}',0),
       (1,'',1,NULL,NULL,NULL,NULL,5,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'ezrichtext',119,'short_description',0,0,1,3,'N;','a:0:{}','a:1:{s:6:"eng-GB";s:17:"Short description";}',0),
       (1,'',2,0,0,0,0,10,0,0,0,'','','','','','ezrichtext',120,'intro',0,1,1,4,NULL,NULL,'a:2:{s:6:"eng-GB";s:5:"Intro";s:16:"always-available";s:6:"eng-GB";}',0),
       (1,'',2,0,0,0,0,20,0,0,0,'','','','','','ezrichtext',121,'body',0,0,1,5,NULL,NULL,'a:2:{s:6:"eng-GB";s:4:"Body";s:16:"always-available";s:6:"eng-GB";}',0),
       (0,'',2,0,0,0,0,0,0,0,0,'','','','','','ezboolean',123,'enable_comments',0,0,0,6,NULL,NULL,'a:2:{s:6:"eng-GB";s:15:"Enable comments";s:16:"always-available";s:6:"eng-GB";}',0),
       (1,'',12,0,0,0,0,0,0,0,0,'New file','','','',NULL,'ezstring',146,'name',0,1,1,1,NULL,NULL,'a:2:{s:6:"eng-GB";s:4:"Name";s:16:"always-available";s:6:"eng-GB";}',0),
       (1,'',12,0,0,0,0,10,0,0,0,'','','','',NULL,'ezrichtext',147,'description',0,0,1,2,NULL,NULL,'a:2:{s:6:"eng-GB";s:11:"Description";s:16:"always-available";s:6:"eng-GB";}',0),
       (1,'',12,0,0,0,0,0,0,0,0,'','','','',NULL,'ezbinaryfile',148,'file',0,1,0,3,NULL,NULL,'a:2:{s:6:"eng-GB";s:4:"File";s:16:"always-available";s:6:"eng-GB";}',0),
       (1,'',2,0,0,0,0,255,0,0,0,'','','','','','ezstring',152,'short_title',0,0,1,2,NULL,NULL,'a:2:{s:6:"eng-GB";s:11:"Short title";s:16:"always-available";s:6:"eng-GB";}',0),
       (1,'',2,0,0,0,0,1,0,0,0,'','','','','','ezauthor',153,'author',0,0,0,3,NULL,NULL,'a:2:{s:6:"eng-GB";s:6:"Author";s:16:"always-available";s:6:"eng-GB";}',0),
       (1,'',2,0,0,0,0,0,0,0,0,'','','','','','ezobjectrelation',154,'image',0,0,1,7,NULL,NULL,'a:2:{s:6:"eng-GB";s:5:"Image";s:16:"always-available";s:6:"eng-GB";}',0),
       (1,'',1,NULL,NULL,NULL,NULL,100,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'ezstring',155,'short_name',0,0,1,2,'N;','a:0:{}','a:1:{s:6:"eng-GB";s:10:"Short name";}',0),
       (1,'',1,NULL,NULL,NULL,NULL,20,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'ezrichtext',156,'description',0,0,1,4,'N;','a:0:{}','a:1:{s:6:"eng-GB";s:11:"Description";}',0),
       (1,'',4,0,0,0,0,10,0,0,0,'','','','','','eztext',179,'signature',0,0,1,4,NULL,NULL,'a:2:{s:6:"eng-GB";s:9:"Signature";s:16:"always-available";s:6:"eng-GB";}',0),
       (1,'',4,0,0,0,0,10,0,0,0,'','','','','','ezimage',180,'image',0,0,0,5,NULL,NULL,'a:2:{s:6:"eng-GB";s:5:"Image";s:16:"always-available";s:6:"eng-GB";}',0);

INSERT INTO `ezcontentclass_classgroup` (`contentclass_id`, `contentclass_version`, `group_id`, `group_name`)
VALUES (1, 0, 1, 'Content'),
       (2, 0, 1, 'Content'),
       (3, 0, 2, 'Users'),
       (4, 0, 2, 'Users'),
       (5, 0, 3, 'Media'),
       (12, 0, 3, 'Media');

INSERT INTO `ezcontentclass_name` (`contentclass_id`, `contentclass_version`, `language_id`, `language_locale`, `name`)
VALUES (1, 0, 2, 'eng-GB', 'Folder'),
       (2, 0, 3, 'eng-GB', 'Article'),
       (3, 0, 3, 'eng-GB', 'User group'),
       (4, 0, 3, 'eng-GB', 'User'),
       (5, 0, 3, 'eng-GB', 'Image'),
       (12, 0, 3, 'eng-GB', 'File');

INSERT INTO `ezcontentclassgroup` (`created`, `creator_id`, `id`, `modified`, `modifier_id`, `name`)
VALUES (1031216928, 14, 1, 1033922106, 14, 'Content'),
       (1031216941, 14, 2, 1033922113, 14, 'Users'),
       (1032009743, 14, 3, 1033922120, 14, 'Media');

INSERT INTO `ezcontentobject` (`contentclass_id`, `current_version`, `id`, `initial_language_id`, `language_mask`, `modified`, `name`, `owner_id`, `published`, `remote_id`, `section_id`, `status`)
VALUES (1,9,1,2,3,1448889046,'Exponential Platform',14,1448889046,'9459d3c29e15006e45197295722c7ade',1,1),
       (3,1,4,2,3,1033917596,'Users',14,1033917596,'f5c88a2209584891056f987fd965b0ba',2,1),
       (4,2,10,2,3,1072180405,'Anonymous User',14,1033920665,'faaeb9be3bd98ed09f606fc16d144eca',2,1),
       (3,1,11,2,3,1033920746,'Guest accounts',14,1033920746,'5f7f0bdb3381d6a461d8c29ff53d908f',2,1),
       (3,1,12,2,3,1033920775,'Administrator users',14,1033920775,'9b47a45624b023b1a76c73b74d704acf',2,1),
       (3,1,13,2,3,1033920794,'Editors',14,1033920794,'3c160cca19fb135f83bd02d911f04db2',2,1),
       (4,3,14,2,3,1301062024,'Administrator User',14,1033920830,'1bb4fe25487f05527efa8bfd394cecc7',2,1),
       (1,1,41,2,3,1060695457,'Media',14,1060695457,'a6e35cbcb7cd6ae4b691f3eee30cd262',3,1),
       (3,1,42,2,3,1072180330,'Anonymous Users',14,1072180330,'15b256dbea2ae72418ff5facc999e8f9',2,1),
       (1,1,49,2,3,1080220197,'Images',14,1080220197,'e7ff633c6b8e0fd3531e74c6e712bead',3,1),
       (1,1,50,2,3,1080220220,'Files',14,1080220220,'732a5acd01b51a6fe6eab448ad4138a9',3,1),
       (1,1,51,2,3,1080220233,'Multimedia',14,1080220233,'09082deb98662a104f325aaa8c4933d3',3,1);

INSERT INTO `ezcontentobject_attribute` (`attribute_original_id`, `contentclassattribute_id`, `contentobject_id`, `data_float`, `data_int`, `data_text`, `data_type_string`, `id`, `language_code`, `language_id`, `sort_key_int`, `sort_key_string`, `version`)
VALUES (0,4,1,NULL,NULL,'Exponential Platform','ezstring',1,'eng-GB',3,0,'exponential platform',9),
       (0,119,1,NULL,NULL,'<?xml version="1.0" encoding="UTF-8"?><section xmlns="http://docbook.org/ns/docbook" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:ezxhtml="http://ez.no/xmlns/ezpublish/docbook/xhtml" xmlns:ezcustom="http://ez.no/xmlns/ezpublish/docbook/custom" version="5.0-variant ezpublish-1.0"><para><emphasis role="strong">You are now ready to start your project.</emphasis></para></section>','ezrichtext',2,'eng-GB',3,0,'',9),
       (0,7,4,NULL,NULL,'Main group','ezstring',7,'eng-GB',3,0,'',1),
       (0,6,4,NULL,NULL,'Users','ezstring',8,'eng-GB',3,0,'',1),
       (0,8,10,0,0,'Anonymous','ezstring',19,'eng-GB',3,0,'anonymous',2),
       (0,9,10,0,0,'User','ezstring',20,'eng-GB',3,0,'user',2),
       (0,12,10,0,0,'','ezuser',21,'eng-GB',3,0,'',2),
       (0,6,11,0,0,'Guest accounts','ezstring',22,'eng-GB',3,0,'',1),
       (0,7,11,0,0,'','ezstring',23,'eng-GB',3,0,'',1),
       (0,6,12,0,0,'Administrator users','ezstring',24,'eng-GB',3,0,'',1),
       (0,7,12,0,0,'','ezstring',25,'eng-GB',3,0,'',1),
       (0,6,13,0,0,'Editors','ezstring',26,'eng-GB',3,0,'',1),
       (0,7,13,0,0,'','ezstring',27,'eng-GB',3,0,'',1),
       (0,8,14,0,0,'Administrator','ezstring',28,'eng-GB',3,0,'administrator',3),
       (0,9,14,0,0,'User','ezstring',29,'eng-GB',3,0,'user',3),
       (30,12,14,0,0,'','ezuser',30,'eng-GB',3,0,'',3),
       (0,4,41,0,0,'Media','ezstring',98,'eng-GB',3,0,'',1),
       (0,119,41,0,1045487555,'<?xml version="1.0" encoding="UTF-8"?>
<section xmlns="http://docbook.org/ns/docbook" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:ezxhtml="http://ez.no/xmlns/ezpublish/docbook/xhtml" xmlns:ezcustom="http://ez.no/xmlns/ezpublish/docbook/custom" version="5.0-variant ezpublish-1.0"/>
','ezrichtext',99,'eng-GB',3,0,'',1),
       (0,6,42,0,0,'Anonymous Users','ezstring',100,'eng-GB',3,0,'anonymous users',1),
       (0,7,42,0,0,'User group for the anonymous user','ezstring',101,'eng-GB',3,0,'user group for the anonymous user',1),
       (0,155,1,NULL,NULL,'Exponential Platform','ezstring',102,'eng-GB',3,0,'exponential platform',9),
       (0,155,41,0,0,'','ezstring',103,'eng-GB',3,0,'',1),
       (0,156,1,NULL,NULL,'<?xml version="1.0" encoding="UTF-8"?><section xmlns="http://docbook.org/ns/docbook" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:ezxhtml="http://ez.no/xmlns/ezpublish/docbook/xhtml" xmlns:ezcustom="http://ez.no/xmlns/ezpublish/docbook/custom" version="5.0-variant ezpublish-1.0"><para>This is the clean installation coming with Exponential Platform.</para><para>It''s a bare-bones setup of the Platform, an excellent foundation to build upon if you want to start your project from scratch.</para></section>','ezrichtext',104,'eng-GB',3,0,'',9),
       (0,156,41,0,1045487555,'<?xml version="1.0" encoding="UTF-8"?>
<section xmlns="http://docbook.org/ns/docbook" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:ezxhtml="http://ez.no/xmlns/ezpublish/docbook/xhtml" xmlns:ezcustom="http://ez.no/xmlns/ezpublish/docbook/custom" version="5.0-variant ezpublish-1.0"/>
','ezrichtext',105,'eng-GB',3,0,'',1),
       (0,4,49,0,0,'Images','ezstring',142,'eng-GB',3,0,'images',1),
       (0,155,49,0,0,'','ezstring',143,'eng-GB',3,0,'',1),
       (0,119,49,0,1045487555,'<?xml version="1.0" encoding="UTF-8"?>
<section xmlns="http://docbook.org/ns/docbook" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:ezxhtml="http://ez.no/xmlns/ezpublish/docbook/xhtml" xmlns:ezcustom="http://ez.no/xmlns/ezpublish/docbook/custom" version="5.0-variant ezpublish-1.0"/>
','ezrichtext',144,'eng-GB',3,0,'',1),
       (0,156,49,0,1045487555,'<?xml version="1.0" encoding="UTF-8"?>
<section xmlns="http://docbook.org/ns/docbook" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:ezxhtml="http://ez.no/xmlns/ezpublish/docbook/xhtml" xmlns:ezcustom="http://ez.no/xmlns/ezpublish/docbook/custom" version="5.0-variant ezpublish-1.0"/>
','ezrichtext',145,'eng-GB',3,0,'',1),
       (0,4,50,0,0,'Files','ezstring',147,'eng-GB',3,0,'files',1),
       (0,155,50,0,0,'','ezstring',148,'eng-GB',3,0,'',1),
       (0,119,50,0,1045487555,'<?xml version="1.0" encoding="UTF-8"?>
<section xmlns="http://docbook.org/ns/docbook" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:ezxhtml="http://ez.no/xmlns/ezpublish/docbook/xhtml" xmlns:ezcustom="http://ez.no/xmlns/ezpublish/docbook/custom" version="5.0-variant ezpublish-1.0"/>
','ezrichtext',149,'eng-GB',3,0,'',1),
       (0,156,50,0,1045487555,'<?xml version="1.0" encoding="UTF-8"?>
<section xmlns="http://docbook.org/ns/docbook" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:ezxhtml="http://ez.no/xmlns/ezpublish/docbook/xhtml" xmlns:ezcustom="http://ez.no/xmlns/ezpublish/docbook/custom" version="5.0-variant ezpublish-1.0"/>
','ezrichtext',150,'eng-GB',3,0,'',1),
       (0,4,51,0,0,'Multimedia','ezstring',152,'eng-GB',3,0,'multimedia',1),
       (0,155,51,0,0,'','ezstring',153,'eng-GB',3,0,'',1),
       (0,119,51,0,1045487555,'<?xml version="1.0" encoding="UTF-8"?>
<section xmlns="http://docbook.org/ns/docbook" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:ezxhtml="http://ez.no/xmlns/ezpublish/docbook/xhtml" xmlns:ezcustom="http://ez.no/xmlns/ezpublish/docbook/custom" version="5.0-variant ezpublish-1.0"/>
','ezrichtext',154,'eng-GB',3,0,'',1),
       (0,156,51,0,1045487555,'<?xml version="1.0" encoding="UTF-8"?>
<section xmlns="http://docbook.org/ns/docbook" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:ezxhtml="http://ez.no/xmlns/ezpublish/docbook/xhtml" xmlns:ezcustom="http://ez.no/xmlns/ezpublish/docbook/custom" version="5.0-variant ezpublish-1.0"/>
','ezrichtext',155,'eng-GB',3,0,'',1),
       (0,179,10,0,0,'','eztext',177,'eng-GB',3,0,'',2),
       (0,179,14,0,0,'','eztext',178,'eng-GB',3,0,'',3),
       (0,180,10,0,0,'','ezimage',179,'eng-GB',3,0,'',2),
       (0,180,14,0,0,'<?xml version="1.0" encoding="utf-8"?>
<ezimage serial_number="1" is_valid="" filename="" suffix="" basename="" dirpath="" url="" original_filename="" mime_type="" width="" height="" alternative_text="" alias_key="1293033771" timestamp="1301057722"><original attribute_id="180" attribute_version="3" attribute_language="eng-GB"/></ezimage>
','ezimage',180,'eng-GB',3,0,'',3);

INSERT INTO `ezcontentobject_name` (`content_translation`, `content_version`, `contentobject_id`, `language_id`, `name`, `real_translation`)
VALUES ('eng-GB',9,1,2,'Exponential Platform','eng-GB'),
       ('eng-GB',1,4,3,'Users','eng-GB'),
       ('eng-GB',2,10,3,'Anonymous User','eng-GB'),
       ('eng-GB',1,11,3,'Guest accounts','eng-GB'),
       ('eng-GB',1,12,3,'Administrator users','eng-GB'),
       ('eng-GB',1,13,3,'Editors','eng-GB'),
       ('eng-GB',3,14,3,'Administrator User','eng-GB'),
       ('eng-GB',1,41,3,'Media','eng-GB'),
       ('eng-GB',1,42,3,'Anonymous Users','eng-GB'),
       ('eng-GB',1,49,3,'Images','eng-GB'),
       ('eng-GB',1,50,3,'Files','eng-GB'),
       ('eng-GB',1,51,3,'Multimedia','eng-GB');

INSERT INTO `ezcontentobject_tree` (`contentobject_id`, `contentobject_is_published`, `contentobject_version`, `depth`, `is_hidden`, `is_invisible`, `main_node_id`, `modified_subnode`, `node_id`, `parent_node_id`, `path_identification_string`, `path_string`, `priority`, `remote_id`, `sort_field`, `sort_order`)
VALUES (0,1,1,0,0,0,1,1448999778,1,1,'','/1/',0,'629709ba256fe317c3ddcee35453a96a',1,1),
       (1,1,9,1,0,0,2,1301073466,2,1,'node_2','/1/2/',0,'f3e90596361e31d496d4026eb624c983',8,1),
       (4,1,1,1,0,0,5,1301062024,5,1,'users','/1/5/',0,'3f6d92f8044aed134f32153517850f5a',1,1),
       (11,1,1,2,0,0,12,1081860719,12,5,'users/guest_accounts','/1/5/12/',0,'602dcf84765e56b7f999eaafd3821dd3',1,1),
       (12,1,1,2,0,0,13,1301062024,13,5,'users/administrator_users','/1/5/13/',0,'769380b7aa94541679167eab817ca893',1,1),
       (13,1,1,2,0,0,14,1081860719,14,5,'users/editors','/1/5/14/',0,'f7dda2854fc68f7c8455d9cb14bd04a9',1,1),
       (14,1,3,3,0,0,15,1301062024,15,13,'users/administrator_users/administrator_user','/1/5/13/15/',0,'e5161a99f733200b9ed4e80f9c16187b',1,1),
       (41,1,1,1,0,0,43,1081860720,43,1,'media','/1/43/',0,'75c715a51699d2d309a924eca6a95145',9,1),
       (42,1,1,2,0,0,44,1081860719,44,5,'users/anonymous_users','/1/5/44/',0,'4fdf0072da953bb276c0c7e0141c5c9b',9,1),
       (10,1,2,3,0,0,45,1081860719,45,44,'users/anonymous_users/anonymous_user','/1/5/44/45/',0,'2cf8343bee7b482bab82b269d8fecd76',9,1),
       (49,1,1,2,0,0,51,1081860720,51,43,'media/images','/1/43/51/',0,'1b26c0454b09bb49dfb1b9190ffd67cb',9,1),
       (50,1,1,2,0,0,52,1081860720,52,43,'media/files','/1/43/52/',0,'0b113a208f7890f9ad3c24444ff5988c',9,1),
       (51,1,1,2,0,0,53,1081860720,53,43,'media/multimedia','/1/43/53/',0,'4f18b82c75f10aad476cae5adf98c11f',9,1);

INSERT INTO `ezcontentobject_version` (`contentobject_id`, `created`, `creator_id`, `id`, `initial_language_id`, `language_mask`, `modified`, `status`, `user_id`, `version`, `workflow_event_pos`)
VALUES (4,0,14,4,2,3,0,1,0,1,1),
       (11,1033920737,14,439,2,3,1033920746,1,0,1,0),
       (12,1033920760,14,440,2,3,1033920775,1,0,1,0),
       (13,1033920786,14,441,2,3,1033920794,1,0,1,0),
       (41,1060695450,14,472,2,3,1060695457,1,0,1,0),
       (42,1072180278,14,473,2,3,1072180330,1,0,1,0),
       (10,1072180337,14,474,2,3,1072180405,1,0,2,0),
       (49,1080220181,14,488,2,3,1080220197,1,0,1,0),
       (50,1080220211,14,489,2,3,1080220220,1,0,1,0),
       (51,1080220225,14,490,2,3,1080220233,1,0,1,0),
       (14,1301061783,14,499,2,3,1301062024,1,0,3,0),
       (1,1448889045,14,506,2,3,1448889046,1,0,9,0);

INSERT INTO `eznode_assignment` (`contentobject_id`, `contentobject_version`, `from_node_id`, `id`, `is_main`, `op_code`, `parent_node`, `parent_remote_id`, `remote_id`, `sort_field`, `sort_order`, `priority`, `is_hidden`)
VALUES (8,2,0,4,1,2,5,'','0',1,1,0,0),
       (42,1,0,5,1,2,5,'','0',9,1,0,0),
       (10,2,-1,6,1,2,44,'','0',9,1,0,0),
       (4,1,0,7,1,2,1,'','0',1,1,0,0),
       (12,1,0,8,1,2,5,'','0',1,1,0,0),
       (13,1,0,9,1,2,5,'','0',1,1,0,0),
       (41,1,0,11,1,2,1,'','0',1,1,0,0),
       (11,1,0,12,1,2,5,'','0',1,1,0,0),
       (49,1,0,27,1,2,43,'','0',9,1,0,0),
       (50,1,0,28,1,2,43,'','0',9,1,0,0),
       (51,1,0,29,1,2,43,'','0',9,1,0,0),
       (14,3,-1,38,1,2,13,'','0',1,1,0,0);

INSERT INTO `ezpolicy` (`function_name`, `id`, `module_name`, `original_id`, `role_id`)
VALUES ('*',317,'content',0,3),
       ('login',319,'user',0,3),
       ('read',328,'content',0,1),
       ('login',331,'user',0,1),
       ('*',332,'*',0,2),
       ('read',333,'content',0,4),
       ('view_embed',334,'content',0,1),
       ('*',340,'url',0,3);

INSERT INTO `ezpolicy_limitation` (`id`, `identifier`, `policy_id`)
VALUES (251,'Section',328),
       (252,'Section',329),
       (253,'SiteAccess',331),
       (254,'Class',333),
       (255,'Owner',333),
       (256,'Class',334);

INSERT INTO `ezpolicy_limitation_value` (`id`, `limitation_id`, `value`)
VALUES (477,251,'1'),
       (478,252,'1'),
       (479,253,'1766001124'),
       (480,254,'4'),
       (481,255,'1'),
       (482,256,'5'),
       (483,256,'12');

INSERT INTO `ezrole` (`id`, `is_new`, `name`, `value`, `version`)
VALUES (1,0,'Anonymous','',0),
       (2,0,'Administrator','0',0),
       (3,0,'Editor','',0),
       (4,0,'Member','',0);

INSERT INTO `ezsection` (`id`, `identifier`, `locale`, `name`, `navigation_part_identifier`)
VALUES (1,'standard','','Standard','ezcontentnavigationpart'),
       (2,'users','','Users','ezusernavigationpart'),
       (3,'media','','Media','ezmedianavigationpart');

INSERT INTO `ezsite_data` (`name`, `value`)
VALUES ('ibexa-release','3.3');

INSERT INTO `ezurlalias` (`destination_url`, `forward_to_id`, `id`, `is_imported`, `is_internal`, `is_wildcard`, `source_md5`, `source_url`)
VALUES ('content/view/full/2',0,12,1,1,0,'d41d8cd98f00b204e9800998ecf8427e',''),
       ('content/view/full/5',0,13,1,1,0,'9bc65c2abec141778ffaa729489f3e87','users'),
       ('content/view/full/12',0,15,1,1,0,'02d4e844e3a660857a3f81585995ffe1','users/guest_accounts'),
       ('content/view/full/13',0,16,1,1,0,'1b1d79c16700fd6003ea7be233e754ba','users/administrator_users'),
       ('content/view/full/14',0,17,1,1,0,'0bb9dd665c96bbc1cf36b79180786dea','users/editors'),
       ('content/view/full/15',0,18,1,1,0,'f1305ac5f327a19b451d82719e0c3f5d','users/administrator_users/administrator_user'),
       ('content/view/full/43',0,20,1,1,0,'62933a2951ef01f4eafd9bdf4d3cd2f0','media'),
       ('content/view/full/44',0,21,1,1,0,'3ae1aac958e1c82013689d917d34967a','users/anonymous_users'),
       ('content/view/full/45',0,22,1,1,0,'aad93975f09371695ba08292fd9698db','users/anonymous_users/anonymous_user'),
       ('content/view/full/51',0,28,1,1,0,'38985339d4a5aadfc41ab292b4527046','media/images'),
       ('content/view/full/52',0,29,1,1,0,'ad5a8c6f6aac3b1b9df267fe22e7aef6','media/files'),
       ('content/view/full/53',0,30,1,1,0,'562a0ac498571c6c3529173184a2657c','media/multimedia');

INSERT INTO `ezurlalias_ml` (`action`, `action_type`, `alias_redirects`, `id`, `is_alias`, `is_original`, `lang_mask`, `link`, `parent`, `text`, `text_md5`)
VALUES ('nop:','nop',1,17,0,0,1,17,0,'media2','50e2736330de124f6edea9b008556fe6'),
       ('eznode:43','eznode',1,9,0,1,3,9,0,'Media','62933a2951ef01f4eafd9bdf4d3cd2f0'),
       ('nop:','nop',1,3,0,0,1,3,0,'users2','86425c35a33507d479f71ade53a669aa'),
       ('eznode:5','eznode',1,2,0,1,3,2,0,'Users','9bc65c2abec141778ffaa729489f3e87'),
       ('eznode:2','eznode',1,1,0,1,3,1,0,'','d41d8cd98f00b204e9800998ecf8427e'),
       ('eznode:14','eznode',1,6,0,1,3,6,2,'Editors','a147e136bfa717592f2bd70bd4b53b17'),
       ('eznode:44','eznode',1,10,0,1,3,10,2,'Anonymous-Users','c2803c3fa1b0b5423237b4e018cae755'),
       ('eznode:12','eznode',1,4,0,1,3,4,2,'Guest-accounts','e57843d836e3af8ab611fde9e2139b3a'),
       ('eznode:13','eznode',1,5,0,1,3,5,2,'Administrator-users','f89fad7f8a3abc8c09e1deb46a420007'),
       ('nop:','nop',1,11,0,0,1,11,3,'anonymous_users2','505e93077a6dde9034ad97a14ab022b1'),
       ('eznode:12','eznode',1,26,0,0,1,4,3,'guest_accounts','70bb992820e73638731aa8de79b3329e'),
       ('eznode:14','eznode',1,29,0,0,1,6,3,'editors','a147e136bfa717592f2bd70bd4b53b17'),
       ('nop:','nop',1,7,0,0,1,7,3,'administrator_users2','a7da338c20bf65f9f789c87296379c2a'),
       ('eznode:13','eznode',1,27,0,0,1,5,3,'administrator_users','aeb8609aa933b0899aa012c71139c58c'),
       ('eznode:44','eznode',1,30,0,0,1,10,3,'anonymous_users','e9e5ad0c05ee1a43715572e5cc545926'),
       ('eznode:15','eznode',1,8,0,1,3,8,5,'Administrator-User','5a9d7b0ec93173ef4fedee023209cb61'),
       ('eznode:15','eznode',1,28,0,0,0,8,7,'administrator_user','a3cca2de936df1e2f805710399989971'),
       ('eznode:53','eznode',1,20,0,1,3,20,9,'Multimedia','2e5bc8831f7ae6a29530e7f1bbf2de9c'),
       ('eznode:52','eznode',1,19,0,1,3,19,9,'Files','45b963397aa40d4a0063e0d85e4fe7a1'),
       ('eznode:51','eznode',1,18,0,1,3,18,9,'Images','59b514174bffe4ae402b3d63aad79fe0'),
       ('eznode:45','eznode',1,12,0,1,3,12,10,'Anonymous-User','ccb62ebca03a31272430bc414bd5cd5b'),
       ('eznode:45','eznode',1,31,0,0,1,12,11,'anonymous_user','c593ec85293ecb0e02d50d4c5c6c20eb'),
       ('eznode:53','eznode',1,34,0,0,1,20,17,'multimedia','2e5bc8831f7ae6a29530e7f1bbf2de9c'),
       ('eznode:52','eznode',1,33,0,0,1,19,17,'files','45b963397aa40d4a0063e0d85e4fe7a1'),
       ('eznode:51','eznode',1,32,0,0,1,18,17,'images','59b514174bffe4ae402b3d63aad79fe0');

INSERT INTO `ezurlalias_ml_incr` (`id`)
VALUES (1), (2), (3), (4), (5), (6), (7), (8), (9), (10), (11), (12), (13), (14), (15), (16), (17),
       (18), (19), (20), (21), (22), (24), (25), (26), (27), (28), (29), (30), (31), (32), (33),
       (34), (35), (36), (37);

INSERT INTO `ezuser` (`contentobject_id`, `email`, `login`, `password_hash`, `password_hash_type`)
VALUES (10,'anonymous@link.invalid','anonymous','$2y$10$35gOSQs6JK4u4whyERaeUuVeQBi2TUBIZIfP7HEj7sfz.MxvTuOeC',7),
       (14,'admin@link.invalid','admin','$2y$10$FDn9NPwzhq85cLLxfD5Wu.L3SL3Z/LNCvhkltJUV0wcJj7ciJg2oy',7);

INSERT INTO `ezuser_role` (`contentobject_id`, `id`, `limit_identifier`, `limit_value`, `role_id`)
VALUES (11,28,'','',1),
       (42,31,'','',1),
       (13,32,'Subtree','/1/2/',3),
       (13,33,'Subtree','/1/43/',3),
       (12,34,'','',2),
       (13,35,'','',4);

INSERT INTO `ezuser_setting` (`is_enabled`, `max_login`, `user_id`)
VALUES (1,1000,10),
       (1,10,14);

-- ================================================
-- Legacy eZ Publish schema (ezplatform:install ibexa-oss compatibility)
-- ================================================

CREATE TABLE IF NOT EXISTS `ezapprove_items` (
  `collaboration_id` int NOT NULL DEFAULT '0',
  `id` int NOT NULL,
  `workflow_process_id` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)

);

CREATE TABLE IF NOT EXISTS `ezbasket` (
  `id` int NOT NULL,
  `order_id` int NOT NULL DEFAULT '0',
  `productcollection_id` int NOT NULL DEFAULT '0',
  `session_id` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)

);

CREATE TABLE IF NOT EXISTS `ezcollab_group` (
  `created` int NOT NULL DEFAULT '0',
  `depth` int NOT NULL DEFAULT '0',
  `id` int NOT NULL,
  `is_open` int NOT NULL DEFAULT '1',
  `modified` int NOT NULL DEFAULT '0',
  `parent_group_id` int NOT NULL DEFAULT '0',
  `path_string` varchar(255) NOT NULL DEFAULT '',
  `priority` int NOT NULL DEFAULT '0',
  `title` varchar(255) NOT NULL DEFAULT '',
  `user_id` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)

);

CREATE TABLE IF NOT EXISTS `ezcollab_item` (
  `created` int NOT NULL DEFAULT '0',
  `creator_id` int NOT NULL DEFAULT '0',
  `data_float1` float NOT NULL DEFAULT '0',
  `data_float2` float NOT NULL DEFAULT '0',
  `data_float3` float NOT NULL DEFAULT '0',
  `data_int1` int NOT NULL DEFAULT '0',
  `data_int2` int NOT NULL DEFAULT '0',
  `data_int3` int NOT NULL DEFAULT '0',
  `data_text1` longtext NOT NULL,
  `data_text2` longtext NOT NULL,
  `data_text3` longtext NOT NULL,
  `id` int NOT NULL,
  `modified` int NOT NULL DEFAULT '0',
  `status` int NOT NULL DEFAULT '1',
  `type_identifier` varchar(40) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)

);

CREATE TABLE IF NOT EXISTS `ezcollab_item_group_link` (
  `collaboration_id` int NOT NULL DEFAULT '0',
  `created` int NOT NULL DEFAULT '0',
  `group_id` int NOT NULL DEFAULT '0',
  `is_active` int NOT NULL DEFAULT '1',
  `is_read` int NOT NULL DEFAULT '0',
  `last_read` int NOT NULL DEFAULT '0',
  `modified` int NOT NULL DEFAULT '0',
  `user_id` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`collaboration_id`,`group_id`,`user_id`)

);

CREATE TABLE IF NOT EXISTS `ezcollab_item_message_link` (
  `collaboration_id` int NOT NULL DEFAULT '0',
  `created` int NOT NULL DEFAULT '0',
  `id` int NOT NULL,
  `message_id` int NOT NULL DEFAULT '0',
  `message_type` int NOT NULL DEFAULT '0',
  `modified` int NOT NULL DEFAULT '0',
  `participant_id` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)

);

CREATE TABLE IF NOT EXISTS `ezcollab_item_participant_link` (
  `collaboration_id` int NOT NULL DEFAULT '0',
  `created` int NOT NULL DEFAULT '0',
  `is_active` int NOT NULL DEFAULT '1',
  `is_read` int NOT NULL DEFAULT '0',
  `last_read` int NOT NULL DEFAULT '0',
  `modified` int NOT NULL DEFAULT '0',
  `participant_id` int NOT NULL DEFAULT '0',
  `participant_role` int NOT NULL DEFAULT '1',
  `participant_type` int NOT NULL DEFAULT '1',
  PRIMARY KEY (`collaboration_id`,`participant_id`)

);

CREATE TABLE IF NOT EXISTS `ezcollab_item_status` (
  `collaboration_id` int NOT NULL DEFAULT '0',
  `is_active` int NOT NULL DEFAULT '1',
  `is_read` int NOT NULL DEFAULT '0',
  `last_read` int NOT NULL DEFAULT '0',
  `user_id` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`collaboration_id`,`user_id`)

);

CREATE TABLE IF NOT EXISTS `ezcollab_notification_rule` (
  `collab_identifier` varchar(255) NOT NULL DEFAULT '',
  `id` int NOT NULL,
  `user_id` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)

);

CREATE TABLE IF NOT EXISTS `ezcollab_profile` (
  `created` int NOT NULL DEFAULT '0',
  `data_text1` longtext NOT NULL,
  `id` int NOT NULL,
  `main_group` int NOT NULL DEFAULT '0',
  `modified` int NOT NULL DEFAULT '0',
  `user_id` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)

);

CREATE TABLE IF NOT EXISTS `ezcollab_simple_message` (
  `created` int NOT NULL DEFAULT '0',
  `creator_id` int NOT NULL DEFAULT '0',
  `data_float1` float NOT NULL DEFAULT '0',
  `data_float2` float NOT NULL DEFAULT '0',
  `data_float3` float NOT NULL DEFAULT '0',
  `data_int1` int NOT NULL DEFAULT '0',
  `data_int2` int NOT NULL DEFAULT '0',
  `data_int3` int NOT NULL DEFAULT '0',
  `data_text1` longtext NOT NULL,
  `data_text2` longtext NOT NULL,
  `data_text3` longtext NOT NULL,
  `id` int NOT NULL,
  `message_type` varchar(40) NOT NULL DEFAULT '',
  `modified` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)

);

CREATE TABLE IF NOT EXISTS `ezcontentbrowserecent` (
  `created` int NOT NULL DEFAULT '0',
  `id` int NOT NULL,
  `name` varchar(255) NOT NULL DEFAULT '',
  `node_id` int NOT NULL DEFAULT '0',
  `user_id` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)

);

CREATE TABLE IF NOT EXISTS `ezcurrencydata` (
  `auto_rate_value` decimal(10,5) NOT NULL DEFAULT '0.00000',
  `code` varchar(4) NOT NULL DEFAULT '',
  `custom_rate_value` decimal(10,5) NOT NULL DEFAULT '0.00000',
  `id` int NOT NULL,
  `locale` varchar(255) NOT NULL DEFAULT '',
  `rate_factor` decimal(10,5) NOT NULL DEFAULT '1.00000',
  `status` int NOT NULL DEFAULT '1',
  `symbol` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)

);

CREATE TABLE IF NOT EXISTS `ezdiscountrule` (
  `id` int NOT NULL,
  `name` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)

);

CREATE TABLE IF NOT EXISTS `ezdiscountsubrule` (
  `discount_percent` float DEFAULT NULL,
  `discountrule_id` int NOT NULL DEFAULT '0',
  `id` int NOT NULL,
  `limitation` char(1) DEFAULT NULL,
  `name` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)

);

CREATE TABLE IF NOT EXISTS `ezdiscountsubrule_value` (
  `discountsubrule_id` int NOT NULL DEFAULT '0',
  `issection` int NOT NULL DEFAULT '0',
  `value` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`discountsubrule_id`,`value`,`issection`)

);

CREATE TABLE IF NOT EXISTS `ezenumobjectvalue` (
  `contentobject_attribute_id` int NOT NULL DEFAULT '0',
  `contentobject_attribute_version` int NOT NULL DEFAULT '0',
  `enumelement` varchar(255) NOT NULL DEFAULT '',
  `enumid` int NOT NULL DEFAULT '0',
  `enumvalue` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`contentobject_attribute_id`,`contentobject_attribute_version`,`enumid`)

);

CREATE TABLE IF NOT EXISTS `ezenumvalue` (
  `contentclass_attribute_id` int NOT NULL DEFAULT '0',
  `contentclass_attribute_version` int NOT NULL DEFAULT '0',
  `enumelement` varchar(255) NOT NULL DEFAULT '',
  `enumvalue` varchar(255) NOT NULL DEFAULT '',
  `id` int NOT NULL,
  `placement` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`,`contentclass_attribute_id`,`contentclass_attribute_version`)

);

CREATE TABLE IF NOT EXISTS `ezforgot_password` (
  `hash_key` varchar(32) NOT NULL DEFAULT '',
  `id` int NOT NULL,
  `time` int NOT NULL DEFAULT '0',
  `user_id` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)

);

CREATE TABLE IF NOT EXISTS `ezgeneral_digest_user_settings` (
  `day` varchar(255) NOT NULL DEFAULT '',
  `digest_type` int NOT NULL DEFAULT '0',
  `id` int NOT NULL,
  `receive_digest` int NOT NULL DEFAULT '0',
  `time` varchar(255) NOT NULL DEFAULT '',
  `user_id` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)

);

CREATE TABLE IF NOT EXISTS `ezisbn_group` (
  `description` varchar(255) NOT NULL DEFAULT '',
  `group_number` int NOT NULL DEFAULT '0',
  `id` int NOT NULL,
  PRIMARY KEY (`id`)

);

CREATE TABLE IF NOT EXISTS `ezisbn_group_range` (
  `from_number` int NOT NULL DEFAULT '0',
  `group_from` varchar(32) NOT NULL DEFAULT '',
  `group_length` int NOT NULL DEFAULT '0',
  `group_to` varchar(32) NOT NULL DEFAULT '',
  `id` int NOT NULL,
  `to_number` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)

);

CREATE TABLE IF NOT EXISTS `ezisbn_registrant_range` (
  `from_number` int NOT NULL DEFAULT '0',
  `id` int NOT NULL,
  `isbn_group_id` int NOT NULL DEFAULT '0',
  `registrant_from` varchar(32) NOT NULL DEFAULT '',
  `registrant_length` int NOT NULL DEFAULT '0',
  `registrant_to` varchar(32) NOT NULL DEFAULT '',
  `to_number` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)

);

CREATE TABLE IF NOT EXISTS `ezmessage` (
  `body` longtext,
  `destination_address` varchar(50) NOT NULL DEFAULT '',
  `id` int NOT NULL,
  `is_sent` int NOT NULL DEFAULT '0',
  `send_method` varchar(50) NOT NULL DEFAULT '',
  `send_time` varchar(50) NOT NULL DEFAULT '',
  `send_weekday` varchar(50) NOT NULL DEFAULT '',
  `title` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)

);

CREATE TABLE IF NOT EXISTS `ezmodule_run` (
  `function_name` varchar(255) DEFAULT NULL,
  `id` int NOT NULL,
  `module_data` longtext,
  `module_name` varchar(255) DEFAULT NULL,
  `workflow_process_id` int DEFAULT NULL,
  PRIMARY KEY (`id`)

);

CREATE TABLE IF NOT EXISTS `ezmultipricedata` (
  `contentobject_attr_id` int NOT NULL DEFAULT '0',
  `contentobject_attr_version` int NOT NULL DEFAULT '0',
  `currency_code` varchar(4) NOT NULL DEFAULT '',
  `id` int NOT NULL,
  `type` int NOT NULL DEFAULT '0',
  `value` decimal(15,2) NOT NULL DEFAULT '0.00',
  PRIMARY KEY (`id`)

);

CREATE TABLE IF NOT EXISTS `eznotificationcollection` (
  `data_subject` longtext NOT NULL,
  `data_text` longtext NOT NULL,
  `event_id` int NOT NULL DEFAULT '0',
  `handler` varchar(255) NOT NULL DEFAULT '',
  `id` int NOT NULL,
  `transport` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)

);

CREATE TABLE IF NOT EXISTS `eznotificationcollection_item` (
  `address` varchar(255) NOT NULL DEFAULT '',
  `collection_id` int NOT NULL DEFAULT '0',
  `event_id` int NOT NULL DEFAULT '0',
  `id` int NOT NULL,
  `send_date` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)

);

CREATE TABLE IF NOT EXISTS `eznotificationevent` (
  `data_int1` int NOT NULL DEFAULT '0',
  `data_int2` int NOT NULL DEFAULT '0',
  `data_int3` int NOT NULL DEFAULT '0',
  `data_int4` int NOT NULL DEFAULT '0',
  `data_text1` longtext NOT NULL,
  `data_text2` longtext NOT NULL,
  `data_text3` longtext NOT NULL,
  `data_text4` longtext NOT NULL,
  `event_type_string` varchar(255) NOT NULL DEFAULT '',
  `id` int NOT NULL,
  `status` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)

);

CREATE TABLE IF NOT EXISTS `ezoperation_memento` (
  `id` int NOT NULL,
  `main` int NOT NULL DEFAULT '0',
  `main_key` varchar(32) NOT NULL DEFAULT '',
  `memento_data` longtext NOT NULL,
  `memento_key` varchar(32) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`,`memento_key`)

);

CREATE TABLE IF NOT EXISTS `ezorder` (
  `account_identifier` varchar(100) NOT NULL DEFAULT 'default',
  `created` int NOT NULL DEFAULT '0',
  `data_text_1` longtext,
  `data_text_2` longtext,
  `email` varchar(150) DEFAULT '',
  `id` int NOT NULL,
  `ignore_vat` int NOT NULL DEFAULT '0',
  `is_archived` int NOT NULL DEFAULT '0',
  `is_temporary` int NOT NULL DEFAULT '1',
  `order_nr` int NOT NULL DEFAULT '0',
  `productcollection_id` int NOT NULL DEFAULT '0',
  `status_id` int DEFAULT '0',
  `status_modified` int DEFAULT '0',
  `status_modifier_id` int DEFAULT '0',
  `user_id` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)

);

CREATE TABLE IF NOT EXISTS `ezorder_item` (
  `description` varchar(255) DEFAULT NULL,
  `id` int NOT NULL,
  `is_vat_inc` int NOT NULL DEFAULT '0',
  `order_id` int NOT NULL DEFAULT '0',
  `price` float DEFAULT NULL,
  `type` varchar(30) DEFAULT NULL,
  `vat_value` float NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)

);

CREATE TABLE IF NOT EXISTS `ezorder_nr_incr` (
  `id` int NOT NULL,
  PRIMARY KEY (`id`)

);

CREATE TABLE IF NOT EXISTS `ezorder_status` (
  `id` int NOT NULL,
  `is_active` int NOT NULL DEFAULT '1',
  `name` varchar(255) NOT NULL DEFAULT '',
  `status_id` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)

);

CREATE TABLE IF NOT EXISTS `ezorder_status_history` (
  `id` int NOT NULL,
  `modified` int NOT NULL DEFAULT '0',
  `modifier_id` int NOT NULL DEFAULT '0',
  `order_id` int NOT NULL DEFAULT '0',
  `status_id` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)

);

CREATE TABLE IF NOT EXISTS `ezpaymentobject` (
  `id` int NOT NULL,
  `order_id` int NOT NULL DEFAULT '0',
  `payment_string` varchar(255) NOT NULL DEFAULT '',
  `status` int NOT NULL DEFAULT '0',
  `workflowprocess_id` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)

);

CREATE TABLE IF NOT EXISTS `ezpdf_export` (
  `created` int DEFAULT NULL,
  `creator_id` int DEFAULT NULL,
  `export_classes` varchar(255) DEFAULT NULL,
  `export_structure` varchar(255) DEFAULT NULL,
  `id` int NOT NULL,
  `intro_text` longtext,
  `modified` int DEFAULT NULL,
  `modifier_id` int DEFAULT NULL,
  `pdf_filename` varchar(255) DEFAULT NULL,
  `show_frontpage` int DEFAULT NULL,
  `site_access` varchar(255) DEFAULT NULL,
  `source_node_id` int DEFAULT NULL,
  `status` int DEFAULT NULL,
  `sub_text` longtext,
  `title` varchar(255) DEFAULT NULL,
  `version` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`,`version`)

);

CREATE TABLE IF NOT EXISTS `ezpending_actions` (
  `id` int NOT NULL,
  `action` varchar(64) NOT NULL DEFAULT '',
  `created` int DEFAULT NULL,
  `param` longtext,
  PRIMARY KEY (`id`)

);

CREATE TABLE IF NOT EXISTS `ezprest_authcode` (
  `client_id` varchar(200) NOT NULL DEFAULT '',
  `expirytime` bigint NOT NULL DEFAULT '0',
  `id` varchar(200) NOT NULL DEFAULT '',
  `scope` varchar(200) DEFAULT NULL,
  `user_id` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)

);

CREATE TABLE IF NOT EXISTS `ezprest_authorized_clients` (
  `created` int DEFAULT NULL,
  `id` int NOT NULL,
  `rest_client_id` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  PRIMARY KEY (`id`)

);

CREATE TABLE IF NOT EXISTS `ezprest_clients` (
  `client_id` varchar(200) DEFAULT NULL,
  `client_secret` varchar(200) DEFAULT NULL,
  `created` int NOT NULL DEFAULT '0',
  `description` longtext,
  `endpoint_uri` varchar(200) DEFAULT NULL,
  `id` int NOT NULL,
  `name` varchar(100) DEFAULT NULL,
  `owner_id` int NOT NULL DEFAULT '0',
  `updated` int NOT NULL DEFAULT '0',
  `version` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)

);

CREATE TABLE IF NOT EXISTS `ezprest_token` (
  `client_id` varchar(200) NOT NULL DEFAULT '',
  `expirytime` bigint NOT NULL DEFAULT '0',
  `id` varchar(200) NOT NULL DEFAULT '',
  `refresh_token` varchar(200) NOT NULL DEFAULT '',
  `scope` varchar(200) DEFAULT NULL,
  `user_id` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)

);

CREATE TABLE IF NOT EXISTS `ezproductcategory` (
  `id` int NOT NULL,
  `name` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)

);

CREATE TABLE IF NOT EXISTS `ezproductcollection` (
  `created` int DEFAULT NULL,
  `currency_code` varchar(4) NOT NULL DEFAULT '',
  `id` int NOT NULL,
  PRIMARY KEY (`id`)

);

CREATE TABLE IF NOT EXISTS `ezproductcollection_item` (
  `contentobject_id` int NOT NULL DEFAULT '0',
  `discount` float DEFAULT NULL,
  `id` int NOT NULL,
  `is_vat_inc` int DEFAULT NULL,
  `item_count` int NOT NULL DEFAULT '0',
  `name` varchar(255) NOT NULL DEFAULT '',
  `price` float DEFAULT '0',
  `productcollection_id` int NOT NULL DEFAULT '0',
  `vat_value` float DEFAULT NULL,
  PRIMARY KEY (`id`)

);

CREATE TABLE IF NOT EXISTS `ezproductcollection_item_opt` (
  `id` int NOT NULL,
  `item_id` int NOT NULL DEFAULT '0',
  `name` varchar(255) NOT NULL DEFAULT '',
  `object_attribute_id` int DEFAULT NULL,
  `option_item_id` int NOT NULL DEFAULT '0',
  `price` float NOT NULL DEFAULT '0',
  `value` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)

);

CREATE TABLE IF NOT EXISTS `ezpublishingqueueprocesses` (
  `created` int DEFAULT NULL,
  `ezcontentobject_version_id` int NOT NULL DEFAULT '0',
  `finished` int DEFAULT NULL,
  `pid` int DEFAULT NULL,
  `started` int DEFAULT NULL,
  `status` int DEFAULT NULL,
  PRIMARY KEY (`ezcontentobject_version_id`)

);

CREATE TABLE IF NOT EXISTS `ezrss_export` (
  `access_url` varchar(255) DEFAULT NULL,
  `active` int DEFAULT NULL,
  `created` int DEFAULT NULL,
  `creator_id` int DEFAULT NULL,
  `description` longtext,
  `id` int NOT NULL,
  `image_id` int DEFAULT NULL,
  `main_node_only` int NOT NULL DEFAULT '1',
  `modified` int DEFAULT NULL,
  `modifier_id` int DEFAULT NULL,
  `node_id` int DEFAULT NULL,
  `number_of_objects` int NOT NULL DEFAULT '0',
  `rss_version` varchar(255) DEFAULT NULL,
  `site_access` varchar(255) DEFAULT NULL,
  `status` int NOT NULL DEFAULT '0',
  `title` varchar(255) DEFAULT NULL,
  `url` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`,`status`)

);

CREATE TABLE IF NOT EXISTS `ezrss_export_item` (
  `category` varchar(255) DEFAULT NULL,
  `class_id` int DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `enclosure` varchar(255) DEFAULT NULL,
  `id` int NOT NULL,
  `rssexport_id` int DEFAULT NULL,
  `source_node_id` int DEFAULT NULL,
  `status` int NOT NULL DEFAULT '0',
  `subnodes` int NOT NULL DEFAULT '0',
  `title` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`,`status`)

);

CREATE TABLE IF NOT EXISTS `ezrss_import` (
  `active` int DEFAULT NULL,
  `class_description` varchar(255) DEFAULT NULL,
  `class_id` int DEFAULT NULL,
  `class_title` varchar(255) DEFAULT NULL,
  `class_url` varchar(255) DEFAULT NULL,
  `created` int DEFAULT NULL,
  `creator_id` int DEFAULT NULL,
  `destination_node_id` int DEFAULT NULL,
  `id` int NOT NULL,
  `import_description` longtext NOT NULL,
  `modified` int DEFAULT NULL,
  `modifier_id` int DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `object_owner_id` int DEFAULT NULL,
  `status` int NOT NULL DEFAULT '0',
  `url` longtext,
  PRIMARY KEY (`id`,`status`)

);

CREATE TABLE IF NOT EXISTS `ezscheduled_script` (
  `command` varchar(255) NOT NULL DEFAULT '',
  `id` int NOT NULL,
  `last_report_timestamp` int NOT NULL DEFAULT '0',
  `name` varchar(50) NOT NULL DEFAULT '',
  `process_id` int NOT NULL DEFAULT '0',
  `progress` int DEFAULT '0',
  `user_id` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)

);

CREATE TABLE IF NOT EXISTS `ezsearch_search_phrase` (
  `id` int NOT NULL,
  `phrase` varchar(250) DEFAULT NULL,
  `phrase_count` int DEFAULT '0',
  `result_count` int DEFAULT '0',
  PRIMARY KEY (`id`)

);

CREATE TABLE IF NOT EXISTS `ezsession` (
  `data` longtext NOT NULL,
  `expiration_time` int NOT NULL DEFAULT '0',
  `session_key` varchar(32) NOT NULL DEFAULT '',
  `user_hash` varchar(32) NOT NULL DEFAULT '',
  `user_id` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`session_key`)

);

CREATE TABLE IF NOT EXISTS `ezstarrating` (
  `contentobject_id` int NOT NULL,
  `contentobject_attribute_id` int NOT NULL,
  `rating_average` float NOT NULL,
  `rating_count` int NOT NULL,
  PRIMARY KEY (`contentobject_id`,`contentobject_attribute_id`)

);

CREATE TABLE IF NOT EXISTS `ezstarrating_data` (
  `id` int NOT NULL,
  `created_at` int NOT NULL,
  `user_id` int NOT NULL,
  `session_key` varchar(32) NOT NULL,
  `rating` float NOT NULL,
  `contentobject_id` int NOT NULL,
  `contentobject_attribute_id` int NOT NULL,
  PRIMARY KEY (`id`)

);

CREATE TABLE IF NOT EXISTS `ezsubtree_notification_rule` (
  `id` int NOT NULL,
  `node_id` int NOT NULL DEFAULT '0',
  `use_digest` int DEFAULT '0',
  `user_id` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)

);

CREATE TABLE IF NOT EXISTS `eztipafriend_counter` (
  `count` int NOT NULL DEFAULT '0',
  `node_id` int NOT NULL DEFAULT '0',
  `requested` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`node_id`,`requested`)

);

CREATE TABLE IF NOT EXISTS `eztipafriend_request` (
  `created` int NOT NULL DEFAULT '0',
  `email_receiver` varchar(100) NOT NULL DEFAULT ''

);

CREATE TABLE IF NOT EXISTS `eztrigger` (
  `connect_type` char(1) NOT NULL DEFAULT '',
  `function_name` varchar(200) NOT NULL DEFAULT '',
  `id` int NOT NULL,
  `module_name` varchar(200) NOT NULL DEFAULT '',
  `name` varchar(255) DEFAULT NULL,
  `workflow_id` int DEFAULT NULL,
  PRIMARY KEY (`id`)

);

CREATE TABLE IF NOT EXISTS `ezuser_discountrule` (
  `contentobject_id` int DEFAULT NULL,
  `discountrule_id` int DEFAULT NULL,
  `id` int NOT NULL,
  `name` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)

);

CREATE TABLE IF NOT EXISTS `ezuservisit` (
  `current_visit_timestamp` int NOT NULL DEFAULT '0',
  `failed_login_attempts` int NOT NULL DEFAULT '0',
  `last_visit_timestamp` int NOT NULL DEFAULT '0',
  `login_count` int NOT NULL DEFAULT '0',
  `user_id` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`user_id`)

);

CREATE TABLE IF NOT EXISTS `ezvatrule` (
  `country_code` varchar(255) NOT NULL DEFAULT '',
  `id` int NOT NULL,
  `vat_type` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)

);

CREATE TABLE IF NOT EXISTS `ezvatrule_product_category` (
  `product_category_id` int NOT NULL DEFAULT '0',
  `vatrule_id` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`vatrule_id`,`product_category_id`)

);

CREATE TABLE IF NOT EXISTS `ezvattype` (
  `id` int NOT NULL,
  `name` varchar(255) NOT NULL DEFAULT '',
  `percentage` float DEFAULT NULL,
  PRIMARY KEY (`id`)

);

CREATE TABLE IF NOT EXISTS `ezview_counter` (
  `count` int NOT NULL DEFAULT '0',
  `node_id` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`node_id`)

);

CREATE TABLE IF NOT EXISTS `ezwaituntildatevalue` (
  `contentclass_attribute_id` int NOT NULL DEFAULT '0',
  `contentclass_id` int NOT NULL DEFAULT '0',
  `id` int NOT NULL,
  `workflow_event_id` int NOT NULL DEFAULT '0',
  `workflow_event_version` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`,`workflow_event_id`,`workflow_event_version`)

);

CREATE TABLE IF NOT EXISTS `ezwishlist` (
  `id` int NOT NULL,
  `productcollection_id` int NOT NULL DEFAULT '0',
  `user_id` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)

);

CREATE TABLE IF NOT EXISTS `ezworkflow` (
  `created` int NOT NULL DEFAULT '0',
  `creator_id` int NOT NULL DEFAULT '0',
  `id` int NOT NULL,
  `is_enabled` int NOT NULL DEFAULT '0',
  `modified` int NOT NULL DEFAULT '0',
  `modifier_id` int NOT NULL DEFAULT '0',
  `name` varchar(255) NOT NULL DEFAULT '',
  `version` int NOT NULL DEFAULT '0',
  `workflow_type_string` varchar(50) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`,`version`)

);

CREATE TABLE IF NOT EXISTS `ezworkflow_assign` (
  `access_type` int NOT NULL DEFAULT '0',
  `as_tree` int NOT NULL DEFAULT '0',
  `id` int NOT NULL,
  `node_id` int NOT NULL DEFAULT '0',
  `workflow_id` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)

);

CREATE TABLE IF NOT EXISTS `ezworkflow_event` (
  `data_int1` int DEFAULT NULL,
  `data_int2` int DEFAULT NULL,
  `data_int3` int DEFAULT NULL,
  `data_int4` int DEFAULT NULL,
  `data_text1` varchar(255) DEFAULT NULL,
  `data_text2` varchar(255) DEFAULT NULL,
  `data_text3` varchar(255) DEFAULT NULL,
  `data_text4` varchar(255) DEFAULT NULL,
  `data_text5` longtext,
  `description` varchar(50) NOT NULL DEFAULT '',
  `id` int NOT NULL,
  `placement` int NOT NULL DEFAULT '0',
  `version` int NOT NULL DEFAULT '0',
  `workflow_id` int NOT NULL DEFAULT '0',
  `workflow_type_string` varchar(50) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`,`version`)

);

CREATE TABLE IF NOT EXISTS `ezworkflow_group` (
  `created` int NOT NULL DEFAULT '0',
  `creator_id` int NOT NULL DEFAULT '0',
  `id` int NOT NULL,
  `modified` int NOT NULL DEFAULT '0',
  `modifier_id` int NOT NULL DEFAULT '0',
  `name` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)

);

CREATE TABLE IF NOT EXISTS `ezworkflow_group_link` (
  `group_id` int NOT NULL DEFAULT '0',
  `group_name` varchar(255) DEFAULT NULL,
  `workflow_id` int NOT NULL DEFAULT '0',
  `workflow_version` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`workflow_id`,`group_id`,`workflow_version`)

);

CREATE TABLE IF NOT EXISTS `ezworkflow_process` (
  `activation_date` int DEFAULT NULL,
  `content_id` int NOT NULL DEFAULT '0',
  `content_version` int NOT NULL DEFAULT '0',
  `created` int NOT NULL DEFAULT '0',
  `event_id` int NOT NULL DEFAULT '0',
  `event_position` int NOT NULL DEFAULT '0',
  `event_state` int DEFAULT NULL,
  `event_status` int NOT NULL DEFAULT '0',
  `id` int NOT NULL,
  `last_event_id` int NOT NULL DEFAULT '0',
  `last_event_position` int NOT NULL DEFAULT '0',
  `last_event_status` int NOT NULL DEFAULT '0',
  `memento_key` varchar(32) DEFAULT NULL,
  `modified` int NOT NULL DEFAULT '0',
  `node_id` int NOT NULL DEFAULT '0',
  `parameters` longtext,
  `process_key` varchar(32) NOT NULL DEFAULT '',
  `session_key` varchar(32) NOT NULL DEFAULT '0',
  `status` int DEFAULT NULL,
  `user_id` int NOT NULL DEFAULT '0',
  `workflow_id` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)

);
