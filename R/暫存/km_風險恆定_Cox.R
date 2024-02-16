# 生成模拟数据
set.seed(123)  # 设置随机种子以确保结果可重复

# 创建示例数据框
data <- data.frame(
  Time = c(rexp(50, rate = 0.1), rexp(50, rate = 0.2)),  # 时间数据，使用指数分布生成
  Event = c(rep(1, 50), rep(1, 50)),  # 事件数据，假设所有样本都发生了事件
  Treatment = factor(rep(c("A", "B"), each = 50)),  # 处理变量，假设有两个水平
  Censored = sample(c(0, 1), 100, replace = TRUE)  # 截断信息，假设随机生成截断信息，0表示未截断，1表示截断
)

# 查看数据集前几行
head(data)

library(survival)

# 使用 survfit() 函数计算不同处理水平的生存曲线
surv_object <- survfit(Surv(Time, Event) ~ Treatment, data = data)

# 绘制 Kaplan-Meier 生存曲线
plot(surv_object, col = c("blue", "red"), lwd = 2,
     xlab = "Time", ylab = "Survival Probability",
     main = "Kaplan-Meier Survival Curve by Treatment")

# 找到被截断的观察值索引
censored_idx <- which(data$Censored == 1)

# 在KM图上标记被截断的观察值
points(surv_object$time[censored_idx], surv_object$surv[censored_idx], col = "black", pch = 3)

# 找到存活率为 75%、50% 和 25% 对应的时间点
quantiles <- quantile(surv_object$time, probs = c(0.25, 0.5, 0.75))

# 在KM图上添加垂直线
abline(v = quantiles, col = "black", lty = 2)



# 进行Log-Rank检验
result <- survdiff(Surv(Time, Event) ~ Treatment, data = data)
print(result)



data <- data.frame(
  Time = c(rexp(50, rate = 0.1), rexp(50, rate = 0.2)),  # 时间数据，使用指数分布生成
  Event = c(rep(1, 50), rep(1, 50)),  # 事件数据，假设所有样本都发生了事件
  Treatment = factor(rep(c("A", "B"), each = 50)),  # 处理变量，假设有两个水平
  Censored = sample(c(0, 1), 100, replace = TRUE),  # 截断信息，假设随机生成截断信息，0表示未截断，1表示截断
  Covariate1 = sample(c(0,1,2), 100, replace = TRUE),
  Covariate2 = c(rexp(50, rate = 0.3), rexp(50, rate = 0.5))
  )



# 拟合 Cox 比例风险模型
cox_model <- coxph(Surv(Time, Event) ~ Treatment + Covariate1 + Covariate2, data = data)

# 进行 Schoenfeld 残差检验
schoenfeld_test <- cox.zph(cox_model)

# 查看检验结果
print(schoenfeld_test)


# 拟合Cox比例风险模型
cox_model <- coxph(Surv(Time, Event) ~ Treatment + Covariate1 + Covariate2, data = data)

# 查看Cox模型的摘要信息
summary(cox_model)







# 安裝必要的套件（如果還未安裝的話）
# install.packages("survival")

library(survival)

# 模擬資料
set.seed(123)
n <- 100  # 樣本數
time <- rexp(n, rate = 0.1)  # 模擬時間數據
event <- rbinom(n, size = 1, prob = 0.7)  # 模擬事件發生數據
treatment <- factor(sample(c("0", "1"), size = n, replace = TRUE))  # 模擬處置變量
covariate1 <- rnorm(n)  # 其他協變量
covariate2 <- rnorm(n)  # 其他協變量

# 模擬設限資料（假設時間大於某個值為設限）
censored_time <- ifelse(time > 5, 5, time)  # 模擬設限資料

# 建立資料框
data <- data.frame(Time = censored_time, Event = event, Treatment = treatment, Covariate1 = covariate1, Covariate2 = covariate2)


# 擬合 Kaplan-Meier 模型
km_fit <- survfit(Surv(Time, Event) ~ Treatment, data = data)

# 繪製 Kaplan-Meier 曲線
install.packages("survminer")

library(survminer)
ggsurvplot(km_fit, data = data, risk.table = TRUE, pval = TRUE, conf.int = TRUE, legend.labs = c("Treatment 0", "Treatment 1"))
