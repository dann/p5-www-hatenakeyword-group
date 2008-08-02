use strict;
use warnings;
use Test::More;
use WWW::HatenaKeyword::Group;
use utf8;
use Encode;

my $username = $ENV{WWW_HATENADIARY_TEST_USERNAME};
my $password = $ENV{WWW_HATENADIARY_TEST_PASSWORD};
my $group    = $ENV{WWW_HATENADIARY_TEST_GROUP};

if ( $username && $password && $group ) {
    plan tests => 3;
}
else {
    plan skip_all => "Set ENV:WWW_HATENADIARY_TEST_USERNAME/PASSWORD/GROUP";
}

my $api = WWW::HatenaKeyword::Group->new(
    username => $username,
    password => $password,
    group    => $group,
);

my $keyword_name = '日本語テストキーワード';
my $keyword_body = 'ムース';

{
    $api->create( keyword => $keyword_name, body => $keyword_body );
    my $keyword = $api->retrieve( keyword => $keyword_name );
    is( Encode::decode_utf8( $keyword->{body} ),
        $keyword_body, 'Creates a new keyword' );
}

TODO: {
    local $TODO = "bug ...";
    $keyword_body = 'アップデート';
    $api->update( keyword => $keyword_name, body => $keyword_body );
    my $keyword = $api->retrieve( keyword => $keyword_name );
    is( Encode::decode_utf8( $keyword->{body} ),
        $keyword_body, 'updated a new keyword' );
}

{
    $api->delete( keyword => $keyword_name );
    my $keyword = $api->retrieve( keyword => $keyword_name );
    ok( !$keyword->{body}, 'Delete a keyword' );
}
