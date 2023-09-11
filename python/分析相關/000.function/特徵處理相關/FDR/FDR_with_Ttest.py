import pandas as pd
from scipy.stats import ttest_ind

def FDR_with_ttest(DF):
    '''
    column 1 : label, label 只有兩種
    other : feature
    '''
    feature_list = DF.columns
    Label = list(set(DF[feature_list[0]].values))
    data_label0 = data.loc[DF[feature_list[0]] == Label[0],]
    data_label1 = data.loc[DF[feature_list[0]] == Label[1],]
    feature_list = feature_list[1:]
    p_values = []
    for feature in feature_list:
        X1 = data_label0[feature]
        X2 = data_label1[feature]
        t_stat, p_value = ttest_ind(X1,X2)
        p_values.append(p_value)

    N = len(p_values)
    DF = pd.DataFrame({'feature_name' : feature_list,
                        'p_value' : p_values}).sort_values('p_value')
    p_value_sorted = DF['p_value'].values

    FDR_test = [p_value_sorted[i] * N / (i+1) for i in range(N)]
    for i in range(N-1, 0, -1):
        if FDR_test[i] < FDR_test[i-1]:
            FDR_test[i-1] = FDR_test[i]
    DF['FDR'] = FDR_test
    return(DF)

    
if __name__ == '__main__':
    import pandas as pd
    import numpy as np
    data = pd.read_csv('./python/分析相關/000.function/test_data/BostonHousing.csv')
    data = data[[data.columns[-1]] + list(data.columns[:-1])]
    data['medv'] = np.where(data['medv'] > np.mean(data['medv']),1 ,0)
    FDR = FDR_with_ttest(data)
    print(FDR)



