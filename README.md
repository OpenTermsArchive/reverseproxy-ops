# Open Terms Archive - ops

Recipes to setup infrastructure and deploy Open Terms Archive proxy

> Recettes pour mettre en place l'infrastructure et déployer le proxy nginx d'Open Terms Archive

## Requirements

- Install [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
- Install required Ansible roles `ansible-galaxy install -r requirements.yml`

See [troubleshooting](#troubleshooting) in case of errors

## Development

In order to try out the infrastructure setup, we use virtual machines. We use [Vagrant](https://www.vagrantup.com) to describe and spawn these virtual machines with a simple `vagrant up` command.

### Dependencies

In order to automatically set up a virtual machine:

1. Install [Vagrant](https://www.vagrantup.com/docs/installation/).
2. Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads) to manage virtual machines. If you prefer Docker, or have an Apple Silicon machine, install [Docker](https://docs.docker.com/get-docker/) instead.
3. Create a dedicated SSH key with no password: `ssh-keygen -f ~/.ssh/ota-vagrant -q -N ""`. This key will be automatically used by Vagrant.

> VirtualBox is not compatible with Apple Silicon (M1…) processors. If you have such a machine, you will need to use the Docker provider. Since MongoDB cannot be installed on ARM, it is skipped in the infrastructure installation process. This means you cannot test the MongoDB storage repository with Vagrant with an Apple Silicon processor.

## Configuration

### [For developement only] Configure your host machine to access the VM.

Edit your hosts file `/etc/hosts`, add the following line so you can connect to the VM to test deployed apps from your host machine's browser:

```
192.168.33.12    ota.local
```

Now on your browser you will be able to access deployed app on the VM with the URL `http://ota.local` to mimic the real architecture of our servers

The guest VM's IPs can be changed in the `VagrantFile`:

## Usage

To avoid making changes on the production server by mistake, by default all commands will only affect the vagrant developement VM. Note that the VM needs to be started before with `vagrant up`.\
To execute commands on the production server you should specify it by adding the option `-i inventories/production.yml` to the following commands.

- **Setup a phoenix server:**

```
ansible-playbook site.yml
```

- **Setup infrastructure only:**

```
ansible-playbook infra.yml
```

- **Setup apps only:**

```
ansible-playbook apps.yml
```

- **Setup one sub part of the infra:**

```
ansible-playbook playbooks/infra/<MODULE>.yml
```

_You can find all available modules in `playbooks/infra` directory._

For example, to setup only nginx on the new server:

```
ansible-playbook playbooks/infra/nginx.yml
```

### Options

Ansible provide among many others the following useful options:

- `--diff`: to see what changed.
- `--check`: to simulate execution.
- `--check --diff`: to see what will be changed.

For example, if you modify the nginx config and you want to see what will be changed you can run:

```
ansible-playbook playbooks/infra/nginx.yml --check --diff
```

### Sample commands

In order to deploy here are the corresponding commands

#### for vagrant

```bash
# Deploy site
ansible-playbook playbooks/site.yml

# Deploy all infra only
ansible-playbook playbooks/infra.yml

# Deploy only docker
ansible-playbook playbooks/infra/docker.yml
```

#### for production 

```bash
# Check deployment of whole site
ansible-playbook playbooks/site.yml -i inventories/production.yml --check --diff

# Deploy whole site
ansible-playbook playbooks/site.yml -i inventories/production.yml
```
## Troubleshooting

### Failed to connect to the host via ssh: Received disconnect from 127.0.0.1 port 2222:2: Too many authentication failures

Modify ansible ssh options to the `inventories/dev.yml` file like this:

```
all:
  children:
    dev:
      hosts:
        '127.0.0.1':
          […]
          ansible_ssh_private_key_file: .vagrant/machines/default/virtualbox/private_key
          ansible_ssh_extra_args: -o StrictHostKeyChecking=no -o IdentitiesOnly=yes
          […]
```

Or alternatively you can use the dev-fix config by appending `-i ops/inventories/dev-fix.yml`

### ansible: command not found

if you're on mac OSX and tried to install with `pip install ansible`
you may need to add python's bin folder to your path with

```
export PATH=$PATH:/Users/<yourusername>/Library/Python/3.7/bin
```

### ~/.netrc access too permissive: access permissions must restrict access to only the owner

on linux

```
chmod og-rw /home/<yourusername>/.netrc
```

on mac OSX

```
chmod og-rw /Users/<yourusername>/.netrc
```

### <urlopen error [SSL: CERTIFICATE_VERIFY_FAILED] certificate verify failed: unable to get local issuer certificate (\_ssl.c:1123)>

on mac OSX, go to folder `/Applications/Python 3.9` and double click on `Install Certificates.command`

### An error occurred during the signature verification. GPG error

```
# https://www.linuxuprising.com/2019/06/fix-missing-gpg-key-apt-repository.html

sudo apt update 2>&1 1>/dev/null | sed -ne 's/.*NO_PUBKEY //p' | while read key; do if ! [[ ${keys[*]} =~ "$key" ]]; then sudo apt-key adv --keyserver hkp://pool.sks-keyservers.net:80 --recv-keys "$key"; keys+=("$key"); fi; done
sudo apt update 2>&1 1>/dev/null | sed -ne 's/.*NO_PUBKEY //p' | while read key; do if ! [[ ${keys[*]} =~ "$key" ]]; then sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv-keys "$key"; keys+=("$key"); fi; done
```
