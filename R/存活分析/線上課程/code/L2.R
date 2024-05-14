set.seed(123)  # 設定隨機種子以便重現結果
X <- rep(1:5, each=20)  # 生成X值，每個值重複20次
Y <- X * 3 + rnorm(length(X), mean=0, sd=10)  # Y值基於X產生，隨著X增大而增大

data <- data.frame(X, Y)

library(ggplot2)

# 確保X是數值型
data$X_numeric <- as.numeric(as.character(data$X))

# 繪製組合圖
ggplot(data, aes(x=factor(X), y=Y)) +
  geom_boxplot(width=0.7, alpha=0.5, outlier.shape=NA, color="black") +  # 畫出Box Plot
  geom_jitter(aes(x=X_numeric), width=0.2, size=2, color="blue", alpha=0.6) +  # 散點圖，X軸使用數值型
  geom_smooth(aes(x=X_numeric, y=Y), method="lm", se=TRUE, color="red") +  # 回歸線，使用數值型X
  labs(title="Combined Box Plot, Scatter Plot and Regression Line", x="X", y="Y") +
  theme_minimal()

