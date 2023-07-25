set.seed(42)
u <- rnorm(100)
v <- rnorm(100, mean = 3,  sd = 2)
w <- rnorm(100, mean = -3, sd = 1)
e <- rnorm(100, mean = 0,  sd = 3)
p <- rnorm(100, mean = 0,  sd = 1)
d <- rnorm(100, mean = 5, sd = 20)
y <- 5 + 4 * u + 3 * v + 2 * w + e + p

y

data <- data.frame( i = 1 : 100,
                    y = y,
                    u = u,
                    v = v,
                    w = w,
                    e = e,
                    d = d)


## 輸出給 python 用
write.csv(data,
            file =  paste0(getwd(),
                 "/python/分析相關/013.監督式學習/001.Regression/mranova_test.csv"),
            row.names = FALSE)
