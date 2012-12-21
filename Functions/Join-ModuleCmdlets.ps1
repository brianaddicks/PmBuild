function Join-ModuleCmdlets {
	<#
	.SYNOPSIS
		Joins multiple ps1 files into a single psm1 file.
	.DESCRIPTION
		Takes all ps1 files in a given directory and combines them into a single powershell module file (psm1).
	.PARAMETER ModuleName
		Name of the module being built, output file will be $ModuleName.psm1
    .PARAMETER FunctionDir
		Directory containing the ps1 files to join.
    .PARAMETER OutDir
		Directory to save the psm1 file to.
    .PARAMETER ExcludePattern
		Pattern to exclude certain ps1 files by name.
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

            $Hashes = @{}
            foreach ($File in $Files) {
                $Hash = (get-hash $file).HashString
                $Hashes.Add("$File",$Hash)
                $Current = gc $File
                $Joined += $Current
            }
            
            $Joined | Out-File "$OutDir\$ModuleName.psm1" -Force -Encoding default
            remove-module $ModuleName -errorAction silentlyContinue
            import-module "$OutDir\$ModuleName.psm1" -global
            #for future use
            #return $Hashes

        }
    }

    PROCESS {
        Join-Files
    }
}