#http://data.ssb.no/api/v0/dataset/59322?lang=no

$AgeInfo = Invoke-RestMethod "http://data.ssb.no/api/v0/dataset/59322.csv?lang=no"

$Dataset = ConvertFrom-Csv $AgeInfo -Delimiter ";"
$DatasetBeggeKjønn = $Dataset | where {$_.Kjønn -like "0 Begge Kjønn"}
$DatasetMenn = $Dataset | where {$_.Kjønn -like "1 Menn"}
$DatasetKvinner = $Dataset | where {$_.Kjønn -like "2 Kvinner"}


$Tall = "10211: Befolkning, etter alder, kjønn, år og statistikkvariabel"


Function Total {

    param(

         [Parameter(Mandatory)]
         [int]$Year,

         [Parameter()]
         [ValidateSet("Begge", "Menn", "Kvinner")]
         [String]$Who = "Begge",

         [Parameter()]
         [Switch]$NoFormat

         )

        if ($Year -le "1845" ) {
    
            Write-Host "Vi har bare folketall fra 1846 og fremover" -ForegroundColor Red
            break

            }

        switch ( $Who ) {

            "Begge" { $DatasetInUse = $DatasetBeggeKjønn }
            "Menn" { $DatasetInUse = $DatasetMenn }
            "Kvinner" { $DatasetInUse = $DatasetKvinner }

            }

        $Total = $null
        ($DatasetInUse | Where { $_.år -like $Year }).$Tall| %  {
    
                $Total += [int]$_

            }

        $FormatTotal = '{0:N0}' -f $Total                      

        if ( $NoFormat ) {
            $Total
            }


        else {

            if ($Who -like "Begge") { 
                Write-Host "I $Year var folketallet i norge " -NoNewline
                Write-Host $FormatTotal -ForegroundColor Red
            }

            else {
                Write-Host "I $Year var folketallet for $Who i Norge " -NoNewline
                Write-Host $FormatTotal -ForegroundColor Red
                }

            }
            
    }


Function CompareYears {

    #Compare the total population between two years, Return value in int and percentage for increase 

    param(
        
         [parameter(Mandatory)]
         [int]$CompareYear1,

         [parameter(Mandatory)]
         [int]$CompareYear2,

         [Parameter()]
         [ValidateSet("Begge", "Menn", "Kvinner")]
         [String]$Who = "Begge"

         )

    $Comparative1 = Total $CompareYear1 -Who $Who -NoFormat
    $Comparative2 = Total $CompareYear2 -Who $Who -NoFormat


    $Difference = $Comparative2 - $Comparative1
    $DifferenceFormatted = '{0:N0}' -f $Difference
    $PercentageIncrease = $Difference  / $Comparative1 * 100
    $PercentageIncrease = [math]::Round($PercentageIncrease, 2)

    #Output

    if ( $Who -like "Begge" ) { 
        Write-Host "Mellom årene $CompareYear1 og $CompareYear2 opplevde norge en befolkningsvekst på:"
        }
    else { 
        Write-Host "Mellom årene $CompareYear1 og $CompareYear2 opplevde norge en befolkningsvekst i anntal $Who på:"
        }
    Write-host $DifferenceFormatted -ForegroundColor Red
    Write-Host "Det er en " -NoNewline
    Write-host $PercentageIncrease -ForegroundColor Red -NoNewline
    Write-Host " % økning"

}

Function AverageAge {

    Param(

        [Parameter(Mandatory)]
        [int]$Year,

        [Parameter()]
        [ValidateSet("Begge", "Menn", "Kvinner")]
        [String]$Who = "Begge",

        [Parameter()]
        [Switch]$NoFormat

        )

            if ($Year -le "1845" ) {
    
            Write-Host "Vi har bare folketall fra 1846 og fremover" -ForegroundColor Red
            break

            }

        switch ( $Who ) {

            "Begge" { $DatasetInUse = $DatasetBeggeKjønn }
            "Menn" { $DatasetInUse = $DatasetMenn }
            "Kvinner" { $DatasetInUse = $DatasetKvinner }

            }

        $Total = Total $Year -Who $Who -NoFormat

        $TotalAge = $Null
        foreach ( $Object in ($DatasetInUse | Where { $_.år -like $Year })) {
    
            [int]$Age = ($Object.alder -split " ")[1]
            [int]$Number = $Object.$Tall
            $Totalage += $Age * $Number

            }

        $AverageAge = $TotalAge / $Total

        $FormatAverage = [math]::Round($AverageAge, 2)                   

        if ( $NoFormat ) {
            $AverageAge
            }

        else {

            if ($Who -like "Begge") { 
                Write-Host "I $Year Var gjennomsnittsalderen i Norge " -NoNewline
            }

            else {
                Write-Host "I $Year var gjennomsnittsalderen for $Who i Norge " -NoNewline
            }

            Write-Host $FormatAverage -ForegroundColor Red -NoNewline
            Write-Host " år"

            }

    }

Function AgeDistribution {

    Param(

        [Parameter(Mandatory)]
        [int]$Year,

        [Parameter()]
        [ValidateSet("Begge", "Menn", "Kvinner")]
        [String]$Who = "Begge",

        [Parameter()]
        [Switch]$NoFormat

        )

            if ($Year -le "1845" ) {
    
            Write-Host "Vi har bare folketall fra 1846 og fremover" -ForegroundColor Red
            break

            }

        switch ( $Who ) {

            "Begge" { $DatasetInUse = $DatasetBeggeKjønn }
            "Menn" { $DatasetInUse = $DatasetMenn }
            "Kvinner" { $DatasetInUse = $DatasetKvinner }

            }

        $Total = Total $Year -Who $Who -NoFormat

        $AgeDistribution = @()
        foreach ( $Object in ($DatasetInUse | Where { $_.år -like $Year })) {
    
            [int]$Age = ($Object.alder -split " ")[1]
            [int]$Number = $Object.$Tall

            $AgeObject = New-Object –TypeName PSObject
            $AgeObject | Add-Member –MemberType NoteProperty –Name Age –Value $Age
            $AgeObject | Add-Member –MemberType NoteProperty –Name Count –Value $Number

            $AgeDistribution += $AgeObject

            }

        foreach ( $Object in $AgeDistribution ) {

            if ( $Object.Age -le "25" ) {
                $Group1 += $object.count
                }
            if ( $Object.Age -le "50" -and $Object.age -ge "26" ) {
                $Group2 += $object.count
                }
            if ( $Object.Age -le "75" -and $Object.age -ge "51" ) {
                $Group3 += $object.count
                }
            if ( $Object.Age -le "100" -and $Object.age -ge "76" ) {
                $Group4 += $object.count
                }
            if ( $Object.age -gt "100" ) {
                $Group5 += $object.count
                }
            }
            
        $GroupsArray = @{"0 - 25" = $Group1; "26 - 50" = $Group2; "51 - 75" =  $Group3; "76 - 100" = $Group4; "100+" = $Group5}
        
        $OutPutObject = @()
        #Calculate percentage
        Foreach ( $Group in $GroupsArray.Keys ) {

        $i = New-Object –TypeName PSObject
        $i | Add-Member –MemberType NoteProperty –Name AgeGroup –Value $Group
        $i | Add-Member –MemberType NoteProperty –Name Count –Value $GroupsArray.$Group

        $Percentage = [math]::Round((($GroupsArray.$Group) / $Total * 100), 2)

        $i | Add-Member –MemberType NoteProperty –Name Percentage –Value $Percentage
        $OutPutObject += $i

            }

        if ( $NoFormat ) {
            $AgeDistribution
            }

        else {

            if ($Who -like "Begge") { 
                Write-Host "I $Year var totalbefolkningen i Norge " -NoNewline
            }

            else {
                Write-Host "I $Year var totalbefolkningen av $Who i Norge " -NoNewline
            }

            Write-Host $Total -ForegroundColor Red
            Write-Host ""
            
            $OutPutObject

            }
    }

