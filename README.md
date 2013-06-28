# VagrantPress

### You are a Wordpress Plugin or Wordpress Theme developer?

... and you are looking for the ultimate Wordpress development environment? You don't want do clutter
your operating system with Apache, Mysql and PHP packages and you actually don't want to maintain 
local [zombie webservers](http://en.wikipedia.org/wiki/Zombie_computer). Don't look any further!


VagrantPress is a packaged WordPress development environment. 
[VirtualBox](https://www.virtualbox.org/), 
[Vagrant](http://www.vagrantup.com/), 
[Puppet](https://puppetlabs.com/puppet/what-is-puppet/) ftw


## Installation is as easy as ...

Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads) and [Vagrant](http://downloads.vagrantup.com/) first,
then type in your console:

```
$ git clone https://github.com/hellominti/vagrantpress.git
$ cd vagrantpress
$ cp .my.conf my.conf
$ vagrant up; vagrant reload
```

You are good to go. Now open in your browser ...
 * [http://192.168.192.168](http://192.168.192.168) (have a look at phpinfo())
 * [http://192.168.192.168/phpmyadmin](http://192.168.192.168/phpmyadmin)
 * [http://test.wp](http://test.wp) (verify DNS works)
 * [http://wptest.wp](http://wptest.wp) (a fresh wordpress installation)

VagrantPress automates all DNS handling for you. During *vagrant up|reload* you might be asked for 
your password to update your ```/etc/resolver``` directory. 
(If you are not on a Mac, you might need to change ```config.dnsmasq.resolver``` 
in the Vagrantfile to point to your /etc/resolver directory.)


## Once you've installed VagrantPress ...

... you can start working on your Wordpress Plugins, Wordpress Themes or the Wordpress Core.

### Start VagrantPress
In your console, change to your VagrantPress directory and run ```vagrant up``` to start the
virtual machine. 

### Wordpress Developing

#### Create a new Wordpress Installation
Go to the projects directory and create a new directory inside it, like ```projects/another-site.wp```. 
Specify the Wordpress version which you want to install by creating a file or directory named after 
the version number, like ```projects/another-site.wp/3.5.1```. Wait about 10 seconds and see the magic happen. 
VagrantPress will install Wordpress into ```projects/another-site.wp```. As soon as it is ready,
a file called ```__ready__``` appears. You can delete ```__ready__``` at anytime.

Please note that there are no restrictions on the domain ending. You could create projects folders
like ```my-site.dev``` or ```this.is.my.site```. Once you introduce new domain endings (like here
```.dev``` and ```.is.my.site```) run ```vagrant reload``` to restart according services.
(@todo create vagrant plugin to restart dnsmasq on guest and activate new domains, ```vagrant init-domains```)

#### Usage of [wp-cli](http://wp-cli.org/)
```vagrant wp help``` or ```vagrant wp help --path="/shared_projects/wordpress_site"```

(@todo include path in command, like ```vagrant wordpress_site wp help```)

#### Access your virtual machine via ssh
We designed VagrantPress to be a seamless integration into your host system. Should you still
want to log into your virtual machine, do it with ```vagrant ssh```.

### Stop VagrantPress
In your console, change to your VagrantPress directory and run ```vagrant halt``` to stop the
virtual machine. 

You can delete your virtual machine with ```vagrant destroy```. Should you have made any changes
on the virtual machine, they will be deleted as well. VagrantPress keeps a backup of your
Wordpress MySQL databases though. This is done automatically for you. MySQL Backups are kept in 
```projects/your_wordpress_site.wp/.mysql_dump```. Once you run ```vagrant up``` or ```vagrant reload``` 
and a database is missing for one of your wordpress sites, it will automatically create that 
missing database and imports the MySQL Backup from ```projects/your_wordpress_site.wp/.mysql_dump```.


## Credentials

<table>
  <tr>
    <td>MySQL</td>
    <td>User: root, Password: vagrant</td>
  </tr>
  <tr>
    <td>Default Wordpress Installation</td>
    <td>User: vagrant, Password: vagrant</td>
  </tr>
</table>


## TODOS

 * Keep a local copy of config files for apache, php, mysql, ... and symlink them to the virtual machine. 
   one can then edit config files without going to vagrant ssh 
 * refactor MysqlBackupPlugin.rb
 * refactor vagrant-dns
 * what happens when wordpress installation has no database and no mysql_dump.sql?
 * deleting a directory in projects should delete the according database accordingly
 * allow mysql remote access
 * packages: memcached, phpunit


