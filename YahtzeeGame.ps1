<#
.SYNOPSIS
  Yahzee Game completely in PowerShell
.DESCRIPTION
  Kicks off a game of Yahtzee completely in the console. Currently single player only.
  Now includes ASCII art dice
.NOTES
  Author:         Chris Smith (smithcbp on github)
  Creation Date:  5/14/2021
  Todos:
    -Triple Yahtzee
    -WPF GUI
    -Multiplayer
.EXAMPLE
  Just run YahtzeeGame.ps1 and have fun :)
#>

<#
    .SYNOPSIS
    Displays a set of Dice

    .DESCRIPTION
    Displays a set of ASCII dice based on inputs.
    Can take in either a array of integers to display exactly what dice you want
    or an integer to display that many random dice

    .PARAMETER Random
    How many Dice to create randomly

    .PARAMETER NumberSet
    An array of integers to display

    .PARAMETER DieColor
    Color to Display the Dice in

    .INPUTS
    Not Implemented

    .OUTPUTS
    Not Implemented

    .EXAMPLE
    PS> Show-AsciiDice -Random 3
     _____     _____     _____ 
    |o   o|   |     |   | o   |
    |  o  |   |  o  |   |  o  |
    |o   o|   |     |   |   o |
     -----     -----     -----  

    .EXAMPLE
    PS> Show-AsciiDice -NumberSet @(5, 1, 3)
     _____     _____     _____ 
    |o   o|   |     |   | o   |
    |  o  |   |  o  |   |  o  |
    |o   o|   |     |   |   o |
     -----     -----     -----  
#>
function Show-AsciiDice {
    Param
    (
        [parameter(Mandatory, ParameterSetName = 'Random')][int] $Random,
        [parameter(Mandatory, ParameterSetName = 'Numbers')][ValidateRange(1, 6)][int[]] $NumberSet,
        [parameter()][ValidateSet('Black', 'DarkBlue', 'DarkGreen', 'DarkCyan', 'DarkRed', 'DarkMagenta', 'DarkYellow', 'Gray', 'DarkGray', 'Blue', 'Green', 'Cyan', 'Red', 'Magenta', 'Yellow', 'White')][String] $DieColor = 'White'
    )

    #   If Random then add a number to Number Set $Random times
    if ($PsCmdlet.ParameterSetName -eq 'Random') { $NumberSet = (1..$random | ForEach-Object { Get-Random -Minimum 1 -Maximum 7 }) }

    #   Setup each slice of the dice to be displayed
    $OutputTop =            foreach ($Number in $Numberset) {Write-Output "$($Global:DiceSlices.Top)$($Global:DiceSpacer)"}
    $OutputTopMiddle =      foreach ($Number in $Numberset) {Write-Output "$($Global:Dice.$($Number).Top)$($Global:DiceSpacer)"}
    $OutputMiddle =         foreach ($Number in $Numberset) {Write-Output "$($Global:Dice.$($Number).Middle)$($Global:DiceSpacer)"}
    $OutputBottomMiddle =   foreach ($Number in $Numberset) {Write-Output "$($Global:Dice.$($Number).Bottom)$($Global:DiceSpacer)"}
    $OutputBottom =         foreach ($Number in $Numberset) {Write-Output "$($Global:DiceSlices.Bottom)$($Global:DiceSpacer)"}

    #   Display each slice of the dice
    Write-Host -ForegroundColor $DieColor $OutputTop
    Write-Host -ForegroundColor $DieColor $OutputTopMiddle
    Write-Host -ForegroundColor $DieColor $OutputMiddle
    Write-Host -ForegroundColor $DieColor $OutputBottomMiddle
    Write-Host -ForegroundColor $DieColor $OutputBottom
}

#   Menu Function
Function Read-Choice {
    param(
        [parameter(Mandatory)] $Options,
        [parameter()][string] $Property,
        [parameter()][string] $Prompt = 'Select you score'
    )
    Begin {
        $ObjectArray = @()
        $ChoiceArray = @()
    }
    Process {
        #Gather up options
        if ($Property -and $Property -notin ($Options[0] | Get-Member | Select-Object -ExpandProperty name)) {
            Throw "Property `"$Property`" is not an attribute of choice $($Options[0])"
        }
        $Options | ForEach-Object {
            $ObjectArray += $_
            if ($Property) {
                $ChoiceArray += $_.$Property
            }
            else {
                $ChoiceArray += $_
            }
        }
    }
    End {
        #for ($i = 0; $i -lt $ChoiceArray.Count; $i++) {
            #Show options
            #Write-Host "  " -NoNewline
            #Write-Host ($i + 1) -NoNewline -ForegroundColor Green -BackgroundColor Black
            #Write-Host ". $($ChoiceArray[$i])" 
        #}
        Do {
            $Answer = Read-Host -Prompt $Prompt
            if ($Answer -in 1..($ChoiceArray.count)) {
                $Chosen = $ObjectArray[$Answer - 1]
            }
            if (!$Chosen) { 
                Write-Host "Invalid choice '$Answer'.  Please try again or press Ctrl+C to quit." -ForegroundColor Yellow
            }
            else {
                $Chosen
            }
        } While (!$Chosen)
    } 
}

<#
    .SYNOPSIS
    Displays the ScoreCard

    .DESCRIPTION
    Displays the current ScoreCard.
    This is a wrapper for the outline of the ScoreCard.
    It calls Show-ScoreCardSection for the 'Upper' and 'Lower'
    sections.

    .INPUTS
    Not Implemented

    .OUTPUTS
    Not Implemented

    .EXAMPLE
    PS> Show-ScoreCard
    ~~~~Score Card~~~~
    Ones    : 0
    Twos    : 0
    Threes  : 0
    Fours   : 0
    Fives   : 0
    Sixes   : 0
    ~~~~~~~~~~~~~~~~~~
    ThreeofaKind    : 0
    FourofaKind     : 0
    FullHouse       : 0
    SmStraight      : 0
    LgStraight      : 0
    _Yahtzee_       : 0
    _Chance_        : 0
    ~~~~~~~~~~~~~~~~~~
#>
Function Show-ScoreCard{
    Clear-Host

    #Write scoreboard to console
    Write-Host -ForegroundColor Blue "$Global:Title"
    Write-Host '~~~~Score Card~~~~'
    Show-ScoreCardSection -Type 'Upper'
    Write-Host $Global:SpacerScoreCard
    Show-ScoreCardSection -Type 'Lower'
    Write-Host $Global:SpacerScoreCard
}

<#
    .SYNOPSIS
    Displays a section of the ScoreCard

    .DESCRIPTION
    Displays a section of the ScoreCard.
    References the Type property of the ScoreCardObject
    to determine what is displayed

    .PARAMETER Type
    What section of the ScoreCardObject to display

    .INPUTS
    Not Implemented

    .OUTPUTS
    Not Implemented

    .EXAMPLE
    PS> Show-ScoreCardSection -Type 'Upper'
    Ones    : 0
    Twos    : 0
    Threes  : 0
    Fours   : 0
    Fives   : 0
    Sixes   : 0
#>
Function Show-ScoreCardSection{
    param (
        [Parameter(Mandatory)][ValidateSet('Upper', 'Lower')][string] $Type
    )
    Foreach($Score in ($Global:ScoreboardObject.psobject.Properties | Where-Object {($_.MemberType -eq 'NoteProperty') -and ($_.Value.Type -eq $Type)})){

        $ScoreForegroundColor = if($Score.Value.Used -and $Score.Value.Value -eq 0){
                                    'Red'
                                }elseif($Score.Value.Value -eq 0){
                                    'White'
                                }else{
                                    'Green'
        }

        Write-Host -ForegroundColor $ScoreForegroundColor "$($Score.Name)`t: $($Score.Value.Value)"
    }
}

<#
    .SYNOPSIS
    Rolls dice

    .DESCRIPTION
    Rolls an amount of dice based Count parameter

    .PARAMETER Count
    Number of dice to roll

    .INPUTS
    Not Implemented

    .OUTPUTS
    Not Implemented

#>
function Invoke-DiceRoll {
    param (
        [Parameter(Mandatory)][int] $Count
    )
    $Global:Dicearray = 1..$($Count)
    foreach ($number in $Global:Dicearray) { 1..6 | Get-Random }
}

#   Kicks off 1 round of Yahtzee
function Invoke-YahtzeeTurn {

    #Set up incrementing variables
    $NumberOfRolls = 1
    $i = 0
    $RollResult = 1..5

    #Build Die Objects
    foreach ($Die in $RollResult) {
        $i++
        $Die | Add-Member -MemberType NoteProperty -Name 'DicePosition' -Value ($i) -Force
        #$Die | Add-Member -MemberType NoteProperty -name "DicePosition" -Value ([char](64 + $i)) -Force  #Select die with letter instead of number
        $Die | Add-Member -MemberType NoteProperty -Name 'Held' -Value ' ' -Force
        $Die | Add-Member -MemberType NoteProperty -Name 'Value' -Value (Invoke-DiceRoll -Count 1) -Force
    }

    Show-ScoreCard
    #Roll only 2 more times after initial
    $RollResult = While ($NumberOfRolls -le 2) {
    
        #Clear held property
        foreach ($Die in $RollResult) {
            $Die.Held = ' '
        }

        #Draw die and selection
        Show-AsciiDice -Numbers ($RollResult.Value) -DieColor Yellow
        Write-Host '   1        2        3        4        5'
 
        #Prompt for die selection
        $HoldAnswer = Read-Host 'Enter die to hold or leave blank (ex. 123)'   
        $HoldAnswer = $HoldAnswer.ToCharArray()

        #Modify die object with held property
        foreach ($Die in $RollResult) {
            foreach ($Answer in $HoldAnswer) {
                if ($($Die.DicePosition) -match $Answer) {
                    $Die.Held = 'Hold'
                }  
            }
      
            #Reroll non-held die
            if ($($Die.Held) -notlike 'Hold') {
                $Die.Value = Invoke-DiceRoll -Count 1
                $Die.Held = ' '
                $Die.Value
            }
        }
    
        #Indicate held die and pause
        $HeldDieInt = $RollResult | Where-Object Held -Like 'Hold' | Select-Object value
        $HeldDieInt = $HeldDieInt.value
   
        #Check if all 5 die held and end turn
        if ($($HoldAnswer.count) -eq 5) {
            $NumberOfRolls = 2
        }
    
        #Increment number of rolls and output final roll result after 3 rolls
        $NumberOfRolls++
        if ($NumberOfRolls -ge 3) {
            $RollResult
        }
    }

    #Convert roll result to array of values
    $RollResult = $RollResult.value

    #Create Scoring Table Object, a temporary scoreboard for choosing which score to take
    $SelectScoringTableObject = New-Object -TypeName PSObject
  
    #Make all score values 0
    foreach ($ScoreName in $Global:ScoreNameArray) {
        $SelectScoringTableObject | Add-Member -MemberType NoteProperty -Name $ScoreName -Value 0
    }

    #Top section score calculating
    $SelectScoringTableObject.Ones      = ($RollResult -match '1' | Measure-Object -Sum).sum
    $SelectScoringTableObject.Twos      = ($RollResult -match '2' | Measure-Object -Sum).sum
    $SelectScoringTableObject.Threes    = ($RollResult -match '3' | Measure-Object -Sum).sum
    $SelectScoringTableObject.Fours     = ($RollResult -match '4' | Measure-Object -Sum).sum
    $SelectScoringTableObject.Fives     = ($RollResult -match '5' | Measure-Object -Sum).sum
    $SelectScoringTableObject.Sixes     = ($RollResult -match '6' | Measure-Object -Sum).sum

    #Bottom section score calculating
    $SelectScoringTableObject.ThreeofaKind  = if ((($RollResult | Group-Object) | Select-Object -expand count) -ge 3) {
                                                  $RollResult | Measure-Object -Sum | Select-Object -ExpandProperty sum
                                              }else{
                                                  0
                                              }
    $SelectScoringTableObject.FourofaKind   = if (((($RollResult | Group-Object) | Select-Object -expand count) -ge 4)) {
                                                  $RollResult | Measure-Object -Sum | Select-Object -ExpandProperty sum
                                              }else{
                                                  0
                                              }
    $SelectScoringTableObject.FullHouse     = if (((($RollResult | Group-Object) | Select-Object count) -match '3') -and ((($RollResult | Group-Object) | Select-Object count) -match '2')) {
                                                  25
                                              }else{
                                                  0
                                              }
    $SelectScoringTableObject.SmStraight    = if ((( -join ($RollResult | Sort-Object -u) -match '1234|2345|3456|12345|23456')) -eq $true ) {
                                                  30
                                              }else{
                                                  0
                                              }
    $SelectScoringTableObject.LgStraight    = if ((( -join ($RollResult | Sort-Object -u) -match '12345|23456')) -eq $true ) {
                                                  40
                                              }else{
                                                  0
                                              }
    $SelectScoringTableObject._Yahtzee_   = if ((($RollResult | Group-Object) | Select-Object count) -match '5') {
                                                  50
                                              }else{
                                                  0
                                              }
    $SelectScoringTableObject._Chance_    = $RollResult | Measure-Object -Sum | Select-Object -ExpandProperty sum

    #Build Score Selection Menu
    $ScoreMenuTemp = $SelectScoringTableObject.psobject.Properties | Select-Object Name, Value

    $ScoreMenu = foreach ($item in $ScoreMenuTemp) {
        if (!$Global:ScoreboardObject.$($item.name).Used) {
            $item
        }
    }

    #Present Score Selection Menu
    Show-AsciiDice -Numbers ($RollResult) -DieColor Yellow
    Write-Host -ForegroundColor Cyan 'Choose a score:'
    $Index = 0
    foreach ($item in $ScoreMenu) {
        $Index++
        Write-Host "$Index.) $($item.name)`t$($item.value)"
    }

    #Read menu selection, output selected score object.
    $ScoreChoice = Read-Choice -Options $ScoreMenu.name 
    $SelectedScore = ($ScoreMenu | Where-Object name -Like $ScoreChoice)
    return $SelectedScore
}

<#
    .SYNOPSIS
    Displays the end screen
    .DESCRIPTION
    Displays the end screen with tally of all scores

    .INPUTS
    Not Implemented

    .OUTPUTS
    Not Implemented

    .EXAMPLE
    PS> Show-EndScreen
    ~~~~Score Card~~~~
    Ones    : 0
    Twos    : 2
    Threes  : 9
    Fours   : 4
    Fives   : 5
    Sixes   : 6
    ~~~~~~~~~~~~~~~~~~
    ThreeofaKind    : 20
    FourofaKind     : 0
    FullHouse       : 0
    SmStraight      : 0
    LgStraight      : 0
    _Yahtzee_       : 0
    _Chance_        : 20
    ~~~~~~~~~~~~~~~~~~
    Top Total    : 26
    Top Bonus    : 0
    Bottom Total : 40
    ~~~~~~~~~~~~~~~~~~
    Total Score  : 66
    ~~~~~~~~~~~~~~~~~~
    Highest Score: 313
    Average Score: 53.4444444444444
    Lowest Score: 0
    Games Played: 9
#>
Function Show-EndScreen{
    Show-ScoreCard

    #Sum up scores
    foreach($Score in ($Global:ScoreboardObject.psobject.Properties | Where-Object {($_.MemberType -eq 'NoteProperty')})){
        switch($Score.Value.Type){
            Upper {$TopTotalSum += $Score.Value.Value}
            Lower {$BottomTotalSum += $Score.Value.Value}
        }
    }

    #Check for bonus score
    $TopBonus = if ($TopTotalSum -ge 63) { 35 }else{ 0 }

    #Sum up final score
    $FinalTotal = $TopTotalSum + $TopBonus + $BottomTotalSum

    #Write Final Results to Console
    Write-Host "Top Total    : $TopTotalSum"
    Write-Host "Top Bonus    : $TopBonus"
    Write-Host "Bottom Total : $BottomTotalSum"
    Write-Host $Global:SpacerScoreCard
    Write-Host "Total Score  : $FinalTotal"

    #Check for highscorebool. If so, write to console.
    if ($Global:ScoreBool -eq $true) {
        Add-Content -Path $Global:ScoresPath "$FinalTotal"
        $ScoreContent = Get-Content $Global:ScoresPath
        $GamesPlayed = $ScoreContent.count
        $AverageScore = ($ScoreContent | Measure-Object -Average).Average
        $HighScore = ($ScoreContent | Measure-Object -Maximum).Maximum
        $LowestScore = ($ScoreContent | Measure-Object -Minimum).Minimum
        Write-Host $Global:SpacerScoreCard
        Write-Host "Highest Score: $HighScore"
        Write-Host "Average Score: $AverageScore"
        Write-Host " Lowest Score: $LowestScore"
        Write-Host " Games Played: $GamesPlayed "

        if ($FinalTotal -gt $HighScore) {
            Write-Host $Global:SpacerScoreCard
            Write-Host "$FinalTotal is a new high score! Great job!"
        } 
    }
    Write-Host ' '
    Pause
}

<#
    .SYNOPSIS
    Setup method for creating all Global variables
    .DESCRIPTION
    Setup method for creating all Global variables

    .INPUTS
    Not Implemented

    .OUTPUTS
    Not Implemented
#>
Function New-Globals{
    $Global:Title = '
    \ /                  
     Y  _ |_ _|_ _  _  _ 
     | (_|| | |_ /_(/_(/_'
    
    #Keep track of scores boolean. Will write a score file to appata if $true. 
    $Global:ScoreBool = $true
    
    #   Setup Dice Object
    $Global:DiceSlices = [PSCustomObject]@{
        Top        = ' _____ '
        None       = '|     |'
        LeftPip    = '| o   |'
        MiddlePip  = '|  o  |'
        RightPip   = '|   o |'
        TwoPips    = '|o   o|'
        Bottom     = ' ----- '
    }
    
    $Global:Dice = [PSCustomObject]@{
        1 = @{
            Top     = $Global:DiceSlices.None
            Middle  = $Global:DiceSlices.MiddlePip
            Bottom  = $Global:DiceSlices.None
        }
        2 = @{
            Top     = $Global:DiceSlices.RightPip
            Middle  = $Global:DiceSlices.None
            Bottom  = $Global:DiceSlices.LeftPip
        }
        3 = @{
            Top     = $Global:DiceSlices.LeftPip
            Middle  = $Global:DiceSlices.MiddlePip
            Bottom  = $Global:DiceSlices.RightPip
        }
        4 = @{
            Top     = $Global:DiceSlices.TwoPips
            Middle  = $Global:DiceSlices.None
            Bottom  = $Global:DiceSlices.TwoPips
        }
        5 = @{
            Top     = $Global:DiceSlices.TwoPips
            Middle  = $Global:DiceSlices.MiddlePip
            Bottom  = $Global:DiceSlices.TwoPips
        }
        6 = @{
            Top     = $Global:DiceSlices.TwoPips
            Middle  = $Global:DiceSlices.TwoPips
            Bottom  = $Global:DiceSlices.TwoPips
        }
    }
    
    #   Space between Dice
    $Global:DiceSpacer = '  '
    
    #   Space for ScoreCard
    $Global:SpacerScoreCard = '~~~~~~~~~~~~~~~~~~'

    #   Create Array of Score Names
    $Global:ScoreNameArray = @('Ones', 'Twos', 'Threes', 'Fours', 'Fives', 'Sixes', 'ThreeofaKind', 'FourofaKind', 'FullHouse', 'SmStraight', 'LgStraight', '_Yahtzee_', '_Chance_')

    #Create Scoreboard Object
    $Global:ScoreboardObject = [PSCustomObject]@{
        Ones = [PSCustomObject]@{
            Value = 0
            Type = 'Upper'
            Used = $false
        }
        Twos = [PSCustomObject]@{
            Value = 0
            Type = 'Upper'
            Used = $false
        }
        Threes = [PSCustomObject]@{
            Value = 0
            Type = 'Upper'
            Used = $false
        }
        Fours =[PSCustomObject] @{
            Value = 0
            Type = 'Upper'
            Used = $false
        }
        Fives = [PSCustomObject]@{
            Value = 0
            Type = 'Upper'
            Used = $false
        }
        Sixes = [PSCustomObject]@{
            Value = 0
            Type = 'Upper'
            Used = $false
        }
        ThreeofaKind = [PSCustomObject]@{
            Value = 0
            Type = 'Lower'
            Used = $false
        }
        FourofaKind = [PSCustomObject]@{
            Value = 0
            Type = 'Lower'
            Used = $false
        }
        FullHouse = [PSCustomObject]@{
            Value = 0
            Type = 'Lower'
            Used = $false
        }
        SmStraight = [PSCustomObject]@{
            Value = 0
            Type = 'Lower'
            Used = $false
        }
        LgStraight = [PSCustomObject]@{
            Value = 0
            Type = 'Lower'
            Used = $false
        }
        _Yahtzee_ = [PSCustomObject]@{
            Value = 0
            Type = 'Lower'
            Used = $false
        }
        _Chance_ = [PSCustomObject]@{
            Value = 0
            Type = 'Lower'
            Used = $false
        }
    }

    #Set TurnNumber Variable to be incremented
    $Global:TurnNumber = 1

    $Global:ScoresPath = "$env:APPDATA\PowershellYahtzeeHighScore.txt"
}

<#
    .SYNOPSIS
    Setup method for creating a score file
    .DESCRIPTION
    Setup method for creating a score file to track
    games and outcomes

    .INPUTS
    Not Implemented

    .OUTPUTS
    Not Implemented
#>
Function New-ScoreFile{
    if (($Global:ScoreBool -eq $true) -and (!$(Test-Path $Global:ScoresPath))) {
        Set-Content -Path $Global:ScoresPath -Value '' -Force
    }
}

#   Main Game Entry point
New-Globals
New-ScoreFile

#Invoke Yahtzee round for each scorable item. Increment turn number
While($Global:TurnNumber -lt 14) {
    $TurnResult = Invoke-YahtzeeTurn
    $Global:ScoreboardObject.$($TurnResult.Name).Value = $TurnResult.Value
    $Global:ScoreboardObject.$($TurnResult.Name).Used = $true
    $Global:TurnNumber++
}

Show-EndScreen