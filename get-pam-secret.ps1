function Get-PAMSecret ([string]$token, [string]$sapm_name, [string]$sapm_path, [string]$comment) {
    $payload  = @{
        'token' = $token
        'comment' = $comment
        'sapmAccountPath' = $sapm_path
        'sapmAccountName' = $sapm_name
        # 'passwordExpirationInMinute' = 30
        'passwordChangeRequired' = 'FALSE'
        'responseType' = 'JSON'
    }
      
    $headers = @{
        'Content-Type' = 'application/json'
    }
      
    [Net.ServicePointManager]::SecurityProtocol = "tls12"
    try {
  
        $request = Invoke-WebRequest -uri 'https://....set-pam-uri' -Method Get -Headers $headers -Body $payload -UseBasicParsing
    } catch {
        Write-Output $_.Exception.Message
        $result = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($result)
        $reader.BaseStream.Position = 0
        $reader.DiscardBufferedData()
        $response = $reader.ReadToEnd()
        return "Error: $($response)"
    }

    # $secret = ('{"secret": {"username": "", "password": ""}}'| ConvertFrom-Json).secret 
    $secret = ($request.content | ConvertFrom-Json).secret 
    Remove-Variable 'request' -Force
    # $secret.password = ConvertTo-SecureString $secret.password -AsPlainText -Force

    return $secret
}
