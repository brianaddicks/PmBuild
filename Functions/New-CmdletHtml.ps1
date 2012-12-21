function New-CmdletHtml {
	<#
	.SYNOPSIS
		Generates a powershell cmdlet help page in Html.
	.DESCRIPTION
		Generates a detailed help page in html for a given cmdlet, based on get-help of the cmdlet.
	.PARAMETER Command
		Name of the Command to generate a help page for.  If a module name is specified, all cmdlets in the module will be processed.
    .PARAMETER OutDir
		Directory to store the resulting file.
    .PARAMETER Exclude
        Designate an array of strings containing the name of commands to exclude from processing.
    .PARAMETER Header
        Designate a file whose contents you want prepended to the generated page.
    .PARAMETER Footer
        Designate a file whose contents you want appended to the generated page.
	#>
    
    Param (
        [Parameter(Mandatory=$True,Position=0)]
        [String]$Command,

        [Parameter(Mandatory=$True,Position=1)]
        [ValidateScript({Test-Path $_ -PathType 'Container'})] 
        [String]$OutDir,

        [Parameter(Mandatory=$True)]
        [alias('head')]
        [string]$Header,

        [Parameter(Mandatory=$True)]
        [alias('foot')]
        [string]$Footer,

        [Parameter(Mandatory=$False)]
        [alias('x')]
        [array]$Exclude
    )

    BEGIN {
        function Create-Page ( [string]$Command ) {
            $OutFile = "$OutDir\$Command.html"
            $tempfile = "$OutDir\$Command.txt"
            get-help $command -full | Out-File -FilePath $tempfile -width 500
            $Current = gc $tempfile
            $CurrentString = [string]::join("`n",$Current)
            $Steps = 7
            $TimerStart = Get-Date
            $i = 0
    
            $SynopsisRx = [regex] "(?msx)
                ^ ( SYNOP[^`$]+? )$
                .+?
                ^\s+ (?<synopsis> [^`$]+? )`$
                "

            $SyntaxRx = [regex] "(?msx)
                ^ ( SYNTA[^`$]+? )$
                .+?
                ^\s+ (?<syntax> [^`$]+? )`$
                "

            $DescriptionRx = [regex] "(?msx)
                ^ ( DESCRIP[^`$]+? )$
                .+?
                ^\s+ (?<description> [^`$]+? )`$
                "

            $ParametersRx = [regex] '(?msx)
                ^\s+\-(?<name>[^$]+?)$
                .+?
                ^\s+(?<desc> [^$]+? )$
                .+?
                ^\s+Required\?\s+ (?<required> [^$]+? )$
                .+?
                ^\s+Position\?\s+ (?<position> [^$]+? )$
                .+?
                ^\s+Default\svalue\s+(?<default>\w+)?$
                .+?
                ^\s+Accept\spipeline\sinput\?\s+ (?<pipeline> [^$]+? )$
                .+?
                ^\s+Accept\swildcard\scharacters\?\s+ (?<wild> [^$]+? )$
                '

            $ExamplesRx = [regex] '(?msx)
                -\sEXAMPLE\s(?<number>\d+)[^$]+?$
                (?<body>.+?^\s+^\s+^\s+^)
                '
            

            $i++
            Write-Progress -Activity "Generating html for $Command" -Status "Finding Name $i/$Steps" -Id 2 -PercentComplete (( $i / $Steps) * 100) -ParentId 1
            $Name = $Command
            $Elapsed = ((Get-Date) - $TimerStart).TotalSeconds
            $Timer = get-date
            if ($Elapsed -gt 3) { Write-Host "Name: $Elapsed" }
            
            $i++
            Write-Progress -Activity "Generating html for $Command" -Status "Finding Synopsis $i/$Steps" -Id 2 -PercentComplete (( $i / $Steps) * 100) -ParentId 1
            $Synopsis = $SynopsisRx.Match($CurrentString).Groups['synopsis'].value
            $Elapsed = ((Get-Date) - $Timer).TotalSeconds
            $Timer = get-date
            if ($Elapsed -gt 3) { Write-Host "Synopsis: $Elapsed" }
            
            $i++
            Write-Progress -Activity "Generating html for $Command" -Status "Finding Syntax $i/$Steps" -Id 2 -PercentComplete (( $i / $Steps) * 100) -ParentId 1
            $Syntax = ($SyntaxRx.Match($CurrentString).Groups['syntax'].value).Replace("<","&lt;")
            $Elapsed = ((Get-Date) - $Timer).TotalSeconds
            $Timer = get-date
            if ($Elapsed -gt 3) { Write-Host "Syntax: $Elapsed" }
            
            $i++
            Write-Progress -Activity "Generating html for $Command" -Status "Finding Description $i/$Steps" -Id 2 -PercentComplete (( $i / $Steps) * 100) -ParentId 1
            $Description = $DescriptionRx.Match($CurrentString).Groups['description'].value
            $Elapsed = ((Get-Date) - $Timer).TotalSeconds
            $Timer = get-date
            if ($Elapsed -gt 3) { Write-Host "Description: $Elapsed" }

            $gen = ""
            $gen += "        <h1>$Name</h1>`r`n`r`n"

            $gen += "          <h2>Synopsis</h2>`r`n"
            $gen += "            <p>$Synopsis</p>`r`n`r`n"

            $gen += "          <h2>Syntax</h2>`r`n"
            $gen += "            <p>$Syntax</p>`r`n`r`n"

            $gen += "          <h2>Description</h2>`r`n"
            $gen += "            <p>$Description</p>`r`n`r`n"

            $gen += "          <h2>Parameters</h2>`r`n"

            $i++
            Write-Progress -Activity "Generating html for $Command" -Status "Finding Parameters $i/$Steps" -Id 2 -PercentComplete (( $i / $Steps) * 100) -ParentId 1
            $Parameters = $ParametersRx.matches($CurrentString)
            foreach ($param in $Parameters) {
                $p = ($param.groups['name'].value).Replace("<","&lt;")
                $gen += "            <h3>-$p</h3>`r`n"
                $gen += "              <p>$($param.groups['desc'].value)</p>"
                $gen += "<table>"
                $gen += "              <tr><td>Required</td><td>$($param.groups['required'].value)</td></tr>`r`n"
                $gen += "              <tr><td>Position</td><td>$($param.groups['position'].value)</td></tr>`r`n"
                $gen += "              <tr><td>Default Value</td><td>$($param.groups['default'].value)</td></tr>`r`n"
                $gen += "              <tr><td>Accept pipeline input</td><td>$($param.groups['pipeline'].value)</td></tr>`r`n"
                $gen += "              <tr><td>Accept wildcard characters</td><td>$($param.groups['wild'].value)</td></tr>`r`n`r`n"
                $gen += "</table>"
            }
            $Elapsed = ((Get-Date) - $Timer).TotalSeconds
            $Timer = get-date
            if ($Elapsed -gt 3) { Write-Host "Parameters: $Elapsed" }

            $i++
            Write-Progress -Activity "Generating html for $Command" -Status "Finding Examples $i/$Steps" -Id 2 -PercentComplete (( $i / $Steps) * 100) -ParentId 1
            $Examples = $ExamplesRx.Matches($CurrentString)
            foreach ($example in $Examples) {
                $gen += "          <h2>Example $($example.groups['number'].value)</h2>`r`n"
                $gen += "              <pre><code>$($example.groups['body'].value.trim())</code></pre>`r`n"
            }
            $Elapsed = ((Get-Date) - $Timer).TotalSeconds
            $Timer = get-date
            if ($Elapsed -gt 3) { Write-Host "Examples: $Elapsed" }

            $html = @"
$Header
$gen
$Footer
"@

            $html | out-file $OutFile -Encoding default    
            rm $tempfile
            $Elapsed = ((Get-Date) - $TimerStart).TotalSeconds
            if ($Elapsed -gt 3) { Write-Host "Completed $Name`: $Elapsed" }
        }
    }

    PROCESS {
        $Header = [io.file]::ReadAllText("$Header")
        $Footer = [io.file]::ReadAllText("$Footer")
        if (Get-Module $Command) {
            $Commands = gcm -Module $Command
            $i = 0
            foreach ($c in $Commands) {
                $Progress = ( $i / ($Commands.count)) * 100
                Write-Progress -Activity "Generating html for $Command" -Status "$i/$($Commands.count): $($c.name).html" -Id 1 -PercentComplete $Progress
                $i++
                if ($Exclude -contains $c) { continue }
                Create-page $c.name
            }
        } elseif (Get-Command $Command -errorAction SilentlyContinue) {
            Create-page $Command
        } else {
            Throw "no valid module or command"
        }
    }
}