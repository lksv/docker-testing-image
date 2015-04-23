#!/bin/bash
# SETUP ENV
set -eo pipefail

#sudo apt-get -y update
#sudo apt-get -y -qq upgrade
sudo apt-get -y -qq install bash curl build-essential bison openssl vim wget git mc

# fake git because of AVG policy
sudo git config --global url."https://github.com".insteadOf git://github.com

#sudo apt-get -y install --reinstall language-pack-en
export LANG="en_US.UTF-8"

# INSTALL_CHEF
mkdir -p /tmp/vm-provisioning
cd /tmp/vm-provisioning
curl -L https://www.opscode.com/chef/install.sh | sudo bash -s -- -v 11.16.2-1

# PREP_CHEF
mkdir -p /tmp/vm-provisioning/assets/cache
cat > /tmp/vm-provisioning/assets/solo.rb <<EOF
root = File.expand_path(File.dirname(__FILE__))
file_cache_path File.join(root, "cache")
cookbook_path [ "/tmp/vm-provisioning/travis-cookbooks/ci_environment" ]
log_location STDOUT
verbose_logging false
EOF

cd /tmp/vm-provisioning
rm -rf travis-cookbooks
#curl -L https://api.github.com/repos/travis-ci/travis-cookbooks/tarball/%{branch} > travis-cookbooks.tar.gz
#curl -L https://api.github.com/repos/travis-ci/travis-cookbooks/tarball/master > travis-cookbooks.tar.gz
curl -L https://api.github.com/repos/travis-ci/travis-cookbooks/tarball/ha-feature-trusty > travis-cookbooks.tar.gz
tar xvf travis-cookbooks.tar.gz
mv travis-ci-travis-cookbooks-* travis-cookbooks
rm travis-cookbooks.tar.gz

sudo apt-get install -y ruby-dev
sudo gem install activesupport

sudo cat > /tmp/vm-provisioning/travis-cookbooks/vm_templates/common/cip.yml <<EOF_YAML
json:
  rvm:
    default: 2.2.0
    rubies:
      - name: 2.2.0
      - name: 1.9.3
      - name: jruby-1.7.19
    gems:
      - nokogiri
  travis_build_environment:
    use_tmpfs_for_builds: false
    user: $USERCH
    group: $USERCH
    home: /home/$USERCH
  nodejs:
    default_modules:
      - module: grunt
      - module: grunt-cli
      - module: bower
recipes:
  - travis_build_environment
  - openssl
  - git::ppa
  - java
  - ant
  - maven
  - rvm
  - rvm::multi
  - nodejs::multi
  - nodejs::iojs
  - sweeper
EOF_YAML

cd /tmp/vm-provisioning;
ruby /tmp/gen_json.rb cip >/tmp/vm-provisioning/cip.json;

cat /tmp/vm-provisioning/cip.json;

sudo chef-solo -c /tmp/vm-provisioning/assets/solo.rb -j /tmp/vm-provisioning/cip.json

