use Rex -feature => ['exec_autodie'];

my $RAILS_ROOT   = '/home/multiser/tienda';

desc 'Configura el sistema entero para dar el servicio web';
task 'ConfigurarMaquina', sub {
    ConfigurarServidorWeb();
    ConfigurarBDWeb();
    ConfigurarAplicacionWeb();
};

desc 'Configura la aplicacion web';
task 'ConfigurarAplicacionWeb', sub {
    pkg 'mysql-devel', ensure => 'present';
    # compass-rails se coge del git de momento
    pkg 'git', ensure => 'present';
    run 'bundle install', cwd => $RAILS_ROOT;
    for my $env qw(production development test) {
        run "RAILS_ENV=$env bundle exec rake db:create", cwd => $RAILS_ROOT;
        run "RAILS_ENV=$env bundle exec rake db:migrate", cwd => $RAILS_ROOT;
        run "RAILS_ENV=$env bundle exec rake db:seed", cwd => $RAILS_ROOT;
    }
    run "RAILS_ENV=production bundle exec rake assets:precompile", cwd => $RAILS_ROOT;
    file '/etc/httpd/conf.d/web_oficina.conf', 'source' => 'archivos/web_oficina.conf';
    file '/home/multiser/ruby', ensure => 'directory';
    ln '/usr/lib64/ruby/gems/2.0.0/' => '/home/multiser/ruby/gems';
    file '/usr/local/ruby20', ensure => 'directory';
    ln '/usr/bin' => '/usr/local/ruby20/bin';
    service 'httpd' => 'restart';
};

desc 'Instala Ruby y sus dependencias para correr la aplicacion web';
task 'InstalarRuby', sub {
    pkg 'epel-release', ensure => 'present';
    pkg [qw(rpm-build glibc-devel gcc openssl-devel db4-devel readline-devel ncurses-devel gdbm-devel tcl-devel byacc libyaml libyaml-devel libffi libffi-devel)], ensure => 'present';

    my $rpm_build_dir = '/usr/src/redhat';
    download 'https://cache.ruby-lang.org/pub/ruby/2.0/ruby-2.0.0-p353.tar.gz' => "$rpm_build_dir/SOURCES";
    download 'https://raw.githubusercontent.com/hansode/ruby-2.0.0-rpm/e7c0d0b1c067fdf7dfdddc6970fc2748c3534c97/ruby200.spec' => "$rpm_build_dir/SPECS";
    run "rpmbuild -bb $rpm_build_dir/SPECS/ruby200.spec", 
        auto_die => 0, 
        unless => "test -e $rpm_build_dir/RPMS/x86_64/ruby-2.0.0p353-2.x86_64.rpm";
    run "rpm -Uvh $rpm_build_dir/RPMS/x86_64/ruby-2.0.0p353-2.x86_64.rpm",
        auto_die => 0,
        unless => "which ruby && ruby -v | grep 2.0.0p353" ;
    run 'gem install bundler';
};

desc 'Instala Phusion Passenger';
task 'InstalarPassenger', sub {
    InstalarRuby();
    pkg 'gcc-c++', ensure => 'present';
    run 'gem install passenger -v 4.0.45';
};

desc 'Instala el modulo de apache para passenger';
task 'InstalarModPassenger', sub {
    pkg [qw(gcc-c++ curl-devel openssl-devel zlib-devel httpd-devel apr-devel apr-util-devel)], ensure => 'present';
    run 'echo -e "\n\n\n" | passenger-install-apache2-module', unless => 'test -e /usr/lib64/ruby/gems/2.0.0/gems/passenger-4.0.45/buildout/apache2/mod_passenger.so';
    file '/etc/httpd/conf.d/passenger.conf', source => 'archivos/passenger.conf';
};

desc 'Instala y prepara la base de datos para la web';
task 'ConfigurarBDWeb', sub {
    pkg [qw(mysql mysql-server)], ensure => 'present';
    service 'mysqld', ensure => 'started';
    run "mysqladmin -u root password 'root'", auto_die => 0;
    run q{mysql -u root --password=root <<< "}
        . q{CREATE USER 'multiser_tienda'@'localhost' IDENTIFIED BY 'password';}
        . q{GRANT ALL PRIVILEGES ON multiser_tienda.* TO 'multiser_tienda'@'localhost';}
        . q{GRANT ALL PRIVILEGES ON multiser_tienda_dev.* TO 'multiser_tienda'@'localhost';}
        . q{GRANT ALL PRIVILEGES ON multiser_tienda_test.* TO 'multiser_tienda'@'localhost';}
        . q{FLUSH PRIVILEGES;"}, auto_die => 0;
    
};

desc 'Configurar el servidor web apache';
task 'ConfigurarServidorWeb', sub {
    pkg 'httpd', ensure => 'present';
    InstalarPassenger();
    InstalarModPassenger();
    service 'httpd', ensure => 'started';
};
