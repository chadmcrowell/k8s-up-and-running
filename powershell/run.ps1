# variables
$rg = "pwshk8s-rg"
$loc = "eastus"
$templateFile = "template.json"
$parameterFile = "parameters.json"

# create new resource group
New-AzResourceGroup -Name $rg -Location $loc

# create a new aks cluster
New-AzResourceGroupDeployment `
    -Name "pwshk8sdeploy" `
    -ResourceGroupName $rg `
    -TemplateFile $templateFile `
    -TemplateParameterFile $parameterFile `
    -Mode Incremental