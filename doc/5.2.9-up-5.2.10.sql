SET FOREIGN_KEY_CHECKS = 0;
ALTER TABLE `cms_content` DROP COLUMN `content_url`;
ALTER TABLE `cms_content` ADD COLUMN `content_out_link` varchar(255) NULL DEFAULT NULL COMMENT '文章为链接' AFTER `content_hit`;

UPDATE `mcms`.`mdiy_tag` SET `tag_name` = 'arclist', `tag_type` = 'list', `tag_sql` = ' <#assign _typeid=\'\'/>\r\n<#assign _typetitle=\'\'/>\r\n<#assign _size=\'20\'/>\r\n\r\n<#if column?? && column.id?? && column.id?number gt 0>\r\n  <#assign  _typeid=\'${column.id}\'>\r\n</#if>\r\n\r\n<#if typeid??>\r\n  <#assign  _typeid=\'${typeid}\'>\r\n</#if>\r\n\r\n<#if typetitle??>\r\n  <#assign  _typetitle=\'${typetitle}\'>\r\n</#if>\r\n\r\n<#if size??>\r\n  <#assign  _size=\'${size}\'>\r\n</#if>\r\n\r\n<#if orderby?? >\r\n    <#if orderby==\'date\'>\r\n      <#assign  _orderby=\'content_datetime\'>\r\n  <#elseif orderby==\'updatedate\'>\r\n    <#assign  _orderby=\'cms_content.update_date\'>\r\n    <#elseif orderby==\'hit\'>\r\n      <#assign  _orderby=\'content_hit\'>\r\n    <#elseif orderby==\'sort\'>\r\n      <#assign  _orderby=\'content_sort\'>\r\n    <#else>\r\n        <#assign  _orderby=\'cms_content.content_datetime\'>\r\n     </#if>\r\n<#else>\r\n    <#assign  _orderby=\'cms_content.content_datetime\'>\r\n</#if>\r\n\r\nSELECT\r\n  cms_content.id AS id,\r\n  content_title AS title,\r\n  content_title AS fulltitle,\r\n  content_author AS author,\r\n  content_source AS source,\r\n  content_details AS content,\r\n  category.category_title AS typetitle,\r\n  category.id AS typeid,\r\ncategory.category_path AS typepath,\r\n  category.category_img AS typelitpic,\r\n  category.category_keyword as typekeyword,\r\n  category.top_id as topId,\r\n  category.category_parent_ids as parentids,\r\n  category.category_type AS \"type\",\r\n\r\n  <#--列表页动态链接-->\r\n  <#if isDo?? && isDo>\r\n    CONCAT(\'/${modelName}/list.do?typeid=\', category.category_id) as typelink,\r\n  <#else>\r\n    (SELECT \'index.html\') AS typelink,\r\n  </#if>\r\n    content_description AS descrip,\r\n    content_hit AS hit,\r\n    content_type AS flag,\r\n    cms_content.content_keyword AS keyword,\r\n    content_img AS litpic,\r\n\r\n  <#--内容页动态链接-->\r\n  <#if isDo?? && isDo>\r\n    CONCAT(\'/${modelName}/view.do?id=\', cms_content.id,\'&orderby=${_orderby}\',\'&order=${order!\'ASC\'}\',\'&typeid=${typeid}\') as \"link\",\r\n  <#else>\r\n    CONCAT(category.category_path,\'/\',if(category_type=2,\"index\",cms_content.id),\'.html\') AS \"link\",\r\n  </#if>\r\n\r\n  <#if tableName??>${tableName}.*,</#if>\r\n  content_datetime AS \"date\"\r\nFROM\r\n  cms_content LEFT JOIN cms_category as category\r\n  ON cms_content.category_id = category.id\r\n\r\n  <#--判断是否有自定义模型表-->\r\n  <#if tableName??>\r\n    LEFT JOIN ${tableName} ON ${tableName}.link_id=cms_content.id\r\n  </#if>\r\n  WHERE\r\n    content_display=0\r\n    and cms_content.del=0\r\n    <#--根据站点编号查询-->\r\n    <#if appId?? >\r\n      and cms_content.app_id=${appId}\r\n    </#if>\r\n    <#--判断是否有搜索分类集合-->\r\n    <#if search?? && _typeid==\"\">\r\n      <#if search.categoryIds?has_content>and FIND_IN_SET(category.id,\'${search.categoryIds}\')</#if>\r\n        <#--标题-->\r\n        <#if search.content_title??> and content_title like CONCAT(\'%\',\'${search.content_title}\',\'%\')</#if>\r\n        <#--作者-->\r\n        <#if search.content_author??> and content_author like CONCAT(\'%\',\'${search.content_author}\',\'%\')</#if>\r\n        <#--来源-->\r\n        <#if search.content_source??> and content_source like CONCAT(\'%\',\'${search.content_source}\',\'%\')</#if>\r\n        <#--属性-->\r\n        <#if search.content_type??> and  (\r\n          <#list search.content_type?split(\',\') as item>\r\n            <#if item?index gt 0> or</#if>\r\n            FIND_IN_SET(\'${item}\',cms_content.content_type)\r\n          </#list>)\r\n        </#if>\r\n\r\n        <#--描述-->\r\n        <#if search.content_description??>\r\n        and content_description like CONCAT(\'%\',\'${search.content_description}\',\'%\')\r\n        </#if>\r\n\r\n        <#--关键字-->\r\n        <#if search.content_keyword??> and content_keyword like CONCAT(\'%\',\'${search.content_keyword}\',\'%\')</#if>\r\n\r\n        <#--内容-->\r\n        <#if search.content_details??> and content_details like CONCAT(\'%\',\'${search.content_details}\',\'%\')</#if>\r\n\r\n    <#--自定义顺序-->\r\n        <#if search.content_sort??> and content_sort=${search.content_sort}</#if>\r\n    <#--时间范围-->\r\n        <#if search.content_datetime_start??&&search.content_datetime_end??>\r\n          and content_datetime between \'${search.content_datetime_start}\' and \'${search.content_datetime_end}\'\r\n        </#if>\r\n    <#else>\r\n      <#--查询栏目-->\r\n      <#if _typeid?has_content>\r\n        and (cms_content.category_id=${_typeid} or cms_content.category_id in (select id FROM cms_category where cms_category.del=0\r\n        <#if _typetitle?has_content>\r\n        and cms_category.category_title=\'${_typetitle}\'</#if> and FIND_IN_SET(${_typeid},CATEGORY_PARENT_IDS)))\r\n        </#if>\r\n    </#if>\r\n      <#--标题-->\r\n      <#if content_title??> and content_title like CONCAT(\'%\',\'${content_title}\',\'%\')</#if>\r\n      <#--作者-->\r\n      <#if content_author??> and content_author like CONCAT(\'%\',\'${content_author}\',\'%\')</#if>\r\n      <#--来源-->\r\n      <#if content_source??> and content_source like CONCAT(\'%\',\'${content_source}\',\'%\')</#if>\r\n      <#--属性-->\r\n      <#if content_type??> and content_type like CONCAT(\'%\',\'${content_type}\',\'%\')</#if>\r\n      <#--描述-->\r\n      <#if content_description??> and content_description like CONCAT(\'%\',\'${content_description}\',\'%\')</#if>\r\n      <#--关键字-->\r\n      <#if content_keyword??> and content_keyword like CONCAT(\'%\',\'${content_keyword}\',\'%\')</#if>\r\n      <#--内容-->\r\n      <#if content_details??> and content_details like CONCAT(\'%\',\'${content_details}\',\'%\')</#if>\r\n      <#--自定义顺序-->\r\n      <#if content_sort??> and content_sort=${content_sort}</#if>\r\n      <#--自定义模型-->\r\n      <#if diyModel??>\r\n        <#list diyModel as dm>\r\n          <#assign json=\"${dm}\"?eval />\r\n          and ${tableName}.${json.key} like CONCAT(\'%\',\'${json.value}\',\'%\')\r\n        </#list>\r\n      </#if>\r\n      <#--文章属性-->\r\n      <#if flag?? >\r\n        and(\r\n          <#list flag?split(\',\') as item>\r\n          <#if item?index gt 0> or</#if>\r\n          FIND_IN_SET(\'${item}\',cms_content.content_type)\r\n          </#list>)\r\n      </#if>\r\n      <#if noflag??>\r\n          and(\r\n          <#list noflag?split(\',\') as item>\r\n          <#if item?index gt 0> and</#if>\r\n          FIND_IN_SET(\'${item}\',cms_content.content_type)=0\r\n          </#list> or cms_content.content_type is null)\r\n      </#if>\r\n\r\n      <#--字段排序-->\r\n      <#if orderby?? >\r\n      ORDER BY\r\n          <#if orderby==\'date\'> content_datetime\r\n          <#elseif orderby==\'updatedate\'> cms_content.update_date\r\n          <#elseif orderby==\'hit\'> content_hit\r\n          <#elseif orderby==\'sort\'> content_sort\r\n        <#else>\r\n          cms_content.content_datetime\r\n        </#if>\r\n  <#else>\r\n      ORDER BY   cms_content.content_datetime\r\n  </#if>\r\n\r\n  <#if order?? >\r\n    <#if order==\'desc\'> desc</#if>\r\n    <#if order==\'asc\'> asc</#if>\r\n  <#else>\r\n    desc\r\n  </#if>\r\n    LIMIT\r\n  <#--判断是否分页-->\r\n  <#if ispaging?? && (pageTag.pageNo)??>\r\n      ${((pageTag.pageNo-1)*_size?eval)?c},${_size?default(20)}\r\n    <#else>\r\n      ${_size?default(20)}\r\n    </#if>\r\n', `tag_class` = NULL, `tag_description` = '文章列表', `UPDATE_BY` = NULL, `UPDATE_DATE` = NULL, `CREATE_BY` = NULL, `CREATE_DATE` = NULL, `DEL` = 0, `NOT_DEL` = 1 WHERE `id` = 3;
UPDATE `mcms`.`mdiy_tag` SET `tag_name` = 'channel', `tag_type` = 'list', `tag_sql` = '<#assign _typeid=\'0\'/>\r\n<#if column?? && column.id?? && column.id?number gt 0>\r\n  <#assign  _typeid=\'${column.id}\'>\r\n  <#assign  selfid=\'${column.id}\'>\r\n</#if>\r\n\r\n<#if typeid??>\r\n  <#assign  _typeid=\'${typeid}\'>\r\n</#if>\r\n\r\nselect\r\n  id,\r\n  id as typeid,\r\n  category_title as typetitle,\r\n  <#--动态链接-->\r\n  <#if isDo?? && isDo>\r\n  CONCAT(\'/${modelName}/list.do?typeid=\', id) as typelink,\r\n  <#else>\r\n    <#--栏目类型为链接-->\r\n    CONCAT(category_path,\'/index.html\') as typelink,\r\n  </#if>\r\n  category_keyword as typekeyword,\r\n  category_diy_url as typeurl,\r\n  category_flag as flag,\r\n  category_parent_ids as parentids,\r\n  category_descrip as typedescrip,\r\n  category_type as type,\r\n  category_path as typepath,\r\n  leaf as typeleaf,\r\n  category_img as typelitpic ,\r\n  ( SELECT count(*) FROM cms_category cc WHERE cc.category_id = cms_category.id AND cc.del = 0 ) AS childsize \r\n  from cms_category\r\n  where\r\n  cms_category.del=0\r\n  <#--根据站点编号查询-->\r\n  <#if appId?? >\r\n    and cms_category.app_id=${appId}\r\n  </#if>\r\n\r\n  <#--栏目属性-->\r\n  <#if flag?? >\r\n  and\r\n    (<#list flag?split(\',\') as item>\r\n      <#if item?index gt 0> or</#if>\r\n    FIND_IN_SET(\'${item}\',category_flag)\r\n    </#list>)\r\n  </#if>\r\n\r\n  <#if noflag?? >\r\n    and\r\n    (<#list noflag?split(\',\') as item>\r\n      <#if item?index gt 0> and</#if>\r\n      FIND_IN_SET(\'${item}\',category_flag)=0\r\n    </#list> or category_flag is null)\r\n  </#if>\r\n\r\n  <#--type默认son-->\r\n  <#if !type??||!type?has_content>\r\n    <#assign type=\'son\'/>\r\n  </#if>\r\n\r\n  <#if type?has_content>\r\n  <#--顶级栏目（单个）-->\r\n    <#if type==\'top\'>\r\n      <#if _typeid != \'0\'>\r\n        and (id = top_id or top_id = 0)\r\n      </#if>\r\n\r\n    <#elseif type==\'nav\'>\r\n      and(category_id=0 or category_id is null)\r\n\r\n    <#--同级栏目（多个）-->\r\n    <#elseif type==\'level\'>\r\n      \r\n      <#if _typeid != \'0\'>\r\n        and category_id=(select category_id from cms_category where id=${_typeid})\r\n      \r\n      </#if>\r\n\r\n    <#--当前栏目（单个）-->\r\n  <#elseif type==\'self\'>\r\n     \r\n     <#if _typeid != \'0\'>\r\n      and id=${_typeid}\r\n     </#if>\r\n\r\n    <#--当前栏目的所属栏目（多个）-->\r\n  <#elseif type==\'path\'>\r\n      \r\n     <#if _typeid != \'0\'>\r\n       and id in (<#if column?? && column.categoryParentIds??>${column.categoryParentIds},</#if>${_typeid})\r\n     </#if>\r\n    <#--子栏目（多个）-->\r\n\r\n  <#elseif type==\'son\'>\r\n      \r\n     <#if _typeid != \'0\'>\r\n      and category_id=${_typeid}\r\n     </#if>\r\n\r\n  <#--上一级栏目没有则取当前栏目（单个）-->\r\n  <#elseif type==\'parent\'>\r\n     <#if _typeid != \'0\'>\r\n      and\r\n       <#if column?? && column.categoryId??>\r\n        id=${column.categoryId}\r\n       <#else>\r\n        id=${_typeid}\r\n       </#if>\r\n     </#if>\r\n  </#if>\r\n\r\n<#else> <#--默认顶级栏目-->\r\n   and\r\n  <#if _typeid != \'0\'>\r\n   id=${_typeid}\r\n  <#else>\r\n   (category_id=0 or category_id is null)\r\n  </#if>\r\n\r\n</#if>\r\n\r\n<#--字段排序-->\r\n<#if type == \'path\'>\r\n	ORDER BY category_path asc\r\n<#else>\r\n	<#if orderby?? >\r\n		ORDER \r\n		<#if orderby==\'date\'> category_datetime\r\n		<#elseif orderby==\'sort\'> category_sort\r\n		<#else>id</#if>\r\n	</#if>\r\n\r\n	<#if order?? >\r\n		<#if order==\'desc\'> desc</#if>\r\n		<#if order==\'asc\'> asc</#if>\r\n	</#if>\r\n</#if>', `tag_class` = NULL, `tag_description` = '通用栏目', `UPDATE_BY` = NULL, `UPDATE_DATE` = NULL, `CREATE_BY` = NULL, `CREATE_DATE` = NULL, `DEL` = 0, `NOT_DEL` = 1 WHERE `id` = 4;
UPDATE `mcms`.`mdiy_tag` SET `tag_name` = 'global', `tag_type` = 'single', `tag_sql` = 'select\nAPP_NAME as name,\napp_logo as logo,\napp_keyword as keyword,\napp_description as descrip,\napp_copyright as copyright,\n<#--动态解析 -->\n<#if isDo?? && isDo>\nCONCAT(\'${url}\',\'${html}/\',app_dir) as url,\n\'${url}\' as host,\n<#--使用地址栏的域名 -->\n<#elseif url??>\nCONCAT(\'${url}\',\'${html}/\',app_dir) as url,\n\'${url}\' as host,\n<#else>\nCONCAT(REPLACE(REPLACE(TRIM(substring_index(app_url,\'\\n\',1)), CHAR(10),\'\'), CHAR(13),\'\'),\'/html/\',app_dir) as url,\nREPLACE(REPLACE(TRIM(substring_index(app_url,\'\\n\',1)), CHAR(10),\'\'), CHAR(13),\'\') as host,\n</#if>\nCONCAT(\'template/\',id,\'/\',app_style) as \"style\" <#-- 判断是否为手机端 -->\nfrom app\n<#--根据站点编号查询-->\n<#if appId?? >\n  where id = ${appId}\n</#if>', `tag_class` = NULL, `tag_description` = '全局', `UPDATE_BY` = NULL, `UPDATE_DATE` = NULL, `CREATE_BY` = NULL, `CREATE_DATE` = NULL, `DEL` = 0, `NOT_DEL` = 1 WHERE `id` = 5;
UPDATE `mcms`.`mdiy_tag` SET `tag_name` = 'field', `tag_type` = 'single', `tag_sql` = 'SELECT\ncms_content.id as id,\ncontent_title as title,\ncontent_author as author, \ncontent_source as source, \ncontent_details as content,\ncms_category.id as typeid,\ncms_category.leaf as typeleaf,\ncms_category.category_title as typetitle,\ncms_category.category_img AS typelitpic,\ncms_category.top_id as topId,\ncms_category.category_flag as typeflag,\ncms_category.category_parent_ids as parentids,\ncms_category.category_keyword as typekeyword,\ncms_category.category_descrip as typedescrip,\ncms_category.category_diy_url as typeurl,\n<#--动态链接-->\n<#if isDo?? && isDo>\nCONCAT(\'/${modelName}/list.do?typeid=\', cms_category.id) as typelink,\n<#else>\n	<#--栏目类型为链接-->\n	CONCAT(cms_category.category_path,\'/index.html\') as typelink,\n</#if>\ncms_content.content_img AS litpic,\n<#--内容页动态链接-->\n<#if isDo?? && isDo>\nCONCAT(\'/mcms/view.do?id=\', cms_content.id) as \"link\",\n<#else>\nCONCAT(cms_category.category_path,\'/\',cms_content.id,\'.html\') AS \"link\",\n</#if>\ncontent_datetime as \"date\",\ncontent_description as descrip,\nCONCAT(\'<script type=\"text/javascript\" src=\"${url}/cms/content/\',cms_content.id,\'/hit.do\"></script>\') as hit,\ncontent_type as flag,\ncategory_title as typetitle,\n<#if tableName??>${tableName}.*,</#if>\ncontent_keyword as keyword\nFROM cms_content\nLEFT JOIN cms_category  ON\ncms_category.id = cms_content.category_id\n<#--判断是否有自定义模型表-->\n<#if tableName??>left join ${tableName} on ${tableName}.link_id=cms_content.id</#if>\nWHERE\n<#--如果是栏目列表页没有文章id所以只取栏目id-->\n<#if column??&&column.id??&&!id??>\ncms_category.id=${column.id} and\n</#if>\n cms_content.del=0\n<#if id??> and cms_content.id=${id}</#if>', `tag_class` = NULL, `tag_description` = '文章内容', `UPDATE_BY` = NULL, `UPDATE_DATE` = NULL, `CREATE_BY` = NULL, `CREATE_DATE` = NULL, `DEL` = 0, `NOT_DEL` = 1 WHERE `id` = 7;
UPDATE `mcms`.`mdiy_tag` SET `tag_name` = 'pre', `tag_type` = 'single', `tag_sql` = '<#assign select=\"(SELECT \'\')\"/>\n<#if orderby?? >\n      <#if orderby==\"date\">\n       <#assign  _orderby=\"content_datetime\">\n      <#elseif orderby==\"updatedate\">\n <#assign  _orderby=\"cms_content.update_date\">\n      <#elseif orderby==\"hit\">\n      <#assign  _orderby=\"content_hit\">\n      <#elseif orderby==\"sort\">\n       <#assign  _orderby=\"content_sort\">\n      <#else><#assign  _orderby=\"cms_content.id\"></#if>\n   <#else>\n   <#assign  _orderby=\"cms_content.id\">\n  </#if>\n<#if pageTag.preId??>\nSELECT\ncms_content.id as id,\ncontent_title as title,\ncontent_author as author, \ncontent_source as source, \ncontent_details as content,\ncategory.category_title as typename,\ncategory.category_id as typeid,\n(SELECT \'index.html\') as typelink,\ncontent_img as litpic,\n<#--内容页动态链接-->\n  <#if isDo?? && isDo>\n   CONCAT(\'/${modelName}/view.do?id=\', cms_content.id,\'&orderby=${_orderby}\',\'&order=${order!\'ASC\'}\',\'&typeid=${typeid}\') as \"link\",\n  <#else>\n  CONCAT(category_path,\'/\',cms_content.id,\'.html\') AS \"link\",\n  </#if>\ncontent_datetime as \"date\",\ncontent_description as descrip,\ncontent_hit as hit,\ncontent_type as flag,\ncontent_keyword as keyword \nFROM cms_content\nLEFT JOIN cms_category as category ON cms_content.category_id=category.id\nWHERE cms_content.id=${pageTag.preId}\n<#else>\nSELECT\n${select} as id,\n${select} as title,\n${select} as fulltitle,\n${select} as author, \n${select} as source, \n${select} as content,\n${select} as typename,\n${select} as typeid,\n${select} as typelink,\n${select} as litpic,\n${select} as \"link\",\n${select} as \"date\",\n${select} as descrip,\n${select} as hit,\n${select} as flag,\n${select} as keyword\n</#if>', `tag_class` = NULL, `tag_description` = '文章上一篇', `UPDATE_BY` = NULL, `UPDATE_DATE` = NULL, `CREATE_BY` = NULL, `CREATE_DATE` = NULL, `DEL` = 0, `NOT_DEL` = 1 WHERE `id` = 8;
UPDATE `mcms`.`mdiy_tag` SET `tag_name` = 'page', `tag_type` = 'single', `tag_sql` = 'select\n<#if !(pageTag.indexUrl??)>\n  <#--判断是否有栏目对象，用于搜索不传栏目-->\n  <#if column??>\n    <#assign path=column.categoryPath/>\n  <#else>\n    <#assign path=\"\"/>\n  </#if>\n  <#--总记录数、总页数-->\n  (SELECT ${pageTag.total}) as \"total\",\n  (SELECT ${pageTag.size}) as \"size\",\n\n  <#--记录总数-->\n  (SELECT ${pageTag.rcount}) as \"rcount\",\n  <#--当前页码-->\n  (SELECT ${pageTag.pageNo}) as \"cur\",\n  <#--首页-->\n  CONCAT(\'${path}\', \'/index.html\') as \"index\",\n  <#--上一页-->\n  <#if (pageTag.pageNo?eval-1) gt 1>\n    CONCAT(\'${path}\',\'/list-${pageTag.pageNo?eval-1}.html\') as \"pre\",\n  <#else>\n    CONCAT(\'${path}\',\'/index.html\') as \"pre\",\n  </#if>\n\n  <#--下一页-->\n  <#if pageTag.total==1>\n  CONCAT(\'${path}\', \'/index.html\') as \"next\",\n  CONCAT(\'${path}\', \'/index.html\') as \"last\"\n  <#else>\n    <#if pageTag.pageNo?eval gte pageTag.total>\n    CONCAT(\'${path}\',\'/list-${pageTag.total}.html\') as \"next\",\n    <#else>\n    CONCAT(\'${path}\',\'/list-${pageTag.pageNo?eval+1}.html\') as \"next\",\n    </#if>\n  <#--最后一页-->\n  CONCAT(\'${path}\',\'/list-${pageTag.total}.html\') as \"last\"\n  </#if>\n\n<#else>\n  <#--判断是否是搜索页面-->\n  \'${pageTag.indexUrl}\' as \"index\",\n  \'${pageTag.lastUrl}\' as \"last\",\n  \'${pageTag.preUrl}\' as \"pre\",\n  \'${pageTag.nextUrl}\' as \"next\",\n  (select ${pageTag.total}) as \"total\",\n  (select ${pageTag.size}) as \"size\",\n  (select ${pageTag.rcount}) as \"rcount\",\n  (select ${pageTag.pageNo}) as \"cur\"\n</#if>', `tag_class` = NULL, `tag_description` = '通用分页', `UPDATE_BY` = NULL, `UPDATE_DATE` = NULL, `CREATE_BY` = NULL, `CREATE_DATE` = NULL, `DEL` = 0, `NOT_DEL` = 1 WHERE `id` = 9;
UPDATE `mcms`.`mdiy_tag` SET `tag_name` = 'next', `tag_type` = 'single', `tag_sql` = '<#assign select=\"(SELECT \'\')\"/>\n<#if orderby?? >\n      <#if orderby==\"date\">\n	   <#assign  _orderby=\"content_datetime\">\n      <#elseif orderby==\"updatedate\">\n <#assign  _orderby=\"cms_content.update_date\">\n      <#elseif orderby==\"hit\">\n	  <#assign  _orderby=\"content_hit\">\n      <#elseif orderby==\"sort\">\n	   <#assign  _orderby=\"content_sort\">\n      <#else><#assign  _orderby=\"cms_content.id\"></#if>\n   <#else>\n   <#assign  _orderby=\"cms_content.id\">\n  </#if>\n<#if pageTag.nextId??>\nSELECT\ncms_content.id as id,\ncontent_title as title,\ncontent_author as author, \ncontent_source as source, \ncontent_details as content,\ncategory.category_title as typename,\ncategory.category_id as typeid,\n(SELECT \'index.html\') as typelink,\ncontent_img as litpic,\n<#--内容页动态链接-->\n  <#if isDo?? && isDo>\n   CONCAT(\'/${modelName}/view.do?id=\', cms_content.id,\'&orderby=${_orderby}\',\'&order=${order!\'ASC\'}\',\'&typeid=${typeid}\') as \"link\",\n  <#else>\n  CONCAT(category_path,\'/\',cms_content.id,\'.html\') AS \"link\",\n  </#if>\ncontent_datetime as \"date\",\ncontent_description as descrip,\ncontent_hit as hit,\ncontent_type as flag,\ncontent_keyword as keyword \nFROM cms_content\nLEFT JOIN cms_category as category ON cms_content.category_id=category.id\nWHERE cms_content.id=${pageTag.nextId}\n<#else>\nSELECT\n${select} as id,\n${select} as title,\n${select} as fulltitle,\n${select} as author, \n${select} as source, \n${select} as content,\n${select} as typename,\n${select} as typeid,\n${select} as typelink,\n${select} as litpic,\n${select} as \"link\",\n${select} as \"date\",\n${select} as descrip,\n${select} as hit,\n${select} as flag,\n${select} as keyword \n</#if>\n', `tag_class` = NULL, `tag_description` = '文章下一篇', `UPDATE_BY` = NULL, `UPDATE_DATE` = NULL, `CREATE_BY` = NULL, `CREATE_DATE` = NULL, `DEL` = 0, `NOT_DEL` = 1 WHERE `id` = 10;
UPDATE `mcms`.`mdiy_tag` SET `tag_name` = 'diyform', `tag_type` = 'macro', `tag_sql` = '<#macro ms_diyform formName>\n<div id=\"form\" v-cloak style=\"width: 30%; margin: 5% auto\">\n  <div id=\"formModel\">\n    <!--会自动渲染代码生成器的表单-->\n  </div>\n  <!--必须包含验证码-->\n  <el-form ref=\"form\" :model=\"form\" :rules=\"rules\" label-position=\"right\" size=\"large\" label-width=\"120px\">\n    <el-row :gutter=\"0\" justify=\"start\" align=\"top\">\n      <el-col :span=\"12\">\n        <el-form-item label=\"验证码\" prop=\"rand_code\">\n          <el-input\n                  v-model=\"form.rand_code\"\n                  :disabled=\"false\"\n                  :readonly=\"false\"\n                  :clearable=\"true\"\n                  placeholder=\"请输入验证码\">\n          </el-input>\n        </el-form-item>\n      </el-col>\n      <el-col :span=\"12\">\n        <div style=\"display: flex; height: 38px;margin-left: 1em; align-items: center; cursor: pointer\">\n          <img :src=\"verifCode\" class=\"code-img\" @click=\"code\"/>\n          <div @click=\"code\" style=\"margin-left: 10px\">\n            看不清？换一张\n          </div>\n        </div>\n      </el-col>\n    </el-row>\n    <el-form-item label=\"  \">\n      <el-button @click=\"save\" type=\"primary\" :loading=\"isLoading\" style=\"width: 200px\">\n        {{isLoading ? \'保存中\' : \'保存\'}}\n      </el-button>\n    </el-form-item>\n  </el-form>\n</div>\n<script>\n  //vue的实例名称必须为 from\n  var form = new Vue({\n    el: \'#form\',\n    data: {\n      formModel: undefined, //自定义业务的vue对象\n      verifCode:  \"/code?t=\" + new Date().getTime(),\n      isLoading: false,\n      form: {\n        rand_code: \'\'\n      },\n      rules: {\n        rand_code: [\n          {required: true, message: \'请输入验证码\', trigger: \'blur\'},\n          {min: 1, max: 4, message: \'长度不能超过4个字符\', trigger: \'change\'}\n        ],\n      },\n    },\n    methods: {\n      save: function () {\n        var that = this;\n        that.isLoading = true;\n        //将验证码值复制到自定义模型\n        form.formModel.form.rand_code = this.form.rand_code;\n        //调用自定义模型的保存\n        that.formModel.save(function (res) {\n          if (res.result) {\n            that.$notify({\n              title: \'成功\',\n              type: \'success\',\n              message: \'保存成功!\'\n            });\n\n          } else {\n            that.$notify({\n              title: \'失败\',\n              message: res.msg,\n              type: \'warning\'\n            });\n          }\n          that.isLoading = false;\n        });\n      },\n      code: function () {\n        this.verifCode = \"/code?t=\" + (new Date).getTime();\n      }\n    },\n    created: function () {\n      var that = this;\n      ms.mdiy.model.form(\"formModel\", { \"modelName\": \"${formName}\" }).then(function(obj) {\n        that.formModel = obj;\n      });\n    }\n  });\n</script>\n</#macro>', `tag_class` = NULL, `tag_description` = '智能表单', `UPDATE_BY` = '79', `UPDATE_DATE` = '2022-08-11 09:43:34', `CREATE_BY` = NULL, `CREATE_DATE` = NULL, `DEL` = 0, `NOT_DEL` = 1 WHERE `id` = 11;

SET FOREIGN_KEY_CHECKS = 1;