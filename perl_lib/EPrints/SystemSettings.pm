=head1 NAME

EPrints::SystemSettings

=cut

######################################################################
#
# These are your system settings (as autogenerated by the installer).
# We suggest that you do not alter these, as future installers will
# probably override them.
# 
######################################################################

# This file should only be use'd by EPrints::Config
package EPrints::SystemSettings;

$EPrints::SystemSettings::conf = {
                                   'version' => 'EPrints 3.4.3',
                                   'version_id' => 'eprints-3.4.3',
                                   'base_path' => '/opt/eprints3',
                                   'show_ids_in_log' => 0,
                                   'group' => 'eprints',
                                   'version_history' => [
                                                          'eprints-3.2.3',
                                                          'eprints-3.3.6',
                                                          'eprints-3.3.9',
                                                          'eprints-3.3.10',
                                                          'eprints-3.3.12',
                                                          'eprints-3.3.13',
                                                          'eprints-3.3.14',
                                                          'eprints-3.3.15',
							  'eprints-3.4.0',
							  'eprints-3.4.1',
							  'eprints-3.4.2',
                                                        ],
                                   'smtp_server' => '127.0.0.1', # sensible default, but may not be valid
                                   'user' => 'eprints',
                                   'file_perms' => '0664',
                                   'invocation' => {},
                                   'executables' => {
                                                      'perl' => '/usr/bin/perl'
                                                    },
                                   'dir_perms' => '02775',
                                   'flavours' => {
                                                   'zero' => [##site_lib has been removed from the flavour path and now a special lib that can overwrite core modules.
                                                       'ingredients/bazaar_stub', ## this is loaded here to prevent warning for EPMC.pm module when other repos install bazaar in the /lib dir
                                                    ]
                                                },
                                   'perl_module_isolation' => 0, #after changing this setting, you need to bin/generate_apacheconf --system --replace, then restart apache
 
                              
                                };

## load the flavour inc files into the system settings' 'flavour' key.
my $flavour_dir = $conf->{base_path}."/flavours";
opendir(LIB, $flavour_dir);
my @flavours = grep { $_ ne '.' && $_ ne '..' && $_ !~ m/^\./ } readdir LIB;
closedir(LIB);
foreach my $flavour (@flavours){
    next unless -d "$flavour_dir/$flavour/";
    my $fname = substr($flavour,0,rindex($flavour,"_")); ##flavour name is the parts before the file name, e.g. pub_lib, pub is the flavour name. Flavour name is used by epadmin: e.g. epadmin create pub

    my $incpath = "$flavour_dir/$flavour/inc";
    my @paths = read_inc($incpath);

    if (!exists $conf->{flavours}->{$fname}) ##safty check.
    {
        $conf->{flavours}->{$fname}=\@paths;
    }
}


sub read_inc
{
    my ($file) = @_;

    my @entries;
    open(IN, $file);
    while(<IN>)
    {
        s/^[ \t]+//; # strip leading ws
        next if /^#/; # skip comment lines
        s/#.*//; # trim trailing comments
        s/[ \t\r\n]+$//; # trim trailing ws
        next if /^$/; # skip empty

		#for each path in the inc file:
        foreach my $e ( split( /;/ ) )
        {
            $e =~ s|i:|ingredients/|g;
            $e =~ s|f:|flavours/|g;

            if( $e =~ /(.*)\*/ ) # expand wildcards
            {
                opendir(DIR,$conf->{base_path}."/".$1);
                while (my $item = readdir DIR)
                {
                    next if $item =~ /^\./;
                    push @entries, $1.$item ;
                }
                closedir(DIR);
            }
            else
            {
                push @entries, $e;
            }
        }
    }
	close(IN);
    my %l; # remove duplicates
    @entries = grep { $_ ne '-' } map { $_ = '-' if $l{$_}; $l{$_} = 1; $_ } @entries;

    return @entries;
}




1;



=head1 COPYRIGHT

=for COPYRIGHT BEGIN

Copyright 2021 University of Southampton.
EPrints 3.4 is supplied by EPrints Services.

http://www.eprints.org/eprints-3.4/

=for COPYRIGHT END

=for LICENSE BEGIN

This file is part of EPrints 3.4 L<http://www.eprints.org/>.

EPrints 3.4 and this file are released under the terms of the
GNU Lesser General Public License version 3 as published by
the Free Software Foundation unless otherwise stated.

EPrints 3.4 is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with EPrints 3.4.
If not, see L<http://www.gnu.org/licenses/>.

=for LICENSE END
