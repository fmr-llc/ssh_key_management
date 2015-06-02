# SSH Public Key Manager

## Installation

1. configure your [devise authentication](https://github.com/plataformatec/devise)
    1. If using LDAP, modify config/ldap.yml to your environment

2. configure your database connection (config/database.yml)

3. modify your [dotenv file](https://github.com/bkeepers/dotenv) from the .env.example

4. install gems

        bundle install


6. start application

  -        rails server

  or

  - configure capistrano

            config/deploy.rb
            config/deploy/staging.rb
            config/deploy/production.rb

  -  and

             cap deploy

## OpenSSH Daemon Integration
The are two main ways to integrate OpenSSH and the Key Manager:

1. Modify OpenSSH config with AuthorizedKeysCommand and the corresponding authorized_keys script

  - RedHat 6 supports the AuthorizedKeysCommandRunAs directive (RedHat patched OpenSSH 5.3p1)
  - RedHat 7 supports the AuthorizedKeysCommandUser directive(vanilla OpenSSH 6.6.1p1)
  - Ubuntu 14/04 supports the AuthorizedKeysCommandUser directive (vanilla OpenSSH 6.6.1p1)

  **The Linux packages will install the proper sshd_config file and script, but you may need to modify the template for your environment**

2. Cron/Scheduler task

  - RedHat 5 and below (and other wonky UNIXes with an old OpenSSH server) there is a bash script

  **The Linux packages will install the proper script, but you may need to modify the template for your environment**

  - Windows BitVise server there is a PowerShell script

  **The Windows MSI will install the proper PowerShell script, but you may need to modify the template for your environment**


## OS Packages

Rake tasks have are setup to create packages for Debian (Ubuntu), RedHat (RHEL, CentOS, Oracle Enterprise Linux), and Windows deployment (MSI).

* Linux packages must be generated on Linux using fpm

        rake sshkm_packages:unix:deb            # builds Ubuntu package (.deb)
        rake sshkm_packages:unix:rpm            # builds RedHat package (.rpm)

* Windows MSIs must be created on Windows using [Wix Toolset](http://wixtoolset.org/)

       **Wix binaries must be added to your windows PATH before MSI generation**

        rake sshkm_packages:windows:msi            # builds Windows MSI


## License

SSH Public Key Manager is released under the [Apache 2.0 License](http://www.apache.org/licenses/LICENSE-2.0).

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
