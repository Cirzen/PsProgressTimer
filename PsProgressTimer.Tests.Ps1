using module .\PsProgressTimer.psm1
InModuleScope -ModuleName PsProgressTimer -ScriptBlock {

    Describe '[CircularBuffer]-[Constructors]' {

        It '[CircularBuffer]-[Constructor]([int]Size) should Not Throw' {
            # -- Arrange
            [int]$Size = 10
            # -- Act
            # -- Assert
            { [CircularBuffer]::New($Size) } | Should Not Throw 
        }# end of it block

    }# end of Describe block

    Describe '[ProgressTimer]-[Constructors]' {

        It '[ProgressTimer]-[Constructor]([int]Count) should Not Throw' {
            # -- Arrange
            [int]$Count = 12
            # -- Act
            # -- Assert
            { [ProgressTimer]::New($Count) } | Should Not Throw 
        }# end of it block

        It '[ProgressTimer]-[Constructor]([int]Count,[int]UseNMostRecent) should Not Throw' {
            # -- Arrange
            [int]$Count = 12
            [int]$UseNMostRecent = 6
            # -- Act
            # -- Assert
            { [ProgressTimer]::New($Count, $UseNMostRecent) } | Should Not Throw 
        }# end of it block
    }# end of Describe block

    Describe '[ProgressTimer]-[Methods]' {
        #Public Method

           #Public Method

        It '[ProgressTimer] --> Start() : [void] - should Not Throw' {
            # -- Arrange
            $Count = 12
            # -- Act
            $Instance = [ProgressTimer]::New($Count)
            # -- Assert
            { $Instance.Start() } | Should Not Throw
        } #End It Block
        #Public Method

        It '[ProgressTimer] --> Start() Should not return anything (voided)' {
            # -- Arrange
            $Count = 12
            # -- Act
            $Instance = [ProgressTimer]::New($Count)
            # -- Assert
            $Instance.Start() | should be $null
        } #End It Block
        #Public Method

        It '[ProgressTimer] --> Lap() : [int] - should Not Throw' {
            # -- Arrange
            $Count = 12
            # -- Act
            $Instance = [ProgressTimer]::New($Count)
            $Instance.Start()
            # -- Assert
            { $Instance.Lap() } | Should Not Throw
        } #End It Block
        #Public Method

        It '[ProgressTimer] --> Lap() : [int] - should return type [int]' {
            # -- Arrange
            $Count = 12
            # -- Act
            $Instance = [ProgressTimer]::New($Count)
            $Instance.Start()
            # -- Assert
            $Instance.Lap() | should -BeOfType ([int])
        } #End It Block
        #Public Method

        It '[ProgressTimer] --> Lap($Count) : [int] - should Not Throw' {
            # -- Arrange
            $Count = 12
            $Lap = 1
            # -- Act
            $Instance = [ProgressTimer]::New($Count)
            $Instance.Start()
            # -- Act
            # -- Assert
            { $Instance.Lap($Lap) } | Should Not Throw
        } #End It Block
        #Public Method

        It '[ProgressTimer] --> Lap($Count) : [int] - should return type [int]' {
            # -- Arrange
            $Count = 12
            $Lap = 1
            # -- Act
            $Instance = [ProgressTimer]::New($Count)
            $Instance.Start()
            # -- Assert
            $Instance.Lap($Lap) | should -BeOfType ([int])
        } #End It Block
        #Public Method

        It '[ProgressTimer] --> UpdateDuration() : [void] - should Not Throw' {
            # -- Arrange
            $Count = 12
            # -- Act
            $Instance = [ProgressTimer]::New($Count)
            $Instance.Start()
            # -- Assert
            { $Instance.UpdateDuration() } | Should Not Throw
        } #End It Block
        #Public Method

        It '[ProgressTimer] --> UpdateDuration() Should not return anything (voided)' {
            # -- Arrange
            $Count = 12
            # -- Act
            $Instance = [ProgressTimer]::New($Count)
            $Instance.Start()
            # -- Assert
            $Instance.UpdateDuration() | should be $null
        } #End It Block
        #Public Method

        It '[ProgressTimer] --> Reset() : [void] - should Not Throw' {
            # -- Arrange
            $Count = 12
            # -- Act
            $Instance = [ProgressTimer]::New($Count)
            $Instance.Start()
            # -- Assert
            { $Instance.Reset() } | Should Not Throw
        } #End It Block
        #Public Method

        It '[ProgressTimer] --> Reset() Should not return anything (voided)' {
            # -- Arrange
            $Count = 12
            # -- Act
            $Instance = [ProgressTimer]::New($Count)
            $Instance.Start()
            # -- Assert
            $Instance.Reset() | should be $null
        } #End It Block
        #Public Method

        It '[ProgressTimer] --> SecondsRemaining() : [double] - should Not Throw' {
            # -- Arrange
            $Count = 12
            # -- Act
            $Instance = [ProgressTimer]::New($Count)
            $Instance.Start()
            # -- Assert
            { $Instance.SecondsRemaining() } | Should Not Throw
        } #End It Block
        #Public Method

        It '[ProgressTimer] --> SecondsRemaining() : [double] - should return type [double]' {
            # -- Arrange
            $Count = 12
            # -- Act
            $Instance = [ProgressTimer]::New($Count)
            $Instance.Start()
            # -- Assert
            $Instance.SecondsRemaining() | should -BeOfType ([double])
        } #End It Block
        #Public Method

        It '[ProgressTimer] --> PercentComplete() : [double] - should Not Throw' {
            # -- Arrange
            $Count = 12
            # -- Act
            $Instance = [ProgressTimer]::New($Count)
            $Instance.Start()
            # -- Assert
            { $Instance.PercentComplete() } | Should Not Throw
        } #End It Block
        #Public Method

        It '[ProgressTimer] --> PercentComplete() : [double] - should return type [double]' {
            # -- Arrange
            $Count = 12
            # -- Act
            $Instance = [ProgressTimer]::New($Count)
            $Instance.Start()
            # -- Assert
            ($Instance.PercentComplete()).GetType().Name | should be double
        } #End It Block
        #Public Method

        It '[ProgressTimer] --> EstimatedTimeOfCompletion() : [datetime] - should Not Throw' {
            # -- Arrange
            $Count = 12
            # -- Act
            $Instance = [ProgressTimer]::New($Count)
            $Instance.Start()
            # -- Assert
            { $Instance.EstimatedTimeOfCompletion() } | Should Not Throw
        } #End It Block
        #Public Method

        It '[ProgressTimer] --> EstimatedTimeOfCompletion() : [datetime] - should return type [datetime]' {
            # -- Arrange
            $Count = 12
            # -- Act
            $Instance = [ProgressTimer]::New($Count)
            $Instance.Start()
            # -- Assert
            ($Instance.EstimatedTimeOfCompletion()).GetType().Name | should be datetime
        } #End It Block
        #Public Method

        It '[ProgressTimer] --> GetEtcString() : [string] - should Not Throw' {
            # -- Arrange
            $Count = 12
            # -- Act
            $Instance = [ProgressTimer]::New($Count)
            $Instance.Start()
            # -- Assert
            { $Instance.GetEtcString() } | Should Not Throw
        } #End It Block
        #Public Method

        It '[ProgressTimer] --> GetEtcString() : [string] - should return type [string]' {
            # -- Arrange
            $Count = 12
            # -- Act
            $Instance = [ProgressTimer]::New($Count)
            $Instance.Start()
            # -- Assert
            ($Instance.GetEtcString()).GetType().Name | should be string
        } #End It Block
        #Public Method

        It '[ProgressTimer] --> GetEtcString($Format,$DefaultValue) : [string] - should Not Throw' {
            # -- Arrange
            [string]$Format = 'yyyymmddHHmmss'
            [string]$DefaultValue = '--:--:--'
            $Count = 12
            # -- Act
            $Instance = [ProgressTimer]::New($Count)
            $Instance.Start()
            # -- Assert
            { $Instance.GetEtcString($Format, $DefaultValue) } | Should Not Throw
        } #End It Block
        #Public Method

        It '[ProgressTimer] --> GetEtcString($Format,$DefaultValue) : [string] - should return type [string]' {
            # -- Arrange
            [string]$Format = 'yyyymmddHHmmss'
            [string]$DefaultValue = '--:--:--'
            $Count = 12
            # -- Act
            $Instance = [ProgressTimer]::New($Count)
            $Instance.Start()
            # -- Assert
            ($Instance.GetEtcString($Format, $DefaultValue)).GetType().Name | should be string
        } #End It Block
        #Public Method

        It '[ProgressTimer] --> GetSplat() : [hashtable] - should Not Throw' {
            # -- Arrange
            $Count = 12
            # -- Act
            $Instance = [ProgressTimer]::New($Count)
            $Instance.Start()
            # -- Assert
            { $Instance.GetSplat() } | Should Not Throw
        } #End It Block
        #Public Method

        It '[ProgressTimer] --> GetSplat() : [hashtable] - should return type [hashtable]' {
            # -- Arrange
            $Count = 12
            # -- Act
            $Instance = [ProgressTimer]::New($Count)
            $Instance.Start()
            # -- Assert
            ($Instance.GetSplat()).GetType().Name | should be hashtable
        } #End It Block
        #Public Method

        It '[ProgressTimer] --> WriteProgress() : [void] - should Not Throw' {
            # -- Arrange
            $Count = 12
            # -- Act
            $Instance = [ProgressTimer]::New($Count)
            $Instance.ActivityText = "Running Pester Tests"
            $Instance.Start()
            # -- Assert
            { $Instance.WriteProgress() } | Should Not Throw
        } #End It Block
        #Public Method

        It '[ProgressTimer] --> WriteProgress() Should not return anything (voided)' {
            # -- Arrange
            $Count = 12
            # -- Act
            $Instance = [ProgressTimer]::New($Count)
            $Instance.ActivityText = "Running Pester Tests"
            $Instance.Start()
            # -- Assert
            $Instance.WriteProgress() | should be $null
        } #End It Block
        #Public Method

        It '[ProgressTimer] --> BuildActivityText($LeaderText) : [string] - should Not Throw' {
            # -- Arrange
            [string]$LeaderText = 'leader'
            $Count = 12
            # -- Act
            $Instance = [ProgressTimer]::New($Count)
            $Instance.Start()
            # -- Assert
            { $Instance.BuildActivityText($LeaderText) } | Should Not Throw
        } #End It Block
        #Public Method

        It '[ProgressTimer] --> BuildActivityText($LeaderText) : [string] - should return type [string]' {
            # -- Arrange
            [string]$LeaderText = 'Leader'
            $Count = 12
            # -- Act
            $Instance = [ProgressTimer]::New($Count)
            $Instance.Start()
            # -- Assert
            ($Instance.BuildActivityText($LeaderText)).GetType().Name | should be string
        } #End It Block
        #Public Method

        It '[ProgressTimer] --> IsComplete() : [bool] - should Not Throw' {
            # -- Arrange
            $Count = 12
            # -- Act
            $Instance = [ProgressTimer]::New($Count)
            $Instance.Start()
            # -- Assert
            { $Instance.IsComplete() } | Should Not Throw
        } #End It Block
        #Public Method

        It '[ProgressTimer] --> IsComplete() : [bool] - should return type [bool]' {
            # -- Arrange
            $Count = 12
            # -- Act
            $Instance = [ProgressTimer]::New($Count)
            $Instance.Start()
            # -- Assert
            $Instance.IsComplete() | should -BeOfType ([bool])
        } #End It Block
    }#EndDescribeBlock
}#End InModuleScope