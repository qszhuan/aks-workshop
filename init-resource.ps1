$regionName = "australiaeast"
$resourceGroup = "aksworkshop"
$subnetName= "ask-subnet"
$vnetName = "aks-vnet"

# new resource group
az group create --name $resourceGroup --location $regionName
# vnet
$vnet = az network vnet create --resource-group $resourceGroup --location $regionName --name $vnetName --address-prefixes 10.0.0.0/8 --subnet-name $subnetName --subnet-prefixes 10.240.0.0/16

$subnetId = $(az network vnet subnet show --resource-group $resourceGroup --vnet-name $vnetName --name $subnetName --query id -o tsv)

$version=$(az aks get-versions --location $regionName --query 'orchestrators[?!isPreview] | [-1].orchestratorVersion' --output tsv)

# create cluster
$aksClusterName = "aksworkshop-$(RANDOM)"
az aks create --resource-group $resourceGroup --name $aksClusterName --vm-set-type VirtualMachineScaleSets --node-count 2 --load-balancer-sku standard --location $regionName --kubernetes-version $version --network-plugin azure --vnet-subnet-id $subnetId --service-cidr 10.2.0.0/24 --dns-service-ip 10.2.0.10 --docker-bridge-address 172.17.0.1/16 --generate-ssh-keys

#connect cluster
az aks get-credentials --resource-group $resourceGroup --name $aksClusterName

kubectl get nodes

# create namespace
kubectl create namespace ratingsapp