package ELAG;
use Catmandu -all;
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

 	eval {
		$result->{output} =  to_yaml fix_one($in,$fix);
	};

	if ($@) {
		$result->{error} = $@;
		$result->{error} =~ s/Trace begun.*//sm;
	}
	
	template 'fix' , $result;
};

get '/marc' => sub {
	my $skip   = params->{skip} // 0;
	my $record = store->search(start => $skip)->first;
	$record->{id} = $record->{_id};
	template 'marc', { record => $record };
};

post '/marc' => sub {
	my $skip   = params->{skip} // 0;
	my $record = store->search(start => $skip)->first;
	my $fix    = params->{fix} // '';
	
	$record->{id} = $record->{_id};

	my $result = {
		record => $record ,
		fix    => $fix
	};

	eval {
		$result->{output} =  to_yaml fix_record($record,$fix);
	};

	if ($@) {
		$result->{error} = $@;
		$result->{error} =~ s/Trace begun.*//sm;
	}

	template 'marc' , $result;
};

sub store {
    Catmandu->store('MongoDB')->bag;
}

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

sub fix_record {
	my $record = shift;
	my $fixer  = fixer shift;

	$fixer->fix($record);
}

true;
