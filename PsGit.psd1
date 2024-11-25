@{
    # ID used to uniquely identify this module
    GUID = 'a8fb9b59-5bcd-43f8-aca8-612aa1d9c3ac'

    # Author of this module
    Author = 'Jeremiah Haywood'

    # Copyright statement for this module
    Copyright = '(c) 2024 Jeremiah Haywood. All rights reserved.'

    # Version number of this module.
    ModuleVersion = '0.0.1'

    # Minimum version of PowerShell this module requires
    PowerShellVersion = '7.4'

    # Script files (.ps1) that are run in the caller's environment prior to importing this module.
    ScriptsToProcess = @(
        '.\src\public\PsGitLog.ps1',
        '.\src\private\Setup.ps1',
        '.\src\public\PsGitPullOptions.ps1',
        '.\src\public\PsGitCloneOptions.ps1',
        '.\src\public\PsGit.ps1'
    )

    # required for working with sqlite
    RequiredAssemblies = $(
        if ($env:OS -ne 'Windows_NT') {
            @(
                ".\src\lib\LibGit2Sharp\linux\LibGit2Sharp.dll"
            )
        } else {
            @(
                ".\src\lib\LibGit2Sharp\win\LibGit2Sharp.dll"
            )
        }
    )

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{
        PSData = @{
            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @('Git','LibGit2Sharp')

            # A URL to the license for this module.
            LicenseUri = 'https://github.com/port-43/PsGit/blob/main/LICENSE'

            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/port-43/PsGit'

            # A URL to an icon representing this module.
            # IconUri = ''

            # ReleaseNotes of this module
            # ReleaseNotes = ''

            # Prerelease string of this module
            # Prerelease = ''

            # Flag to indicate whether the module requires explicit user acceptance for install/update/save
            RequireLicenseAcceptance = $true

            # External dependent modules of this module
            # ExternalModuleDependencies = @()

        } # End of PSData hashtable
    } # End of PrivateData hashtable
}
