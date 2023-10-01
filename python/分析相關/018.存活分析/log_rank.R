#install.packages("survival")

# 載入 survival 套件
library(survival)

# 創建一個示例數據集
time <- c(5, 10, 15, 20, 25, 30)
event <- c(1, 1, 1, 0, 1, 0)  # 1 表示事件發生，0 表示事件未發生
group <- factor(c("A", "A", "A", "B", "B", "B"))  # 這是兩個不同組的示例

# 創建 survival 物件
surv_obj <- Surv(time, event, type="right")

# 執行 Log-Rank 檢驗
logrank_test <- survdiff(surv_obj ~ group)
print(logrank_test)
