- シーケンステーブルの作成
CREATE TABLE sequence_table (
    name VARCHAR(50) NOT NULL PRIMARY KEY,
    current_value BIGINT NOT NULL,
    increment INT NOT NULL DEFAULT 1,
    comment VARCHAR(100)
) ENGINE=InnoDB;

- 初期データの投入
INSERT INTO sequence_table (name, current_value, increment, comment) 
VALUES ('SEQUENCE_NO', 0, 1, '管理番号用シーケンス');

- シーケンス取得用の関数
DELIMITER //

CREATE FUNCTION get_sequence_id(sequence_name VARCHAR(50)) 
RETURNS BIGINT
DETERMINISTIC
BEGIN
    DECLARE next_val BIGINT;
    
    -- FOR UPDATEで行ロックを取得
    SELECT current_value INTO next_val 
    FROM sequence_table 
    WHERE name = sequence_name
    FOR UPDATE;
    
    -- 値を更新
    UPDATE sequence_table 
    SET current_value = next_val + increment 
    WHERE name = sequence_name;
    
    -- 次の値を返却
    RETURN next_val + 1;
END //

DELIMITER ;

- 使用例 :
SELECT get_sequence_id('SEQUENCE_NO');
