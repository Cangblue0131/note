# 安裝和載入生存分析套件
#install.packages("survival")

library(survival)

# 創建一個虛擬的生存數據集
set.seed(123)
n <- 100  # 樣本數
time <- rexp(n, rate = 0.2)  # 生成生存時間，假設指數分佈
status <- sample(0:1, n, replace = TRUE)  # 生成事件狀態，0表示設限，1表示事件發生
age <- rnorm(n, mean = 50, sd = 10)  # 自變數1：年齡
sex <- factor(sample(c("男", "女"), n, replace = TRUE))  # 自變數2：性別

# 將數據組合成一個數據框
data <- data.frame(time, status, age, sex)

# 擬合Cox比例風險模型
cox_model <- coxph(Surv(time, status) ~ age + sex, data = data)

# 顯示模型摘要
summary(cox_model)
