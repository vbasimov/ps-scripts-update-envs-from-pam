# Получаем параметры:
#   -config   -- cписок файлов с конфигурациями из строки параметров: -config file1, file2, fileN
Param(
    [parameter(mandatory=$true)][array[]]$config,
    [parameter(mandatory=$false)][int]$restart
)

# Импортируем необходимое
. .\get-pam-secret.ps1
. .\update-task-user-credentials.ps1

# Устанавливаем начальное значение глобального статуса для отображения в пайплайне
$globalExitStatus = 0

# Проверяем наличие и возможность прочитать файлы - они должны содержать валидный JSON
foreach ($conf in $config) {
    try {
        Get-Content $conf -ErrorAction Stop | ConvertFrom-Json | out-null
    } catch {
        Write-Output $_.Exception.Message
        $globalExitStatus =  1
    }
}

# Если при разборе файлов были ошибки, то останавливаем скрипт с ошибкой
if ($globalExitStatus -eq 1){
    exit $globalExitStatus
}

[int] $restartDelay = 120       # Секунды для задержки перезагрузки
[bool] $isChanged = $false      # Флаг того, изменилось ли что-то
[array] $namesWithErrs = @()    # Для сбора того, что не удалось получить

foreach ($conf in $config) {
    
    # Получаем конфиг из файла
    [Object] $conf = Get-Content $conf -ErrorAction Stop | ConvertFrom-Json
    
    # Проходимся по секции env
    foreach ($item in $conf.env.PSObject.Properties) {
        try {
            
            # Получаем доступы из PAM
            $credentials = Get-PAMSecret $item.value.token $item.value.secretName $item.value.secretPath "$env:COMPUTERNAME - connect from configuration script"
            
            # расшифоровываем пароль $value = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($credentials.password))
            
            if ($null -ne $credentials.password){
                $value = $credentials.password
            } elseif ($null -ne $credentials.data) {
                $value = $credentials.data
            }

            # Проверяем принужительность или не совпадение значения с текущим установленным
            if ($restart -or $value -ne [Environment]::GetEnvironmentVariable($item.name, 'Machine')){
                
                # Меняем флаг изменения
                $isChanged = $true
        
                # Устанавливаем, в переменные окружения
                [Environment]::SetEnvironmentVariable($item.name, $value, 'Machine')

                # затираем значение пароля из памяти
                Remove-Variable 'value'
                
                # Если был установлен jobUser в True,есть и username и password - значит ищем таски в task scheduler, запускаемые от данной уз
                if ($item.value.jobUser -And $null -ne $credentials.username -And $null -ne $credentials.password) {
                    $tasks = Get-ScheduledTask | Where-Object { $_.Principal.UserId -eq $credentials.username }

                    # обновляем учетные данные тасков
                    foreach ($t in $tasks) {
                        Update-Task-Credentials $t $credentials.username $credentials.password
                    }

                    $username = $credentials.username
                    $tasks = Get-ScheduledTask | Where-Object { $_.Principal.UserId -eq "$username" }

                    foreach ($t in $tasks) {
                        Update-Task-Credentials $t "$username" $credentials.password
                    }
                    
                }

            }
        } catch {
            Write-Output $_.Exception.Message
            $namesWithErrs += $item.name
        }
    }
}

if ($isChanged){
    Write-Output "One of variables has changed."
} else {
    Write-Output "No one of variables not changed"
}

if ($namesWithErrs.Count -gt 0) {
    Write-Output "Unable to get/set next variables: $($namesWithErrs)"
    $globalExitStatus = 1
}

if ($restart) {
    Write-Output "restart server in $restartDelay seconds"
    invoke-command -computername localhost -scriptblock {msg * "Server restart in $restartDelay seconds. Please save your work. You will be logged off in 5 minutes."}
    Restart-Computer -Force # -Wait -Timeout $restartDelay
}
exit $globalExitStatus
