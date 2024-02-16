@echo off
REM 上述是用於關閉CMD窗口中的回應
REM REM是用來寫註解的
set N = 5
REM 使用RScript執行R檔案並傳遞N值, 可以在set後面輸入\p來確保輸入值
"C:\Program Files\R\R-4.1.3\bin\Rscript.exe" R_bat.R %N%