# AXI4 ID
## ID 的功能
- 讓 Master 在 **同時有多個 transaction 還沒完成時**，  
知道每一筆回來的 response/data 是屬於哪一筆 request
- 支援 **亂序完成** 和 **交錯傳輸**


## Outstanding ⭢ ID
現在已經做到：
- 同時送出多個 `AW` (`wr_outstanding > 1`)
- 同時送出多個 `AR` (`rd_outstanding > 1`)

但是 **Slave 有權力用任何順序回覆** (不同交易間)

AXI4 沒有規範
- `B` 一定依照 `AW` 順序回
- `R` burst 一定依照 `AR` 順序回

## ID and it's rule
~~ID = burst number~~  
ID = transaction 的名字 (tag / label)
- 同個 burst 的所有 data beats → **同一個 ID**
- 不同 burst → **ID 可以相同或不同** (由 Master 決定)

#### Rule 1: 同個 ID 的 transaction 必須 in-order
    
- 所以 out-of-order 只發生在 **不同 ID 之間**

#### Rule 2: 不同 ID 的 transaction 可以完全亂序


#### Rule 3: ID 是 Master 的責任

## Write and Read
### Write
AXI4 取消了 `WID`，所以寫入的亂序只發生在 `B` Channel，`W` channel 無法亂序  

ex~
1. Master 發出 `AWID` = 0 (Addr A)
2. Master 發出 `AWID` = 1 (Addr B)
3. Master 依序送出 Data A, Data B (`W` Channel 沒 ID，只能依序)
4. Slave 處理 B 比較快，先回傳 `BID` = 1 (`BVALID`)
5. Master 收到，標記 B 交易完成
6. Slave 處理 A 完畢，回傳 `BID` = 0 (`BVALID`)。

### Read
支援 Read Data Interleaving (讀取資料交錯)  


ex~ 假設 Burst Length = 2 beats
1. Master 發出 `ARID` = 0 (Addr A)
2. Master 發出 `ARID` = 1 (Addr B)
3. Slave 回傳資料流可能長這樣：
    - `RID` = 1, Data = B0 (B 的第一筆先回來!)
    - `RID` = 0, Data = A0 (A 的第一筆)
    - `RID` = 1, Data = B1 (B 結束)
    - `RID` = 0, Data = A1 (A 結束)


