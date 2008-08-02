package WWW::HatenaKeyword::Group;
use MooseX::Method;
use Moose;
use WWW::HatenaLogin;
use Web::Scraper;
use DateTime;
use DateTime::TimeZone;
use DateTime::Format::Strptime;
use URI::Escape;
use JSON::Syck 'Load';

our $VERSION = '0.01';

has 'username' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has 'password' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has 'group' => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
);

has 'keywordlist_url' => (
    is  => 'rw',
    isa => 'Str',
);

has 'keyword' => (
    is  => 'rw',
    isa => 'Str',
);

has 'base' => (
    is  => 'rw',
    isa => 'Str',
);

has 'mech_opt' => (
    is  => 'ro',
    isa => 'HashRef',
);

has 'rkm' => (
    is  => 'rw',
    isa => 'Str',
);

has 'session' => ( is => 'rw', );

no Moose;

sub BUILD {
    my $self = shift;
    my $base = "http://" . $self->group . ".g.hatena.ne.jp/";
    $self->base($base);

    my $keywordlist_url = $self->base . "keywordlist";
    $self->keywordlist_url($keywordlist_url);

    $self->session(
        WWW::HatenaLogin->new(
            {   nologin  => 1,
                username => $self->username,
                password => $self->password,
                mech_opt => $self->mech_opt,
            }
        )
    );

    unless ( $self->session->is_loggedin ) {
        $self->login;
    }

    $self->rkm($self->get_rkm);
}

method update => named(
    keyword => { isa => 'Str', required => 1 },
    body    => { isa => 'Str', required => 1 },
) => sub {
    my ( $self, $args ) = @_;
    my $uri = $self->base . "keyword";
    $self->session->mech->post(
        $uri,
        {   rkm        => $self->rkm,
            word       => $args->{keyword},
            body       => $args->{body},
            edit       => 'edit',
            mode       => 'enter',
            timestamp  => $self->current_timestamp,
            olddelflag => 0,
        }
    );

};

method current_timestamp => named(
) => sub {
    my ( $self, $args ) = @_;

    my $tzhere = DateTime::TimeZone->new( name => 'local' );
    my $dt = DateTime->now(time_zone => $tzhere);
    my $format = DateTime::Format::Strptime->new(
         pattern => '%Y%m%d%H%M%S',
         on_error => 'undef',
    );  
    my $current_timestamp = $format->format_datetime($dt);
    return $current_timestamp;
};

method list_keywords => named( 
) => sub {
    my ($self) = @_;

    my $mech = $self->session->mech;
    $mech->get( $self->keywordlist_url );

    my $scraper = scraper {
        process '//div[@class="refererlist"]/ul/li/a', 'keywords[]' => {
            name => 'TEXT',
            url  => '@href',
        };
    };
    my $result = $scraper->scrape( \$mech->content );
    return $result->{keywords};
};

method create => named(
    keyword => { isa => 'Str', required => 1 },
    body    => { isa => 'Str', },
) => sub {
    my ( $self, $args ) = @_;
    $self->_post_keyword(%$args);
};

method delete => named( 
    keyword => { isa => 'Str', required => 1 }, 
) => sub {
    my ( $self, $args ) = @_;
    my $uri = $self->base . "keyword";
    $self->session->mech->post($uri, {
        rkm => $self->rkm,
        word => $args->{keyword},
        mode => 'delete',
    });
};

method retrieve => named( 
    keyword => { isa => 'Str', required => 1 }, 
) => sub {
    my ( $self, $args ) = @_;

    my $mech = $self->session->mech;
    $mech->get(
        $self->keyword_url( keyword => $args->{keyword} ) . "?mode=edit" );
    
    my $scraper = scraper {
        process '//textarea', 'body' => 'TEXT';
    };
    my $result = $scraper->scrape( \$mech->content );

    {
        keyword => $args->{keyword},
        body => $result->{body},
    }
};

method keyword_url => named( 
    keyword => { isa => 'Str', required => 1 }, 
) => sub {
    my ( $self, $args ) = @_;

    my $url = $self->base . "keyword/" . uri_escape_utf8($args->{keyword});
    $url;
};

method get_rkm  => named(
) => sub {
    my $self = shift;
    my $rkm;

    $self->{diary} = $self->base . $self->session->username.'/';
    $self->session->mech->get( $self->{diary} . "?mode=json" );
    eval { $rkm = Load( $self->session->mech->content )->{rkm}; };

    $rkm;
};

method is_loggedin => named(
) => sub {
    my $self = shift;
    return $self->session->is_loggedin;
};

method login => named(
) => sub {
    my $self = shift;
    $self->session->login;
};

method logout => named(
) => sub {
    my $self = shift;
    $self->session->logout;
};

method _post_keyword => named( 
    keyword => { isa => 'Str', required => 1 }, 
    body    => { isa => 'Str', required => 1 },
) => sub {
    my ($self, $args) = @_;
    my $uri = $self->base . "keyword";
    $self->session->mech->post($uri, {
        rkm => $self->rkm,
        word => $args->{keyword},
        body => $args->{body},
        name => 'edit',
        mode => 'enter',
    });
};

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

WWW::HatenaKeyword::Group - CRUD interface for Hatena::Keyword on Hatena::Group 

=head1 SYNOPSIS

  use WWW::HatenaKeyword::Group;
  my $api = WWW::HatenaKeyword::Group->new({
      username => $username,
      password => $password,
      group    => $group,
      mech_opt => {
          timeout    => $timeout,
          cookie_jar => HTTP::Cookies->new(...),
      },
  });

=head1 DESCRIPTION

WWW::HatenaKeyword::Group provides CRUD interface for Hatena::Keyword on Hatena::Group

=head1 ACKNOWLEDGMENT

antipop++ for some codes copied from L<WWW::HatenaDiary>.

=head1 AUTHOR

Dann E<lt>techmemo@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
