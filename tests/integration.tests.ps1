BeforeAll {
    Import-Module "$PSScriptRoot\..\PsGit.psd1"
    $LocalDirectory = '.\tests\clone-test'
    $GitRepository  = 'https://github.com/octocat/Hello-World.git'
}

Describe "PsGit Integration Tests" {
    It "Clone Public Repository" {
        $Repository = [PsGit]::CloneRepo($GitRepository, $LocalDirectory)

        Test-Path $Repository | Should -Be $true
    }

    It "Get Repository Status" {
        [PsGit]::RepoStatus("$LocalDirectory\Hello-World") | Should -Be $null
    }

    It "Invalid.Get Repository Status" {
        {
            [PsGit]::RepoStatus("$LocalDirectory")
        } | Should -Throw
    }
}

AfterAll {
    Remove-Module PsGit
    Remove-Item $LocalDirectory -Force -Recurse
}
