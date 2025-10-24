# Wazuh Kubernetes

[![Slack](https://img.shields.io/badge/slack-join-blue.svg)](https://wazuh.com/community/join-us-on-slack/)
[![Email](https://img.shields.io/badge/email-join-blue.svg)](https://groups.google.com/forum/#!forum/wazuh)
[![Documentation](https://img.shields.io/badge/docs-view-green.svg)](https://documentation.wazuh.com)
[![Documentation](https://img.shields.io/badge/web-view-green.svg)](https://wazuh.com)

Deploy a Wazuh cluster with a basic indexer and dashboard stack on Kubernetes.

## Branches

* `master` branch contains the latest code, be aware of possible bugs on this branch.
* `stable` branch on correspond to the last Wazuh stable version.


## Documentation

## Things you need to configure on this repo before deploying it 

#### 1) See the domain, SSL cert config [here](#configuring-a-domain-and-ssl-cert-and-for-wazuh-dashboard) (ommit step 4 for now)  

#### 2) Create the privates certs stored on ../wazuh-kubernetes/wazuh/certs/ for both dashboard_http and indexer_cluster  
go within those two folders and run `./generate_certs.sh`  

#### 3) Configure all the integrations you'll use on the master.conf and worker.conf  
`WARNING`: the two files will have the same config, but do not copy the whole document content of one within the other, they have speciall sections for each one, if you do this you'll break wazuh.
#### 4) Apply the yaml's files using the kustomization   
Check you're on the correct path:  
```bash
$ pwd 
/your-folders-path/kubernetes/wazuh-kubernetes

```
Then apply the yaml's: 
```bash
kubectl apply -k envs/eks/
```

## Ajust wazuh resources  

If you want to change the default values for the wazuh resources, you can do it from these files:  

#### 1) Wazuh indexer:  

```
wazuh-kubernetes/envs/eks/indexer-resources.yaml
wazuh-kubernetes/wazuh/indexer_stack/wazuh-indexer/cluster/indexer-sts.yaml
``` 
make sure these file have the exact same config for the requested resources.  

#### 2) Wazuh manager:  
```
master:
wazuh-kubernetes/envs/eks/wazuh-master-resources.yaml
wazuh-kubernetes/wazuh/wazuh_managers/wazuh-master-sts.yaml


worker:
wazuh-kubernetes/envs/eks/wazuh-worker-resources.yaml
wazuh-kubernetes/wazuh/wazuh_managers/wazuh-worker-sts.yaml
```  
make sure these file have the exact same config for the requested resources.    

#### 3) Wazuh dashboard: 

```
wazuh-kubernetes/envs/eks/dashboard-resources.yaml
wazuh-kubernetes/wazuh/indexer_stack/wazuh-dashboard/dashboard-deploy.yaml

```  
make sure these file have the exact same config for the requested resources.  

## Amazon EKS development

To deploy a cluster on Amazon EKS cluster read the instructions on [instructions.md](instructions.md).
Note: For Kubernetes version 1.23 or higher, the assignment of an IAM Role is necessary for the CSI driver to function correctly. Within the AWS documentation you can find the instructions for the assignment: https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html
The installation of the CSI driver is mandatory for new and old deployments if you are going to use Kubernetes 1.23 for the first time or you need to upgrade the cluster.

## Local development

To deploy a cluster on your local environment (like Minikube, Kind or Microk8s) read the instructions on [local-environment.md](local-environment.md).

## Directory structure

    ├── CHANGELOG.md
    ├── cleanup.md
    ├── envs
    │   ├── eks
    │   │   ├── dashboard-resources.yaml
    │   │   ├── indexer-resources.yaml
    │   │   ├── kustomization.yml
    │   │   ├── storage-class.yaml
    │   │   ├── wazuh-master-resources.yaml
    │   │   └── wazuh-worker-resources.yaml
    │   └── local-env
    │       ├── indexer-resources.yaml
    │       ├── kustomization.yml
    │       ├── storage-class.yaml
    │       └── wazuh-resources.yaml
    |
    ├── images
    ├── instructions.md
    ├── LICENSE
    ├── local-environment.md
    ├── README.md
    ├── upgrade.md
    ├── VERSION
    └── wazuh
        ├── base
        │   ├── storage-class.yaml
        │   └── wazuh-ns.yaml
        ├── certs
        │   ├── dashboard_http
        │   │   └── generate_certs.sh
        │   └── indexer_cluster
        │       └── generate_certs.sh
        ├── indexer_stack
        │   ├── wazuh-dashboard
        │   │   ├── dashboard_conf
        │   │   │   └── opensearch_dashboards.yml
        │   │   ├── dashboard-deploy.yaml
        |   |   ├── dashboard-ingress.yaml
        │   │   └── dashboard-svc.yaml
        │   └── wazuh-indexer
        │       ├── cluster
        │       │   ├── indexer-api-svc.yaml
        │       │   └── indexer-sts.yaml
        │       ├── indexer_conf
        │       │   ├── internal_users.yml
        |       |   ├── snapshot_storage.yaml
        │       │   └── opensearch.yml
        │       └── indexer-svc.yaml
        ├── kustomization.yml
        ├── secrets
        │   ├── dashboard-cred-secret.yaml
        │   ├── indexer-cred-secret.yaml
        │   ├── wazuh-api-cred-secret.yaml
        │   ├── wazuh-authd-pass-secret.yaml
        │   └── wazuh-cluster-key-secret.yaml
        ├── wazuh_managers
        |    ├── wazuh-cluster-svc.yaml
        |    ├── wazuh_conf
        |    │   ├── entrypoint-integrations-cm.yaml
        |    |   ├── entrypoint-syslog-cm.yaml
        |    |   ├── filebeat.yml
        |    |   ├── local_rules_configmap.yaml
        |    |   ├── master.conf
        |    |   ├── misp-rules-configmap.yaml
        |    |   ├── sentinelone-rules-configmap.yaml
        |    |   ├── sentinelone-rules-configmap.yaml
        |    |   ├── syslog-ng-cm.yaml
        |    |   ├── wazuh-template-json-configmap.yaml
        |    │   └── worker.conf
        |    └── wazuh-integrations
        |        ├── wazuh-master-sts.yaml
        |        ├── wazuh-master-svc.yaml
        |        ├── wazuh-workers-svc.yaml
        |        └── wazuh-worker-sts.yaml
        └───kustomization.yml   

  
## How to safely update wazuh
  
Before updating Wazuh, make sure to create a snapshot of your indexes. You can follow the steps in the [Wazuh Indexer S3 Snapshots Configuration](#wazuh-indexer-s3-snapshots-configuration) section.

Once your snapshot is created, you should provision new PVCs without deleting the existing ones. This approach is recommended because updating Wazuh may also upgrade OpenSearch. If the new Wazuh version fails and you need to revert, OpenSearch will not automatically downgrade, and you cannot change its version via YAML files since it is managed by the Wazuh indexer. This situation can be problematic.

By updating Wazuh with fresh PVCs, you ensure that if something goes wrong, you can restore the previous version using the original PVCs, which contain the compatible OpenSearch data. With this in mind, let's proceed with the update steps.

### 1. Scale down the indexer and manager pods  

```
kubectl scale statefulset wazuh-indexer -n wazuh --replicas=0
kubectl scale statefulset wazuh-manager-master -n wazuh --replicas=0
kubectl scale statefulset wazuh-manager-worker -n wazuh --replicas=0
``` 
wait a few seconds until the pods are deleted, you can check if they already has been deleted with `kubectl get pods -n wazuh` you should see only the dashboard pod.  

### 2. Delete the originals PVC's
Delete the PVC's for the indexer and master, you can look the names using: 
```bash
$ kubectl get pvc -n wazuh
NAME                                          STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS    VOLUMEATTRIBUTESCLASS   AGE
snapshots-pvc                                 Bound    snapshots-pv                               50Gi       RWX                            <unset>                 53d
wazuh-indexer-wazuh-indexer-0                 Bound    pvc-95aa80a1-b4d4-47cc-bbb3-f865881e8de4   300Gi      RWO            wazuh-storage   <unset>                 40m
wazuh-indexer-wazuh-indexer-1                 Bound    pvc-ddeeaa68-8ef3-4b27-a324-63837badff29   300Gi      RWO            wazuh-storage   <unset>                 39m
wazuh-manager-master-wazuh-manager-master-0   Bound    pvc-f422dc1c-2401-4d7a-b02c-1eb269ee347b   50Gi       RWO            wazuh-storage   <unset>                 2d
wazuh-manager-worker-wazuh-manager-worker-0   Bound    pvc-79790861-2177-47d5-86c7-5da07792a5f5   50Gi       RWO            wazuh-storage   <unset>                 2d

```  
Then delete the ones asociated with the indexer and manager, you can do: 
```bash
kubectl delete pvc wazuh-indexer-wazuh-indexer-0 wazuh-indexer-wazuh-indexer-1 wazuh-manager-master-wazuh-manager-master-0 wazuh-manager-worker-wazuh-manager-worker-0 -n wazuh
```
once deleted, you can check again with `kubectl get pvc -n wazuh`, they should be gone, but don't worry, you didn't deleted the Persistance Volumes, just the Claims wazuh was using for those PV's.  

### 3. Patch the original PV's 
You need to change the storage class of the original PVs to allow Kubernetes to create new ones. If Kubernetes finds PVs that exactly match the requirements of the StatefulSets for the Wazuh indexer and manager, it will reuse the original PVs once they become Available. To prevent this and ensure new PVs are created, follow these steps:
```bash
$ kubectl get pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM                                               STORAGECLASS    VOLUMEATTRIBUTESCLASS   REASON   AGE
pvc-10bf2193-7c60-42b6-a5fd-bf582ace15f3   5Gi        RWO            Delete           Bound       shuffle/backend-apps-claim                          shuffle-data    <unset>                          98d
pvc-14745f27-9470-4a3b-b097-87f186c24347   30Gi       RWO            Delete           Bound       iris-web/iris-worker-claim                          iris-sc         <unset>                          183d
pvc-3b819a85-d87c-46df-b764-89a06c020027   30Gi       RWO            Delete           Bound       iris-web/iris-app-claim                             iris-sc         <unset>                          183d
pvc-5191ab26-0566-4b4e-a78a-8e49755b2f7f   30Gi       RWO            Delete           Bound       shuffle/opensearch-claim0                           shuffle-data    <unset>                          98d
pvc-79790861-2177-47d5-86c7-5da07792a5f5   50Gi       RWO            Retain           Released    wazuh/wazuh-manager-worker-wazuh-manager-worker-0   wazuh-storage   <unset>                          302d
pvc-95aa80a1-b4d4-47cc-bbb3-f865881e8de4   300Gi      RWO            Retain           Released    wazuh/wazuh-indexer-wazuh-indexer-0                 wazuh-storage   <unset>                          47h
pvc-b8795ae3-bd41-4cf7-9e29-3020e95f2f76   30Gi       RWO            Delete           Bound       iris-web/iris-psql-claim                            iris-sc         <unset>                          171d
pvc-d900e964-9e82-4520-b5e8-4c18bb56d6c7   5Gi        RWO            Delete           Bound       shuffle/backend-files-claim                         shuffle-data    <unset>                          98d
pvc-ddeeaa68-8ef3-4b27-a324-63837badff29   300Gi      RWO            Retain           Released    wazuh/wazuh-indexer-wazuh-indexer-1                 wazuh-storage   <unset>                          47h
pvc-f422dc1c-2401-4d7a-b02c-1eb269ee347b   50Gi       RWO            Retain           Released    wazuh/wazuh-manager-master-wazuh-manager-master-0   wazuh-storage   <unset>                          302d
snapshots-pv                               50Gi       RWX            Retain           Bound       wazuh/snapshots-pvc                                                 <unset>                          65d
``` 
You'll easily identify the original PVs by their `STATUS`, which will be set to `Released`. These are the ones that need their `STORAGECLASS` changed from `wazuh-storage` to a different value, such as `manual-backup`. To do this, follow these steps:
```bash
 kubectl patch pv <INDEXER-0-PV-NAME> <INDEXER-0-PV-NAME> <MASTER-PV-NAME> <WORKER-PV-NAME> -p '{"spec":{"storageClassName":"manual-backup"}}'
```
once done, we can check again with `kubectl get pv` and now the `STORAGECLASS` should be `manual-backup`.  

### 3. Scale up manager and indexer Statefull set  

Now we can create the new PV's and PVC's, we just need to run the following commands:  
```bash
kubectl scale statefulset wazuh-indexer -n wazuh --replicas=2
kubectl scale statefulset wazuh-manager-master -n wazuh --replicas=1
kubectl scale statefulset wazuh-manager-worker -n wazuh --replicas=1
```
wait a few moments and check wazuh is up and running, once wazuh is running, you can update wazuh and see if it's working. If everything is okay, then you can connect the originals PV's again. If wazuh new version is broken, and you want to go back to the previous version, the following steps will be the same.  

### 4.  We need to patch again the PV's to the original StorageClass  

Run the same command you runned on step 2 but this time use the wazuh storage class name:  
```bash
 kubectl patch pv <INDEXER-0-PV-NAME> <INDEXER-0-PV-NAME> <MASTER-PV-NAME> <WORKER-PV-NAME> -p '{"spec":{"storageClassName":"wazuh-storage"}}'
```
Check the patch was applied properly:   
```bash
kubectl get pv
``` 
you should see now the originals PV's with the `STORAGECLASS` column on `wazuh-storage`
### 5. Restore the PV's and PVC's  
First we need to redo [step 1](#1-scale-down-the-indexer-and-manager-pods).  

Then we are going to delete the new PVC's  and PV's using: 
```bash
kubectl delete pvc wazuh/wazuh-indexer-wazuh-indexer-1 wazuh/wazuh-indexer-wazuh-indexer-0 wazuh/wazuh-manager-worker-wazuh-manager-worker-0 wazuh/wazuh-manager-worker-wazuh-manager-master-0 -n wazuh 

kubectl delete pv <new-pvs-names> 
``` 
Finally, we need to change the `STATUS` of the original PVs from `Released` to `Available`. This ensures that when we scale up the pods, Kubernetes will automatically use these PVs for the Wazuh indexer and manager, as they match the requirements specified in the StatefulSets. To do this, edit each PV as follows: 

```bash
kubectl edit pv <PV-NAME>
```
It'll look like this: 

```yaml
# Please edit the object below. Lines beginning with a '#' will be ignored,
# and an empty file will abort the edit. If an error occurs while saving this file will be
# reopened with the relevant failures.
#
apiVersion: v1
kind: PersistentVolume
metadata:
  annotations:
    pv.kubernetes.io/bound-by-controller: "yes"
    pv.kubernetes.io/migrated-to: ebs.csi.aws.com
    pv.kubernetes.io/provisioned-by: kubernetes.io/aws-ebs
    volume.kubernetes.io/provisioner-deletion-secret-name: ""
    volume.kubernetes.io/provisioner-deletion-secret-namespace: ""
  creationTimestamp: "2025-10-01T14:10:52Z"
  finalizers:
  - kubernetes.io/pv-protection
  - external-attacher/ebs-csi-aws-com
  labels:
    topology.kubernetes.io/region: us-east-1
    topology.kubernetes.io/zone: us-east-1a
  name: pvc-95aa80a1-b4d4-47cc-bbb3-f865881e8de4
  resourceVersion: "169626996"
  uid: fd73ac26-2711-4055-af93-3db4855ef815
spec:
  accessModes:
  - ReadWriteOnce
  awsElasticBlockStore:
    fsType: ext4
    volumeID: vol-0400063ec92e7bc74
  capacity:
    storage: 300Gi
  claimRef:                ####################################DELETE FROM THIS LINE#####
    apiVersion: v1
    kind: PersistentVolumeClaim
    name: wazuh-indexer-wazuh-indexer-0
    namespace: wazuh
    resourceVersion: "169626989"
    uid: b5e8edb7-263a-4c05-973d-aad0f01b5ae1 #################TILL HERE#################
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: topology.kubernetes.io/zone
          operator: In
          values:
          - us-east-1a
        - key: topology.kubernetes.io/region
          operator: In
          values:
          - us-east-1
  persistentVolumeReclaimPolicy: Retain

``` 
we are going to delete the whole `claimRef:` section, as marked above with the comments for all the original PV's of Wazuh indexer and master. Once done, save the file and exit, now when you run a `kubectl get pv` you  
should see the original PV's `STATUS` = Avaibable.  

Now for finishing we scale up again: 

```bash
kubectl scale statefulset wazuh-indexer -n wazuh --replicas=2
kubectl scale statefulset wazuh-manager-master -n wazuh --replicas=1
kubectl scale statefulset wazuh-manager-worker -n wazuh --replicas=1
``` 

Wait a few minutes and check wazuh's working properly again and with the correct version, you can check the version connecting to the master pods and running:  
```bash
 /var/ossec/bin/wazuh-control info
``` 
Expected output: 
```bash
WAZUH_VERSION="v4.12.0"
WAZUH_REVISION="rc1"
WAZUH_TYPE="server"
```
## Wazuh Indexer S3 Snapshots Configuration

This section documents the configuration steps required to enable Wazuh Indexer (based on OpenSearch) to create and store snapshots in an AWS S3 bucket.

### 1. Create the S3 bucket
Create a bucket on AWS without any special config, just the defaults

### 2. Create IAM Policy for S3 Snapshots

In AWS IAM, create a new policy (e.g., `Wazuh-S3-Snapshot-Policy`) with the following JSON content (replace the bucket name with the one created on the 1st step):

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetBucketLocation",
                "s3:ListBucket",
                "s3:ListBucketMultipartUploads",
                "s3:ListBucketVersions"
            ],
            "Resource": [
                "arn:aws:s3:::<REPLACE-WITH-YOUR-S3-BUCKET-NAME>"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:AbortMultipartUpload",
                "s3:DeleteObject",
                "s3:GetObject",
                "s3:ListMultipartUploadParts",
                "s3:PutObject"
            ],
            "Resource": [
                "arn:aws:s3:::<REPLACE-WITH-YOUR-S3-BUCKET-NAME>/*"
            ]
        }
    ]
}
```    
### 3. Create IAM User with Programmatic Access 
#### a) Go to IAM on AWS and click on users -> ceate a new user   
![If the image doesn't appears, it may be deleted from /images/create_user_1.png](images/create_user_1.png)  
select a name and `DO NOT` select the "Provide user access to...", then hit next  

#### b) Select the permissions options 'Attach policies directly' 
![If the image doesn't appears, it may be deleted from /images/create_user_2.png](images/create_user_2.png) 
here you're gonna type your policy name created on the [step 2](#2-create-iam-policy-for-s3-snapshots) 

#### c) Review the details of the users, and if everything it is okay, hit create, then go to the user and click on 'Security Credentials' scroll down til you find access key section, hit create access key
![If the image doesn't appears, it may be deleted from /images/create_user_3.png](images/create_user_3.png) 

select the option `Application running on an AWS compute service`  

![If the image doesn't appears, it may be deleted from /images/create_user_4.png](images/create_user_4.png)  
then hit create, and copy those credentials, you'll need them on the next step. 

### 1. Install the `repository-s3` plugin on indexer pods and set the `AWS_ACCES_KEY_ID` and `AWS_SECRET_ACCES_KEY_ID`
We do the configurations using the `command` of the indexer container (`indexer-sts.yaml`):

```yaml
            #Add the following envs
            - name: OPENSEARCH_PATH_CONF  # Config for S3 bucket snapshots
              value: "/usr/share/wazuh-indexer"     
            - name: AWS_ACCESS_KEY_ID
              valueFrom:
                secretKeyRef:
                  name: wazuh-s3-creds
                  key: access_key_id
            - name: AWS_SECRET_ACCESS_KEY
              valueFrom:
                secretKeyRef:
                  name: wazuh-s3-creds
                  key: secret_access_key    


```

```yaml
          command:  #Install the S3 plugin if not installed yet, then start normally
            - sh
            - -c
            - |
            # 

            # The following checks if the repository-s3 plugin is not installed before proceeding     
              if ! /usr/share/wazuh-indexer/bin/opensearch-plugin list | grep -q repository-s3; then
                echo "Installing repository-s3 plugin..."
                echo "y" | /usr/share/wazuh-indexer/bin/opensearch-plugin install repository-s3
              fi

              # Create keystore if not exist
              if [ ! -f /usr/share/wazuh-indexer/opensearch.keystore ] || ! /usr/share/wazuh-indexer/bin/opensearch-keystore list > /dev/null 2>&1; then
                  echo "Creating OpenSearch keystore..."
                  /usr/share/wazuh-indexer/bin/opensearch-keystore create
              fi              

              if ! /usr/share/wazuh-indexer/bin/opensearch-keystore list | grep -q s3.client.default.access_key; then
                echo -n "$AWS_ACCESS_KEY_ID" | /usr/share/wazuh-indexer/bin/opensearch-keystore add s3.client.default.access_key --stdin
              fi
              if ! /usr/share/wazuh-indexer/bin/opensearch-keystore list | grep -q s3.client.default.secret_key; then
                echo -n "$AWS_SECRET_ACCESS_KEY" | /usr/share/wazuh-indexer/bin/opensearch-keystore add s3.client.default.secret_key --stdin
              fi   
            
              # Set correct perms and owner
              chown wazuh-indexer:wazuh-indexer /usr/share/wazuh-indexer/opensearch.keystore
              chmod 660 /usr/share/wazuh-indexer/opensearch.keystore


              # Start original entrypoint
              exec /usr/share/wazuh-indexer/bin/systemd-entrypoint     
          #Rest of the code bellow             
          ports:
            - containerPort: 9200
              name: indexer-rest
            - containerPort: 9300
              name: indexer-nodes
```
### Check everything it's  properly configured

#### 1) Connect to wazuh indexer :  

`kubectl exec -it wazuh-indexer-0 -n wazuh -- /bin/bash`  

#### 2) Check if the keys are properly mounted:  
```bash 
bash-5.2$ /usr/share/wazuh-indexer/bin/opensearch-keystore list
keystore.seed
s3.client.default.access_key
s3.client.default.secret_key
bash-5.2$ 


#Check the s3 plugin is installed: 
bash-5.2$ /usr/share/wazuh-indexer/bin/opensearch-plugin list  
opensearch-alerting
opensearch-anomaly-detection
opensearch-asynchronous-search
opensearch-cross-cluster-replication
opensearch-geospatial
opensearch-index-management
opensearch-job-scheduler
opensearch-knn
opensearch-ml
opensearch-neural-search
opensearch-notifications
opensearch-notifications-core
opensearch-observability
opensearch-performance-analyzer
opensearch-reports-scheduler
opensearch-security
opensearch-sql
repository-s3  #HERE YOU SHOULD SEE THE S3 PLUGIN

```
you can't see the content of the keys, but you can try creating a snapshot repositorie, if you can create it then the keys are OK.  

#### 3) Go to Wazuh - > Index Management -> Repositories and click on 'Create Repositorie'
 ![If the image doesn't appears, it may be deleted from /images/respositoy-snapshot-creation.png](images/respositoy-snapshot-creation.png) 

you need to put a repo name, your s3 bucket name and region AWS region (e.g us-east-1). Here's the code: 

```json
{
    "type": "s3",
    "settings": {
        "bucket": "<YOUR-S3-BUCKET-NAME>",
        "base_path": "wazuhsnapshots",
        "region": "<YOUR-AWS-REGION>"
    }
}
```
Note: `base_path` is a subdirectory within your S3 bucket, you can name it however you want.

#### 4) Create the Snapshot Policy 
In the same section (Index Managament) go to `Snapshots Policy` and click on create a new one  

 ![If the image doesn't appears, it may be deleted from /images/snapshot-policy-creation.png](images/snapshot-policy-creation.png)  

 select a `Policy Name` and `Description`. `Source and destination` select the indexes you want to use for your snapshots (you have to type it), e.g:  
 ``` bash
 wazuh-alerts-4.x-*
 ```  

 the destination will be the repo you just created on the previous step, or if you want you can create the repo right there clicking on the `Create repository` buttom at the right.  
 Next set the snapshot frequency you need.  

 ![If the image doesn't appears, it may be deleted from /images/snapshot-policy-creation-2.png](images/snapshot-policy-creation-2.png)
next click on `Specify retention conditions` and select the time you want to have those snapshots on S3 before deleting them forever. Finally click on `Create`.  

#### 5) Restoring a snapshot  

Go to `Snapshots`, select your snapshots and click on `restore`, then you'll need to select if you want to restore all the indexes or just a set of them. You'll need to have an account with snapshots permissions for this step.  If you are having problems with the permissions, you can check the logs by trying to restore the snapshot from the terminal, like this:  
```bash
curl -k -u <user>:'<password>' -X POST \
  "https://indexer:9200/_snapshot/<snapshot_repository>/<snapshot_name>/_restore?master_timeout=5m" \
  -H 'Content-Type: application/json' \
  -d '{
        "indices": "<index_name>",
        "include_global_state": false
      }'
```  
make sure to replace `<snapshot_repository>, <snapshot_name>` and `<index_name>` with the proper values

## Configuring a domain and SSL cert and for wazuh dashboard  
We are going to do it using route53, external plugin, an ALB and ingress.   

#### 1) Configure and set a domain on route53. 
For this you need to create a hosted zone, once done you need to set the external dns-plugin.  

#### 2) Install the dns external plugin 
Once done, you need to configure this section of the `external-dns-setup.yaml` (you can get this file on the repo [`external-dns-kubernetes`](https://github.com/Marvel-Advisors-LLC/external-dns-plugin))  

```yaml
      containers:
        - name: external-dns
          image: registry.k8s.io/external-dns/external-dns:v0.15.1
          args:
            - --source=service
            - --source=ingress
            - --domain-filter=<HOSTED-ZONE-YOU-CREATED> # will make ExternalDNS see only the hosted zones matching provided domain, omit to process all available hosted zones
            - --provider=aws
            - --policy=upsert-only # would prevent ExternalDNS from deleting any records, omit to enable full synchronization
            - --aws-zone-type=public # only look at public hosted zones (valid values are public, private or no value for both)
            - --registry=txt
            - --txt-owner-id=external-dns
            #- --log-level=debug
          env:
            - name: AWS_DEFAULT_REGION
              value: us-east-1 # change to region where EKS is installed
```
once done, apply the yaml and check everything is running properly.  

#### 3) Create the SSL cert.  
Go to AWS-> Certificate manager, and click on Request-> Request a public certificate.  
Use the following config:  
```yaml
- Fully qualified domain name: *.<HOSTED-ZONE-YOU-CREATED>  #This will apply the cert on each sub domain of your hosted zone
- Validation method: DNS validation - recommended 
```

Then click on request and validate the DNS using route53.   

#### 4) Create the ingress object  

Configure the file `wazuh-kubernetes/wazuh/indexer-stack/wazuh-dashboard/dashboard-ingress.yaml` with the domain name you  
 want (must be something like `my-domain.<HOSTED-ZONE-YOU-CREATED>`) and ssl cert arn.  
Then run: 
```bash
$ pwd 
/your-pc-path/kubernetes/wazuh-kubernetes
$ kubectl apply -k envs/eks/
```
If everything is okay, you should be able to connect via https to your wazuh dashboard on you new domain name.
## Contribute

If you want to contribute to our project please don't hesitate to send a pull request. You can also join our users [mailing list](https://groups.google.com/d/forum/wazuh) or the [Wazuh Slack community channel](https://wazuh.com/community/join-us-on-slack/) to ask questions and participate in discussions.

## Credits and Thank you

Based on the previous work from JPLachance [coveo/wazuh-kubernetes](https://github.com/coveo/wazuh-kubernetes) (2018/11/22).

## License and copyright

WAZUH
Copyright (C) 2016, Wazuh Inc.  (License GPLv2)

## References

* [Wazuh website](http://wazuh.com)
