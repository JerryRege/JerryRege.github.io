@echo off
chcp 65001 >nul
title Cydia/Sileo 软件源打包工具
echo ================================================
echo    Cydia/Sileo 软件源自动打包工具
echo ================================================
echo.
echo 当前目录: %cd%
echo.

:: 检查 Python
echo [1/4] 检查 Python 环境...
python --version >nul 2>&1
if errorlevel 1 (
    echo 错误: 未找到 Python
    pause
    exit /b 1
)
echo 已找到 Python
echo.

:: 检查架构目录
echo [2/4] 检查 deb 文件...
if exist "roothide" goto :found
if exist "rootless" goto :found
if exist "rootful" goto :found
echo 错误: 未找到 roothide/rootless/rootful 文件夹
pause
exit /b 1

:found
echo 找到架构目录
echo.

:: 运行 Python 脚本
echo [3/4] 生成 Packages 和 Release...
python build_repo.py
if errorlevel 1 (
    echo.
    echo 打包失败！
    pause
    exit /b 1
)

:: Git 推送
echo.
echo [4/4] 推送到 GitHub...
git add .
git commit -m "sync repo"
git push

echo.
echo ================================================
echo 完成！
echo ================================================
pause