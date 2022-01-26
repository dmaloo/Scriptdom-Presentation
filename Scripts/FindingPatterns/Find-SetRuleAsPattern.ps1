function Find-SetRuleAsPattern
{
    #Pass set statement option and its value and check for existence
    [CmdletBinding()]
    param(
           $ScriptData,
           [string]$Ruleoption,
           [boolean]$Ruleonoff,
           $tsqlfragmentforrule
    )

    
    Try
    {
        class VisitorSetOnOffRule: Microsoft.SqlServer.TransactSql.ScriptDom.TSQLFragmentVisitor
        {
            [boolean] $onofffound  
            #Initializing variables to param values as they can't be accessed inside visit
            $isruleonoff = $Ruleonoff
            $isruleoption = $Ruleoption  
            [void]Visit ([Microsoft.SqlServer.TransactSql.ScriptDom.SetOnOffStatement] $fragment) 
            {
            
  
                #Making sure use statement is the first
                if ($fragment.ison -eq $this.isruleonoff -and $fragment.options -eq $this.isruleoption)
                {
                    $this.onofffound = 1
                    
                }
            }
        }
        
        $visitorsetonoff = [VisitorSetOnOffRule]::new()
        $tSqlFragmentforrule.Accept($visitorsetonoff)
        $lintererror = @()
        if ($visitorsetonoff.onofffound)
        {
        }
        else
        {
            if ($Ruleonoff) 
            {
                $on = 'ON'
            }
            else
            {
                $On = 'OFF'
            }

            $ErrorLine = "WARNING: SET '$Ruleoption $On' not found "
            $lintererror = New-LinterError -checkname "Find-SetRule" -errormessage $errorline -startline 0 -startcolumn 0 -length 0
        }    
            
        RETURN $lintererror
    
} #end try
catch {
    throw
}

}