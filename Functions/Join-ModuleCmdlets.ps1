function Join-ModuleCmdlets {
	<#
	.SYNOPSIS
		synopsis
	.DESCRIPTION
		description
	.PARAMETER Command
		command
    .PARAMETER OutDir
		outdir
    .EXAMPLE
        example
    .EXAMPLE
        example
	#>
    
    Param (
        [Parameter(Mandatory=$True,Position=0)]
        [String]$ModuleName,

        [Parameter(Mandatory=$True,Position=1)]
        [ValidateScript({Test-Path $_ -PathType 'Container'})] 
        [String]$FunctionDir,

        [Parameter(Mandatory=$True,Position=2)]
        [ValidateScript({Test-Path $_ -PathType 'Container'})] 
        [String]$OutDir,

        [Parameter(Mandatory=$False)]
        [alias('xp')]
        [string]$ExcludePattern
    )

    BEGIN {
        function Join-Files {
            $Joined = @()
            $lsparams = @{}
            if ($ExcludePattern) { $lsparams.Add("Exclude",$ExcludePattern) }
            $lsparams.Add("Path","$FunctionDir\*.ps1")

            $Files = ls @lsparams

            foreach ($File in $Files) {
                $Current = gc $File
                $Joined += $Current
            }
            
            $Joined | Out-File "$OutDir\$ModuleName.psm1" -Force -Encoding default
            remove-module $ModuleName -errorAction silentlyContinue
            import-module "$OutDir\$ModuleName.psm1" -global

        }
    }

    PROCESS {
        Join-Files
    }
}