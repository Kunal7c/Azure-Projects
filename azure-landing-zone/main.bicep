param location string
param environment string
param project string
param owner string
param vmSize string
param loginUsername string
@secure()
param loginPass string

module hub 'modules/hub.bicep' = {
  name: 'hub'
  params: {
    location: location
    environment: environment
    project: project
    owner: owner
    vmSize: vmSize
    loginUsername: loginUsername
    loginPass: loginPass
  }
}
