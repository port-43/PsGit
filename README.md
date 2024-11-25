# PsGit Documentation

## Overview

The PsGit module is designed for automating Git repository interactions using `LibGit2Sharp`. It includes customizable options for cloning repositories, checking out branches or tags, handling credentials, and querying repository status.

### Installing Module
```powershell
Import-Module .\PsGit.psd1
```

### Primary Classes
- **`PsGitCloneOptions`**: Defines customizable options for cloning Git repositories, including branch/tag selection and credential handling.
- **`PsGit`**: Provides methods for cloning, checking out, and retrieving repository status with detailed logging support.

> 💡 **Tip**: Logging can enabled by setting the following environment variable
> ```powershell
> $env:PsGitLogDebug = 'true'
> ```

---

## Class: PsGitCloneOptions

The `PsGitCloneOptions` class specifies options for cloning a Git repository, such as the target branch or tag, credentials for authentication, and whether to preserve the original repository name in the local clone.

### Properties

- **`CloneType`** (`CloneType`): Specifies the type of clone to perform. Options include:
  - `Main` (default): Clones the main branch.
  - `Tag`: Clones a specific tag.
  - `Branch`: Clones a specific branch.
- **`BranchName`** (`string`): The branch name to clone (used when `CloneType` is set to `Branch`).
- **`Tag`** (`string`): The tag name to clone (used when `CloneType` is set to `Tag`).
- **`PreserveRepositoryName`** (`bool`): If `true`, preserves the repository name in the local directory structure.
- **`Credential`** (`PSCredential`): Credentials for private repository authentication.

### Constructors

1. Convenient Properties Constructor
Initializes an instance with properties from a hashtable.
```powershell
[PsGitCloneOptions]::new([hashtable] $Properties)
 ```

1. Type-specific Constructor
```powershell
# minimal
[PsGitCloneOptions]::new([CloneType] $Type, [string] $Value)

# full
[PsGitCloneOptions]::new([CloneType] $Type, [string] $Value, [bool] $PreserveRepositoryName, [pscredential] $Credential)
```

### Example Usage
```powershell
$Options = [PsGitCloneOptions]::new(@{
    CloneType              = 'Tag'
    Credential             = $(Get-Credential)
    PreserveRepositoryName = $false
    Tag                    = 'v1.0'
})
```

## Class: PsGit
The `PsGit` class provides methods for cloning repositories, checking out branches or tags, and retrieving repository status. This class utilizes the PsGitCloneOptions to define cloning behavior.

### Properties
- `RepositoryDirectory` (`System.IO.DirectoryInfo`): The directory where the repository is cloned.
- `Repository` (`LibGit2Sharp.Repository`): Represents the active Git repository instance.
- `Logger` (`PsGitLog`): Logger instance for tracking Git operations.

### Constructors
Initializes an instace of `PsGit` based on the provided git directory.

1. Type-specific Constructor
```powershell
[PsGit]::new([System.IO.DirectoryInfo] '.\path\to\git\dir')
```

### Methods

#### Cloning
- `Clone([uri] $RepoUrl)`: Clones the repository to the current working directory.
- `Clone([uri] $RepoUrl, [System.IO.DirectoryInfo] $Destination)`: Clones the repository to a specified directory.
- `Clone([uri] $RepoUrl, [PsGitCloneOptions] $Options)`: Clones with specific options, such as branch, tag, and credentials.
- `Clone([uri] $RepoUrl, [System.IO.DirectoryInfo] $Destination, [PsGitCloneOptions] $Options)`: Clones to a specific directory with clone options.

#### Static Cloning Methods
These static methods provide quick access for repository cloning with minimal configuration.

- `CloneRepo([uri] $RepoUrl)`: Clones a repository to the current working directory.
- `CloneRepo([uri] $RepoUrl, [System.IO.DirectoryInfo] $Destination)`: Clones to a specified directory.
- `CloneRepo([uri] $RepoUrl, [PsGitCloneOptions] $Options)`: Clones with specific options.
- `CloneRepo([uri] $RepoUrl, [System.IO.DirectoryInfo] $Destination, [PsGitCloneOptions] $Options)`: Clones to a specific directory with custom options.

#### Status
- `Status()`: Returns the current repository status.

#### Static Status Methods
- `RepoStatus()`: Static method to get the status of a repository in the current directory.
- `RepoStatus([System.IO.DirectoryInfo] $RepositoryDirectory)`: Static method to get the status of a repository in a specified directory.

### Example Usage
```powershell
# clone repo to current directory
[PsGit]::CloneRepo('https://example.repo/project.git')

# create PsGit object and get status of repo at local directory test
$PsGit = [PsGit]::new('.\test')

$PsGit.Status()

# clone repo to local directory test
[PsGit]::CloneRepo('https://example.repo/project.git', '.\test')

# clone repo to absolute path based on a specific tag, with credentials and don't preserve the project name
[PsGit]::CloneRepo('https://example.repo/project.git', 'C:\Path\to\directory', [PsGitCloneOptions]::new(@{
    CloneType              = 'Tag'
    Credential             = $(Get-Credential)
    PreserveRepositoryName = $false
    Tag                    = 'v1.0'
}))

# clone repo to working directory based on a specific branch, with credentials and preserve the project name
[PsGit]::CloneRepo('https://example.repo/project.git', [PsGitCloneOptions]::new(@{
    CloneType              = 'Branch'
    Credential             = $(Get-Credential)
    PreserveRepositoryName = $true
    BranchName             = 'development'
}))

# get status of repo in the current working directory
[PsGit]::RepoStatus()

# get status of repo at the directory test
[PsGit]::RepoStatus('.\test')
```
