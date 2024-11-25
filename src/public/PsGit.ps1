[NoRunspaceAffinity()]
class PsGit {
    [System.IO.DirectoryInfo] $RepositoryDirectory
    [LibGit2Sharp.Repository] $Repository
    [PsGitLog] $Logger = [PsGitLog]::new()

    PsGit([System.IO.DirectoryInfo] $RepositoryDirectory) {
        $this.TestDirectory($RepositoryDirectory)
        $this.RepositoryDirectory = $RepositoryDirectory
        $this.NewRepository()
    }

    # clone repo to working directory
    [string] Clone([uri] $RepoUrl) {
        $Response = [LibGit2Sharp.Repository]::Clone($RepoUrl.AbsoluteUri, $this.GenerateDestination($RepoUrl, $pwd.Path, $true).FullName)

        return $Response
    }

    # clone repo to a specified directory
    [string] Clone([uri] $RepoUrl, [System.IO.DirectoryInfo] $Destination) {
        $Response = [LibGit2Sharp.Repository]::Clone($RepoUrl.AbsoluteUri, $this.GenerateDestination($RepoUrl,$Destination, $false).FullName)

        return $Response
    }

    # clone repo to working directory with clone options
    [string] Clone([uri] $RepoUrl, [PsGitCloneOptions] $Options) {
        $Response     = $null
        $PsGit        = $null
        $CloneOptions = $null

        if ($Options) {
            $CloneOptions = [LibGit2Sharp.CloneOptions]::new()
        }

        # add auth details
        if ($Options.Credential) {
            $RepoCredentials          = [LibGit2Sharp.UsernamePasswordCredentials]::new()
            $RepoCredentials.Username = $Options.Credential.UserName
            $RepoCredentials.Password = $Options.Credential.GetNetworkCredential().Password
            $CloneOptions.FetchOptions.CredentialsProvider = [LibGit2Sharp.Handlers.CredentialsHandler]{
                $RepoCredentials
            }
        }

        # preserve project name
        $Destination = $this.GenerateDestination($RepoUrl,$pwd.Path ,$Options.PreserveRepositoryName)

        # clone specific branch
        if ($Options.CloneType -eq [CloneType]::Branch) {
            $CloneOptions.BranchName = $Options.BranchName
            $Response                = [LibGit2Sharp.Repository]::Clone($RepoUrl.AbsoluteUri, $Destination.FullName, $CloneOptions)
        }

        # clone and checkout tag
        if ($Options.CloneType -eq [CloneType]::Tag) {
            $CloneOptions.Checkout = $false
            $Response              = [LibGit2Sharp.Repository]::Clone($RepoUrl.AbsoluteUri, $Destination.FullName, $CloneOptions)

            try {
                $PsGit = [PsGit]::new($Destination.FullName)
                $Tag   = $PsGit.Repository.Tags.where({$_.FriendlyName -eq $Options.Tag})

                if ($Tag) { [Void] [LibGit2Sharp.Commands]::Checkout($PsGit.Repository, $Tag.Target.Sha) }
            } catch {

            } finally {
                if ($PsGit) { $PsGit.Dispose() }
            }
        }

        # default clone
        if ($Options.CloneType -eq [CloneType]::Main) {
            $Response = [LibGit2Sharp.Repository]::Clone($RepoUrl.AbsoluteUri, $Destination.FullName, $CloneOptions)
        }



        $Response = [LibGit2Sharp.Repository]::Clone($RepoUrl.AbsoluteUri, $this.GenerateDestination($RepoUrl, $pwd.Path).FullName)

        return $Response
    }

    # clone repo to specified directory with clone options
    [string] Clone([uri] $RepoUrl, [System.IO.DirectoryInfo] $Destination, [PsGitCloneOptions] $Options) {
        $Response     = $null
        $PsGit        = $null
        $CloneOptions = $null

        if ($Options) {
            $CloneOptions = [LibGit2Sharp.CloneOptions]::new()
        }

        # add auth details
        if ($Options.Credential) {
            $RepoCredentials          = [LibGit2Sharp.UsernamePasswordCredentials]::new()
            $RepoCredentials.Username = $Options.Credential.UserName
            $RepoCredentials.Password = $Options.Credential.GetNetworkCredential().Password
            $CloneOptions.FetchOptions.CredentialsProvider = [LibGit2Sharp.Handlers.CredentialsHandler]{
                $RepoCredentials
            }
        }

        # preserve project name
        $Destination = $this.GenerateDestination($RepoUrl, $Destination.FullName, $Options.PreserveRepositoryName)

        # clone specific branch
        if ($Options.CloneType -eq [CloneType]::Branch) {
            $CloneOptions.BranchName = $Options.BranchName
            $Response                = [LibGit2Sharp.Repository]::Clone($RepoUrl.AbsoluteUri, $Destination.FullName, $CloneOptions)
        }

        # clone and checkout tag
        if ($Options.CloneType -eq [CloneType]::Tag) {
            $CloneOptions.Checkout = $false
            $Response              = [LibGit2Sharp.Repository]::Clone($RepoUrl.AbsoluteUri, $Destination.FullName, $CloneOptions)

            try {
                $PsGit = [PsGit]::new($Destination.FullName)
                $Tag   = $PsGit.Repository.Tags.where({$_.FriendlyName -eq $Options.Tag})

                if ($Tag) { [Void] [LibGit2Sharp.Commands]::Checkout($PsGit.Repository, $Tag.Target.Sha) }
            } catch {
                throw $_
            } finally {
                if ($PsGit) { $PsGit.Dispose() }
            }
        }

        # default clone
        if ($Options.CloneType -eq [CloneType]::Main) {
            $Response = [LibGit2Sharp.Repository]::Clone($RepoUrl.AbsoluteUri, $Destination.FullName, $CloneOptions)
        }



        $Response = [LibGit2Sharp.Repository]::Clone($RepoUrl.AbsoluteUri, $this.GenerateDestination($RepoUrl, $pwd.Path).FullName)

        return $Response
    }

    # clone repo to working directory
    static [string] CloneRepo([uri] $RepoUrl) {
        $Method      = 'CloneRepo([uri] $RepoUrl)'
        $Destination = [System.IO.DirectoryInfo] ($pwd.Path + '\' + [System.IO.Path]::GetFileNameWithoutExtension($RepoUrl.AbsoluteUri))

        $script:PsGitLog.Log('Info', "Cloning repo to current working directory", $Method)
        $Response = [LibGit2Sharp.Repository]::Clone($RepoUrl.AbsoluteUri, $Destination.FullName)

        return $Response
    }

    # clone repo to a specified directory
    static [string] CloneRepo([uri] $RepoUrl, [System.IO.DirectoryInfo] $Destination) {
        $Method           = 'CloneRepo([uri] $RepoUrl, [System.IO.DirectoryInfo] $Destination)'
        $FinalDestination = [System.IO.DirectoryInfo] ($Destination.FullName + '\' + [System.IO.Path]::GetFileNameWithoutExtension($RepoUrl.AbsoluteUri))

        $script:PsGitLog.Log('Info', "Cloning repo to destination $($FinalDestination.FullName)", $Method)
        $Response = [LibGit2Sharp.Repository]::Clone($RepoUrl.AbsoluteUri, $FinalDestination.FullName)

        return $Response
    }

    # clone repo to working directory with clone options
    static [string] CloneRepo([uri] $RepoUrl, [PsGitCloneOptions] $Options) {
        $Method       = 'CloneRepo([uri] $RepoUrl, [PsGitCloneOptions] $Options)'
        $Response     = $null
        $PsGit        = $null
        $CloneOptions = $null

        if ($Options) {
            $CloneOptions = [LibGit2Sharp.CloneOptions]::new()
        }

        # add auth details
        if ($Options.Credential) {
            $RepoCredentials          = [LibGit2Sharp.UsernamePasswordCredentials]::new()
            $RepoCredentials.Username = $Options.Credential.UserName
            $RepoCredentials.Password = $Options.Credential.GetNetworkCredential().Password
            $CloneOptions.FetchOptions.CredentialsProvider = [LibGit2Sharp.Handlers.CredentialsHandler]{
                $RepoCredentials
            }
        }

        # preserve project name
        if ($Options.PreserveRepositoryName) {
            $Destination = [System.IO.DirectoryInfo] ($pwd.Path + '\' + [System.IO.Path]::GetFileNameWithoutExtension($RepoUrl.AbsoluteUri))
        } else {
            $Destination = [System.IO.DirectoryInfo] $pwd.Path
        }

        # clone specific branch
        if ($Options.CloneType -eq [CloneType]::Branch) {
            $CloneOptions.BranchName = $Options.BranchName

            $script:PsGitLog.Log('Info', "Cloning branch $($CloneOptions.BranchName)", $Method)
            $Response                = [LibGit2Sharp.Repository]::Clone($RepoUrl.AbsoluteUri, $Destination.FullName, $CloneOptions)
        }

        # clone and checkout tag
        if ($Options.CloneType -eq [CloneType]::Tag) {
            $CloneOptions.Checkout = $false
            $Response              = [LibGit2Sharp.Repository]::Clone($RepoUrl.AbsoluteUri, $Destination.FullName, $CloneOptions)

            try {
                $PsGit = [PsGit]::new($Destination.FullName)
                $Tag   = $PsGit.Repository.Tags.where({$_.FriendlyName -eq $Options.Tag})

                $script:PsGitLog.Log('info',"Checking out tag $($Tag.FriendlyName) at commit sha $($Tag.Target.Sha)", $Method)
                if ($Tag) { [Void] [LibGit2Sharp.Commands]::Checkout($PsGit.Repository, $Tag.Target.Sha) }
            } catch {
                $script:PsGitLog.Log('error', $_.ErrorDetails.Message, $Method)
                throw $_
            } finally {
                if ($PsGit) { $PsGit.Dispose() }
            }
        }

        # default clone
        if ($Options.CloneType -eq [CloneType]::Main) {
            $script:PsGitLog.Log('info',"Cloning default main branch", $Method)
            $Response = [LibGit2Sharp.Repository]::Clone($RepoUrl.AbsoluteUri, $Destination.FullName, $CloneOptions)
        }

        return $Response
    }

    # clone repo to specified directory with clone options
    static [string] CloneRepo([uri] $RepoUrl, [System.IO.DirectoryInfo] $Destination, [PsGitCloneOptions] $Options) {
        $Method       = 'CloneRepo([uri] $RepoUrl, [System.IO.DirectoryInfo] $Destination, [PsGitCloneOptions] $Options)'
        $Response     = $null
        $PsGit        = $null
        $CloneOptions = $null

        if ($Options) {
            $CloneOptions = [LibGit2Sharp.CloneOptions]::new()
        }

        # add auth details
        if ($Options.Credential) {
            $RepoCredentials          = [LibGit2Sharp.UsernamePasswordCredentials]::new()
            $RepoCredentials.Username = $Options.Credential.UserName
            $RepoCredentials.Password = $Options.Credential.GetNetworkCredential().Password
            $CloneOptions.FetchOptions.CredentialsProvider = [LibGit2Sharp.Handlers.CredentialsHandler]{
                $RepoCredentials
            }
        }

        # preserve project name
        if ($Options.PreserveRepositoryName) {
            $Destination = [System.IO.DirectoryInfo] ($Destination.FullName + '\' + [System.IO.Path]::GetFileNameWithoutExtension($RepoUrl.AbsoluteUri))
        }

        # clone specific branch
        if ($Options.CloneType -eq [CloneType]::Branch) {
            $CloneOptions.BranchName = $Options.BranchName

            $script:PsGitLog.Log('Info', "Cloning branch $($CloneOptions.BranchName)", $Method)
            $Response                = [LibGit2Sharp.Repository]::Clone($RepoUrl.AbsoluteUri, $Destination.FullName, $CloneOptions)
        }

        # clone and checkout tag
        if ($Options.CloneType -eq [CloneType]::Tag) {
            $CloneOptions.Checkout = $false
            $Response              = [LibGit2Sharp.Repository]::Clone($RepoUrl.AbsoluteUri, $Destination.FullName, $CloneOptions)

            try {
                $PsGit = [PsGit]::new($Destination.FullName)
                $Tag   = $PsGit.Repository.Tags.where({$_.FriendlyName -eq $Options.Tag})

                $script:PsGitLog.Log('info',"Checking out tag $($Tag.FriendlyName) at commit sha $($Tag.Target.Sha)", $Method)
                if ($Tag) { $null = [LibGit2Sharp.Commands]::Checkout($PsGit.Repository, $Tag.Target.Sha) }
            } catch {
                $script:PsGitLog.Log('error', $_.ErrorDetails.Message, $Method)
                throw $_
            } finally {
                if ($PsGit) { $PsGit.Dispose() }
            }
        }

        # default clone
        if ($Options.CloneType -eq [CloneType]::Main) {
            $script:PsGitLog.Log('info',"Cloning default main branch", $Method)
            $Response = [LibGit2Sharp.Repository]::Clone($RepoUrl.AbsoluteUri, $Destination.FullName, $CloneOptions)
        }

        return $Response
    }

    # get repo status, assumes current directory is repo
    [LibGit2Sharp.RepositoryStatus] Status() {
        $Status = $null

        try {
            $StatusOptions = [LibGit2Sharp.StatusOptions]::new()
            $Status        = $this.Repository.RetrieveStatus($StatusOptions)
        } catch {
            throw $_
        }

        return $Status
    }

    # get repo status, assumes current directory is repo
    static [LibGit2Sharp.RepositoryStatus] RepoStatus() {
        $Status = $null

        try {
            $PsGit         = [psgit]::new($Pwd.Path)
            $StatusOptions = [LibGit2Sharp.StatusOptions]::new()
            $Status        = $PsGit.Repository.RetrieveStatus($StatusOptions)
        } catch {
            throw $_
        } finally {
            if ($PsGit.Repository) {
                $PsGit.Repository.Dispose()
            }
        }

        return $Status
    }

    # get repo status of supplied directory
    static [LibGit2Sharp.RepositoryStatus] RepoStatus([System.IO.DirectoryInfo] $RepositoryDirectory) {
        $Status = $null

        try {
            $PsGit         = [psgit]::new($RepositoryDirectory.FullName)
            $StatusOptions = [LibGit2Sharp.StatusOptions]::new()
            $Status        = $PsGit.Repository.RetrieveStatus($StatusOptions)
        } catch {
            throw $_
        } finally {
            if ($PsGit.Repository) {
                $PsGit.Repository.Dispose()
            }
        }

        return $Status
    }

    [LibGit2Sharp.MergeResult] Pull([PsGitPullOptions] $Options) {
        $PullOptions              = [LibGit2Sharp.PullOptions]::new()
        $PullOptions.FetchOptions.CredentialsProvider = $this.AddAuthentication($Options)

        $PullOptions

        return ''
    }

    # add authentication to options
    [System.MulticastDelegate] AddAuthentication([object] $PsGitOptions) {
        $CredentialsHandlerDelegate = $null

        if ($PsGitOptions.Credential) {
            $RepoCredentials          = [LibGit2Sharp.UsernamePasswordCredentials]::new()
            $RepoCredentials.Username = $PsGitOptions.Credential.UserName
            $RepoCredentials.Password = $PsGitOptions.Credential.GetNetworkCredential().Password

            $CredentialsHandlerDelegate = [LibGit2Sharp.Handlers.CredentialsHandler]{
                $RepoCredentials
            }
        }

        return $CredentialsHandlerDelegate
    }

    # add authentication to options
    # [Void] AddAuthentication([object] $LibGit2SharpOptions, [object] $PsGitOptions) {
    #     $LibGit2SharpOptions.FetchOptions = [LibGit2Sharp.FetchOptions]::new()

    #     if ($PsGitOptions.Credential) {
    #         $RepoCredentials          = [LibGit2Sharp.UsernamePasswordCredentials]::new()
    #         $RepoCredentials.Username = $PsGitOptions.Credential.UserName
    #         $RepoCredentials.Password = $PsGitOptions.Credential.GetNetworkCredential().Password

    #         $LibGit2SharpOptions.FetchOptions.CredentialsProvider = [LibGit2Sharp.Handlers.CredentialsHandler]{
    #             $RepoCredentials
    #         }
    #     }
    # }

    # create a new repository object
    [Void] NewRepository() {
        $this.Dispose()
        $this.Repository = [LibGit2Sharp.Repository]::new($this.RepositoryDirectory)
    }

    # create a new repository object with a supplied empty directory
    [Void] NewRepository([System.IO.DirectoryInfo] $GitRepository) {
        $this.Dispose()
        $this.Repository = [LibGit2Sharp.Repository]::new($GitRepository)
    }

    # internal method to test directory validity
    hidden [Void] TestDirectory([System.IO.DirectoryInfo] $Directory) {
        if (!(Test-Path $Directory.FullName -Type Container)) {
            throw [System.Management.Automation.ItemNotFoundException]::new("$($Directory.FullName) not found")
        }
    }

    hidden [System.IO.DirectoryInfo] GenerateDestination([uri] $RepoUrl, [System.IO.DirectoryInfo] $ProvidedDestination, [bool] $PreserveRepositoryName) {
        if ($PreserveRepositoryName) {
            $Destination = [System.IO.DirectoryInfo] ($ProvidedDestination.FullName + '\' + [System.IO.Path]::GetFileNameWithoutExtension($RepoUrl.AbsoluteUri))
        } else {
            $Destination = $ProvidedDestination
        }

        return $Destination
    }

    # dispose of repository resource
    [Void] Dispose() {
        if ($this.Repository) {
            $this.Repository.Dispose()
        }
    }
}
