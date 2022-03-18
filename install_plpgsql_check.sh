sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt -y update
sudo apt-get install -y postgresql-server-dev-14 libicu-dev gcc make
git clone --depth 1 https://github.com/okbob/plpgsql_check.git 
cd plpgsql_check/
sudo make && sudo make install