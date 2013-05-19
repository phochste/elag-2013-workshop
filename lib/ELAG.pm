package ELAG;
use Catmandu::Importer::YAML;
use Catmandu::Fix;
use File::Temp qw(tempfile);
use Dancer ':syntax';
use HTML::FillInForm;

our $VERSION = '0.1';

get '/' => sub {
    template 'fix';
};

post '/fix' => sub {
	my $fix      = params->{fix} // '';
 	my $in       = params->{input} // '';

 	my $result   = { 
 		input => $in , 
 		fix => $fix 
 	};

	$result->{output} =  to_yaml fix_one($in,$fix);
	
	template 'fix' , $result;
};

sub fixer {
	my $fix = shift // '';
    my ($fh, $filename) = tempfile();
    print $fh $fix;
    close $fh;

    Catmandu::Fix->new(fixes => [$filename]);
}

sub fix_one {
	my $str      = shift;
	my $fixer    = fixer shift;
    my $fh;

	open($fh, "+<", \$str);

	my $it = Catmandu::Importer::YAML->new(file => $fh);

	my $ret = $fixer->fix($it)->first;

	close($fh);

	$ret;
}

true;
