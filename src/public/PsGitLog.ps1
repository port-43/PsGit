[NoRunspaceAffinity()]
class PsGitLog {
    [bool] $Debug = $false
    [LogType] $LogType = [LogType]::json

    # this method logs details to stdout
    [Void] Log([LogLevel] $Level, [string] $Message, [string] $Method) {
        if (!$this.Debug -and $env:PsGitLogDebug -ne 'true') {
            return
        }

        $Timestamp = Get-Date -format "yyyy-MM-dd HH:mm:ss.fff"
        $StructuredLog = [ordered]@{
            timestamp = $timestamp
            level     = $Level.ToString()
            thread    = [System.Threading.Thread]::CurrentThread.ManagedThreadId
            hostname  = $env:COMPUTERNAME;
            method    = $Method
            message   = $Message
        }

        switch ($this.LogType) {
            ([LogType]::json) {
                $StructuredLog | ConvertTo-Json -Compress | Write-Information -InformationAction Continue
            }
            ([LogType]::logfmt) {
                $KeyValueList = [System.Collections.Generic.List[string]]::new()
                foreach ($Key in $StructuredLog.Keys) {
                    if ($StructuredLog[$Key] -match '\s') {
                        $KeyValueList.Add("$Key=`"$($StructuredLog[$Key])`"")
                    } else {
                        $KeyValueList.Add("$Key=$($StructuredLog[$Key])")
                    }
                }

                $KeyValueList -join " " | Write-Information -InformationAction Continue
            }
        }
    }

    static [Void] SLog([LogLevel] $Level, [string] $Message, [string] $Method) {
        $SLogType = [LogType]::json

        if ($env:PsGitLogDegug -ne 'true') {
            return
        }

        $Timestamp = Get-Date -format "yyyy-MM-dd HH:mm:ss.fff"
        $StructuredLog = [ordered]@{
            timestamp = $timestamp
            level     = $Level.ToString()
            thread    = [System.Threading.Thread]::CurrentThread.ManagedThreadId
            hostname  = $env:COMPUTERNAME;
            method    = $Method
            message   = $Message
        }

        switch ($SLogType) {
            ([LogType]::json) {
                $StructuredLog | ConvertTo-Json -Compress | Write-Information -InformationAction Continue
            }
            ([LogType]::logfmt) {
                $KeyValueList = [System.Collections.Generic.List[string]]::new()
                foreach ($Key in $StructuredLog.Keys) {
                    if ($StructuredLog[$Key] -match '\s') {
                        $KeyValueList.Add("$Key=`"$($StructuredLog[$Key])`"")
                    } else {
                        $KeyValueList.Add("$Key=$($StructuredLog[$Key])")
                    }
                }

                $KeyValueList -join " " | Write-Information -InformationAction Continue
            }
        }
    }

    static [Void] SLog([LogLevel] $Level, [string] $Message, [string] $Method, [bool] $Debug) {
        $SLogType = [LogType]::json

        if (!$Debug) {
            return
        }

        $Timestamp = Get-Date -format "yyyy-MM-dd HH:mm:ss.fff"
        $StructuredLog = [ordered]@{
            timestamp = $timestamp
            level     = $Level.ToString()
            thread    = [System.Threading.Thread]::CurrentThread.ManagedThreadId
            hostname  = $env:COMPUTERNAME;
            method    = $Method
            message   = $Message
        }

        switch ($SLogType) {
            ([LogType]::json) {
                $StructuredLog | ConvertTo-Json -Compress | Write-Information -InformationAction Continue
            }
            ([LogType]::logfmt) {
                $KeyValueList = [System.Collections.Generic.List[string]]::new()
                foreach ($Key in $StructuredLog.Keys) {
                    if ($StructuredLog[$Key] -match '\s') {
                        $KeyValueList.Add("$Key=`"$($StructuredLog[$Key])`"")
                    } else {
                        $KeyValueList.Add("$Key=$($StructuredLog[$Key])")
                    }
                }

                $KeyValueList -join " " | Write-Information -InformationAction Continue
            }
        }
    }

    static [Void] SLog([LogLevel] $Level, [string] $Message, [string] $Method, [bool] $Debug, [LogType] $SLogType) {
        if (!$Debug) {
            return
        }

        $Timestamp = Get-Date -format "yyyy-MM-dd HH:mm:ss.fff"
        $StructuredLog = [ordered]@{
            timestamp = $timestamp
            level     = $Level.ToString()
            thread    = [System.Threading.Thread]::CurrentThread.ManagedThreadId
            hostname  = $env:COMPUTERNAME;
            method    = $Method
            message   = $Message
        }

        switch ($SLogType) {
            ([LogType]::json) {
                $StructuredLog | ConvertTo-Json -Compress | Write-Information -InformationAction Continue
            }
            ([LogType]::logfmt) {
                $KeyValueList = [System.Collections.Generic.List[string]]::new()
                foreach ($Key in $StructuredLog.Keys) {
                    if ($StructuredLog[$Key] -match '\s') {
                        $KeyValueList.Add("$Key=`"$($StructuredLog[$Key])`"")
                    } else {
                        $KeyValueList.Add("$Key=$($StructuredLog[$Key])")
                    }
                }

                $KeyValueList -join " " | Write-Information -InformationAction Continue
            }
        }
    }
}

enum LogType {
    json   = 1
    logfmt = 2
}

enum LogLevel {
    info    = 1
    trace   = 2
    warning = 3
    error   = 4
}
