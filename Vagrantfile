$script = <<-SCRIPT
# echo "Preparing local node_modules folder…"
# mkdir -p /home/vagrant/app/sdk/vagrant_node_modules
# chown vagrant:vagrant /home/vagrant/app/sdk/vagrant_node_modules
echo "cd $1" >> /home/vagrant/.profile
echo "cd $1" >> /home/vagrant/.bashrc
echo "All good!!"
SCRIPT

IMAGE_NAME = "bento/ubuntu-20.04"

VAGRANTFILE_API_VERSION = "2"

K8S_NAME = "name-k8s-01"

MASTERS_NUM = 1
MASTERS_CPU = 2
MASTERS_MEM = 2048

NODES_NUM = 1
NODES_CPU = 2
NODES_MEM = 2048

NFS_CPU = 2
NFS_MEM = 2048
NFS_NUM = 0

IP_BASE = "192.168.10."

VAGRANT_DISABLE_VBOXSYMLINKCREATE=1

VM_SYNCED_FOLDER_PATH = "/vagrant"

# Setup constants
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # Use vagrant-env plugin if available
  if Vagrant.has_plugin?("vagrant-env")
    config.env.load('.env.local', '.env') # enable the plugin
  end

  K8S_NAME = env_or_default('K8S_NAME', "example-k8s-01")

  IP_BASE = env_or_default('IP_BASE', "192.168.10.")

# Number of worker nodes to provision
  MASTERS_NUM = env_or_default_int('MASTERS_NUM', 1)

  MASTERS_CPU = env_or_default_int('MASTERS_CPU', 2)

  MASTERS_MEM = env_or_default_int('MASTERS_MEM', 2048)

  # Number of worker nodes to provision
  NODES_NUM = env_or_default_int('NODES_NUM', 1)

  NODES_CPU = env_or_default_int('NODES_CPU', 2)

  NODES_MEM = env_or_default_int('NODES_MEM', 2048)

 # nfs nodes to provision
  NFS_NUM = env_or_default_int('NFS_NUM', 0)

  NFS_CPU = env_or_default_int('NFS_CPU', 2)

  NFS_MEM = env_or_default_int('NFS_MEM', 2048)

  INSTALL_NFS = env_or_default_bool('INSTALL_NFS', false)

  # To install Helm, set the following variable to true
  INSTALL_HELM = env_or_default_bool('INSTALL_HELM', false)

  # To install Nginx, set the following variable to true
  INSTALL_NGINX = env_or_default_bool('INSTALL_NGINX', false)

  # To install Operator Lifecycle Manager, set the following variable to true
  INSTALL_OLM = env_or_default_bool('INSTALL_OLM', false)

  # Comma seperated list of operators to install
  # Use install yaml name without .yaml extension.
  # i.e.: For grafana operator with url https://operatorhub.io/install/grafana-operator.yaml use 'grafana-operator'
  INSTALL_OPERATORS = env_or_default('INSTALL_OPERATORS','')


  # To install Argo Cd, set the following variable to true
  INSTALL_ARGOCD = env_or_default_bool('INSTALL_ARGOCD', false)

end

# Convenience methods
def env_or_default(key, default)
  ENV[key] && ! ENV[key].empty? ? ENV[key] : default
end

def env_or_default_int(key, default)
  env_or_default(key, default).to_i
end

def env_or_default_bool(key, default)
  env_or_default(key, default).to_s.downcase == 'true'
end

Vagrant.configure("2") do |config|
    config.ssh.insert_key = false

    (1..NFS_NUM).each do |k|
        config.vm.define "k8s-nfs" do |node|
            node.vm.box = IMAGE_NAME
            node.vm.network "private_network", ip: "#{IP_BASE}#{11 + MASTERS_NUM + NODES_NUM}"
            node.vm.hostname = "k8s-nfs"
            node.vm.disk :disk, size: "10GB", primary: true
            node.vm.provider "virtualbox" do |v|
                v.memory = NFS_MEM
                v.cpus = NFS_CPU
                #v.customize ["modifyvm", :id, "--cpuexecutioncap", "20"]
            end
            args = []
                args.push("IP_RANGE=#{IP_BASE}0")

            node.vm.provision "shell",
                       path: "vagrant/nfs-setup/install_nfs.sh",
                       args: args
        end
    end
    (1..MASTERS_NUM).each do |i|
        config.vm.define "k8s-m-#{i}" do |master|
            master.vm.box = IMAGE_NAME
            master.vm.network "private_network", ip: "#{IP_BASE}#{i + 10 }"
            master.vm.hostname = "k8s-m-#{i}"
            master.vm.synced_folder ".", VM_SYNCED_FOLDER_PATH
            master.vm.provider "virtualbox" do |v|
                v.memory = MASTERS_MEM
                v.cpus = MASTERS_CPU
            end

            master.vm.provision "ansible" do |ansible|
                ansible.playbook = "vagrant/roles/k8s.yml"
                #Redefine defaults
                ansible.extra_vars = {
                    k8s_cluster_name:       K8S_NAME,
                    k8s_master_admin_user:  "vagrant",
                    k8s_master_admin_group: "vagrant",
                    k8s_master_apiserver_advertise_address: "#{IP_BASE}#{i + 10}",
                    k8s_master_node_name: "k8s-m-#{i}",
                    k8s_node_public_ip: "#{IP_BASE}#{i + 10}"
                }
            end
            master.vm.provision :shell, inline: $script, args:"#{VM_SYNCED_FOLDER_PATH}"


             args = []
                            args.push("IpNfs=#{IP_BASE}#{11 + MASTERS_NUM + NODES_NUM}")
                            args.push("InstallOLM=#{INSTALL_OLM}")
                            args.push("InstallHelm=#{INSTALL_HELM}")
                            args.push("InstallNginx=#{INSTALL_NGINX}")
                            args.push("InstallNfs=#{INSTALL_NFS}")
                            args.push("InstallOperators=#{INSTALL_OPERATORS}")
                            args.push("InstallArgoCd=#{INSTALL_ARGOCD}")
            master.vm.provision "shell",
                       path: "vagrant/k8s-addons/install-addons.sh",
                       args: args

        end
    end

    (1..NODES_NUM).each do |j|
        config.vm.define "k8s-n-#{j}" do |node|
            node.vm.box = IMAGE_NAME
            node.vm.network "private_network", ip: "#{IP_BASE}#{j + 10 + MASTERS_NUM}"
            node.vm.hostname = "k8s-n-#{j}"
            node.vm.provider "virtualbox" do |v|
                v.memory = NODES_MEM
                v.cpus = NODES_CPU
                #v.customize ["modifyvm", :id, "--cpuexecutioncap", "20"]
            end
            node.vm.provision "ansible" do |ansible|
                ansible.playbook = "vagrant/roles/k8s.yml"
                #Redefine defaults
                ansible.extra_vars = {
                    k8s_cluster_name:     K8S_NAME,
                    k8s_node_admin_user:  "vagrant",
                    k8s_node_admin_group: "vagrant",
                    k8s_node_public_ip: "#{IP_BASE}#{j + 10 + MASTERS_NUM}"
                }
            end
        end
    end
end