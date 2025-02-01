# Function to change DNS settings
function Set-Dns {
    param (
        [string]$networkInterface,
        [string]$dns1,
        [string]$dns2
    )

    # Get the network adapter
    $adapter = Get-NetAdapter | Where-Object {$_.Name -eq $networkInterface}

    if ($adapter) {
        # Set DNS servers for IPv4
        Set-DnsClientServerAddress -InterfaceAlias $adapter.Name -ServerAddresses $dns1,$dns2

        # Set DNS servers for IPv6 (uncomment if needed)
        # Set-DnsClientServerAddress -InterfaceAlias $adapter.Name -ServerAddresses "2001:4860:4860::8888","2001:4860:4860::8844" -AddressFamily IPv6

        Write-Output "DNS settings for $networkInterface updated successfully."
    } else {
        Write-Output "Network adapter $networkInterface not found."
    }
}

# Set Google Public DNS for Ethernet and Wi-Fi connections
Set-Dns -networkInterface "Ethernet" -dns1 "8.8.8.8" -dns2 "8.8.4.4"
Set-Dns -networkInterface "Wi-Fi" -dns1 "8.8.8.8" -dns2 "8.8.4.4"
