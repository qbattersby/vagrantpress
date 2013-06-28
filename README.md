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

Open [http://192.168.192.168](http://192.168.192.168) in your browser or [http://192.168.192.168/phpmyadmin](http://192.168.192.168/phpmyadmin)

With the help of a DNS handling plugin, you can open  [http://test.wp](http://test.wp) 
and [http://wptest.wp](http://wptest.wp). VagrantPress currently uses [vagrant-dnsmasq](https://github.com/mattes/vagrant-dnsmasq)
which can be installed with ```vagrant plugin install vagrant-dnsmasq```. There are alternatives available, please have a look at this 
[list of other DNS handling plugins](https://github.com/mitchellh/vagrant/wiki/Available-Vagrant-Plugins#local-domain-resolution).

@todo: Integrate DNS handling into core VagrantPress?

## Once you've installed VagrantPress ...

... you can start working on your Wordpress Plugins, Wordpress Themes or the Wordpress Core.

 * __Start by creating a new Wordpress installation.__  
   Go to the projects directory and create a new directory inside it, like ```projects/another-site.wp```. 
   Specify the Wordpress version which you want to install by creating a file or directory named after 
   the version number, like ```projects/another-site.wp/3.5.1```. Wait about 10 seconds and see the magic happen. 
   VagrantPress will install Wordpress into ```projects/another-site.wp```. As soon as it is ready,
   a file called ```__ready__``` appears. You can delete ```__ready__``` at anytime.
 * Sometimes you may want to __log into your VagrantPress__ virtual machine with ```vagrant ssh```.
 * __Stop__ your VagrantPress virtual machine with ```vagrant halt```. 
 * __Destroy__ your VagrantPress virtual machine with ```vagrant destroy```. This will dump all MySQL data
   into ```projects/another-site.wp/.mysql_dump```. By the way, ```vagrant up``` and ```vagrant reload```
   looks for existing MySQL dumps and imports them.
 * Run wp-cli remotely via ```vagrant wp help```

@todo: improve workflow description


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
 * what happens when wordpress installation has no database and no mysql_dump.sql?
 * dns handling?!
 * deleting a directory in projects should delete the according database accordingly
 * allow mysql remote access
 * packages: xdebug, memcached, phpunit
 * Mac ships with bind! ;-) http://negativespace.net/2013/05/14/apache-dns-wildcard-hosting-with-mac-os-x/


