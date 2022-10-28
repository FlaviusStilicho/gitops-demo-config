This project is a small demo I set up to test a GitOps flow using Flux to deploy a workload with Terraform.
It consists of two repositories. This repository contains all the infra code.
This repository: https://github.com/FlaviusStilicho/gitops-demo-app contains a dummy application and a pipeline that
builds a docker image on every commit using Github Actions and then does a commit in this repository, allowing the 
gitops operator to automatically update the app running in the cloud.

Want to try this for yourself? Feel free to fork this repository.

I Performed the following steps, to get all this deployed

## Install flux CLI locally
curl -s https://fluxcd.io/install.sh | sudo bash
export GITHUB_TOKEN=<your-token>
export GITHUB_USER=<your-username>
export REPOSITORY=<owner>/<repository>

## Deploy the Kubernetes cluster 
First, we need to deploy the kubernetes cluster. 
To do this, run a terraform apply in the infra directory (do change the name of the google project to your own, and perhaps change the URL to this repository of you forked it in variables.tf)
The deployment will fail partially, but the cluster will be created.

## Deploy flux using the flux CLI
Get kubectl credentials to your new cluster using gcloud
`gcloud container clusters get-credentials --project <project> --zone <zone> <cluster_name>`

Then, deploy Flux with the below command. It will commit the resources it deploys to the directory you specify in your repository - in my case, the flux directory. If you clone this repository, deletetheflux directory and let bootstrap recreate it

flux bootstrap github \
  --owner=$GITHUB_USER \
  --repository=$REPOSITORY \
  --branch=master \
  --path=./flux/ \
  --personal

Afterwards, run terraform apply again for the infra directory.

## Enable WLI on service account
You need to patch the terraform runner so that it has the permissions nescessary to deploy your app. I made mine editor because it's easy, but clearly that is not secure, so you can change it to a minimum required set of roles by changing the role in flux.tf.

kubectl annotate serviceaccount tf-runner --namespace flux-system \
    iam.gke.io/gcp-service-account=flux-terraform@nc-alex-bakker.iam.gserviceaccount.com


With this, you should be good to go!