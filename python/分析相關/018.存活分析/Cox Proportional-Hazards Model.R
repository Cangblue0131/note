# �w�˩M���J�ͦs���R�M��
#install.packages("survival")

library(survival)

# �Ыؤ@�ӵ������ͦs�ƾڶ�
set.seed(123)
n <- 100  # �˥���
time <- rexp(n, rate = 0.2)  # �ͦ��ͦs�ɶ��A���]���Ƥ��G
status <- sample(0:1, n, replace = TRUE)  # �ͦ��ƥ󪬺A�A0���ܳ]���A1���ܨƥ�o��
age <- rnorm(n, mean = 50, sd = 10)  # ���ܼ�1�G�~��
sex <- factor(sample(c("�k", "�k"), n, replace = TRUE))  # ���ܼ�2�G�ʧO

# �N�ƾڲզX���@�Ӽƾڮ�
data <- data.frame(time, status, age, sex)

# ���XCox��ҭ��I�ҫ�
cox_model <- coxph(Surv(time, status) ~ age + sex, data = data)

# ��ܼҫ��K�n
summary(cox_model)
