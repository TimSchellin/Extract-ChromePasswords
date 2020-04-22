write-output "ducky script converter!`nInserts delays and ENTER keys between each command`n"
$file = read-host -prompt "path of file: "
$default_delay = read-host -prompt "default time to delay: "
foreach ($line in get-content($file)){
    write-output "STRING $line `nDELAY $default_delay `nENTER `nDELAY $default_delay"
}
