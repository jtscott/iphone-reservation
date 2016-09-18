$date = get-date -format "yyyy-MM-dd HH:mm"
$uriPusho = "https://api.pushover.net/1/messages.json"
$tokPusho = "YOUR_APP_TOKEN"
$apiPusho = "YOUR_API_TOKEN"
$parameters = @{
                token = "$tokPusho"
                user = "$apiPusho"
                message = "iPhone at $store is in stock."
                priority = "1"
                sound = "echo"
                url = "https://reserve-ca.apple.com/CA/en_CA/reserve/iPhone"
                url_title = "Click here to reserve"
                }
$logfile = "C:\iphone.txt"
$store_names = @("Chinook","Market ")


$jsonfeed = invoke-restmethod -URI "https://reserve.cdn-apple.com/CA/en_CA/reserve/iPhone/availability.json" -Method Get | Select-Object R209,R301
$chinook = $jsonfeed.R209 | Select-Object "MG3F2CL/A" | Out-String
$market = $jsonfeed.R120 | Select-Object "MG3F2CL/A" | Out-String


$chinook_status = $chinook -match 'True'
$market_status = $market -match 'True'


$store_status = @("$chinook_status", "$market_status")


$store_hash = @{} #Initialize a hash table
for ( $n = 0; $n -lt $store_names.Count; $n++ ) { #Find how many assets to iterate through
    $store_hash.Add($store_names[$n], $store_status[$n]) #Combine the asset and zips arrays into a table for iteration
}


foreach ($status in $store_hash.GetEnumerator()) {
    if ($($status.Value) -eq "True") {
        $store = "$($status.Name)"
        $parameters | Invoke-RestMethod -Uri $uriPusho -Method Post
    }
    else {
    $store = "$($status.Name)"
    echo "$date $store`:  No stock." | out-file -Append $logfile
    }
}