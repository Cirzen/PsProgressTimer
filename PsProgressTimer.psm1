using namespace System.Collections.Generic;

class CircularBuffer
{
    hidden [Queue[double]]$Queue
    hidden [int]$Size

    CircularBuffer([int]$Size)
    {
        $this.Queue = [Queue[double]]::new($Size)
        $this.Size = $Size
    }

    [bool]IsFull()
    {
        return $this.Queue.Count -eq $this.Size
    }

    [void]Add([double]$Value)
    {
        if ($this.IsFull())
        {
            $this.Queue.Dequeue()
        }
        $this.Queue.Enqueue($Value)
    }
    [double]Read()
    {
        return $this.Queue.Dequeue()
    }

    [double]Peek()
    {
        return $this.Queue.Peek()
    }

    [void]Resize([int]$NewSize)
    {
        if ($NewSize -lt 1)
        {
            throw [System.ArgumentException]::new("Size must be greater than 0")
        }
        if ($NewSize -ge $this.Size)
        {
            $this.Size = $NewSize
            return
        }
        for ($i = 0; $i++ -lt $this.Size - $NewSize; )
        {
            $this.Queue.Dequeue()
        }
        $this.Queue.TrimExcess()
    }

    [IEnumerator[double]]GetEnumerator()
    {
        return $this.Queue.GetEnumerator()
    }
}

class ProgressTimer
{
    hidden [CircularBuffer]$Buffer
    hidden [System.Diagnostics.Stopwatch]$Stopwatch
    hidden [int]$TotalCount
    hidden [int]$UseNMostRecent
    hidden [bool]$IntraLapTime
    [int]$Counter
    [string]$ActivityText
    [System.Nullable[int]]$Id
    [System.Nullable[int]]$ParentId
    [scriptblock]$Status

    ProgressTimer([int]$Count)
    {
        $this._init($Count, $Count)
    }

    ProgressTimer([int]$Count, [int]$UseNMostRecent)
    {
        $this._init($Count, $UseNMostRecent)
    }

    hidden [void] _init([int]$c, [int]$u)
    {
        $this.Buffer = [CircularBuffer]::new($u)
        $this.Stopwatch = [System.Diagnostics.Stopwatch]::new()
        $this.TotalCount = $c
        $this.Counter = 0
        $this.IntraLapTime = 0
    }

    [void]Start()
    {
        $this.Stopwatch.Restart()
    }

    # Marks the iteration and uses the time taken since the last to calculate the average
    [int]Lap()
    {
        if (!$this.Stopwatch.IsRunning)
        {
            throw [System.InvalidOperationException]::new("Timer has not yet been started")
        }
        $this.Buffer.Add($this.Stopwatch.Elapsed.TotalSeconds + $this.IntraLapTime)
        $this.IntraLapTime = 0
        $this.Stopwatch.Restart()
        $this.Counter++
        return $this.Counter
    }

    # Updates the duration of the last entry in the buffer without performing a lap.
    [void]UpdateDuration()
    {
        if (!$this.Stopwatch.IsRunning)
        {
            throw [System.InvalidOperationException]::new("Timer has not yet been started")
        }
        $this.IntraLapTime += $this.Stopwatch.Elapsed.TotalSeconds
        $this.Stopwatch.Restart()
    }

    [void]Reset()
    {
        $this.Buffer.Queue.Clear()
        $this.Counter = 0
        if ($this.Stopwatch.IsRunning)
        {
            $this.Stopwatch.Restart()
        }
    }

    [double]SecondsRemaining()
    {
        if ($this.Buffer.Queue.Count -eq 0)
        {
            return -1
        }
        $Average = [Linq.Enumerable]::Average($this.Buffer.Queue)
        $Remaining = $this.TotalCount - $this.Counter
        return ($Average * $Remaining) - $this.IntraLapTime
    }

    [double]PercentComplete()
    {
        if ($this.Buffer.Queue.Count -eq 0)
        {
            return -1
        }
        return $this.Counter / $this.TotalCount * 100
    }
    
    [datetime]EstimatedTimeOfCompletion()
    {
        if ($this.Buffer.Queue.Count -eq 0)
        {
            return [datetime]::MaxValue
        }
        # Should SecondsRemaining be cached if the LINQ operation is potentially expensive?
        return [datetime]::Now.AddSeconds($this.SecondsRemaining())
    }

    [string]GetEtcString()
    {
        $EndDate = $this.EstimatedTimeOfCompletion()
        if ($EndDate -eq [datetime]::MaxValue)
        {
            return "--:--:--"
        }
        return $EndDate.ToString()
    }

    [hashtable]GetSplat()
    {
        $SplatHt = [hashtable]::new()
        # Default Properties
        $SplatHt.Add("SecondsRemaining", $this.SecondsRemaining())
        $SplatHt.Add("PercentComplete", $this.PercentComplete())
        
        # Additional properties
        if (![string]::IsNullOrEmpty($this.ActivityText))
        {
            $SplatHt.Add("Activity", $this.BuildActivityText($this.ActivityText))
        }

        if ($this.Id.HasValue)
        {
            $SplatHt.Add("Id", $this.Id.GetValueOrDefault())
        }

        if ($this.ParentId.HasValue)
        {
            $SplatHt.Add("ParentId", $this.ParentId.GetValueOrDefault())
        }

        if ($this.Status -ne $null)
        {
            $SplatHt.Add("Status", "($($this.Counter)/$($this.TotalCount))" + $this.Status.GetNewClosure().InvokeReturnAsIs())

        }

        return $SplatHt
    }

    hidden [string]BuildActivityText([string]$LeaderText)
    {
        $sb = [System.Text.StringBuilder]::new()
        $sb.Append($LeaderText + (" " * [int][bool]$LeaderText)
          ).AppendFormat("ETC: {0}", $this.GetEtcString())
     
        return $sb.ToString()
    }

}

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
    Returns the ProgressTimer object in an already started state
    
    .EXAMPLE
    $Timer = New-ProgressTimer -TotalCount 100 -UseNMostRecent 10
    $Timer.Start()
    ForEach ($n in 1..100)
    {
        $Progress = @{
            Activity = "Running big job. ETC: $($Timer.EstimatedTimeOfCompletion())"
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
        $StatusScript = {return "Running..."}
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

Export-ModuleMember -Function @("New-ProgressTimer")