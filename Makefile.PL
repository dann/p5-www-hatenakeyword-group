use inc::Module::Install;
name 'WWW-HatenaKeyword-Group';
all_from 'lib/WWW/HatenaKeyword/Group.pm';

requires $_
    for (
    qw/
    JSON::Syck
    Moose
    MooseX::Method
    WWW::HatenaLogin
    Web::Scraper
    /
    );

build_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;
