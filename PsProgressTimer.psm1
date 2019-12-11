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
    hidden [double]$BufferAverage
    hidden [System.Diagnostics.Stopwatch]$Stopwatch
    hidden [int]$TotalCount
    hidden [int]$UseNMostRecent
    hidden [double]$IntraLapTime
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

    # Starts the clock on the timer
    [void]Start()
    {
        $this.Stopwatch.Restart()
    }

    # Marks the iteration and uses the time taken since the last to calculate the average
    [int]Lap()
    {
        return $this.Lap(1)
    }
    
    # Marks that [n] iterations have completed and adds the average time [n] times
    [int]Lap([int]$Count)
    {
        if ($Count -lt 0)
        {
            throw [System.ArgumentException]::new("Value cannot be less than zero", "Count")
        }

        if ($count -eq 0)
        {
            $this.UpdateDuration()
            return $this.Counter
        }

        if (!$this.Stopwatch.IsRunning)
        {
            throw [System.InvalidOperationException]::new("Timer has not yet been started")
        }
        for ($i = 0; $i++ -lt $Count; )
        {
            $this.Buffer.Add(($this.Stopwatch.Elapsed.TotalSeconds + $this.IntraLapTime) / $Count)
        }
        $this.Counter += $Count
        $this.BufferAverage = [Linq.Enumerable]::Average($this.Buffer.Queue)
        $this.IntraLapTime = 0
        $this.Stopwatch.Restart()
        return $this.Counter
    }

    # Updates the duration of the last entry in the buffer without performing a counter increment.
    [void]UpdateDuration()
    {
        if (!$this.Stopwatch.IsRunning)
        {
            throw [System.InvalidOperationException]::new("Timer has not yet been started")
        }
        $this.IntraLapTime += $this.Stopwatch.Elapsed.TotalSeconds
        $this.Stopwatch.Restart()
    }

    # Resets the timer to initial state. Allows the object to be reused
    [void]Reset()
    {
        $this.Buffer.Queue.Clear()
        $this.Counter = 0
        if ($this.Stopwatch.IsRunning)
        {
            $this.Stopwatch.Restart()
        }
    }

    # Estimates the seconds remaining from the average rate of the n most recent lap times
    [double]SecondsRemaining()
    {
        if ($this.Buffer.Queue.Count -eq 0)
        {
            return (-1)
        }
        $Remaining = $this.TotalCount - $this.Counter
        return ($this.BufferAverage * $Remaining) - $this.IntraLapTime
    }

    # Calculates the percent complete
    [double]PercentComplete()
    {
        if ($this.Buffer.Queue.Count -eq 0)
        {
            return (-1)
        }
        return [Math]::Min(100, $this.Counter / $this.TotalCount * 100)
    }
    
    # Gets the estimated time of completion based on the seconds remaining.
    [datetime]EstimatedTimeOfCompletion()
    {
        if ($this.Buffer.Queue.Count -eq 0)
        {
            return [datetime]::MaxValue
        }
        return [datetime]::Now.AddSeconds($this.SecondsRemaining())
    }

    # Gets the estimated time of compeletion as a string
    [string]GetEtcString()
    {
        return $this.GetEtcString($null, "--:--:--")
    }

    # Gets the estimated time of compeletion as a string using the specified format and default string if the ETC is not defined
    [string]GetEtcString([string]$Format, [string]$DefaultValue)
    {
        $EndDate = $this.EstimatedTimeOfCompletion()
        if ($EndDate -eq [datetime]::MaxValue)
        {
            return $DefaultValue
        }
        return $EndDate.ToString($Format)
    }

    # Returns a hashtable of the current object state to be used as a splatted parameter for Write-Progress
    [hashtable]GetSplat()
    {
        $SplatHt = [hashtable]::new()
        # Default Properties
        $SplatHt.Add("SecondsRemaining", $this.SecondsRemaining())
        $SplatHt.Add("PercentComplete", $this.PercentComplete())
        $SplatHt.Add("Completed", $this.IsComplete())
        
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
            $SplatHt.Add("Status", "($($this.Counter)/$($this.TotalCount)) " + $this.Status.GetNewClosure().InvokeReturnAsIs())
        }

        return $SplatHt
    }

    # Writes to the Progress stream with the current object state
    [void]WriteProgress()
    {
        $ProgressSplat = $this.GetSplat()
        Write-Progress @ProgressSplat
    }

    hidden [string]BuildActivityText([string]$LeaderText)
    {
        $sb = [System.Text.StringBuilder]::new()
        $sb.Append($LeaderText + (" " * [int][bool]$LeaderText)
        ).AppendFormat("[ETC: {0}", $this.GetEtcString()
        ).Append("]")
     
        return $sb.ToString()
    }

    hidden [bool]IsComplete()
    {
        return $this.Counter -ge $this.TotalCount
    }

}

$ModuleDir = ([System.IO.FileInfo]$PsScriptRoot).Directory.FullName

ForEach ($Path in (Get-ChildItem -Path ([Io.Path]::Combine($PsScriptRoot, "Public"))))
{
    . $Path.FullName
}

ForEach ($Path in (Get-ChildItem -Path ([Io.Path]::Combine($PsScriptRoot, "Private"))))
{
    . $Path.FullName
}

Export-ModuleMember -Function @("New-ProgressTimer")