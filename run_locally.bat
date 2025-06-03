@echo off
REM Скрипт для запуска приложения на локальном компьютере Windows

echo [INFO] Запуск приложения анализа недвижимости в Дубае...

REM Проверка наличия Streamlit
where streamlit >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Streamlit не найден. Установите его командой: pip install -r requirements-postgres.txt
    exit /b 1
)

REM Проверка наличия файла приложения
if not exist fixed_streamlit_app.py (
    echo [ERROR] Файл fixed_streamlit_app.py не найден.
    exit /b 1
)

REM Запуск приложения
echo [INFO] Запуск приложения...
streamlit run fixed_streamlit_app.py

REM Скрипт выполнен успешно
exit /b 0 