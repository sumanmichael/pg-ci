sudo apt-get install postgresql-server-dev-11 libicu-dev gcc make
git clone --depth 1 https://github.com/okbob/plpgsql_check.git 
cd plpgsql_check/
sudo make && sudo make install