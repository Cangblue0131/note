set.seed(2023)
x <- rnorm(50, mean = c(rep(0, 25), rep(3, 25)))
p <- 2 * pnorm(sort(-abs(x)))

### 手動操作
FDR_test = c()
for (i in 1:length(p)){
  FDR_test = c(FDR_test, p[i] * length(p) / i)
}
for (i in length(p):2){
  if (FDR_test[i] < FDR_test[i-1]){
    FDR_test[i-1] = FDR_test[i]
  }
}
FDR_test #FDR

### 使用套件
p.adjust(p, "BH", n = 50) #FDR

## 輸出給 python 用
write.csv(x, file =  paste0(getwd(), "/python/分析相關/012.特徵相關/特徵分析/FDR_data.csv"))
