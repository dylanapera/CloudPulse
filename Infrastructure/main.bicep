@description('The name of the SQL Server')
param sqlServerName string = 'sql-${uniqueString(resourceGroup().id)}'

@description('The name of the SQL Database')
param sqlDatabaseName string = 'sqldb-dev'

@description('The location for all resources')
param location string = resourceGroup().location

@description('The administrator username for SQL Server')
param administratorLogin string = 'sqladmin'

@secure()
@description('The administrator password for SQL Server')
param administratorLoginPassword string

@description('Tags to apply to resources')
param tags object = {
  Environment: 'Development'
  CostCenter: 'Dev'
}

// Azure SQL Server
resource sqlServer 'Microsoft.Sql/servers@2024-05-01-preview' = {
  name: sqlServerName
  location: location
  tags: tags
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    version: '12.0'
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
  }
}

// SQL Database with Developer Edition (cost-effective)
resource sqlDatabase 'Microsoft.Sql/servers/databases@2024-05-01-preview' = {
  parent: sqlServer
  name: sqlDatabaseName
  location: location
  tags: tags
  sku: {
    name: 'Basic'
    tier: 'Basic'
    capacity: 5
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 2147483648 // 2 GB
    catalogCollation: 'SQL_Latin1_General_CP1_CI_AS'
    zoneRedundant: false
    readScale: 'Disabled'
    requestedBackupStorageRedundancy: 'Local'
    isLedgerOn: false
  }
}

// Firewall rule to allow Azure services
resource sqlFirewallRuleAzure 'Microsoft.Sql/servers/firewallRules@2023-08-01' = {
  parent: sqlServer
  name: 'AllowAzureServices'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

@description('The fully qualified domain name of the SQL Server')
output sqlServerFqdn string = sqlServer.properties.fullyQualifiedDomainName

@description('The name of the SQL Server')
output sqlServerName string = sqlServer.name

@description('The name of the SQL Database')
output sqlDatabaseName string = sqlDatabase.name

@description('Connection string (without password)')
output connectionStringTemplate string = 'Server=tcp:${sqlServer.properties.fullyQualifiedDomainName},1433;Initial Catalog=${sqlDatabaseName};Persist Security Info=False;User ID=${administratorLogin};Password={your_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'
