using './main.bicep'

param prefix = 'ecolab-aca'
param location = 'centralus'
param tags = {
  environment: '${prefix}'
}

