Task 'Build' LibGit2Sharp, {}

Task 'LibGit2Sharp' {
    $LibGit2SharpVersion       = '0.30.0'
    $LibGit2SharpDirectory     = './src/lib/LibGit2Sharp'
    $LibGit2SharpDllPath       = './tmp/LibGit2Sharp.0*/lib/net6.0/LibGit2Sharp.dll'
    $LibGit2SharpNativeBinPath = './tmp/LibGit2Sharp.NativeBinaries*/runtimes'
    $TempDirectory             = './tmp'

    # cleanup lib directory
    if (Test-Path $LibGit2SharpDirectory)  {
        Remove-Item -Path $LibGit2SharpDirectory -Force -Recurse -ErrorAction Stop | Out-Null
    }

    # cleanup tmp directory
    if (Test-Path $TempDirectory) {
        Remove-Item -Path $TempDirectory -Force -Recurse -ErrorAction Stop | Out-Null
    }

    # install LibGit2Sharp nuget package
    nuget install LibGit2Sharp -version $LibGit2SharpVersion -outputdirectory ./tmp

    # create destination lib directories
    New-Item -Path $LibGit2SharpDirectory -ItemType Directory -Force |
    New-Item -Path "$LibGit2SharpDirectory/win" -ItemType Directory -Force | Out-Null
    New-Item -Path "$LibGit2SharpDirectory/linux" -ItemType Directory -Force | Out-Null

    # copy LibGit2Sharp dll's and native librraries
    Copy-Item -Path $LibGit2SharpDllPath -Destination "$LibGit2SharpDirectory/win" -Force | Out-Null
    Copy-Item -Path $LibGit2SharpDllPath -Destination "$LibGit2SharpDirectory/linux" -Force | Out-Null
    Copy-Item -Path "$LibGit2SharpNativeBinPath/linux-x64/native/*" -Destination "$LibGit2SharpDirectory/linux" -Force | Out-Null
    Copy-Item -Path "$LibGit2SharpNativeBinPath/win-x64/native/*" -Destination "$LibGit2SharpDirectory/win" -Force | Out-Null

    # cleanup tmp directory
    if (Test-Path $TempDirectory) {
        Remove-Item -Path $TempDirectory -Force -Recurse | Out-Null
    }
}
