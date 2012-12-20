To install pmbuild, download [pmbuild.psm1](https://github.com/brianaddicks/PmBuild/raw/master/PmBuild.psm1).

Place it inside a it's own directory (named pmbuild) inside your Powershell Module path.  You can get your PSModule path from $env:PSModulePath. For example:
* Current User scope: `C:\Users\user\Documents\WindowsPowerShell\Modules\pmbuild\pmbuild.psm1`
* Local Machine scope: `C:\Windows\system32\WindowsPowerShell\v1.0\Modules\pmbuild\pmbuild.psm1`

After the file is in place, you can then import it into your PowerShell session:
`Import-Module pmbuild`
