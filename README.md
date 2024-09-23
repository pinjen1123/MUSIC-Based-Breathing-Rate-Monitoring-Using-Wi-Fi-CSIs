"# MUSIC-Based-Breathing-Rate-Monitoring-Using-Wi-Fi-CSIs" 

P. -J. Lai, Y. -S. Zhan, W. -L. Yeh, M. -L. Ku and C. -M. Yu, "MUSIC-Based Breathing Rate Monitoring Using Wi-Fi CSI," 2022 IEEE 13th Annual Ubiquitous Computing, Electronics & Mobile Communication Conference (UEMCON), New York, NY, NY, USA, 2022, pp. 0380-0384, doi: 10.1109/UEMCON54665.2022.9965699.

-----------------------------------------------------------------
1. CSI收發、檔案存取(terminal運行)
相關檔案：
csi_inject.sh ----------- 發射端設定檔
csi_receive.sh ---------- 接收端設定檔
log_to_file.c ----------- (檔案存成.dat檔)
log_to_server.c	--------- (檔案傳回發送端)

-----------------------------------------------------------------
2. 檔案讀取、計算過程(matlab運行)
主要內容在 folder: \linux-80211n-csitool-supplementary\matlab\
file: new_lineartransform_with_music.m (離線計算)
此檔案為直接讀取.dat檔，直接計算
CSI收發的一段時間後，會存為.dat檔，此檔案為讀取.dat後做計算。(可直接run)
file: realtime_csi_music.m (實時化計算)
此檔案需要兩台主機搭配，進行CSI收發的同時，會邊讀取邊計算。

-----------------------------------------------------------------

參考資料：
https://dhalperi.github.io/linux-80211n-csitool/
https://blog.csdn.net/James_Bond_slm/article/details/117432357
https://www.ebaina.com/articles/140000005367
https://blog.csdn.net/qq_20386411/article/details/83384614?spm=1001.2101.3001.6650.4&utm_medium=distribute.pc_relevant.none-task-blog-2%7Edefault%7ECTRLIST%7ERate-4.pc_relevant_paycolumn_v3&depth_1-utm_source=distribute.pc_relevant.none-task-blog-2%7Edefault%7ECTRLIST%7ERate-4.pc_relevant_paycolumn_v3&utm_relevant_index=8
https://blog.csdn.net/u014645508/article/details/82887470?utm_source=blogxgwz2
