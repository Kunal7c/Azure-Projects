param location string
param environment string
param project string
param owner string
param loginUsername string
param loginPass string
param vmSize string

var tags = {
  environment: environment
  project: project
  owner: owner
}


resource hubNsg 'Microsoft.Network/networkSecurityGroups@2025-05-01' = {
  name: 'nsg-hub-jumpbox'
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'Allow-RDP-MyIP'
        properties: {
          priority: 100
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: '195.86.27.30/32'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '3389'
        }
      }
      {
        name: 'Deny-RDP-All'
        properties: {
          priority: 200
          protocol: 'Tcp'
          access: 'Deny'
          direction: 'Inbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '3389'
        }
      }
    ]
  }
}

resource hubVnet 'Microsoft.Network/virtualNetworks@2025-05-01' = {
  name: 'vnet-hub'
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'hub-subnet-jumpbox'
        properties: {
          addressPrefix: '10.0.1.0/24'
          networkSecurityGroup: {
            id:hubNsg.id
          }
        }
      }
    ]
  }
}

resource pipJumpbox 'Microsoft.Network/publicIPAddresses@2025-05-01' = {
  name: 'pip-jumpbox'
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource nicJumpbox 'Microsoft.Network/networkInterfaces@2025-05-01' = {
  name: 'nic-jumpbox'
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: pipJumpbox.id
          }
          subnet: {
            id: hubVnet.properties.subnets[0].id
          }
        }
      }
    ]
  }
}

resource vmJumpbox 'Microsoft.Compute/virtualMachines@2025-04-01' = {
  name: 'vm-jumpbox'
  location: location
  tags: tags
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-Datacenter'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
    }
    osProfile: {
      computerName: 'vm-jumpbox'
      adminUsername: loginUsername
      adminPassword: loginPass
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nicJumpbox.id
        }
      ]
    }
  }
}


