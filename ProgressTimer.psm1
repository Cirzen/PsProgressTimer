using namespace System.Collections.Generic;

class CircularBuffer # : IEnumerable[double]
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
    [int]$Counter

    ProgressTimer([int]$Count)
    {
        $this.Buffer = [CircularBuffer]::new($Count)
        $this.Stopwatch = [System.Diagnostics.Stopwatch]::new()
        $this.TotalCount = $Count
        $this.Counter = 0
    }

    ProgressTimer([int]$Count, [int]$UseNMostRecent)
    {
        $this.Buffer = [CircularBuffer]::new($UseNMostRecent)
        $this.Stopwatch = [System.Diagnostics.Stopwatch]::new()
        $this.TotalCount = $Count
        $this.Counter = 0
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
        $this.Buffer.Add($this.Stopwatch.Elapsed.TotalSeconds)
        $this.Stopwatch.Restart()
        $this.Counter++
        return $this.Counter
    }

    [double]SecondsRemaining()
    {
        if ($this.Buffer.Queue.Count -eq 0)
        {
            return -1
        }
        $Average = [Linq.Enumerable]::Average($this.Buffer.Queue)
        $Remaining = $this.TotalCount - $this.Counter
        return $Average * $Remaining
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
    
    .EXAMPLE
    $Timer = New-ProgressTimer -TotalCount 100 -UseNMostRecent 10
    $Timer.Start()
    ForEach ($task in $MyBigJob)
    {
        $Progress = @{
            Activity = "Running big job. ETC: $($Timer.EstimatedTimeOfCompletion())"
            Status = $task
            PercentComplete = $Timer.PercentComplete()
            SecondsRemaining = $Timer.SecondsRemaining()
            ID = 1
        }
        Write-Progress @Progress
        
        # Do Work
        # ...
        # ...

        [int]$JobsComplete = $Timer.Lap()
    }
    Write-Progress -ID 1 -Complete
    
    .NOTES
    None
    #>
    
    param(
        
        [Parameter(Mandatory = $true)]
        [int]
        $TotalCount,

        [Parameter(Mandatory = $false)]
        [int]
        $UseNMostRecent = $TotalCount
    )

    return [ProgressTimer]::new($TotalCount, $UseNMostRecent)
}

Export-ModuleMember -Function @("New-ProgressTimer")