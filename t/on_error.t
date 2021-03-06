use strict;
use warnings;
use Test::More;

if($^V >= v5.14)
{
  plan tests => 2;
}
else
{
  plan skip_all => 'test requires perl 5.14 or better';
}

use v5.10;
use AnyEvent;
use AnyEvent::Open3::Simple;
use File::Temp qw( tempdir );
use File::Spec;

my $dir = tempdir( CLEANUP => 1 );

my $done = AnyEvent->condvar;

my $called_on_error = 0;
my $message = '';

my $ipc = AnyEvent::Open3::Simple->new(
  on_error => sub {
    $message = shift;
    $called_on_error = 1;
    $done->send;
  },
  on_exit => sub {
    $done->send;
  },
);

$ipc->run(File::Spec->catfile($dir, 'bogus.pl'));

$done->recv;

is $called_on_error, 1, 'called on_error';
chomp $message;
like $message, qr/^open3: /, "message = $message";
