# CloudPulse Setup Guide

This guide walks you through deploying and configuring the CloudPulse infrastructure and Power BI dashboard.

---

## Prerequisites

- Azure subscription with Owner or Contributor access
- Azure CLI installed ([Download](https://docs.microsoft.com/cli/azure/install-azure-cli))
- PowerShell 7+ or Windows PowerShell 5.1
- SQL Server Management Studio (SSMS) or Azure Data Studio
- Power BI Desktop ([Download](https://powerbi.microsoft.com/desktop/))

---

## Step 1: Deploy Azure Infrastructure

### 1.1 Login to Azure

```powershell
az login
```

### 1.2 Run the Deployment Script

```powershell
.\deploy.ps1
```

You can optionally specify custom parameters:

```powershell
.\deploy.ps1 -ResourceGroupName "rg-cloudpulse-prod" -Location "eastus"
```

When prompted, enter a strong password for the SQL Server administrator account.

### 1.3 Verify Deployment

The deployment creates:
- Azure SQL Server
- Azure SQL Database (Basic tier)
- Firewall rule for Azure services

Note the SQL Server name and database name from the deployment output.

---

## Step 2: Configure Microsoft Entra ID Authentication

### 2.1 Set Up Entra ID Admin for SQL Server

```powershell
# Set variables
$resourceGroupName = "rg-cloudpulse-dev"
$sqlServerName = "<your-sql-server-name>"
$currentUser = az ad signed-in-user show --query id -o tsv
$currentUserEmail = az ad signed-in-user show --query userPrincipalName -o tsv

# Set current user as Entra ID admin
az sql server ad-admin create `
    --resource-group $resourceGroupName `
    --server-name $sqlServerName `
    --display-name $currentUserEmail `
    --object-id $currentUser
```

### 2.2 Add Your IP to SQL Server Firewall

```powershell
# Get your public IP
$myIp = (Invoke-WebRequest -Uri "https://api.ipify.org").Content

# Add firewall rule
az sql server firewall-rule create `
    --resource-group $resourceGroupName `
    --server $sqlServerName `
    --name "MyWorkstation" `
    --start-ip-address $myIp `
    --end-ip-address $myIp
```

### 2.3 Enable Entra ID-Only Authentication (Optional)

For enhanced security, you can disable SQL authentication:

```powershell
az sql server ad-only-auth enable `
    --resource-group $resourceGroupName `
    --name $sqlServerName
```

---

## Step 3: Populate the Database

### 3.1 Connect to SQL Database

Using **Azure Data Studio** or **SSMS**:

1. Open Azure Data Studio
2. Create new connection:
   - **Connection type**: Microsoft SQL Server
   - **Authentication type**: Azure Active Directory - Universal with MFA
   - **Server**: `<your-sql-server-name>.database.windows.net`
   - **Database**: `sqldb-dev`
3. Click **Connect**

### 3.2 Run the Population Script

1. Open the SQL script file: `SQL/populate.sql`
2. Execute the script to create tables and insert data
3. Verify the data was created:

```sql
SELECT * FROM YourTableName;
```

---

## Step 4: Create Power BI Dashboard

### 4.1 Connect Power BI to Azure SQL Database

1. Open **Power BI Desktop**
2. Click **Get Data** → **Azure** → **Azure SQL Database**
3. Enter connection details:
   - **Server**: `<your-sql-server-name>.database.windows.net`
   - **Database**: `sqldb-dev`
4. Select **Microsoft Account** for authentication
5. Sign in with your Azure credentials
6. Click **Connect**

### 4.2 Load Data into Power BI

1. In the **Navigator** window, select the tables you created
2. Click **Load** to import the data
3. Wait for data to load into Power BI

### 4.3 Create a Simple Table Visualization

1. In the **Visualizations** pane, click the **Table** icon
2. From the **Fields** pane, drag the columns you want to display
3. Resize and format the table as needed
4. Add a title by selecting the table and using **Format** options

### 4.4 Create a Map Visualization

1. Click on a blank area of the canvas
2. In the **Visualizations** pane, click the **Map** icon (or **Filled Map**)
3. Configure the map:
   - Drag **Location** field to the map's location well (e.g., city, state, country)
   - Drag a numeric field to the **Size** or **Color saturation** well
4. Power BI will automatically geocode your locations
5. Format the map:
   - Adjust colors, zoom level, and map style
   - Add data labels if needed

### 4.5 Add Additional Visuals (Optional)

- Charts (bar, line, pie)
- KPI cards
- Slicers for filtering

### 4.6 Publish to Power BI Service

1. Click **File** → **Publish** → **Publish to Power BI**
2. Sign in if prompted
3. Select a workspace (or create a new one)
4. Click **Select**
5. Wait for publishing to complete
6. Click **Open '<your-report-name>' in Power BI** to view online

---

## Step 5: Verify and Share

### 5.1 Access Your Dashboard

1. Navigate to [Power BI Service](https://app.powerbi.com)
2. Find your report in the selected workspace
3. Test all visualizations and interactions

### 5.2 Share with Others (Optional)

1. Click **Share** in the top menu
2. Enter email addresses of users
3. Configure permissions
4. Click **Share**

---

## Troubleshooting

### Cannot Connect to SQL Database

- Verify your IP is in the firewall rules
- Check that Entra ID admin is configured
- Ensure you're using the correct authentication method

### Power BI Cannot Find Location Data

- Ensure location columns contain standard location names
- Use dedicated geocoding columns (City, State, Country)
- Check for spelling errors or invalid location names

### Deployment Fails

- Verify you have sufficient permissions in the Azure subscription
- Check that the SQL Server name is unique globally
- Ensure password meets complexity requirements (8+ characters)

---

## Cleanup

To delete all resources and avoid charges:

```powershell
az group delete --name rg-cloudpulse-dev --yes --no-wait
```

---

## Next Steps

- Configure automated data refresh in Power BI Service
- Add more complex visualizations and DAX measures
- Set up row-level security for multi-tenant scenarios
- Enable monitoring and alerts in Azure SQL Database

---

## Support

For issues or questions, please open an issue in the GitHub repository.
