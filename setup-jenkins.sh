# Basierend auf Ubuntu 14.4


# Security
apt-get update
apt-get install -y ufw fail2ban

ufw default deny
ufw allow ssh
ufw allow http
ufw allow https
ufw enable

# Install nginx as reverse HTTP proxy
apt-get install -y nginx apache2-utils
htpasswd -c /etc/nginx/.htpasswd penny

cat > /etc/nginx/sites-available/default << EOI
server {
    listen       80;
    server_name  localhost;

    auth_basic "Restricted";
    auth_basic_user_file /etc/nginx/.htpasswd;

    location /images {
        autoindex on;
        root /var/www/images
    }

    location / {
        proxy_pass   http://[::]:8080/;
    }
}
EOI

mkdir -p /var/www/images
chown jenkins:www-data /var/www/images
chmod 750 /var/www/images


service nginx restart

# Install Jenkins
wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | apt-key add -
echo "deb http://pkg.jenkins-ci.org/debian binary/" > /etc/apt/sources.list.d/jenkins.list
apt-get update
apt-get install -y jenkins

# Install build dependencies
apt-get install -y build-essential subversion libncurses-dev libz-dev git gawk cmake pkg-config

# Build and install ecdsautils for key generation and signing
mkdir -p /tmp/build
cd /tmp/build/
git clone http://git.universe-factory.net/libuecc
cd libuecc/
cmake ./
make
make install
ldconfig

cd ..
git clone https://github.com/tcatm/ecdsautils
cd ecdsautils/
cmake ./
make
make install

# Create new signing secret
ecdsakeygen -s > /var/lib/jenkins/secret
cat /var/lib/jenkins/secret | ecdsakeygen -p > /var/lib/jenkins/secret.pub
chown jenkins:jenkins /var/lib/jenkins/secret /var/lib/jenkins/secret.pub
chmod 640 /var/lib/jenkins/secret
chmod 644 /var/lib/jenkins/secret.pub

# Configure Jenkins:
1) Manage Jenkins > Manage Plugins
  1) Update all installed Plugins
  2) install "Git Plugin"
  3) Restart Jenkins
2) Manage Jenkins > Configure System > Git plugin
  1) Configure user.name and user.email to something sane (jenkins@cccgoe.de)
  2) Save
3) Create New Item
  1) Choose a name with no spaces or non-ascii chars.
  2) Choose "Freestyle project"
4) Configure new project
  1) Source Code Management > GIT
     https://github.com/freifunk-goettingen/site-ffgoe
  2) Build Triggers > Poll SCM
     "H * * * *"
  3) Build > Execute Shell
     "bash build-jenkins.sh"
  4) Save


7f5aC4za2jYd
