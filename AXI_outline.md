# AXI 概要

## CPU 和 AXI 之間的關係
CPU 需要
- 讀 instruction
- 讀 / 寫 data
- 連接記憶體 (RAM / DDR)
- 連接周邊 (UART, Timer, GPIO)

關鍵問題
> CPU 要如何跟 **外界** 溝通

##### 有 3 種可能
1. 自己定義一套 protocol (像是課堂作業)
2. 用簡單匯流排 (ex~ Wishbone, AHB)
3. 用業界標準匯流排 (AXI)

在 Xilinx / FPGA / SoC 世界中
> 99 % 的 IP 都只會講 AXI

## AXI 是什麼
> 一套非常正式，規則很嚴格的 **記憶體存取對話標準**

### AXI (AXI4 / AXI4-Lite)
用途: CPU <-> Memory / Register
- 有 address
- 有 read / write
- 有 response
- 有 burst
### AXI-Stream (AXIS)
用途: 資料流 (沒有 address)
- 只有 `tdata / tvalid / tready / tlast`
- 不關心位址


### AXI Verification IP (VIP)
這不是硬體，而是 **測試用的假設備**

它可以
- 假裝成一個 AXI Master (like CPU)
- 假裝成一個 AXI Slave (like Memory)
- 檢查有沒有違反 protocol
- 產生 transcation

假設我寫了一個 CPU AXI Master
##### 沒有 VIP，當 CPU 沒反應，會不知道錯在哪
- timing?
- protocol?
- memory 沒回應?
##### 有 VIP，VIP 假裝 memory 告訴我們
- 在 data 還沒 ready 就拉 valid
- response 沒等就下一筆
- 違反 AXI ordering





## 學習順序
1. 先理解「為什麼 CPU 需要 bus」
2. 再理解 AXI 的「角色模型」
   - Master / Slave
   - Read / Write
   - valid / ready
3. 只學 AXI4-Lite（不是完整 AXI4）
4. 再看 AXI VIP「怎麼幫你驗證」
5. 最後再回來寫 CPU


