# Open Doors Temp Site
Temporary import sites for semi-automated Open Doors imports.

# Overview
The [Open Doors](http://opendoors.transformativeworks.org/) project is dedicated to preserving at-risk fanworks. Part of 
that work involves importing works into Archive of Our Own from external archives which are being closed down. 

Due to the variety of formats in external websites, some of which are completely incompatible with Archive of Our Own's
importing process, some archives are imported using a semi-automated process involving two technical stages after the
initial Open Doors processes:

1. The metadata and works are extracted from a backup of the old archive and converted into standardised MySQL tables 
(see [Open Doors eFiction](https://github.com/otwcode/open-doors-efiction) and 
   [Open Doors Code (ODAP)](https://github.com/otwcode/open-doors-code) which are used for this stage)
1. The standardised data is hosted in a temporary website accessible to import operators and which allows them to 
perform the import in stages, verifying imported works as they go along. 
   
This repository houses the Rails + React application used to create those sites.

# Running it locally
This is Ruby on Rails site with a React front-end mounted by the `react-rails` gem.

Requirements:
- Ruby 2.7.3 
- MySQL 5.7
- Bundler
- Node 8.11 https://nodejs.org/en/blog/release/v8.11.1/
- Yarn https://yarnpkg.com/lang/en/docs/install/

Note: for ease of local development, the Ruby and MySQL versions should be kept in step with the [otwarchive project](https://github.com/otwcode/otwarchive)

See [Rails Getting Started Guide](http://guides.rubyonrails.org/getting_started.html) for instructions on installing and configuring Rails.

Once this is done, you can install dependencies and run the Rails application from the command line:
```bash
$ cd path/to/this/repo
$ bundle install
$ bin/rails server
``` 

In your browser, navigate to http://localhost:3010/opendoorstempsite to view the temp site.

# Deploying a site
Before you proceed, you will need to install Ansible Playbook (https://docs.ansible.com/ansible/latest/network/getting_started/first_playbook.html).

1. In the `scripts/ansible` directory, create a file called `hosts` with the following contents:
    ```
    [otw]
    [[SERVER_NAME]] ansible_ssh_user=[[SERVER_USER]]
    ```
    Where `SERVER_NAME` and `SERVER_USER` are the server DNS host and ssh user for the web server. You can optionally 
    include the local path to your private SSH key using `ansible_ssh_private_key_file`:
    ```
   [otw]
    server.transformativeworks.org ansible_ssh_user=username ansible_ssh_private_key_file=/path/to/.ssh/something_rsa
    ```

3. Make a copy of `scripts/variables.yml.example` as `scripts/variables.yml` and fill it in with the details 
of the site you're creating. The `sitekey` must be a string with no spaces: this will be used as the installation 
directory, database name and site path. Note: a filled-in `variables.yml` for use with the live temp site server is 
available for OTW staff.

4. Make a copy of `config/secrets.yml.example` as `config/secrets.yml` (you'll probably need to have one for development 
anyway - make sure it has a valid `production` section). Note: `secrets.yml` is included in the `.gitignore` to prevent 
it being accidentally uploaded to Github. 

5. Run 
    ```bash
    $ cd open-doors-temp-site/
    $ ./scripts/deploy-site-from-variables.sh
    ```

Note: the bash script is just provided as a convenience to load parameters from `variables.yml`. If you are working on 
multiple sites, you might want to have different variable files and an edited copy of the bash script for each one.

This will create a shell site populated with dummy data. You can then upload the real tables produced by the ODAP 
directly to the MySQL database on the temp site, which will have the `sitekey` you specified as its name.

# Archiving a site
When you are finished with the site and it has been fully imported, you can archive it using the following procedure:

1. Edit your `scripts/variables.yml` to include the details for your site.
1. Run
    ```bash
    $ cd open-doors-temp-site/
    $ ./scripts/remove-site-from-variables.sh
    ```

This will bundle the MySQL tables and app directory into a zip file and download it to the root of the 
repository on your local machine.

# Vagrant deployment
To test the Ansible provisioning and deployment using Vagrant:

1. Make a copy of `variables.yml.example` as `variables.yml` and fill it in with the details 
   of the site you're creating.
   
1. Navigate to the root of the project and then type:

```bash
$ cd <root of this repo>
$ vagrant up
```

1. Navigate to http://localhost:8080/<site name> to view the deployed site.

The same provisioning script used to set up the remote server will be used to provision a local Vagrant image on Ubuntu 16.04.
(Note that this deploys a production environment which isn't suitable for development)

To deploy a site manually:
 
```bash
$ ansible-playbook scripts/ansible/deploy-site.yml -u ubuntu -i .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory --extra-vars "@scripts/variables.yml"
```

# Server provisioning
To set up a new server from scratch on Ubuntu 16, including fresh installations of Nginx, MySQL and Rails, run the 
`provision-server.yml` playbook, using a populated `variables.yml`:

```bash
$ cd <root of this repo>
$ ansible-playbook scripts/provision-server.yml -i scripts/hosts --extra-vars "@scripts/variables.yml"
```


# Known Issues
1. Webpacker compilation fails with no explanation on Linode: this is probably due to lack of memory for the compilation - stop one of the other sites to resolve this.