@description('The location of the resources.')
param location string

@description('SUSE IP list')
param suseIpList array

@description('The vnet address range')
param vnetAddressPrefix string

@description('The default subnet address range')
param subnetAddressPrefix string 

@description('The sap bits server subnet address range')
param subnetSAPBitsAddressPrefix string

var virtualNetworkName = 'ACSS-vnet'
var networkSecurityGroupName = 'acss-nsg'
var vnetDefaultSubnetName = 'server'

var networkSecurityGroupNameSAPBits = 'acss-nsg-sapbits'
var vnetSAPBitsSubnetName = 'sapbits'

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: networkSecurityGroupName
  location: location
  properties: {
    securityRules: [
      {
        name: 'Allow-SUSE'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefixes: suseIpList
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 200
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource networkSecurityGroupSAPBits 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: networkSecurityGroupNameSAPBits
  location: location
  properties: {
    securityRules: [
      {
        name: 'Allow-ALL'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 200
          direction: 'Inbound'
        }
      }
    ]
  }
}


resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
      }
    subnets: [
      {
        name: vnetDefaultSubnetName
        properties: {
          addressPrefix: subnetAddressPrefix
          networkSecurityGroup: {
            id: networkSecurityGroup.id
          }
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: vnetSAPBitsSubnetName
        properties: {
          addressPrefix: subnetSAPBitsAddressPrefix
          networkSecurityGroup: {
            id: networkSecurityGroupSAPBits.id
          }
        privateEndpointNetworkPolicies: 'Disabled'
        privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
    enableDdosProtection: false
  }
  resource defaultSubnet 'subnets' existing = {
    name: vnetDefaultSubnetName
  }
  resource sapBitsSubnet 'subnets' existing = {
    name: vnetSAPBitsSubnetName
  }
}

output virtualNetworkId string = virtualNetwork.id
output defaultSubnetId string = virtualNetwork::defaultSubnet.id
output sapBitsSubnetId string = virtualNetwork::sapBitsSubnet.id
