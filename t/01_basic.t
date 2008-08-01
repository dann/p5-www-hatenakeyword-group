use strict;
use warnings;
use Test::More;
use WWW::HatenaKeyword::Group;

my $username = $ENV{WWW_HATENADIARY_TEST_USERNAME};
my $password = $ENV{WWW_HATENADIARY_TEST_PASSWORD};
my $group    = $ENV{WWW_HATENADIARY_TEST_GROUP};

if ( $username && $password && $group ) {
    plan tests => 2;
}
else {
    plan skip_all => "Set ENV:WWW_HATENADIARY_TEST_USERNAME/PASSWORD/GROUP";
}

my $api = WWW::HatenaKeyword::Group->new(
    username => $username,
    password => $password,
    group    => $group,
);

my $keyword_name = 'Keyword name';
my $keyword_body = 'Moooooooooooooose';
$api->create( keyword => $keyword_name, body => $keyword_body );
my $keyword = $api->retrieve( keyword => $keyword_name );
is( $keyword->{body}, $keyword_body, 'Creates a new keyword' );

$api->delete( keyword => $keyword_name );
$keyword = $api->retrieve( keyword => $keyword_name );
ok( !$keyword->{body}, 'Delete a keyword' );

