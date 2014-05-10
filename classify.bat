@echo off
for /l %%i in (1,1,240) do (
  if exist ID%%i_*.mat @(
    mkdir ID%%i
    for %%f in (ID%%i_*.mat) do ( move %%f ./ID%%i )
  )
)
@echo on