# Openwrtデバイスでの結果

### 評価したデバイス

bcm4708：ARM Cortex-A9 Broadcom BCM4708A0 800MHz 2C2T  
mt7621：MIPS MediaTek MT7621AT 880MHz 2C4T  
mt7622: MIPS MediaTek MT7622B 1350MHz 2C2T
---
### 更新
202501: mt7622のルータが手に入ったので評価  

### 総評

傾向としては単純にCPUの強さ（シングルスレッドの強さ）とコードの成熟度(おそらくARMのほうが成熟度が高い)に比例していると思われる。  
mt7612は2013年くらいから家庭用市販ルータによく使用されており、各社から出ていた。  
2023年現在ではAArch64(ARM 64Bit)のSoCを使う事例が多いため、新しくこれを採用しようというのはあまり無い。  
bcm4708は2011年からの少し高めの市販ルータでの採用例が何例かあるだけで、あまり見かけない。  
  
2024年末あたりからmt7622採用の家庭用ルータにMT7622がようやく中古に降りてくる事例が出始めている。（2025年1月で5000円くらい）  
他の方の評判の通り、MT7621のものと比べてもAESの性能もCPUの性能も段違いなため、OpenWRT化したい人は見かけたら即入手をおすすめする  
    
MT7621とbcm4708の比較はbcm4708のほうが暗号化性能が高い＝シングルスレッド性能が高いと思われる。  
（が、bcm4708は2C2T、mt7621は2C4Tなので並列にジョブが発生した場合はどうなるか…によるとも言えるかもしれない）  
  
通常こういった組み込み向け用途のCPU(SoC)は、AESやSHA用のアクセラレータが入っていることがあるがこれらにも入っているかどうかは不明。  
仮に入っていたとしても、わざわざOpenWrtのopensslライブラリから叩くコードを実装しているとも思えず、この結果はやはりCPUの性能そのものである。  

MT7622のほうはcpuinfoでもaesやshaの項目が見えていたので、Openwrt側でもARMV8のオプションが有効になっていてARMV8Aの暗号化拡張命令が使用されているようで、暗号化処理のパフォーマンスがRaspberry PI 4よりも断然高くなっている  

また、bcm4708はARMV7(Cortex-A9)であるのでAArch64にあるようなAESやSHAの拡張命令も無くそこまで速度は伸びていない。  
Intel i7-950と比べても遅いので、2023年に出ているN100やN95のいわゆるAlder Lake-Nの廉価版を使ってOpenWrtルータを自作した場合はかなりのパフォーマンスが得られるものと思われる。  
(しかもN100はAES-NI拡張命令も使えるのでi7-950よりも良いパフォーマンスが得られる)

MT7621とbcm4708はAESで暗号化するよりもChacha-polyで暗号化したほうが良い結果が得られている。  
OpenWrtでVPNを建てる場合、OpenVPNを使う場合はOpenWrtのバージョンが21.04以上だと暗号にChacha-polyが使用可能になるので設定をし直すとOpenVPNでも良好なパフォーマンスが得られるかもしれない。  
(OpenVPNは2.5以降でChacha-polyをサポート)  
  
21.04以下の場合は、wireguardを使ったほうが良い結果が得られる  
  
MT7622はAESを使ったほうが早いので素直にAESを使ったほうがパフォーマンスが出る。  
素のCPUの強さも流石にMT7621よりは高いので、Chachapolyでも悪くはないがといった感じ。  

---
### 測定結果

・共通鍵暗号系(16384 bytes)
|  ターゲット  |  AES-128-CBC | AES-256-CBC | AES-128-GCM | AES-256-GCM | ChaPoly |
|  ----  |  ----:  | ----: | ----: | ----: | ----: | 
|  bcm4708  | 23571.11k | 18137.09k | 11539.80k | 10169.00k | 48239.96k |
|  mt7621   | 12225.40k | 9275.19k | 6096.37k | 5258.12k | 20722.22k | 
|  mt7622   | 1016960.34k | 626469.55k | 646075.73k | 571381.08k | 225897.13k | 

・ハッシュ系(16384 bytes)
|  ターゲット  | SHA1 | SHA256 | SHA512 | BLAKE2s256 | BLAKE2b512 |
|  ----  |  ----:  | ----: | ----: | ----: | ----: | 
|  bcm4708  | 58654.72k | 35820.89k | 16569.69k | unknown | unknown |
|  mt7621   | 51508.90k | 22480.37k | 7217.67k | unknown | unknown | 
|  mt7622   | 596765.35k | 562801.32k | 136205.65k | unknown | unknown | 

・楕円暗号と公開鍵認証
|  ターゲット  | op/s(X25519) | op/s(X448) | sign/s(Ed25519) | verify/s(Ed25519) | sign/s(Ed448) | verify/s(Ed448) |
|  ----  |  ----:  | ----: | ----: | ----: | ----: | ----: | 
|  bcm4708  | 644.4 | 96.7 | 1532.7 | 564.9 | 231.9 | 87.6 | 
|  mt7621  | 602.1 | 62.9 | 1207.5 | 559.9 | 136.1 | 56.7 | 
|  mt7622  |  2315.3 | 448.8 | 3283.5 | 1696.9 | 586.0 | 422.4 | 
