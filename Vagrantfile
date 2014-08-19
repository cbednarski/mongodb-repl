Vagrant.configure("2") do |config|
  config.vm.define "db1" do |db1|
    db1.vm.box = "cbednarski/ubuntu-1404"
    db1.vm.network "private_network", ip: "10.7.0.1"
    db1.vm.provision "shell", inline: "bash /vagrant/install-mongodb.sh"
  end

  config.vm.define "db2" do |db2|
    db2.vm.box = "cbednarski/ubuntu-1404"
    db2.vm.network "private_network", ip: "10.7.0.2"
    db2.vm.provision "shell", inline: "bash /vagrant/install-mongodb.sh"
  end

  config.vm.define "db3" do |db3|
    db3.vm.box = "cbednarski/ubuntu-1404"
    db3.vm.network "private_network", ip: "10.7.0.3"
    db3.vm.provision "shell", inline: "bash /vagrant/install-mongodb.sh"
    db3.vm.provision "shell", inline: "mongo /vagrant/replica.js"
  end
end
