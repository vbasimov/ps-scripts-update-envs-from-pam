function Update-Task-Credentials ([System.Object]$task, [string]$username, $password) {
    $initialStatus = $task.State
    $concreteTask = $task.TaskPath + $task.TaskName

    if ($initialStatus -eq "Running") {
        $task | Stop-ScheduledTask; Write-Output "Task stopped"
    }

    Write-Output "changing $concreteTask"
    schtasks /change /s $env:COMPUTERNAME /tn $concreteTask /ru $username /rp $password

    if ($initialStatus -eq "Running") {
        $task | Start-ScheduledTask; Write-Output "Task Started Again"
    }
}
