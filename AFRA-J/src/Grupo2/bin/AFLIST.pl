#!/usr/bin/perl

#TODO: llevar esto a otro .pl
sub contains{
	$value=pop(@_);
	if( grep{ $_ eq $value} @_ ){
		return 1;
	}else{
		return 0;	
	}
}

sub isInitialized{
	
	return 1;
}

sub isAlreadyRunning{
	$counter = `ps -a | grep -c 'AFLIST'`;
	
	if($counter > 3){
		return 1;
	}else{
		return 0;
	}

}

sub showHelp{
	print("ayuda");
}

sub showRegisterFiltersMenu{
	print("\n---------------------FILTROS DE BUSQUEDA---------------------\n\n");
	print("1. Filtrar por central (una, varias, todas)\n");
	print("2. Filtrar por agente (uno, varios, todos)\n");
	print("3. Filtrar por umbral (uno, varios, todos)\n");
	print("4. Filtrar por tipo de llamada (una, varias, todas)\n");
	print("5. Filtrar por tiempo de conversacion (rango)\n");
	print("6. Filtrar por numero (area y numero de linea) (uno, varios, todos)\n");
	print("7. No ingresar mas filtros");
	print("\n\nIngrese un filtro: ");
}

sub filterRegistersByCentrals{
	system("clear");
	print("Ingrese los identificadores de las centrales separados por una coma (\",\")");
	$input = <STDIN>;
	chomp($input);
	@centrals = split /,/, $input;
	print("centrales ingresadas: @centrals\n");
	$input = <STDIN>;
	return \@centrals;
}

sub filterRegistersByAgents{
	system("clear");
	print("filterRegistersByAgents");
	$input = <STDIN>;
}

sub filterRegistersByUmbral{
	system("clear");
	print("filterRegistersByUmbral");
	$input = <STDIN>;
}

sub filterRegistersByType{
	system("clear");
	print("filterRegistersByType");
	$input = <STDIN>;
}

sub filterRegistersByTime{
	system("clear");
	print("filterRegistersByTime");
	$input = <STDIN>;
}

sub filterRegistersByNumber{
	system("clear");
	print("filterRegistersByNumber");
	$input = <STDIN>;
}



sub loadRegisterFilters{

	my %registerFiltersHash;

	# my @emptyLisy = ();

	# $registerFiltersHash{"centrals"} = \@emptyLisy;
	# $registerFiltersHash{"agents"} = \@emptyLisy;
	# $registerFiltersHash{"unmbrals"} = \@emptyLisy;
	# $registerFiltersHash{"types"} = \@emptyLisy;
	# $registerFiltersHash{"times"} = \@emptyLisy;
	# $registerFiltersHash{"numbers"} =  \@emptyLisy;


	$filter = '0';
	while($filter != '7'){
		system("clear");
		showRegisterFiltersMenu();
		$filter = <STDIN>;
		chomp($filter);
		if ($filter == 1) {
			$registerFiltersHash{"centrals"} = filterRegistersByCentrals();
		}
		if ($filter == 2) {
			$registerFiltersHash{"agents"} = filterRegistersByAgents();
		}
		if ($filter == 3) {
			$registerFiltersHash{"unmbrals"} = filterRegistersByUmbral();
		}
		if ($filter == 4) {
			$registerFiltersHash{"types"} = filterRegistersByType();
		}
		if ($filter == 5) {
			$registerFiltersHash{"times"} = filterRegistersByTime();
		}
		if ($filter == 6) {
			$registerFiltersHash{"numbers"} = filterRegistersByNumber();
		}
	}
	@centrals = @{$registerFiltersHash{"centrals"}};
	print("hash{centrals} = @centrals\n");
	return %registerFiltersHash;
}

sub loadInputFiles{
	%h = @_;
	$range = $h{"range"};
	@offices = @{$h{"offices"}};
	$numberOfOffices = @offices;
	#print("num = $numberOfOffices\n");
	#print("offices: @offices\n");
	#print("range: $range\n");
	@list;
	$dirname = "../PROCDIR";
	opendir ( DIR, $dirname );
	while( $filename = readdir(DIR)){
		if ($filename =~ /[^_]_[0-9]{6}/){
			@params = split /_/, $filename;
			@dates = split /-/, $range;
			if ($params[1] >= $dates[0] and $params[1] <= $dates[1]){
				if (($numberOfOffices == 0) or (contains(@offices, $params[0]))) {
					push(@list, "../PROCDIR/$filename");
				}

				
			}
		}
	}
	closedir(DIR);
	$dirname = "../REPODIR";
	opendir ( DIR, $dirname );
	while( $filename = readdir(DIR)){
		if ($filename =~ /subllamadas\.[0-9]{3}/){
				push(@list, "../REPODIR/$filename");
		}
	}
	closedir(DIR);
	return @list;
}

sub isRange{
	return (@_[0] =~ /[0-9]{4}[0-9]{2}-[0-9]{4}[0-9]{2}/);
}

sub loadInputFilesFilters{
	system("clear");
	print("Debe ingresar un rango de fechas para los archivos de entrada\n\tcon el formato AAAAMM-AAAAMM.\n");
	print("\tPor ejemplo: \"201501-201512\" representa todo el 2015\n");
	$range = "";
	while(not isRange($range)){
		print("Escriba aqui un rango valido: ");
		$range = <STDIN>;
		chomp($range);
	}
	%hash;
	$hash{"range"} = $range;

	print("\n\nDebe ingresar una lista de oficinas para filrar los archivos de entrada\n\tseparados por \",\".\n");
	print("\tPor ejemplo: \"DE1,NOP\"\n");
	print("\tEscriba aqui la lista de oficinas: ");	
	$line = <STDIN>;
	chomp($line);
	@offices = split /,/, $line;


	%hash;
	$hash{"range"} = $range;
	$hash{"offices"} = \@offices;
 	
 	#$offices2 = $hash{"offices"};
 	#print("offices2: $offices2->[0]\n");

	#print "@{[%hash]}";

	return %hash;
}

sub main{
	if ( not(isInitialized) ) {
		print("No esta realizada la inicializacion de ambiente\n");
		return 1;
	}
	if ( isAlreadyRunning ) {
		print("Ya hay un AFLIST corriendo\n");
		return 1;
	}
	if (contains(@ARGV, "-h")) {
		showHelp();
		return 0;
	}
	if (contains(@ARGV, "-r")) {
		%fileFiltersHash = loadInputFilesFilters();
		@inputFiles = loadInputFiles(%fileFiltersHash);
		#print("inputs: @inputFiles\n");
		#$inputWaiter = <STDIN>;
		%registerFiltersHash = loadRegisterFilters();
		printRegisterFilters(%registerFiltersHash);
		processFiles(\@inputFiles, \%registerFiltersHash);
	}
}

sub printRegisterFilters{
	%registerFiltersHash = @_;
	@centrals = @{$registerFiltersHash{"centrals"}};
	print("in main, hash{centrals} = @centrals\n");

	$input = <STDIN>;
}

sub processFiles{
	my ($inputFilesRef, $registerFiltersHashRef) = @_;
	my @files = @$inputFilesRef;
	my %filters = %$registerFiltersHashRef;
	#print("inputFiles = @files\n");
	my @centrals = @{$filters{"centrals"}};
	my $centralSize= scalar @centrals;
	#print("centrals @centrals\n");
	#print "central size: $centralSize";

	my $fileHdl;
	foreach my $file (@files){
		open ($fileHdl,"<", $file) or die "no se puede abrir $file: $!";
		while (my $linea=<$fileHdl>) {
			@tokens = split /;/, $linea;
			if (not (  contains(@centrals, $tokens[0]) or $centralSize==0)){
				next;
			}

			print $linea;
		}
		close ($fileHdl);
	}
}


main();
