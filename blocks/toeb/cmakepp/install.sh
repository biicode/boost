if cat /etc/*-release | grep raspbian; then
  dist="raspbian"
elif cat /etc/*-release | grep wheezy; then
  dist="wheezy"
elif cat /etc/*-release | grep jessie; then
  dist="jessie"
elif cat /etc/*-release | grep trusty; then
  dist="trusty"
elif cat /etc/*-release | grep precise; then
  dist="precise"
elif cat /etc/*-release | grep saucy; then
  dist="saucy"
elif cat /etc/*-release | grep quantal; then
  dist="quantal"
elif cat /etc/*-release | grep raring; then # 13.04
  dist="raring"
elif cat /etc/*-release | grep utopic; then # 14.10
  dist="utopic"
else
  echo "Can't find a valid debian-based distribution! Please contact info@biicode.com for help or post in forum.biicode.com!"
  exit 1
fi
echo "deb http://apt_new.biicode.com $dist main" | sudo tee /etc/apt/sources.list.d/biicode.list
sudo wget -O /etc/apt/trusted.gpg.d/biicode.gpg http://apt_new.biicode.com/keyring.gpg
sudo apt-get update
sudo apt-get -y install biicode
