-- ---------------------------------------------------
-- 値を動的に変更するクエリ
-- ---------------------------------------------------
DECLARE
  table_name STRING;
SET
  table_name = "テーブル名";

EXECUTE IMMEDIATE FORMAT
(""" SELECT * FROM `プロジェクト名.データセット名.%s` """, table_name);


-- ---------------------------------------------------
-- 別のクエリの結果を配列に受け取って、ループ処理するクエリ
-- ---------------------------------------------------
# 変数の宣言
DECLARE array_name ARRAY<STRING>; # array_name という配列を作ってループを回します
DECLARE x INT64 DEFAULT 1; # array_nameから取り出す際のインデックス

# 別のクエリの結果を配列に格納
SET array_names = (
SELECT ARRAY_AGG(column_nam) as list
FROM (SELECT column_name FROM `project.dataset.table`)
);

# ループ処理
WHILE x <= array_length(array_name) DO
  SELECT *
  FROM `project.dataset.table`
  WHERE column_name=array_name [ORDINAL(x)] # array_nameのX番目の値を取り出す

  SET x = x + 1;
END WHILE;


-- ---------------------------------------------------
-- 特定の時間以前に作成され、特定の文字列を含むテーブルのメタデータを参照するクエリ
-- ---------------------------------------------------
SELECT
  table_Schema,table_name
FROM
  region-asia-northeast1.INFORMATION_SCHEMA.TABLES
WHERE creation_time < '2022-10-14'and table_name like '%any-string%'


-- ---------------------------------------------------
-- ユーザー毎の料金を算出するクエリ
-- ---------------------------------------------------
SELECT
  -- ユーザー名
  user_email,
  -- 課金額($) = 課金対象の参照データ量(B) × 料金体系($6/TB)
  ROUND(SUM(total_bytes_billed)/ pow(1024, 4) * 6, 2) AS price,
FROM
  -- プロジェクトのジョブのメタデータを取得
  `region-asia-northeast1`.INFORMATION_SCHEMA.JOBS_BY_PROJECT
WHERE
  -- 対象のジョブを実行済みのクエリだけにフィルタ
  job_type = "QUERY" AND state = "DONE"
GROUP BY
  -- ユーザー単位で集約
  user_email
