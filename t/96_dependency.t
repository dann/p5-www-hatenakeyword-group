use Test::Dependencies
	exclude => [qw/Test::Dependencies Test::Base Test::Perl::Critic WWW::HatenaKeyword/],
	style   => 'light';
ok_dependencies();
