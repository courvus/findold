$StartDir = $Null
$Global:CurrentDepth = 0
$Global:AgeFlag = 0
$Global:obs = 0


Function FindOld
{
    Param( [object]$StartDir = (Get-Location),
           [int]$CutoffAge = 365,
           [int]$CutoffDepth = 2 )
           
    
    $CutoffDate = $(Get-Date).AddDays(-$CutoffAge)
    
    [string[]]$SubDirs = (Get-ChildItem -Path $StartDir -Directory).Fullname
       
    $Files = (Get-ChildItem -Path $StartDir -File)
    if (-not $Files -ge 1) {$Global:AgeFlag = 1} #ugly - fix if possible
    foreach ($File in $Files)
    {
        if ($File.LastAccessTime -lt $CutoffDate)
        {
            $Global:AgeFlag = 1
        }

        elseif ($File.LastAccessTime -ge $CutoffDate)
        {
            $Global:AgeFlag = 0
            break
        }
                    
    }

    if ($Global:AgeFlag -eq 0)
    {
        if ($Global:CurrentDepth -gt $CutoffDepth)
        {
            $Global:CurrentDepth--
            return
        }

        elseif ($Global:CurrentDepth -le $CutoffDepth -and -not $SubDirs.Count -le 0)
        {
            $Global:CurrentDepth++
            FindOld -StartDir $SubDirs[0] -CutoffAge $CutoffAge -CutoffDepth ($CutoffDepth)
            #if ($Global:AgeFlag -eq 0 -and $Global:CurrentDepth -gt $CutoffDepth) {return}
            $SubDirs = $SubDirs[1..($SubDirs.Count)]
            
        }
    }
    
    elseif ($Global:AgeFlag -eq 1 -and -not $SubDirs.Count -le 0)
    {
        # Current folder matches criteria so make note
        # of this folder and continue down its tree until
        # it breaks or completes.
        FindOld -StartDir $SubDirs[0] -CutoffAge $CutoffAge -CutoffDepth ($CutoffDepth)
        if ($Global:AgeFlag -eq 0 -and $Global:CurrentDepth -gt $CutoffDepth) 
        {
            $global:currentdepth--
            return
        }
        $SubDirs = $SubDirs[1..($SubDirs.Count)]                      
    }
    
    while ($SubDirs.count -ge 1 -and $Global:CurrentDepth -lt $CutoffDepth)
    {
        $Global:CurrentDepth++
        FindOld -StartDir $SubDirs[0] -CutoffAge $CutoffAge -CutoffDepth $CutoffDepth
        if ($Global:AgeFlag -eq 0 -and $Global:CurrentDepth -gt $CutoffDepth) 
        {
            $global:CurrentDepth--
            return
        }
        $SubDirs = $SubDirs[1..($SubDirs.Count)] 
    }
    
    if ($Global:AgeFlag -eq 1 -and $Global:CurrentDepth -le $CutoffDepth)
    {
        #$FolderSize = "{0:N2}" -f ((Get-ChildItem -Path $StartDir -Recurse | Measure-Object -Property length -Sum).sum / 1GB)
        [string[]]$global:obs += ("($FolderSize GB) $StartDir ($Global:CurrentDepth)")
    }

    $Global:CurrentDepth--
}

       
