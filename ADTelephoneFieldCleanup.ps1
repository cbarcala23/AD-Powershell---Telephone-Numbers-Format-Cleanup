####   Active Directory Telephone Number Cleanup Script by Chris Barcala -2018
####   Format should end up xxxxxxxxxx , if it is a bad number or one that could not be fixed, it is exported to a CSV and appended with username
####   Write outs are commented out and you can remove or uncomment to see expected results when testing.
####   Script by Chris Barcala 2018

##Get all AD Users in OU of your choosing. Get's the properties SamAcountName, telephoneNumber and ipPhone
$Users = Get-Aduser -Searchbase "OU=xxxx,DC=xxxx,DC=xxxx,DC=xxxx" -Filter * -Properties *|select SamAccountName, telephoneNumber, ipPhone


FOREACH($User in $Users) {

    ###VARIABLE DECLARATIONS

    $Phone = $User.telephoneNumber
    $IP = $User.ipPhone
    ##WRITE OUT ORIGINAL NUMBERS
    ##Write-Host $User.samaccountname
    ##Write-Host "Original Telephone Number: $Phone" -ForegroundColor Magenta;
    ##Write-Host "Original IP Phone Number: $ipPhone" -ForegroundColor Magenta;

    ##EXPORT ORIGINAL TELEPHONE AND IP PHONE NUMBERS TO CSV FOR ROLLBACK PROCESS

    $User | select SamAccountName, telephoneNumber, ipPhone | Export-Csv 'C:\yourpath\originalphones.csv' -Append


    ##CLEAN EXISTING PHONE NUMBER BY REMOVING ALL SPECIAL CHARACTERS "- ( ) . x ? *"

    $remCharPhone = "$Phone" -replace "[-().x?*]",""
    ##REMOVE ALL SPACES
    $CleanPhone = "$remCharPhone" -replace "\s",""
    ##WRITE OUT CLEAN PHONE FOR ERROR CHECKING
    ##Write-Host "Cleaned Telephone Number: $CleanPhone" -ForegroundColor Cyan;


    ##START IF STATEMENTS ON CLEANED PHONE NUMBER

    If ($CleanPhone.Length -eq 7) {
    #IF THE PHONE IS 7 CHARACTERS (xxxxxxx), APPEND 206 (Can be any area code of your choosing)
    ##4776061 becomes 2064776061 (assumes it is area code 206)

        Write-Host "Running If Statement 7 characters" -ForegroundColor White;
        $CleanPhone = "206$CleanPhone"
        Write-Host "WILL BECOME phonenumber" $CleanPhone -ForegroundColor Green;
        
        Set-ADUser -Identity $User.SamAccountName -OfficePhone $CleanPhone

        ##EXPORT FIXED VARIABLES
        New-Object -TypeName PSCustomObject -Property @{
            Telephone = $CleanPhone
            SamAccountName = $User.SamAccountName
        } | Export-Csv 'C:\yourpath\fixedphones.csv' -NoTypeInformation -Append

        ##FLAG VARIABLE TRUE
        $goodphone = "1"
       


    } ElseIf ($CleanPhone.Length -eq 11) {
    #IF THE PHONE IS 11 CHARACTERS (xxxxxxxxxxx), REMOVE FIRST DIGIT (1) if it is a 1
    ##12064776061 becomes 2064776061 (removes the first digit)

    Write-Host "Running If Statement 11 characters" -ForegroundColor White;
    
        ##IF IT DOES NOT START WITH A 1, EXPORT BAD NUMBER
        If (!($CleanPhone.StartsWith("1"))) {

            Write-Host "Does not start with 1"
            #EXPORT bad number
            Write-Host "Running Nested If Statement bad numbers export" -ForegroundColor Red;
            $User | select SamAccountName, telephoneNumber, ipPhone | Export-Csv 'C:\yourpath\badphones.csv' -Append

            ##FLAG VARIABLE FALSE
            $goodphone = "2"

        ##OTHERWISE IT IS STARTING WITH A 1 AND CAN BE SET
        } Else {

            Write-Host "DOES start with 1"
            ##Substring removes first digit in string
            $CleanPhone = $CleanPhone.Substring(1)
            Write-Host "WILL BECOME phonenumber" $CleanPhone -ForegroundColor Green;
            
            Set-ADUser -Identity $User.SamAccountName -OfficePhone $CleanPhone
            

        ##EXPORT FIXED PHONES WITH USER
        New-Object -TypeName PSCustomObject -Property @{
            Telephone = $CleanPhone
            SamAccountName = $User.SamAccountName
        } | Export-Csv 'C:\yourpath\fixedphones.csv' -NoTypeInformation -Append

            ##FLAG VARIABLE TRUE
            $goodphone = "1"
        }

    }Elseif ($CleanPhone.Length -eq 10) {

        ##SET THE CLEANED UP PHONE
        
        Set-ADUser -Identity $User.SamAccountName -OfficePhone $CleanPhone
        Write-Host "Cleaned Only Phone Number" $CleanPhone.TELEPHONENUMBER -ForegroundColor Yellow;
        
        ##EXPORT FIXED PHONES WITH USER
        New-Object -TypeName PSCustomObject -Property @{
            Telephone = $CleanPhone
            SamAccountName = $User.SamAccountName
        } | Export-Csv 'C:\yourpath\fixedphones.csv' -NoTypeInformation -Append

        ##FLAG VARIABLE TRUE
        $goodphone = "1"

    }Else {

        #EXPORT bad numbers such as 4 digits, 12 digits. Anything not 7,10,11 digits long OR BLANK is considered bad and must be dealt with manually

        Write-Host "Running ELSE Statement bad numbers export" -ForegroundColor Red;
        $User | select SamAccountName, telephoneNumber, ipPhone | Export-Csv 'C:\yourpath\badphones.csv' -Append

        ##FLAG VARIABLE FALSE
        $goodphone = "2"

    }

    ###COPY LAST 4 DIGITS TO IP PHONE FIELD IF VARIABLE $goodphone is 1 (true) else do not copy last 4 into IP. THIS SCENARIO ASSUMES YOU WANT THE LAST 4 DIGITS FOR THE USERS IPPHONE. IF NOT, YOU CAN REMOVE THIS PART BELOW.
    If($goodphone -match "1") {

        $LastFourDigits = $CleanPhone.Substring(6,4)
        Set-ADUser -Identity $User.SamAccountName -Replace @{ipPhone = $LastFourDigits}
        
    }

}
