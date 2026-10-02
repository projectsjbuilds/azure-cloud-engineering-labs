# Lab 01: Azure Environment Setup

## Project Overview

This lab establishes the foundation for my Azure cloud engineering environment.

The goal is to practice Azure resource organization, governance, cost management, and PowerShell administration while documenting the project as part of my Cloud Engineer portfolio.

## Technologies Used

- Microsoft Azure
- Azure Resource Groups
- Azure Cost Management
- Azure Cloud Shell
- Azure PowerShell
- GitHub

## Objectives

- [ ] Verify Azure subscription access
- [ ] Create a resource group
- [ ] Configure resource tags
- [ ] Configure an Azure budget
- [ ] Verify Azure resources using PowerShell
- [ ] Document the environment in GitHub

## Planned Resources

| Resource | Name |
|---|---|
| Resource Group | RG-CLOUD-LAB |
| Region | Central US |
| Environment | Lab |
| Project | CloudEngineering |

## Implementation

### Step 1 - Azure Subscription

Azure subscription access will be verified before creating resources.

### Step 2 - Resource Group

Planned resource group:

`RG-CLOUD-LAB`

### Step 3 - Resource Tags

Planned tags:

- Environment: Lab
- Project: CloudEngineering
- Owner: PersonalLab

### Step 4 - Cost Management

A monthly Azure budget will be configured to monitor lab spending.

### Step 5 - PowerShell Verification

Azure Cloud Shell and PowerShell will be used to verify the deployed resources.

Example commands:

```powershell
Get-AzContext
Get-AzResourceGroup
Get-AzResourceGroup -Name "RG-CLOUD-LAB"
