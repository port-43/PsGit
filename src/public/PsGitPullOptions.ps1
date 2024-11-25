[NoRunspaceAffinity()]
class PsGitPullOptions {
    [string] $Username
    [mailaddress] $Email
    [pscredential] $Credential

    PsGitPullOptions([hashtable] $Properties) {
        $this.Init($Properties)
    }

    PsGitPullOptions([pscredential] $Credential) {
        $this.Credential = $Credential
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
