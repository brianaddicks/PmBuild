PmBuild
====

Welcome to the **PmBuild** wiki!  **PmBuild** is a PowerShell module that provides tools for combing powershell functions into a single psm1 module file, as well as documenting said cmdlets based on their get-help information.
So far, this module adds 4 new cmdlets as follows:

* **[Join-ModuleCmdlets](http://brianaddicks.github.com/poweralto/Join-ModuleCmdlets.html)**: Joins multiple ps1 files into a single psm1 file.* **[New-CmdletHtml](http://brianaddicks.github.com/poweralto/New-CmdletHtml.html)**: Generates a powershell cmdlet help page in Html.* **[New-ModuleHomeHtml](http://brianaddicks.github.com/poweralto/New-ModuleHomeHtml.html)**: Generates a powershell module summary page in Html.* **[New-ModuleHomeMd](http://brianaddicks.github.com/poweralto/New-ModuleHomeMd.html)**: Generates a powershell module summary page in MarkDown.To install pmbuild, download [pmbuild.psm1](https://github.com/brianaddicks/PmBuild/raw/master/PmBuild.psm1).

Place it inside a it's own directory (named pmbuild) inside your Powershell Module path.  You can get your PSModule path from $env:PSModulePath. For example:
* Current User scope: `C:\Users\user\Documents\WindowsPowerShell\Modules\pmbuild\pmbuild.psm1`
* Local Machine scope: `C:\Windows\system32\WindowsPowerShell\v1.0\Modules\pmbuild\pmbuild.psm1`

After the file is in place, you can then import it into your PowerShell session:
`Import-Module pmbuild`

