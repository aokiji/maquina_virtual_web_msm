use Rex;

desc 'Configura el sistema entero para dar el servicio web';
task 'ConfigurarMaquina', sub {
    InstalarRuby();
    ConfigurarServidorWeb();
};

desc 'Instala Ruby y sus dependencias para correr la aplicacion web';
task 'InstalarRuby', sub {
    file '/etc/yum.repos.d/ruby187.repo', 
        source => 'archivos/ruby187.repo';
    pkg 'ruby', ensure => '1.8.7';
    pkg 'rubygems', ensure => 'present';
    if (`gem -v` !~ qr/^1.6.2$/) {
        run 'gem update --system';
        run 'gem update --system 1.6.2';
    } 
};

desc 'Configurar el servidor web apache';
task 'ConfigurarServidorWeb', sub {
    pkg 'httpd', ensure => 'latest';
    service 'httpd', ensure => 'started';
};
