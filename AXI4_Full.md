# AXI4 Full
## 前情提要
因為 AXI4 Full protocol spec 蠻複雜的，所以接下來會邊 **建立 AXI4 mental model** 邊 **實作受限版本**，最後再用 spec 補洞。而不是一開始就硬啃 spec  

學習路徑：
1. 知道 AXI4 比 Lite 多了什麼，為什麼要這樣設計
2. 開始 AXI4 Full 受限模式實作
    - 訊號是 AXI Full，行為卻像 AXI-Lite
        ```
        ID = 0
        BURST_LEN = 1
        No outstanding
        ```
    - 加入 burst，但不加 outstanding
    - 加入 outstanding



## AXI4 簡介
### 分 5 個 channel
|Channel|功能
|-|-|
|AW| 寫入 **這筆交易是什麼**|
|W| 寫資料|
|B| 寫入完成的回應|
|AR| 讀取 **這筆交易是什麼**|
|R| 讀出的資料 + 回應|  

  

> **這筆交易是什麼** 的意思 (先看看就好)：  
>AW, AR channel 不只有地址，還有很多欄位要填：  
>1. 地址 `AWADDR`：寫入位址。
>2. 數量 `AWLEN`：一次送 1 個，還是連續送 16 個？
>3. 大小 `AWSIZE`：每個包裹是 32-bit 還是 64-bit 寬？
>4. 堆疊方式 `AWBURST`：地址要自動 +1 ( INCR )，還是固定不動 ( FIXED )？
>5. 優先順序 `AWQOS`：這是急件嗎？
>6. 訂單編號 `AWID`：這是第幾號訂單？（方便亂序回覆）  
>
>所以，**這筆交易是什麼** 的意思是：它會定義這筆傳輸的「格式、長度、類型」。

---
### Valid and Ready
5 個 channel，全都遵守
```clike
if (VALID && READY)
    transfer happens
```
#### Valid
代表 **我現在輸出的這組訊號是穩定且有效的**
#### Ready
代表 **我這拍可以接收**


### ID
#### AXI-Lite 世界觀
- 一次只允許一筆 transaction
- 流程：
    - 送完 address
    - 送完 data
    - 收到 response
    - 才能下一筆 transaction  


slave 完全沒有搞混交易的可能
#### AXI Full 世界觀
例如：
```
Master:
  AW #1 (addr=0x100, ID=3)
  AW #2 (addr=0x200, ID=7)

Slave:
  AWREADY 都收了
  但 #2 比 #1 先完成
```

Slave 回傳：
```
B (ID = 7)
B (ID = 3)
```
假如沒有附上 ID，不知道 response 是給哪筆交易的。  
因為 AXI Full 並不是一筆做完才能做下一筆

### Burst 
#### Burst 是什麼
**一個 address transaction，對應多個 data beat**  
也就像是：
```
AW:
  addr = 0x100
  len  = 7         // total 8 beats
  size = 3'b010    // each data is 4 byte

W:
  beat0
  beat1
  ...
  beat7
```
大多數情況，AXI 都是使用 `INCR (Increment mode) burst`  
Master 只需要在 `AW` 通道講一次地址，Slave 會自動計算後續 data 的位址  
以上述例子來看：  
- Beat 0：寫入 `0x100` (起始點)
- Beat 1：寫入 `0x104` (自動 + 4)
- Beat 2：寫入 `0x108` (自動 + 4)
- ...
- Beat 7：寫入 `0x120` (自動 + 4) ⭢ `WLAST` 拉高，結束

#### 為什麼叫做 "beat"
源自音樂的**節拍**。在這段傳輸中，每次 `VALID` 和 `READY` 握手成功，這動作就叫一個 "beat"

#### 為什麼要 burst
**效率**  
只需要填一次交易內容，剩下時間都在資料傳輸



### Outstanding 是什麼
**address phase 和 data / response phase 完全 pipeline**  
之後用 FIFO + ID table 把它拆開來看


### AXI-Lite vs AXI Full signal
#### 總覽表
| Channel | AXI-Lite           | AXI-Full           |
| ------- | ------------------ | ------------------ |
| AW      | 1 address = 1 data | 1 address = N data |
| W       | 只有 1 beat         | 多個 beat + WLAST  |
| B       | 單一回應             | 同樣，但有 BID     |
| AR      | 同 AW              | 同 AW              |
| R       | 單一 data           | 多 beat + RLAST   |


