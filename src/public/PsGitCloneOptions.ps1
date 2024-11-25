[NoRunspaceAffinity()]
class PsGitCloneOptions {
    [CloneType] $CloneType = [CloneType]::Main
    [string] $BranchName
    [string] $Tag
    [bool] $PreserveRepositoryName = $false
    [pscredential] $Credential

    PsGitCloneOptions([hashtable] $Properties) {
        $this.Init($Properties)
    }

    PsGitCloneOptions([CloneType] $Type, [string] $Value) {
        $this.CloneType = $Type
        $this.SetValue($Value)
    }

    PsGitCloneOptions([CloneType] $Type, [string] $Value, [bool] $PreserveRepositoryName) {
        $this.CloneType = $Type
        $this.SetValue($Value)
        $this.PreserveRepositoryName = $PreserveRepositoryName
    }

    PsGitCloneOptions([CloneType] $Type, [string] $Value, [pscredential] $Credential) {
        $this.CloneType = $Type
        $this.SetValue($Value)
        $this.Credential = $Credential
    }

    PsGitCloneOptions([CloneType] $Type, [string] $Value, [bool] $PreserveRepositoryName, [pscredential] $Credential) {
        $this.CloneType = $Type
        $this.SetValue($Value)
        $this.PreserveRepositoryName = $PreserveRepositoryName
        $this.Credential = $Credential
    }

    # set either the branch name or tag based on clone type
    [Void] SetValue([string] $Value) {
        switch ($this.CloneType) {
            ([CloneType]::Tag) { $this.Tag = $Value}
            ([CloneType]::Branch) { $this.BranchName = $Value}
        }
    }

    hidden Init([hashtable] $Properties) {
        foreach ($Key in $Properties.Keys) {
            try {
                $this.$Key = $Properties[$Key]
            } catch {
                $null = $_
            }
        }
    }
}

enum CloneType {
    Main
    Tag
    Branch
}
