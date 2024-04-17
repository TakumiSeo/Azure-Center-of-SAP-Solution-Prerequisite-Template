@description('the location of the deployment')
param location string = resourceGroup().location

@description('the addressprefix of the virtual network')
param vnetAddressPrefix string = '10.0.0.0/16'

@description('the subnet prefix of the virtual network')
param subnetAddressPrefix string = '10.0.0.0/23'


module suseIpList 'modules/deploymentscript/suse.bicep' = {
  name: 'suseIpList'
  params: {
    location: location
  }
}

// output suseIpList string = suseIpList.outputs.suseIp
module virtualNetwork 'modules/network/virtualnetwork.bicep' = {
  name: 'virtualNetwork'
  params: {
    location: location
    suseIpList: suseIpList.outputs.suseIp
    vnetAddressPrefix: vnetAddressPrefix
    subnetAddressPrefix: subnetAddressPrefix
  }
}

