## 讀取和查看data (R內建的)
data(iris)
head(iris, 10)



## prcomp函數會返回主成分的標準差、特徵向量和主成分構成的新矩陣。
#scale = T 代表進行標準化 ,建議為T
#rank = 4 代表主成分份數為4
#retx = T 表示返回score
iris.pca <- prcomp(iris[,-5],scale=T,rank=4,retx=T) # 相關矩陣分解
summary(iris.pca) # 方差解釋度
iris.pca$sdev #特徵值的開方
iris.pca$rotation #變量載荷loading
head(iris.pca$x) #樣本得分score


library(ggfortify)
autoplot(iris.pca,data = iris,col= 'Species',size=2,
         loadings =T,loadings.label = TRUE,
         frame = TRUE,frame.type='norm',
         label = TRUE, label.size = 3
)+
  theme_classic()


