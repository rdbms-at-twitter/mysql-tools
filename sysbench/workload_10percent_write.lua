#!/usr/bin/env sysbench

require("oltp_common")

-- 最大IDを保持する変数
local max_rental_id = 0

function prepare_statements()
   -- Prepare statements if needed
end

function thread_init()
    drv = sysbench.sql.driver()
    con = drv:connect()
    
    -- 最大rental_idを取得
    local rs = con:query("SELECT MAX(rental_id) FROM rental")
    local row = rs:fetch_row()
    if row then
        max_rental_id = tonumber(row[1]) or 0
    end
end

function event()
    -- 10%の確率で更新処理を実行
    local operation = sysbench.rand.uniform(1, 100)
    
    if operation <= 10 and max_rental_id > 0 then
        -- 10%: UPDATE処理
        local random_rental_id = sysbench.rand.uniform(1, max_rental_id)
        con:query(string.format([[
            UPDATE rental 
            SET last_update = NOW() 
            WHERE rental_id = %d
        ]], random_rental_id))
    end
    
    -- 既存の参照クエリ（90%以上の確率で実行）
    con:query([[select @@global.general_log]])
    con:query([[select * from rental limit 10]])
    con:query([[select customer_id,count(*) total from rental group by customer_id order by total desc limit 19]])
    con:query([[select customer_id,count(*) total from rental group by customer_id order by total desc limit 10]])
    con:query([[show tables]])
    con:query([[select * from staff limit 10]])
    con:query([[show tables]])
    con:query([[select * from film limit 10]])
    con:query([[select * from film limit 1]])
    con:query([[select length,count(*) film_length from film group by length order by film_length desc limit 10]])
    con:query([[select length film_length from film group by length order by length desc limit 10]])
    con:query([[select @@version_comment limit 1]])
    con:query([[select USER()]])
    con:query([[show global variables like '%general%']])
    con:query([[show global variables like '%general%']])
end

function thread_done()
    con:disconnect()
end
