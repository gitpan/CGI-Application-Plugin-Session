package TestAppSessionCookie;

use strict;

use CGI::Application;
use CGI::Application::Plugin::Session;
@TestAppSessionCookie::ISA = qw(CGI::Application);

sub cgiapp_init {
  my $self = shift;

  $self->session_config({
                        CGI_SESSION_OPTIONS => [ "driver:File", $self->query, {Directory=>'t/'} ],
                        SEND_COOKIE         => 1,
                        DEFAULT_EXPIRY      => '+1h',
                        COOKIE_PARAMS       => {
                                                 -name    => CGI::Session->name,
                                                 -value   => '1111',
                                                 -path    => '/testpath',
                                                 -domain  => 'mydomain.com',
                                                 -expires => '',
                                               },
  });
}

sub setup {
    my $self = shift;

    $self->start_mode('test_mode');

    $self->run_modes(test_mode => 'test_mode' );
}

sub test_mode {
        my $self = shift;
  my $output = '';

  my $session = $self->session;

  $output .= $session->is_new ? "session created\n" : "session found\n";
  $output .= "id=".$session->id."\n";

  return $output;
}


1;