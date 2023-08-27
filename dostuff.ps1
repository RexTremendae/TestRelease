$tag = Get-Content github.ref.txt
$version = ($tag -split '/')[2]
if ($NULL -eq $version) {
    $version = $tag
}

Set-Content -Path release_info.txt -Value $version

Get-Content -Path release_info.txt
