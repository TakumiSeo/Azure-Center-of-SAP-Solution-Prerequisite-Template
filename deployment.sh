az group create --location japaneast --name "rg-acssVM"
az deployment group create --resource-group "rg-acssVM" --name "acss001" --template-file main.bicep