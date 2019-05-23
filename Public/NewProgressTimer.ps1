function New-ProgressTimer
{
    <#
    .SYNOPSIS
    Creates a new ProgressTimer object to use with Write-Progress
    
    .DESCRIPTION
    Many scripts will use the same code over and over to calculate the PercentComplete and SecondsRemaining values.
    The helper object produced by this function simplifies the process by marking each loop of the iteration with the Lap() method
    The PercentComplete and SecondsRemaining are then available via the PercentComplete() and SecondsRemaining() methods of the object.
    
    .PARAMETER TotalCount
    The total number of iterations expected. This value will be used to calculate the time remaining and percent complete values.
    
    .PARAMETER UseNMostRecent
    Used for calculating the SecondsRemaining value. If specified, the average time per iteration will only be calculated using the last N iterations.
    Higher values produce more stable readings, at the expense of accuracy

    .PARAMETER Start
    Returns the ProgressTimer object in an already started state.
    
    .PARAMETER Id
    The value to assign to the ID parameter of Write-Progress.

    .PARAMETER ParentId
    The value to assign to the ParentID parameter of Write-Progress.

    .PARAMETER ActivityText
    A string to use in the "Activity" header of the progress object. This will be suffixed with the Estimated Time of Completion.

    .PARAMETER StatusScript
    A scriptblock used to calculate the Status property of the progress object. A closure is generated from the scriptblock, so loop variables can be referenced.
    The value will be prefixed with a (x/y) counter showing the numerical progress
    
    
    .EXAMPLE
    $AllServers = Get-MyServers
    $Timer = New-ProgressTimer -TotalCount $AllServers.Count -ActivityText "Checking Servers..." -StatusScript {"Pinging $($Server.IpAddress)"} -Start
    ForEach ($Server in $AllServers)
    {
        $Timer.WriteProgress()
        Test-Connection $Server.IpAddress
        $Timer.Lap()
    }

    # This example shows the ProgressTimer running in full auto mode. The StatusScript property shows how you can use the loop variable
    
    .EXAMPLE
    $Timer = New-ProgressTimer -TotalCount 100 -UseNMostRecent 10
    $Timer.Start()
    ForEach ($n in 1..100)
    {
        $Progress = @{
            Activity = "Running big job."
            Status = $n
            PercentComplete = $Timer.PercentComplete()
            SecondsRemaining = $Timer.SecondsRemaining()
            ID = 1
        }
        Write-Progress @Progress
        
        # Do Work ...
        Start-Sleep -Milliseconds (Get-Random -Minimum 500 -Maximum 3000)

        [int]$JobsComplete = $Timer.Lap()
    }
    Write-Progress -ID 1 -Complete -Activity "Done"

    # This example shows how to maintain control of several of the Write-Progress parameters while letting the timer object handle the PercentComplete and SecondsRemaining calculations
    
    .NOTES
    None
    #>
    
    param(
        
        [Parameter(Mandatory = $true)]
        [int]
        $TotalCount,

        [Parameter(Mandatory = $false)]
        [int]
        $UseNMostRecent = $TotalCount,

        [switch]
        $Start,

        [Parameter(Mandatory = $false)]
        [int]
        $Id = 1,

        [Parameter(Mandatory = $false)]
        [int]
        $ParentId = 0,

        [Parameter(Mandatory = $false)]
        [string]
        $ActivityText = "Performing work",

        [Parameter(Mandatory = $false)]
        [scriptblock]
        $StatusScript = { return "Running..." }
    )

    End
    {
        $ReturnTimer = [ProgressTimer]::new($TotalCount, $UseNMostRecent)
        $ReturnTimer.Id = $Id
        $ReturnTimer.ParentId = $ParentId
        $ReturnTimer.ActivityText = $ActivityText
        $ReturnTimer.Status = $StatusScript
        if ($Start)
        {
            $ReturnTimer.Start()
        }
        return $ReturnTimer
    }
}