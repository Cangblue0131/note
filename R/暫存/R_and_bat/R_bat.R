## 輸入N, 建立 N*2 的模擬值儲存於當前資料夾, 檔案名稱為N
# 讀取從bat檔案傳遞的N值
N <- as.numeric(commandArgs(trailingOnly = TRUE))

# 生成N行2列的隨機正態分佈數據
data <- matrix(rnorm(2 * N), ncol = 2)

# 將數據保存到csv檔案中
write.csv(data, file = paste0("data_N_", N, ".csv"), row.names = FALSE)
