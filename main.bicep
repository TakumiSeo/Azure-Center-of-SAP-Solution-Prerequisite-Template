@description('the location of the deployment')
param location string = resourceGroup().location

@description('the addressprefix of the virtual network')
param vnetAddressPrefix string = '10.0.0.0/16'

@description('the subnet prefix of the virtual network')
param subnetAddressPrefix string = '10.0.0.0/24'

@description('the subnet prefix of the SAP Bits')
param subnetSAPBitsAddressPrefix string = '10.0.1.0/27'

@description('SAP Bits downloader VM admin user name')
param sapbitVmAdminUserName string = 'sapbitadmin'

@description('SSH Key or password for the Virtual Machine. SSH key is recommended.')
@secure()
param adminPasswordOrKey string

@description('SAP Bits downloader VM admin password')
@secure()
param sapbitVmAdminPassword string



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
    subnetSAPBitsAddressPrefix: subnetSAPBitsAddressPrefix
  }
}

module virtualMachine 'modules/compute/vmAcssSetup.bicep' = {
  name: 'virtualMachine'
  params: {
    location: location
    adminPasswordOrKey: adminPasswordOrKey
    subnetSAPBitsId: virtualNetwork.outputs.sapBitsSubnetId
    sapbitVmAdminUserName: sapbitVmAdminUserName
    sapbitVmAdminPassword: sapbitVmAdminPassword
  }
  dependsOn: [
    virtualNetwork
  ]
}
