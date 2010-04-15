package Dancer::Test;
# test helpers for Dancer apps

use strict;
use warnings;
use Test::More import => ['!pass'];

use Dancer ':syntax';
use Dancer::Request;
use Dancer::SharedData;
use Dancer::Renderer;

use base 'Exporter';
use vars '@EXPORT';

@EXPORT = qw(
    route_exists
    route_doesnt_exist

    response_exists
    response_doesnt_exist
    response_status_is
    response_status_isnt
    response_content_is
    response_content_isnt
    response_content_is_deeply
    response_content_like
    response_content_unlike
);

sub import {
    my ($class, %options) = @_;
    my ($package, $script) = caller;
    $class->export_to_level(1, $class, @EXPORT );

    $options{appdir} ||= '..';
    Dancer::_init($options{appdir});
}

# Route Registry

sub route_exists {
    my ($req, $test_name) = @_;

    my ($method, $path) = @$req;
    $test_name ||= "a route exists for $method $path";
    
    $req = Dancer::Request->new_for_request($method => $path);
    ok(Dancer::Route->find($path, $method, $req), $test_name);
}

sub route_doesnt_exist {
    my ($req, $test_name) = @_;

    my ($method, $path) = @$req;
    $test_name ||= "no route exists for $method $path";

    $req = Dancer::Request->new_for_request($method => $path);
    ok((!defined(Dancer::Route->find($path, $method, $req))), $test_name);
}

# Response status

sub response_exists {
    my ($req, $test_name) = @_;
    $test_name ||= "a response is found for @$req";

    my $response = _get_response($req);
    ok(defined($response), $test_name);
}

sub response_doesnt_exist {
    my ($req, $test_name) = @_;
    $test_name ||= "no response found for @$req";

    my $response = _get_response($req);
    ok(!defined($response), $test_name);
}

sub response_status_is {
    my ($req, $status, $test_name) = @_;
    $test_name ||= "response status is $status for @$req";

    my $response = _get_response($req); 
    is $response->{status}, $status, $test_name;
}

sub response_status_isnt {
    my ($req, $status, $test_name) = @_;
    $test_name ||= "response status is not $status for @$req";

    my $response = _get_response($req); 
    isnt $response->{status}, $status, $test_name;
}

# Response content

sub response_content_is {
    my ($req, $matcher, $test_name) = @_;
    $test_name ||= "response content looks good for @$req";

    my $response = _get_response($req); 
    is $response->{content}, $matcher, $test_name;
}

sub response_content_isnt {
    my ($req, $matcher, $test_name) = @_;
    $test_name ||= "response content looks good for @$req";

    my $response = _get_response($req); 
    isnt $response->{content}, $matcher, $test_name;
}

sub response_content_like {
    my ($req, $matcher, $test_name) = @_;
    $test_name ||= "response content looks good for @$req";

    my $response = _get_response($req); 
    like $response->{content}, $matcher, $test_name;
}

sub response_content_unlike {
    my ($req, $matcher, $test_name) = @_;
    $test_name ||= "response content looks good for @$req";

    my $response = _get_response($req); 
    unlike $response->{content}, $matcher, $test_name;
}

sub response_content_is_deeply {
    my ($req, $matcher, $test_name) = @_;
    $test_name ||= "response content looks good for @$req";

    my $response = _get_response($req); 
    is_deeply $response->{content}, $matcher, $test_name;
}

sub _get_response {
    my ($req) = @_;
    my ($method, $path, $params) = @$req;
    my $request = Dancer::Request->new_for_request($method => $path, $params);
    Dancer::SharedData->request($request);
    return Dancer::Renderer::get_action_response();
}

1;
__END__
=pod

=head1 NAME

Dancer::Test - Test helpers to test a Dancer application

=head1 SYNOPSYS

    use strict;
    use warnings;
    use Test::More tests => 2;

    use MyWebApp;
    use Dancer::Test appdir => '..';

    response_status_is [GET => '/'], 200, "GET / is found";
    response_content_like [GET => '/'], qr/hello, world/, "content looks good for /";


=head1 DESCRIPTION

This module provides test heplers for testing Dancer apps.

=head1 CONFIGURATON

When importing Dancer::Test, the appdir is set by defaut to '..', assuming that
your test scrtipt is directly in your t/ directory. If you put your test scrtipt
deeper in the 't/' hierarchy (like in 't/routes/01_some_test.t') you'll have to
tell Dancer::Test that the appdir is one step upper.

To do so, you can tell where the appdir is thanks to an import option:

    use MyWebApp;
    use Dancer::Test appdir => '../..';

Be careful, the order in the example above is very important.
Make sure to use C<Dancer::Test> B<after> importing the application package
otherwise your appdir will be automatically set to C<lib> and your test script
won't be able to find views, conffiles and other application content.

=head1 METHODS

=head2 route_exists([$method, $path], $test_name)

Asserts that the given request matches a route handler in Dancer's
registry.

    route_exists [GET => '/'], "GET / is handled";

=head2 route_doesnt_exist([$method, $path], $test_name)

Asserts that the given request does not match any route handler 
in Dancer's registry.

    route_doesnt_exist [GET => '/bogus_path'], "GET /bogus_path is not handled";


=head2 response_exists([$method, $path], $test_name)

Asserts that a response is found for the given request (note that even though 
a route for that path might not exist, a response can be found during request
processing, because of filters).

    response_exists [GET => '/path_that_gets_redirected_to_home'],
        "response found for unknown path";

=head2 response_doesnt_exist([$method, $path], $test_name)

Asserts that no response is found when processing the given request.

    response_doesnt_exist [GET => '/unknown_path'],
        "response not found for unknown path";

=head2 response_status_is([$method, $path], $status, $test_name)

Asserts that Dancer's response for the given request has a status equal to the
one given.

    response_status_is [GET => '/'], 200, "response for GET / is 200";

=head2 response_status_isnt([$method, $path], $status, $test_name)

Asserts that the status of Dancer's response is not equal to the
one given.

    response_status_isnt [GET => '/'], 404, "response for GET / is not a 404";

=head2 response_content_is([$method, $path], $expected, $test_name)

Asserts that the response content is equal to the C<$expected> string.

    response_content_is [GET => '/'], "Hello, World", 
        "got expected response content for GET /";

=head2 response_content_isnt([$method, $path], $not_expected, $test_name)

Asserts that the response content is not equal to the C<$not_expected> string.

    response_content_is [GET => '/'], "Hello, World", 
        "got expected response content for GET /";

=head2 response_content_is_deeply([$method, $path], $expected_struct, $test_name)

Similar to response_content_is(), except that if response content and 
$expected_struct are references, it does a deep comparison walking each data 
structure to see if they are equivalent.  

If the two structures are different, it will display the place where they start
differing.

    response_content_is_deeply [GET => '/complex_struct'], 
        { foo => 42, bar => 24}, 
        "got expected response structure for GET /complex_struct";

=head2 response_content_like([$method, $path], $regexp, $test_name)

Asserts that the response content for the given request matches the regexp
given.

    response_content_like [GET => '/'], qr/Hello, World/, 
        "response content looks good for GET /";

=head2 response_content_unlike([$method, $path], $regexp, $test_name)

Asserts that the response content for the given request does not match the regexp
given.

    response_content_unlike [GET => '/'], qr/Page not found/, 
        "response content looks good for GET /";


=head1 LICENSE

This module is free software and is distributed under the same terms as Perl
itself.

=head1 AUTHOR

This module has been written by Alexis Sukrieh <sukria@sukria.net>

=head1 SEE ALSO

L<Test::More>

=cut