$calllogfile = "calllog*.csv"
$calllog = Import-Csv $calllogfile
$callarr =@()
foreach($call in $calllog){
	$start = Get-Date $call.'Call Time'
	$durationarray = $call.Talking.Split(":")
	$duration = New-TimeSpan -Hours $durationarray[0] -Minutes $durationarray[1] -Seconds $durationarray[2]
	
	$start
	#$duration
	$end = $start.AddTicks($duration.Ticks)
	$end
	$obj = New-Object -TypeName PSObject
	Add-Member -InputObject $obj -MemberType NoteProperty -Name start -Value $start
	Add-Member -InputObject $obj -MemberType NoteProperty -Name end -Value $end
	$callarr += $obj
}
$period = 1
$firstday = (Get-Date $callarr[0].start).Date
$lastday = (Get-Date $callarr[-1].start).Date
$day = $firstday
$countarr = @()
while ($day -le $lastday) {

	$callarrfilt = $callarr | Where-Object {($_.start -ge $day) -and ($_.start -lt $day.AddHours(24))}
	if($callarrfilt.Count -eq 0){
		$day = $day.AddDays(1)
		continue
	}
	$starttime = Get-Date $callarrfilt[0].start
	$current = $starttime
	$endtime = Get-Date $callarrfilt[-1].end
	while ($current -lt $endtime) {
		$match = $callarrfilt | Where-Object {($_.start -le $current) -and ($_.end -ge $current)}
		if($match.Count -gt 3){
			$current
			$match.count
			$countobj = New-Object -TypeName PSObject
			Add-Member -InputObject $countobj -MemberType NoteProperty -Name minute -Value $current
			Add-Member -InputObject $countobj -MemberType NoteProperty -Name sc -Value $match.count
			$countarr += $countobj
		}
		$current = $current.AddSeconds($period)
	}
	$day = $day.AddDays(1)
}
$countarr | Export-Csv .\sc.csv