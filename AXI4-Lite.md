# AXI4-Lite
## 來學 AXI4-Lite 吧 !
AXI4-Lite 相比 AXI4，少了 burst 的功能。因此比 AXI4 interface 簡單一些，但是最基礎的功能不變。  
柿子先挑軟的吃，來了解了解 AXI4-Lite 在做啥。

### Signal
AXI4-Lite interface 有 5 個 channels
- Read Address
- Read Data
- Write Address
- Write Data
- Write Response
#### Global Signals
|name |descrption|
|-|-|
|ACLK|Global clock source|
|ARESETn|Global reset source, active LOW|


#### Write Address Channel
|name|Source|Description|
|-|-|-|
|AWVALID|Master|Write address valid. Master generates this signal when Write Address and control signals are valid|
|AWREADY|Slave|Write address ready. Slave gererates this signal when it can accept Write Address and control signals|
|AWADDR|Master|Write address, usually 32-bit wide
|AWPROT|Master|Protection type. Slave IP usually ignores and Master IP generates transactions with Normal, Secure and Data attributes (000)|


#### Write Data Channel
|name|Source|Description|
|-|-|-|
|WVALID|Master|Write valid. This signal indicates that valid write data and strobes are available.
|WREADY|Slave|Write ready. This signal indicates that the slave can accept the write data|
|WDATA|Master| Write data (32-bit only)|
|WSTRB|Master| Write strobes. 4-bit signal indicating which of the 4-bytes of Write Data. Slaves can choose assume all bytes are valid|


#### Write Response Channel
|name|Source|Description|
|-|-|-|
|BVALID|Slave| Write response valid. Slave generates this signal when the write response on the bus is valid.
|BREADY|Master|Response ready. Master generates this signal when it can accept a write response|
|BRESP|Slave|Write response. This signal indicates the status of the write transaction|


#### Read Address Channel
|name|Source|Description|
|-|-|-|
|ARVALID| Master|Read address valid. Master generates this signal when Read Address and the control signals are valid|
|ARREADY| Slave|Read address ready. Slave generates this signal when it can accept the read address and control signals|
|ARADDR| Master|Read address, usually 32-bit wide|
|ARPROT| Master| Protection type. Xilinx IP usually ignores as a slave. As a master IP generates transactions with Normal, Secure, and Data attributes (000)|


### Read Data Channel
|name|Source|Description|
|-|-|-|
|RVALID|Slave| Read valid. Slave generates this signal when Read Data is valid|
|RREADY |Master| Read ready. Master generates this signal when it can accept the Read Data and response|
|RDATA|Slave| Read data (32-bit only)
|RRESP|Slave| Read response. This signal indicates the status of data transfer|



## 簡單的例子
### AXI4-Lite 世界觀  
|CPU 動作| AXI 動作|  
|-|-|  
|Store|送 address -> 送 data -> 等 OK|
|Load |送 address -> 等 data|

發送端送 `valid` 訊號，接收端送 `ready` 訊號
每個操作都用 `valid / ready` 確認  
**只有在 `valid && ready == 1` 的那個 cycle，事情才真的發生**


### 寫入 (Store)
假設我的 CPU 要做
```clike
*(0x8000) = 0x12345678;
```
AXI4-Lite 寫入被拆成 3 個部分
#### 1. 寫入位址 (Write Address Channel)
我要送：
- `AWADDR = 0x8000`
- `AWVALID = 1`

等對方：
- `AWREADY = 1`

#### 2. 寫入資料 (Write Data Channel)
我要送：
- `WDATA = 0x12345678`
- `WSTRB = 4'b1111 (全部 byte 都寫)`
- `WVALID = 1`

等對方：
- `WREADY = 1`

##### AXI 規定：
- address 和 data 是 **兩條獨立通道**
- 不保證誰先 ready (但 AXI4-Lite Slave 通常會同時 ready)
- 也因此 CPU 可以在同個 cycle 寫地址和寫資料，不須分兩個 cycle，可以同時發生，也可以分先後

#### 3. 寫入回應 (Write Response Channel)
對方會送：
- `BVALID = 1` 
- `BRESP = OKAY` `(2'b00)`

我要回：
- `BREADY = 1`

CPU 在這之前不能繼續下一筆 store

#### Finite state machine of write
```clike
IDLE
 ↓
SEND_AW + SEND_W
 ↓
WAIT_B
 ↓
IDLE
```

### 讀取 (Load)
假設我的 CPU 要做：
```clike
r1 = *(0x8000);
```
AXI4-Lite 讀取只有兩部分
#### 1. 讀取位址 (Read Address Channel)
我要送：
- `ARADDR = 0x8000`
- `ARVAILD = 1`

等對方：
- `ARREADY = 1`

#### 2. 讀取資料 (Read Data Channel)
對方送：
- `RDATA`
- `RVALID = 1`
- `RRESP = OKAY`

我回送：
- `RREADY = 1`

**只有在 `RVALID && RREADY == 1` 的那一拍，我才能 latch 資料**

#### Finite state machine for read
```clike
IDLE
 ↓
SEND_AR
 ↓
WAIT_R
 ↓
IDLE
```





## reference  
1. [RealDigital](https://www.realdigital.org/doc/a9fee931f7a172423e1ba73f66ca4081)  
2. [axi_and_ace_protocol_spec 載點](https://documentation-service.arm.com/static/5f915b62f86e16515cdc3b1c)  
  - p29 signal descriptions  
  - p126 AXI-Lite
