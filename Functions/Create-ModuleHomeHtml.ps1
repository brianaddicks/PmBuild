function Create-ModuleHomeHtml {
	<#
	.SYNOPSIS
		synopsis
	.DESCRIPTION
		description
	.PARAMETER Module
		module
    .PARAMETER OutDir
		outdir
    .PARAMETER FileName
        filename
    .PARAMETER InProgress
        inprogress
    .PARAMETER Exclude
        exclude
    .EXAMPLE
        EXAMPLE
    .EXAMPLE
        EXAMPLE
	#>
    
    Param (
        [Parameter(Mandatory=$True,Position=0)]
        [String]$Module,

        [Parameter(Mandatory=$True,Position=1)]
        [ValidateScript({Test-Path $_ -PathType 'Container'})] 
        [String]$OutDir,

        [Parameter(Mandatory=$False)]
        [alias('i')]
        [array]$InProgress,

        [Parameter(Mandatory=$False)]
        [alias('f')]
        [string]$FileName,

        [Parameter(Mandatory=$False)]
        [alias('head')]
        [string]$Header,

        [Parameter(Mandatory=$False)]
        [alias('foot')]
        [string]$Footer,

        [Parameter(Mandatory=$False)]
        [alias('x')]
        [array]$Exclude
    )

    BEGIN {
        function Create-Page {
            if ($FileName) {
                $OutFile = "$OutDir\$FileName"
            } else {
                $OutFile = "$OutDir\$Module.html"
            }

            $SynopsisRx = [regex] "(?msx)
                ^ ( SYNOP[^`$]+? )$
                .+?
                ^\s+ (?<synopsis> [^`$]+? )`$
                "
            $i = 0
            $Commands = gcm -Module $Module
            foreach ($c in $Commands) { 
                if ($Exclude -contains $c) { continue }
                $tempfile = "$OutDir\$c.txt"
                get-help $c -full | Out-File -FilePath $tempfile -width 500
                $FileContent = [io.file]::ReadAllText($tempfile)
                $Synopsis = $SynopsisRx.Match($CurrentString).Groups['synopsis'].value

                $CommandContent += "            <li><strong><a href=`"cmdlets/$c.html`">$c</a></strong>: "
                if ($InProgress -contains $c) { $CommandContent += '<strong><span style="color:#f00">**IN PROGRESS**</span></strong> ' }
                $CommandContent += $SynopsisRx.Match($FileContent).groups['synopsis'].value.Trim()
                $CommandContent += "</li>`r`n"
                $i++
                rm $tempfile
            }

            $gen = ""
            $gen += "          <p>So far, this module adds $i new cmdlets as follows:</p>`r`n"
            $gen += "            <ul>`r`n"
            $gen += $CommandContent
            $gen += "`r`n"
            $gen += "            <ul>`r`n"

            $html = @"
$Header
$gen
$Footer
"@
            $html | Out-File $OutFile -Encoding default
        }
    }
    PROCESS {
        $Header = [io.file]::ReadAllText("$Header")
        $Footer = [io.file]::ReadAllText("$Footer")
        if (Get-Module $Module) {
            Create-Page
        } else {
            Throw "no valid module"
        }
    }
}