import numpy as np
import scipy.stats as ss

class regression_ANOVA:
    def __init__(self, X, y, model):
        """
        X : 參數值
        y : 應變數
        model : 預測模型
        """
        #raw data
        self.y = y.values
        self.X = X.values
        self.colnames = list(X.columns)

        self.model = model
        self.model.fit(self.X, self.y)
        self.y_hat = self.model.predict(self.X)
        self.Tl, self.Pl = np.shape(self.X)
        self.Rl = self.Tl - self.Pl - 1

    ### function
    def Forward(self):
        s = []
        while len(s) < len(self.X[0]) :
            feature_list = [i for i in range(len(self.X[0])) if not(i in s)]
            Max_i = 0
            Max_v = 0
            for i in feature_list:
                LM = self.model
                feature_i = s + [i]
                X1 = self.X[:,feature_i]

                LM.fit(X1, self.y)
                y1_pred = LM.predict(X1)
                SSR = np.sum((np.mean(self.y) - y1_pred)**2)
                if SSR > Max_v : 
                    Max_i = i
                    Max_v = SSR
            s += [Max_i]
        return s
    
    def value_code(self, x):
        if x < 0.001:
            return '***'
        if x < 0.01:
            return '**'
        if x < 0.05:
            return '*'
        if x < 0.1:
            return '.'
        else:
            return ''

    ### 
    def SST(self):
        return round(np.sum((np.mean(self.y) - self.y)**2), 3)

    def SSR(self):
        return round(np.sum((np.mean(self.y) - self.y_hat)**2), 3)

    def SSE(self):
        return round(np.sum((self.y - self.y_hat)**2), 3)

    def MSR(self):
        return round(self.SSR()/self.Pl,3)
    
    def MSE(self):
        return round(self.SSE()/self.Rl,3)
    
    def P_value(self):
        return round(1 - ss.f.cdf(self.MSR()/self.MSE(), self.Pl, self.Rl), 5)


    ### table
    def ANOVA_table(self):
        table = \
                '='*120 + '\n' +\
                '{0:^16}'.format("變異來源")  +'{0:^16}'.format("平方和(SS)") +\
                     '{0:^16}'.format("自由度(DF)") + '{0:^16}'.format("平均平方和(MS)") +\
                        '{0:^16}'.format("檢定統計量(F value)") + '{0:^16}'.format("p_value") + '\n' +\
                '-'*120 + '\n' +\
                '{0:^18}'.format("迴歸(Predictors)")+ '{0:>12}'.format(self.SSR()) +\
                     '{0:>17}'.format(self.Pl) + '{0:>22}'.format(self.MSR()) +\
                        '{0:>20}'.format(round(self.MSR()/self.MSE(),3)) + '{0:>17}'.format(self.P_value()) + '{0:>5}'.format(self.value_code(self.P_value())) +'\n' +\
                '\n' +\
                '{0:^18}'.format("殘差(Residuals)")  + '{0:>12}'.format(self.SSE()) +\
                     '{0:>17}'.format(self.Rl) + '{0:>22}'.format(self.MSE()) +\
                        '{0:>20}'.format("") + '{0:^10}'.format("") + '\n' +\
                '-'*120 +'\n' +\
                '{0:^18}'.format("總和(Total)") + '{0:>12}'.format(self.SST()) +\
                     '{0:>17}'.format(self.Tl - 1) + '{0:>22}'.format('') +\
                        '{0:^32}'.format("") + '{0:^10}'.format("") + '\n' +\
                '='*120 + '\n' +\
                "Signif. codes : 0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 '' 1 "
        print(table)


    def ANOVA_table_typeI(self):
        feature_order = self.Forward()
        ## 計算各個 SSR 的遞增值
        feature_i = []
        SSR_list = [0]

        for i in feature_order:
            LM = self.model
            feature_i.append(i)

            X1 = self.X[:,feature_i]

            LM.fit(X1, self.y)
            y1_pred = LM.predict(X1)
            SSR_list.append(round(np.sum(((np.mean(self.y) - y1_pred)**2))  - np.sum(SSR_list),3))
        SSR_list = SSR_list[1:]

        table = \
                '='*120 + '\n' +\
                '{0:^16}'.format("變異來源")  +'{0:^16}'.format("平方和(SS)") +\
                     '{0:^16}'.format("自由度(DF)") + '{0:^16}'.format("平均平方和(MS)") +\
                        '{0:^16}'.format("檢定統計量(F value)") + '{0:^16}'.format("p_value") + '\n' +\
                '-'*120 + '\n' +\
                '{0:^18}'.format("迴歸(Predictors)") + '{0:>12}'.format(self.SSR()) +\
                     '{0:>17}'.format(self.Pl) + '{0:>22}'.format(self.MSR()) +\
                        '{0:>20}'.format(round(self.MSR()/self.MSE(),3)) + '{0:>17}'.format(self.P_value()) + '{0:>5}'.format(self.value_code(self.P_value())) +'\n' +\
                '\n' 

        for i in range(len(feature_order)):
            feature_index = feature_order[i]
            F_value = round(SSR_list[i]/self.MSE(),3)
            p_value = round(1 - ss.f.cdf(F_value, 1, self.Rl), 5)
            table += '{0:>16}'.format(self.colnames[feature_index])  + '{0:>16}'.format(SSR_list[i]) +\
                     '{0:>17}'.format(1) + '{0:>22}'.format(SSR_list[i]) +\
                     '{0:>20}'.format(F_value) + '{0:>17}'.format(p_value) + '{0:>5}'.format(self.value_code(p_value)) +'\n' +\
                '\n' 

        table +=\
                '{0:^18}'.format("殘差(Residuals)")  + '{0:>12}'.format(self.SSE()) +\
                     '{0:>17}'.format(self.Rl) + '{0:>22}'.format(self.MSE()) +\
                        '{0:>20}'.format("") + '{0:^10}'.format("") + '\n' +\
                '-'*120 +'\n' +\
                '{0:^18}'.format("總和(Total)") + '{0:>12}'.format(self.SST()) +\
                     '{0:>17}'.format(self.Tl - 1) + '{0:>22}'.format('') +\
                        '{0:>20}'.format("") + '{0:^10}'.format("") + '\n' +\
                '='*120 + '\n' +\
                "Signif. codes : 0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 '' 1 "
        
        print(table)


    def ANOVA_table_typeII(self):
        feature_order = self.Forward()
        ## 計算各個 SSR 的遞增值
        feature_i = []
        SSR_list = []
        SSR = self.SSR()

        for i in feature_order:
            LM = self.model
            feature_i = [j for j in range(len(feature_order)) if j != i]
            X1 = self.X[:,feature_i]

            LM.fit(X1, self.y)
            y1_pred = LM.predict(X1)
            SSR_list.append(round(SSR - np.sum(((np.mean(self.y) - y1_pred)**2)) ,3))


        table = \
                '='*120 + '\n' +\
                '{0:^16}'.format("變異來源")  +'{0:^16}'.format("平方和(SS)") +\
                     '{0:^16}'.format("自由度(DF)") + '{0:^16}'.format("平均平方和(MS)") +\
                        '{0:^16}'.format("檢定統計量(F value)") + '{0:^16}'.format("p_value") + '\n' +\
                '-'*120 + '\n' +\
                '{0:^18}'.format("迴歸(Predictors)") + '{0:>12}'.format(self.SSR()) +\
                     '{0:>17}'.format(self.Pl) + '{0:>22}'.format(self.MSR()) +\
                        '{0:>20}'.format(round(self.MSR()/self.MSE(),3)) + '{0:>17}'.format(self.P_value()) + '{0:>5}'.format(self.value_code(self.P_value())) +'\n' +\
                '\n' 

        for i in range(len(feature_order)):
            feature_index = feature_order[i]
            F_value = round(SSR_list[i]/self.MSE(),3)
            p_value = round(1 - ss.f.cdf(F_value, 1, self.Rl), 5)
            table += '{0:>16}'.format(self.colnames[feature_index])  + '{0:>16}'.format(SSR_list[i]) +\
                     '{0:>17}'.format(1) + '{0:>22}'.format(SSR_list[i]) +\
                     '{0:>20}'.format(F_value) + '{0:>17}'.format(p_value) + '{0:>5}'.format(self.value_code(p_value)) +'\n' +\
                '\n' 
        

        table +=\
                '{0:^18}'.format("殘差(Residuals)")  + '{0:>12}'.format(self.SSE()) +\
                     '{0:>17}'.format(self.Rl) + '{0:>22}'.format(self.MSE()) +\
                        '{0:>20}'.format("") + '{0:^10}'.format("") + '\n' +\
                '-'*120 +'\n' +\
                '{0:^18}'.format("總和(Total)") + '{0:>12}'.format(self.SST()) +\
                     '{0:>17}'.format(self.Tl - 1) + '{0:>22}'.format('') +\
                        '{0:>20}'.format("") + '{0:^10}'.format("") + '\n' +\
                '='*120 + '\n' +\
                "Signif. codes : 0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 '' 1 "
        
        print(table)



##########
### test
##########
if __name__ == '__main__':
    import pandas as pd
    from sklearn.linear_model import LinearRegression

    data = pd.read_csv('./python/分析相關/000.function/test_data/mranova_test.csv', index_col = 'i') 

    X = data.iloc[:,1:]
    y = data.iloc[:,0]
    Model = LinearRegression()

    # anova table
    print('anova table')
    anova = regression_ANOVA(X, y, Model)
    anova.ANOVA_table()

    print('\n'*3)

    print('anova table typeI')
    anova = regression_ANOVA(X, y, Model)
    anova.ANOVA_table_typeI()
