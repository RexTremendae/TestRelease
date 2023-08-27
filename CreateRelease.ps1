$PSDefaultParameterValues['*:Encoding'] = 'utf8'

function GetNextVersion()
{
    $tags = [string[]] (git tag --list)

    $major_numeric = 0
    $minor_numeric = 0
    $patch_numeric = 0

    for ($i = 0; $i -lt $tags.Length; $i = $i + 1)
    #$tags | ForEach-Object 
    {
        $current = $tags[$i]

        # Version tag should start with 'v'
        if ($current[0] -ne 'v')
        {
            Write-Host "VARNING! " -ForegroundColor Yellow -NoNewline
            Write-Host "$current matchar inte strukturen på versionsnummer (ska börja med 'v')"
            continue;
        }

        # Should be 3 parts in version tag, separated by .
        $parts = $current.Split('.')
        if ($parts.Length -ne 3)
        {
            Write-Host "VARNING! " -ForegroundColor Yellow -NoNewline
            Write-Host "$current matchar inte strukturen på versionsnummer (ska bestå av 3 delar)"
            continue;
        }

        $major_part = $parts[0].Substring(1)
        $minor_part = $parts[1]
        $patch_part = $parts[2]

        # All version parts should be numeric
        if (($major_part -notmatch '\d+') -or ($minor_part -notmatch '\d+') -or ($patch_part -notmatch '\d+'))
        {
            Write-Host "VARNING! " -ForegroundColor Yellow -NoNewline
            Write-Host "$current matchar inte strukturen på versionsnummer (de tre delarna ska vara numeriska)"
            continue;
        }

        $new_major_numeric = [int]$major_part
        $new_minor_numeric = [int]$minor_part
        $new_patch_numeric = [int]$patch_part

        # ---- Major version part ----
        if ($new_major_numeric -gt $major_numeric)
        {
            $major_numeric = $new_major_numeric
            $minor_numeric = $new_minor_numeric
            $patch_numeric = $new_patch_numeric

            continue;
        }
        if ($new_major_numeric -lt $major_numeric)
        {
            continue;
        }

        # ---- Minor version part ----
        if ($new_minor_numeric -gt $minor_numeric)
        {
            $major_numeric = $new_major_numeric
            $minor_numeric = $new_minor_numeric
            $patch_numeric = $new_patch_numeric

            continue;
        }
        if ($new_minor_numeric -lt $minor_numeric)
        {
            continue;
        }

        # ---- Minor version part ----
        if ($new_patch_numeric -gt $patch_numeric)
        {
            $major_numeric = $new_major_numeric
            $minor_numeric = $new_minor_numeric
            $patch_numeric = $new_patch_numeric

            continue;
        }
    }

    return "v$major_numeric.$minor_numeric.$($patch_numeric+1)"
}



### MAIN ###

Push-Location $PSScriptRoot

# Verify no pending changes
if ([string[]] (git status --porcelain).Length -ne 0)
{
    Write-Host 'Kan inte skapa release' -ForegroundColor Red
    Write-Host 'Det finns ej incheckade ändringar. Checka in eller ångra dessa och försök igen.'
    Write-Host ''

    exit;
}

Write-Host 'Beräknar nästa versionsnummer...'
$next_version = GetNextVersion

Write-Host "En ny release med versionsnummer " -NoNewline
Write-Host $next_version -NoNewline -ForegroundColor Magenta
Write-Host " kommer att skapas."
Write-Host "Tryck [ENTER] för att fortsätta, eller [CTRL]+C för att avbryta..."

Read-Host

git tag $next_version
git push origin $next_version

Pop-Location
