InstallOLM=
InstallHelm=false
InstallNginx=false
InstallNfs=false
InstallArgoCd=false
IpNfs=192.168.50.13

for ARGUMENT in "$@"
do

    KEY=$(echo $ARGUMENT | cut -f1 -d=)
    VALUE=$(echo $ARGUMENT | cut -f2 -d=)

    case "$KEY" in
            InstallOLM) InstallOLM=${VALUE};;
            InstallHelm) InstallHelm=${VALUE};;
            InstallNginx) InstallNginx=${VALUE};;
            InstallNfs) InstallNfs=${VALUE};;
            IpNfs) IpNfs=${VALUE};;
            InstallArgoCd) InstallArgoCd=${VALUE};;
            *)
    esac

done

echo "InstallOLM =$InstallOLM"
echo "InstallHelm =$InstallHelm"
echo "InstallNginx =$InstallNginx"
echo "InstallNfs =$InstallNfs"
echo "IpNfs =$IpNfs"

#NFS
NFS_PATH=/srv/kubedata
RELEASE_NAME=nfs-provisioner
NAMESPACE=nfs-system
CHART_VERSION=4.0.10


create_custom_values(){

echo ${IP_NFS}
echo "Custom Values"

sudo echo "
replicaCount: 1
image:
  pullPolicy: IfNotPresent
storageClass:
  name: nfs-client
  defaultClass: true
  archiveOnDelete: true
  accessModes: ReadWriteOnce
  reclaimPolicy: Delete
nfs:
  server: ${IpNfs}
  path: ${NFS_PATH}

"> /home/vagrant/nfs_provisioner/values.production.yaml

}


install_nfs_provisioner(){

  echo "Installing nfs"
  sudo mkdir /home/vagrant/nfs_provisioner
  sudo chown ${USER} -R /home/vagrant/nfs_provisioner

  sudo -u vagrant -H sh -c "kubectl create ns nfs-system"

  sudo -u vagrant -H sh -c "helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/"

  create_custom_values

  sudo -u vagrant -H sh -c "helm install ${RELEASE_NAME} --namespace ${NAMESPACE} --version ${CHART_VERSION} nfs-subdir-external-provisioner/nfs-subdir-external-provisioner -f /home/vagrant/nfs_provisioner/values.production.yaml"

}

kubectl_for_root(){
  sudo mkdir /root/.kube
  sudo cp /home/vagrant/.kube/config /root/.kube/

  #chmod 600 ~/.kube/config

  #or
  chmod o-r ~/.kube/config
  chmod g-r ~/.kube/config
  chmod go-r ~/.kube/config
}

install_helm(){
  echo "Installing Helm"
  curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
  helm repo add stable https://charts.helm.sh/stable/
}

install_nginx(){
    echo "Installing nginx"
    sudo -u vagrant -H sh -c "kubectl create ns ingress-nginx"

    sudo -u vagrant -H sh -c "helm repo add nginx-stable https://helm.nginx.com/stable"
    sudo -u vagrant -H sh -c "helm repo update"

    sudo -u vagrant -H sh -c "helm install nginx-ingress nginx-stable/nginx-ingress --namespace ingress-nginx"

}

install_argocd(){
    echo "Installing Argo CD"
    sudo -u vagrant -H sh -c "kubectl create ns argocd"
    sudo -u vagrant -H sh -c "kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"
    sudo -u vagrant -H sh -c "kubectl patch svc argocd-server -p '{spec: {type: NodePort}}' -n argocd"
    #sudo -u vagrant -H sh -c "kubectl get secret argocd-initial-admin-secret -n argocd -o yaml | base64 --decode > ArgoPassword.txt"
    #sudo -u vagrant -H sh -c "kubectl apply -f application.yaml"
}



install_olm(){
   echo "Installing Operator Lifecycle Manager"
    OLM_RELEASE=$(curl -s https://api.github.com/repos/operator-framework/operator-lifecycle-manager/releases/latest | grep tag_name | cut -d '"' -f 4)
    sudo -u vagrant -H sh -c "kubectl apply -f https://github.com/operator-framework/operator-lifecycle-manager/releases/download/${OLM_RELEASE}/crds.yaml"
    sudo -u vagrant -H sh -c "kubectl apply -f https://github.com/operator-framework/operator-lifecycle-manager/releases/download/${OLM_RELEASE}/olm.yaml"
}


    install_helm

if [ "$InstallNginx" = true ]; then
    install_nginx
fi

if [ "$InstallOLM" = true ]; then
    install_olm
fi

if [ "$InstallNfs" = true ]; then
    install_nfs_provisioner
fi


if [ "$InstallArgoCd" = true ]; then
    install_argocd
fi

for operator in "${InstallOperators[@]}"
do
    echo "Installing Operator : $operator"
    sudo -u vagrant -H sh -c "kubectl create -f https://operatorhub.io/install/$operator.yaml"
done

#cp /home/vagrant/.kube/config /vagrant/vagrant/kube-config/config
