@echo off
REM ============================================================
REM  Regenera el PDF consolidado del informe (Informe-CyberRisk2.0.pdf)
REM  a partir de Informe-CyberRisk2.0.html, con las evidencias incluidas.
REM  Uso: doble clic sobre este archivo. No necesita instalar nada
REM  (usa Microsoft Edge o Google Chrome ya instalados).
REM ============================================================
setlocal
cd /d "%~dp0"

set "NAV=C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
if not exist "%NAV%" set "NAV=C:\Program Files\Microsoft\Edge\Application\msedge.exe"
if not exist "%NAV%" set "NAV=C:\Program Files\Google\Chrome\Application\chrome.exe"
if not exist "%NAV%" set "NAV=C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"

if not exist "%NAV%" (
  echo No se encontro Microsoft Edge ni Google Chrome.
  echo Alternativa: abre Informe-CyberRisk2.0.html en tu navegador y usa Ctrl+P -^> Guardar como PDF.
  pause
  exit /b 1
)

echo Generando Informe-CyberRisk2.0.pdf ...
"%NAV%" --headless=new --disable-gpu --no-pdf-header-footer --print-to-pdf="%~dp0Informe-CyberRisk2.0.pdf" "%~dp0Informe-CyberRisk2.0.html"

if exist "%~dp0Informe-CyberRisk2.0.pdf" (
  echo.
  echo LISTO: se genero Informe-CyberRisk2.0.pdf
) else (
  echo.
  echo ERROR: no se pudo generar el PDF. Usa Ctrl+P en el navegador como alternativa.
)
pause
