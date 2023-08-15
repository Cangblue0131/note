
## 參考1 : https://blog.gtwang.org/r/r-plot-function/2/

########################
#### 散佈圖
########################
#  plot(X, Y
#       xlab : X軸標題
#       ylab : X軸標題
#       main : 大標題
#       xlim : X軸範圍
#       ylim : Y軸範圍
#       pch  : 圖示(int or str)
#       col  : 顏色(int or str)
#       cex  : 大小(int)
#)


X = floor(runif(50,0,11)) # 生成0~10的整數
Y = floor(runif(50,0,11))
df = data.frame(X,Y)
plot(df$X,df$Y)

## 加上標題等
plot(df$X, df$Y, 
    xlab = 'x', # X軸標題
    ylab = 'y', # Y軸標題
    main = 'xy', # 大標題
    xlim = c(0,12), # X軸起始
    ylim = c(0,12)) # Y軸起始


## 加上符號
Z = floor(runif(50,0,11)) 
df = cbind(df, Z)
plot(df$X, df$Y, 
    xlab = 'x', # X軸標題
    ylab = 'y', # Y軸標題
    main = 'xy', # 大標題
    xlim = c(0,12), # X軸起始
    ylim = c(0,12), # Y軸起始
    pch = df$Z ) # 剛好符號對照表的數字多於Z, 所以可以直接用


## 也可以使用條件式, 讓圖形區分開來, 例如 Z < 5的同個符號, > 5 的同個
df$Z = ifelse(df$Z < 5, 1, 16) #以1圖畫<5, 16圖畫>=5
plot(df$X, df$Y, 
    xlab = 'x', # X軸標題
    ylab = 'y', # Y軸標題
    main = 'xy', # 大標題
    xlim = c(0,12), # X軸起始
    ylim = c(0,12), # Y軸起始
    pch = df$Z ) # 剛好符號對照表的數字多於Z, 所以可以直接用


## 顏色
plot(df$X, df$Y, 
    xlab = 'x', # X軸標題
    ylab = 'y', # Y軸標題
    main = 'xy', # 大標題
    xlim = c(0,12), # X軸起始
    ylim = c(0,12), # Y軸起始
    col = 2 )

## 顏色同圖形, 可以直接用 ifelse 修改
Z = floor(runif(50,0,11)) 
df$Z = Z
df$Z = ifelse(df$Z < 5, 'red', 'blue')
plot(df$X, df$Y, 
    xlab = 'x', # X軸標題
    ylab = 'y', # Y軸標題
    main = 'xy', # 大標題
    xlim = c(0,12), # X軸起始
    ylim = c(0,12), # Y軸起始
    col = df$Z )


## 點大小
plot(df$X, df$Y, 
    xlab = 'x', # X軸標題
    ylab = 'y', # Y軸標題
    main = 'xy', # 大標題
    xlim = c(0,12), # X軸起始
    ylim = c(0,12), # Y軸起始
    col = df$Z,
    pch = 16, #圖形
    cex = 2 ) #大小

## 大小同顏色和圖形, 可以用df$ 修改
W = floor(runif(50,0,11)) 
df$W = W
df$W = ifelse(df$W < 5, 1, 2)
plot(df$X, df$Y, 
    xlab = 'x', # X軸標題
    ylab = 'y', # Y軸標題
    main = 'xy', # 大標題
    xlim = c(0,12), # X軸起始
    ylim = c(0,12), # Y軸起始
    col = df$Z,
    pch = 16, #圖形
    cex = df$W ) #大小

###########
## 畫曲線
###########
#lines( X, Y,
#       lwd : 寬度
#       lty : 圖示 (1:實線, 2:虛線, ...)
#)



X = floor(runif(50,0,11))
Y = X * runif(50,0,1) 
df = data.frame(X,Y)
plot(df$X, df$Y,
    xlab = 'x', # X軸標題
    ylab = 'y', # Y軸標題
    main = 'xy', # 大標題
    xlim = c(0,12), # X軸起始
    ylim = c(0,10))
XY_lm <- lm(Y ~ X, data = df) # 回歸
Fit = fitted(XY_lm) # 計算配飾直
ord_X = order(df$X) # 資料小到大的編號
lines(df$X[ord_X], Fit[ord_X], 
        lwd = 3, lty = 2)

XY_loess <- loess(Y ~ X, data = df) #loess
Fit = fitted(XY_loess)
ord_X = order(df$X)
lines(df$X[ord_X], Fit[ord_X], 
        lwd = 1, lty = 2, col = 'red')



