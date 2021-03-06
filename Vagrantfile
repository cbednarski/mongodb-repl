Vagrant.configure("2") do |config|
  config.vm.define "db1" do |db1|
    db1.vm.box = "cbednarski/ubuntu-1404"
    db1.vm.network "private_network", ip: "10.7.0.2"
    db1.vm.provision "shell", inline: "echo 'db1' > /etc/hostname"
    db1.vm.provision "shell", inline: "hostname db1"
    db1.vm.provision "shell", inline: "bash /vagrant/install-mongodb.sh"
  end

  config.vm.define "db2" do |db2|
    db2.vm.box = "cbednarski/ubuntu-1404"
    db2.vm.network "private_network", ip: "10.7.0.3"
    db2.vm.provision "shell", inline: "echo 'db2' > /etc/hostname"
    db2.vm.provision "shell", inline: "hostname db2"
    db2.vm.provision "shell", inline: "bash /vagrant/install-mongodb.sh"
  end

  config.vm.define "db3" do |db3|
    db3.vm.box = "cbednarski/ubuntu-1404"
    db3.vm.network "private_network", ip: "10.7.0.4"
    db3.vm.provision "shell", inline: "echo 'db3' > /etc/hostname"
    db3.vm.provision "shell", inline: "hostname db3"
    db3.vm.provision "shell", inline: "bash /vagrant/install-mongodb.sh"
    db3.vm.provision "shell", inline: %q{sleep 1 && mongo --eval "rs.initiate()"}
    # Add additional nodes slowly so we avoid a race condition in leader election.
    db3.vm.provision "shell", inline: %q{sleep 3 && mongo --eval "rs.add('db1')"}
    db3.vm.provision "shell", inline: %q{sleep 3 && mongo --eval "rs.add('db2')"}
  end
end
