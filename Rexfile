use Rex -feature => ['exec_autodie'];

my $RUBY_VERSION => '1.8.7.299';

desc 'Configura el sistema entero para dar el servicio web';
task 'ConfigurarMaquina', sub {
    ConfigurarServidorWeb();
    ConfigurarBDWeb();
    ConfigurarAplicacionWeb();
};

desc 'Configura la aplicacion web';
task 'ConfigurarAplicacionWeb', sub {
    pkg 'mysql-devel', ensure => 'present';
    run 'bundle install', cwd => '/home/multiser/tienda';
    file '/etc/httpd/conf.d/web_oficina.conf', 'source' => 'archivos/web_oficina.conf';
    file '/home/multiser/ruby', ensure => 'directory';
    ln '/usr/lib64/ruby/gems/1.8/' => '/home/multiser/ruby/gems';
    service 'httpd' => 'restart';
};

desc 'Instala Ruby y sus dependencias para correr la aplicacion web';
task 'InstalarRuby', sub {
    file '/etc/yum.repos.d/ruby187.repo', 
        source => 'archivos/ruby187.repo';
    pkg 'ruby', ensure => $RUBY_VERSION;
    pkg 'ruby-libs', ensure => $RUBY_VERSION;
    pkg 'rubygems', ensure => 'present';
    if (`gem -v` !~ qr/^1.6.2$/) {
        run 'gem update --system';
        run 'gem update --system 1.6.2';
    }
    run 'gem install bundler -v 1.2.1';
};

desc 'Instala Phusion Passenger';
task 'InstalarPassenger', sub {
    InstalarRuby();
    pkg 'ruby-devel', ensure => $RUBY_VERSION;
    run 'gem install passenger -v 3.0.9';
};

desc 'Instala el modulo de apache para passenger';
task 'InstalarModPassenger', sub {
    pkg [qw(gcc-c++ curl-devel openssl-devel zlib-devel httpd-devel apr-devel apr-util-devel)], ensure => 'present';
    run 'echo -e "\n\n\n" | passenger-install-apache2-module', unless => 'ls /usr/lib64/ruby/gems/1.8/gems/passenger-3.0.9/ext/apache2/mod_passenger.so';
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
        . q{FLUSH PRIVILEGES;"}, auto_die => 0;
    
};

desc 'Configurar el servidor web apache';
task 'ConfigurarServidorWeb', sub {
    pkg 'httpd', ensure => 'latest';
    InstalarPassenger();
    InstalarModPassenger();
    service 'httpd', ensure => 'started';
};
