Build-PowerAlto {
    $ExcludeCommands = @("Test-PaConnection")
    $InProgress      = @("Update-PaSoftware")
    $ExcludePattern  = "inprogress*"
    $Module = "poweralto"
    $BaseDir = "C:\Dropbox\dev\poweralto"
    $MainHtml = "index.html"
    $MdFile = "README.md"

    cd $BaseDir
    if ((Get-GitStatus).branch -ne "master") { "changing to master";git checkout master }

    $JoinModule = @{
        ModuleName = $Module
        FunctionDir = "$BaseDir\Functions"
        OutDir = $BaseDir
        ExcludePattern = $ExcludePattern
    }

    Join-ModuleCmdlets @JoinModule


    $HomeMd = @{
        Module = $Module
        OutDir = $BaseDir
        InProgress = $InProgress
        FileName = $MdFile
        Header = "$BaseDir\head.md"
        Footer = "$BaseDir\foot.md"
        Exclude = $ExcludeCommands
    }

    Create-ModuleHomeMd @HomeMd

    if ((Get-GitStatus).HasWorking) {
        git add .
        git commit -am "test"
        git push
    } else {
        "Nothing to commit"
    }

    if ((Get-GitStatus).branch -ne "gh-pages") { "changing to gh-pages";git checkout gh-pages }

    if (Test-Path "$BaseDir\$mainhtml") {
        $HomeHtml = @{
            Module = $Module
            OutDir = $BaseDir
            InProgress = $InProgress
            FileName = $MainHtml
            Header = "$BaseDir\parts\mainheader.html"
            Footer = "$BaseDir\parts\mainfooter.html"
            Exclude = $ExcludeCommands
        }
        "Creating Module Home Page"
        Create-ModuleHomeHtml @HomeHtml


        $cmdlethtml = @{
            Command = $Module
            OutDir = $BaseDir
            Header = "$BaseDir\parts\cmdletheader.html"
            Footer = "$BaseDir\parts\cmdletfooter.html"
            Exclude = $ExcludeCommands
        }
        "Creating CmdletHtml"
        Create-CmdletHtml @CmdletHtml

        if ((Get-GitStatus).HasWorking) {
            git add .
            git commit -am "test"
            git push
        } else {
            "Nothing to commit"
        }
    }

    if ((Get-GitStatus).branch -ne "master") { "changing to master";git checkout master }
}

Set-Alias -Name bpa -Value Build-PowerAlto