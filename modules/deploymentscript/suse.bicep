@description('thr storage account name that is consumed by the deployment script')
var storageAccountName = 'storage${uniqueString(resourceGroup().id)}'

@description('The name of the blob container that is created in the storage account')
var storageBlobContainerName = 'ipcontainer'

@description('The name of the deployment script')
var deploymentScriptName = 'configScript'

@description('The location of the resources passed by main.bicep')
param location string


@description('The role definition id for contributor role')
param blobContributorRoleDefinitionId string = resourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')


@description('The name of the user assigned identity that is created for the deployment script')
var userAssignedIdentityName = 'configDeployer'

@description('The name of the role assignment')
var roleAssignmentName = guid(resourceGroup().id, 'contributorForDS')


resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: userAssignedIdentityName
  location: location
}

resource roleAssignment1 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: roleAssignmentName
  properties: {
    principalId: userAssignedIdentity.properties.principalId
    roleDefinitionId: blobContributorRoleDefinitionId
    principalType: 'ServicePrincipal'
  }
}
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  tags: {
    displayName: storageAccountName
  }
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    encryption: {
      services: {
        blob: {
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    allowBlobPublicAccess: true
    supportsHttpsTrafficOnly: true
  }

  resource blobService 'blobServices' existing = {
    name: 'default'
  }
}

resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  parent: storageAccount::blobService
  name: storageBlobContainerName
  properties: {
    publicAccess: 'Blob'
  }
}


resource deploymentScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: deploymentScriptName
  location: location
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentity.id}': {}
    }
  }
  properties: {
    azCliVersion: '2.55.0'
    timeout: 'PT5M'
    retentionInterval: 'P1D'
    scriptContent: loadTextContent('../../scripts/suseenpoint.sh')
  }
  dependsOn: [
    blobContainer
    roleAssignment1
  ]
}
output suseIp array = deploymentScript.properties.outputs.servers
