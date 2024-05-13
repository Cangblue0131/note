##############
##  一般 KM 圖
##############

#install.packages("survival")
library(survival)

data <- read.csv('D:/github/note/R/存活分析/data1.csv')

data_group1 = data[data$group == 1,] # 取得 group == 1 的 data
data_group2 = data[data$group == 2,]

# 估計生存函數
fit1 <- survfit(Surv(Survivaltime, Status) ~ 1, data=data_group1)
# 繪製KM圖 (虛線為95%信賴區間)
plot(fit1, xlab="Time", ylab="Survival Probability", main="Kaplan-Meier Survival Curve")


# 估計生存函數
fit2 <- survfit(Surv(Survivaltime, Status) ~ 1, data=data_group2)
# 繪製KM圖
lines(fit2, col = 'red')



###############
### 生命表 KM
###############

data <- read.csv('D:/github/note/R/存活分析/data2.csv')
data$P = data$deaths/(data$n - data$cencoring/2)
data$"1-P" = 1 - data$P
data$ST = cumprod(data$'1-P') # 計算累乘結果

x = as.numeric(sub(".*~", "", data$year)) # .*~代表~前面的所有字串, 都用""取代
y = data$ST
y <- c(1, y)


# 使用 stepfun 創建階梯狀函數
step_fun <- stepfun(x, y)

# 繪製階梯狀圖
plot(step_fun, verticals = TRUE, main = "Step Plot")

  
  
  


