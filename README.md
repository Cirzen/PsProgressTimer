# PsProgressTimer
A PowerShell helper module for Write-Progress

## What's this then? Why do I need it?
You and your end users like rich, detailed and actually useful progress messages for your long running processes right? Everyone likes the warm fuzzy feeling of knowing their machine hasn't crashed and is working dilligently on their behalf.
Can you always be bothered to code up accurate PercentComplete and SecondsRemaining values to show that level of detail? I know I can't.
What if it was always simple?

## Huh? Show me

Sure. Well this code:

```powershell
$IPAddresses = Get-Content MyServerAddresses.txt
$Timer = New-ProgressTimer -TotalCount $IPAddresses.Count -ActivityText "Pinging..." -StatusScript {$ip} -Start
Foreach ($ip in $IPAddresses)
{
    $Timer.WriteProgress()
    Test-Connection $ip -Count 4
    [void]$Timer.Lap()
}
```

Gets you this output:

![alt-text](Images\ProgressTimerDemo.gif "Screen capture of rich progress bar")