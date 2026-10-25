# Windows Server 2025 keeps File and Printer Sharing rules disabled; language-independent group ID
Get-NetConnectionProfile
Enable-NetFirewallRule -Group "@FirewallAPI.dll,-28502"
