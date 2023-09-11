
import pandas as pd


def FDR_function(feature_list, p_value):
    N = len(p_value)
    DF = pd.DataFrame({'feature_name' : feature_list,
                       'p_value' : p_value}).sort_values('p_value')
    p_value_sorted = DF['p_value'].values

    FDR_test = [p_value_sorted[i] * N / (i+1) for i in range(N)]
    for i in range(N-1, 0, -1):
        if FDR_test[i] < FDR_test[i-1]:
            FDR_test[i-1] = FDR_test[i]
    DF['FDR'] = FDR_test
    return DF


if __name__ == '__main__':
    from scipy.stats import norm
    data = pd.read_csv('./python/分析相關/000.function/test_data/FDR_test_data.csv')
    p_values = norm.cdf(-abs(data['x'].values)) * 2 # 計算 p_value
    FDR = FDR_function(data['f'], p_values)
    print(FDR)
