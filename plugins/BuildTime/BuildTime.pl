package MT::Plugin::BuildTime;
use strict;
use MT;
use MT::Plugin;
use base qw( MT::Plugin );

use Time::HiRes qw( gettimeofday );

my $plugin = MT::Plugin::BuildTime->new( {
    name => 'BuildTime',
    key => 'buildtime',
    id => 'BuildTime',
    version => '1.00',
    author_name => 'okayama',
    author_link => 'http://weeeblog.net/',
    doc_link => 'http://weeeblog.net/blogs/2008/05/24_1928.php',
    description => '<MT_TRANS phrase=\'_PLUGIN_DESCRIPTION\'>',
    l10n_class => 'BuildTime::L10N',
} );

MT->add_plugin( $plugin );

sub init_registry {
    my $plugin = shift;
    $plugin->registry( {
        callbacks => {
            'MT::App::CMS::init_app'
                => \&_init_app,
            'MT::App::CMS::take_down'
                => \&_take_down,
        },
   } );
}

sub _init_app {
    my ( $cb, $app ) = @_;
    return if $app->mode eq 'filtered_list';
    my ( $epoch, $micro_seconds ) = gettimeofday;
    my $from = {};
    $from = { epoch => $epoch,
              micro_seconds => $micro_seconds,
            };
    $plugin->set_config_value('from', $from);
}

sub _take_down {
    my ( $cb, $app ) = @_;
    return if $app->mode eq 'filtered_list';
    my ( $epoch, $micro_seconds ) = gettimeofday;
    my $to = {};
    $to = { epoch => $epoch,
            micro_seconds => $micro_seconds,
          };
    my $from = $plugin->get_config_value( 'from' );
    my ( $min, $micro );
    $min = $to->{ epoch } - $from->{ epoch };
    $micro = $to->{ micro_seconds } - $from->{ micro_seconds };
    if ( $micro < 0 ) {
        $min--;
        $micro += 1000000;
    }
    $app->print( sprintf( "%d.%06d", $min ,$micro ) );
}

1;