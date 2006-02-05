use Test::More tests => 10;
use File::Spec;
BEGIN { use_ok('CGI::Application::Plugin::Session') };

use lib './t';
use strict;

$ENV{CGI_APP_RETURN_ONLY} = 1;

use CGI;
use TestAppSessionDelete;
my $t1_obj = TestAppSessionDelete->new(QUERY=>CGI->new());
my $t1_output = $t1_obj->run();

like($t1_output, qr/session created/, 'session created');
like($t1_output, qr/Set-Cookie: CGISESSID=[a-zA-Z0-9]+/, 'session cookie set');

my ($id1) = $t1_output =~ /id=([a-zA-Z0-9]+)/s;
ok($id1, 'found session id');

my ( $original_expiry ) = $t1_output =~ /expires=(.+)\s+Date/;

# Test Plan ... create a session ... not going to test that, b/c there are
# other tests for that.  What we're going to do is now create a new CGI query
# object and call the 'logout' runmode, which will call the new session_delete
# method, which should remove the flat file as well as send a cookie header
# with an expire timestamp in the past.

# need to inject session into $query - this is done by an environment var
$ENV{HTTP_COOKIE} = "CGISESSID=$id1";
my $query = new CGI;
$query->param( -name => 'rm', -value => 'logout' );
$t1_obj = TestAppSessionDelete->new( QUERY => $query );
$t1_output = $t1_obj->run();

# vanilla output came through ok?
ok( $t1_output =~ /logout finished/, 'vanilla output came through ok' );
# If that didn't pass, then I'm guessing the session wasn't injected properly

# Was a cookie in the output?
like($t1_output, qr/Set-Cookie: CGISESSID=[a-zA-Z0-9]+/, 'cookie in output');

my ( $new_expiry ) = $t1_output =~ /expires=(.+)\s+Date/;

ok( $original_expiry ne $new_expiry, 'expirations are different' );

# Need to figure out if $new_expiry < $original_expiry and $new_expiry < NOW()
SKIP: {
    eval { require Date::Parse; };
    skip "Date::Parse not installed", 2 if $@;
    Date::Parse->import();
    my $expired_time = str2time( $new_expiry );
    my $original_time = str2time( $original_expiry );
    ok( $expired_time < $original_time, 'The new expiry is older than the original expiry' );
    my $current_time = time();
    # Since the cookie is recreated with a time of minus one day, we shouldn't
    # have to worry about timezones
    ok( $expired_time < $current_time, 'The new expiry is older than now' );
}

# Session object will not disappear and be written
# to disk until it is DESTROYed
undef $t1_obj;
# Is the file gone?
ok( !-e 't/cgisess_'.$id1, 'session_delete wiped the flat file ok' );

