-- 値を動的に変更するクエリ

DECLARE
  table_name STRING;
SET
  table_name = "テーブル名";

EXECUTE IMMEDIATE FORMAT
(""" SELECT * FROM `プロジェクト名.データセット名.%s` """, table_name);
