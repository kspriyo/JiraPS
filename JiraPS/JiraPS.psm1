﻿# Import custom Classes/Objects
# if (!("" -as [Type])) {
#     Add-Type -Path (Join-Path $PSScriptRoot JiraPS.Types.cs) -ReferencedAssemblies Microsoft.CSharp
# }

# Gather all files
$PublicFunctions = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )
$PrivateFunctions = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )

# Import Types
try
{
    Add-Type -Path (Join-Path $PSScriptRoot JiraPS.Types.cs) -ReferencedAssemblies Microsoft.CSharp
}
catch
{
    if (!(("JiraPS.AssigneeType" -as [Type])))
    {
        $errorMessage = @{
            Category         = "OperationStopped"
            CategoryActivity = "Loading custom classes"
            ErrorId          = 1001
            Message          = "Failed to load module JiraPS. [Could not import JiraPS classes]"
        }
        Write-Error @errorMessage
    }
}

# Dot source the functions
foreach ($File in @($PublicFunctions + $PrivateFunctions))
{
    Try
    {
        . $File.FullName
    }
    Catch
    {
        $errorItem = [System.Management.Automation.ErrorRecord]::new(
            ([System.ArgumentException]"Function not found"),
            'Load.Function',
            [System.Management.Automation.ErrorCategory]::ObjectNotFound,
            $File
        )
        $errorItem.ErrorDetails = "Failed to import function $($File.BaseName)"
        $PSCmdlet.ThrowTerminatingError($errorItem)
    }
}
